require 'exception_notifier'

class ExceptionNotifier
  class Rake

    @notifier_options = {}

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
      }
    end

    def self.notifier_options
      @notifier_options
    end

    def self.deliver_notification(exception)
      ExceptionNotifier::Notifier.background_exception_notification(
        exception, notifier_options).deliver
    end

    def self.reset_for_test
      @notifier_options = {}
    end
  end
end
