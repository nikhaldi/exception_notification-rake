require 'delegate'

class ExceptionNotifier
  class Rake
    class MultiDelegator

      def initialize(delegates)
        @delegates = delegates.map do |del|
          SimpleDelegator.new(del)
        end
      end

      def method_missing(m, *args, &block)
        return_values = @delegates.map do |del|
          del.method_missing(m, *args, &block)
        end
        return_values.first
      end
    end
  end
end
