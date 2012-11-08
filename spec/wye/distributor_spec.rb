require 'spec_helper'

module Wye
  Distributor::Test = Class.new { def initialize(values); end }

  describe Distributor do
    describe ".new" do
      subject { proc { Distributor.new(type, values) } }

      let(:values) { [] }

      context "given a type that corresponds to an existing distributor class" do
        let(:type) { :test }
        let(:corresponding_class) { Distributor::Test }

        its(:call) { should be_a(corresponding_class) }
      end

      context "given a type that has no corresponding distributor class" do
        let(:type) { :does_not_exist }

        it { should raise_error }
      end
    end
  end
end
