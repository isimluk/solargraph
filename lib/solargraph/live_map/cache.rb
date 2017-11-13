module Solargraph
  class LiveMap
    class Cache
      def initialize
        @method_cache = {}
      end

      def get_methods options
        @method_cache[options]
      end

      def set_methods options, values
        @method_cache[options] = values
      end

      def clear
        @method_cache.clear
      end
    end
  end
end