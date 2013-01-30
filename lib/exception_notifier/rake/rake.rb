require 'exception_notifier'

class ExceptionNotifier
  class Rake

    ALWAYS_TRUE = lambda { true }

    @notifier_options = {}

    def self.configured?
      !@notifier_options.empty?
    end

    def self.configure(config, options = {})
      @notifier_options.merge!(default_notifier_options)
      @notifier_options.merge!(options)

      if notifier_middleware_configured?(config)
        # We're adding a catch-all ignore_if rule by default for cases where
        # no explicit ExceptionNotifier was installed.
        @notifier_options.delete :ignore_if
      else
        config.middleware.use ExceptionNotifier
      end
    end

    def self.notifier_middleware_configured?(config)
      # TODO this probably won't work in reality ...
      !!config.middleware.detect {|ware| ware.klass == ExceptionNotifier}
    end

    def self.default_notifier_options
      {
        :email_prefix => "[Rake Failure] ",
        # TODO add stdin/stderr sections with captured output
        :background_sections => %w(backtrace),
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
