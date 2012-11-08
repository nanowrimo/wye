require 'wye'
require 'rails'

module Wye
  class Railtie < Rails::Railtie
    initializer 'wye.set_connection_handler', :before => 'active_record.initialize_database' do
      ActiveSupport.on_load(:active_record) do
        require 'wye/active_record/base'
        ::ActiveRecord::Base.connection_handler = Wye::ActiveRecord::ConnectionHandler.new
      end
    end
  end
end
