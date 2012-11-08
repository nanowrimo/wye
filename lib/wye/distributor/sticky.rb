require 'zlib'

module Wye
  module Distributor
    class Sticky
      def initialize(values)
        @values = values
      end

      def next(id)
        @values[Zlib.crc32(id.to_s) % @values.length]
      end
    end
  end
end
