require 'active_record'

module Wye
  module ActiveRecord
    # Implements an identical interface to the standard AR connection handler,
    # but with support for alternate connection pools for each spec.
    #
    class ConnectionHandler < ::ActiveRecord::ConnectionAdapters::ConnectionHandler
      attr_reader :connection_pools
      attr_reader :switch

      def initialize(*arguments)
        super
        @class_to_alternate_pools = {}
        @switch = Switch.new(::ActiveRecord::Base)
      end

      def alternates
        @class_to_alternate_pools.map { |(klass,atp)| atp.map(&:first) }.flatten.uniq
      end

      def distributor(type)
        Distributor.new(type, alternates << nil)
      end

      def establish_connection(name, spec)
        super.tap do
          @class_to_alternate_pools[name] ||= {}

          alternate_specs(spec).each do |alternate,spec|
            @connection_pools[spec] ||= ::ActiveRecord::ConnectionAdapters::ConnectionPool.new(spec)
            @class_to_alternate_pools[name][alternate.to_sym] = @connection_pools[spec]
          end
        end
      end

      def remove_connection(klass)
        super.tap do
          if pools = @class_to_alternate_pools.delete(klass.name)
            pools.each do |(alternate,pool)|
              @connection_pools.delete pool.spec
              pool.automatic_reconnect = false
              pool.disconnect!
            end
          end
        end
      end

      def retrieve_alternate_connection_pool(klass, alternate)
        pools = @class_to_alternate_pools[klass.name]
        return pools[alternate] if pools && pools.include?(alternate)
        return nil if ::ActiveRecord::Base == klass
        retrieve_alternate_connection_pool(klass.superclass, alternate)
      end

      def retrieve_main_connection_pool(klass)
        pool = @class_to_pool[klass.name]
        return pool if pool
        return nil if ::ActiveRecord::Base == klass
        retrieve_main_connection_pool(klass.superclass)
      end

      def retrieve_connection_pool(klass)
        if alternate = switch.current_alternate(klass)
          retrieve_alternate_connection_pool(klass, alternate)
        else
          retrieve_main_connection_pool(klass)
        end
      end

      private

      # Returns the alternate specs for the given one.
      #
      def alternate_specs(spec)
        (spec.config[:alternates] || {}).inject({}) do |specs,(alternate,alternate_config)|
          specs.tap { |specs| specs[alternate] = make_alternate_spec(spec, alternate_config) }
        end
      end

      def make_alternate_spec(spec, alternate_config)
        config = spec.config.clone
        config.delete(:alternates)
        alternate_config.each { |key,value| config[key.to_sym] = value }
        ::ActiveRecord::Base::ConnectionSpecification.new(config, "#{config[:adapter]}_connection")
      end
    end
  end
end
