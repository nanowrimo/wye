require 'active_record'

module Wye
  module ActiveRecord
    module Base
      module ClassMethods
        def on(alternate, &blk)
          connection_handler.switch.on(self, alternate, &blk)
        end
      end
    end
  end
end

::ActiveRecord::Base.extend(Wye::ActiveRecord::Base::ClassMethods)
