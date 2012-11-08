module Wye
  autoload :ActiveRecord, 'wye/active_record'
  autoload :Distributor, 'wye/distributor'
  autoload :Switch, 'wye/switch'
end

require 'wye/railtie' if defined?(Rails)
