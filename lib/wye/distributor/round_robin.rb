module Wye
  module Distributor
    class RoundRobin
      def initialize(values)
        @cycle = values.cycle
      end

      def next(*arguments)
        @cycle.next
      rescue StopIteration
        nil
      end
    end
  end
end
