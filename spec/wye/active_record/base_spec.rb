require 'spec_helper'

module Wye::ActiveRecord
  describe Base do
    it("adds ActiveRecord::Base.on") do
      ActiveRecord::Base.method(:on).should be_a(Method)
      ActiveRecord::Base.method(:on).owner.should be(Base::ClassMethods)
    end

    before(:each) { ActiveRecord::Base.connection_handler = handler }

    let(:handler) { ConnectionHandler.new }

    describe ".on" do
      subject { ActiveRecord::Base.on(alternate, &block) }

      let(:alternate) { :a1 }
      let(:block) { proc {} }

      before(:each) do
        handler.switch.should_receive(:on).with(ActiveRecord::Base, alternate, &block)
      end

      it("doesn't fail") do
        expect { subject }.to_not raise_error
      end
    end
  end
end
