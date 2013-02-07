require 'exception_notifier'

class ExceptionNotifier

  # Append application view path to the ExceptionNotifier lookup context.
  Notifier.append_view_path "#{File.dirname(__FILE__)}/views"

  class Rake

    @notifier_options = {}

    def self.configured?
      !@notifier_options.empty?
    end

    def self.configure(options = {})
      @notifier_options.merge!(default_notifier_options)
      @notifier_options.merge!(options)
    end

    def self.default_notifier_options
      {
        :email_prefix => "[Rake Failure] ",
        :background_sections => %w(rake backtrace),
      }
    end

    def self.notifier_options
      @notifier_options
    end

    def self.maybe_deliver_notification(exception, data={})
      if configured?
        options = notifier_options
        if !data.empty?
          options = options.dup
          options[:data] = data.merge(options[:data] || {})
        end
        ExceptionNotifier::Notifier.background_exception_notification(
          exception, options).deliver
      end
    end

    def self.reset_for_test
      @notifier_options = {}
    end
  end
end
