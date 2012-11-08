module Wye
  module Distributor
    autoload :RoundRobin, 'wye/distributor/round_robin'
    autoload :Sticky, 'wye/distributor/sticky'

    def self.new(type, values)
      klass = type.to_s.classify
      raise "unknown distributor type" unless const_defined?(klass, false)
      const_get(klass).new(values)
    end
  end
end
