require 'spec_helper'

module Wye::Distributor
  describe RoundRobin do
    let(:round_robin) { RoundRobin.new(values) }

    describe "#next" do
      subject { round_robin.next }

      context "when there are values" do
        let(:values) { [:x, :y, :z] }

        it("should cycle through the values infinitely") do
          [:x, :y, :z, :x, :y, :z, :x].each do |next_value|
            round_robin.next.should be(next_value)
          end
        end
      end

      context "when there are no values" do
        let(:values) { [] }

        it { should be_nil }
      end
    end
  end
end
