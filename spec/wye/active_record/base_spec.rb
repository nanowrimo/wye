require 'spec_helper'

module Wye::ActiveRecord
  describe Base do
    it("adds ActiveRecord::Base.on") do
      ActiveRecord::Base.method(:on).should be_a(Method)
      ActiveRecord::Base.method(:on).owner.should be(Base::ClassMethods)
    end
  end
end
