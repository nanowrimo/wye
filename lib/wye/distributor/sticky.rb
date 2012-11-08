require 'zlib'

module Wye
  module Distributor
    class Sticky
      def initialize(values)
        @values = values
      end

      def next(id)
        (mod = @values.length) > 0 ? @values[Zlib.crc32(id.to_s) % mod] : nil
      end
    end
  end
end
