require 'spec_helper'

module Wye::Distributor
  describe Sticky do
    let(:sticky) { Sticky.new(values) }

    describe "#next" do
      subject { sticky.next(id) }

      let(:id) { 'some string' }

      context "when there are values" do
        let(:values) { [:x, :y, :z] }

        it("should always return the same value given the same identifier") do
          value = sticky.next(id)
          100.times { sticky.next(id).should be(value) }
        end
      end

      context "when there are no values" do
        let(:values) { [] }

        it { should be_nil }
      end
    end
  end
end
