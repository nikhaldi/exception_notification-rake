require 'exception_notifier'

class ExceptionNotifier
  class Rake

    ALWAYS_TRUE = lambda { true }

    @notifier_options = {}

    def self.configured?
      !@notifier_options.empty?
    end

    def self.configure(config, options = {})
      # TODO add ExceptionNotifier to middleware if needed
      @notifier_options.merge!(default_notifier_options)
      @notifier_options.merge!(options)
    end

    def self.default_notifier_options
      {
        :email_prefix => "[Rake Failure] ",
        # TODO add stdin/stderr sections with captured output
        :background_sections => %w(backtrace),
        # TODO include this only if ExceptionNotifer not already in use
        :ignore_if => ALWAYS_TRUE,
      }
    end

    def self.notifier_options
      @notifier_options
    end

    def self.maybe_deliver_notification(exception)
      # TODO needs test
      if configured?
        ExceptionNotifier::Notifier.background_exception_notification(
          exception, notifier_options).deliver
      end
    end

    def self.reset_for_test
      @notifier_options = {}
    end
  end
end
