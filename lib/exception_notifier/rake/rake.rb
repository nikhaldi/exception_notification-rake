require 'exception_notifier'

class ExceptionNotifier

  # Append application view path to the ExceptionNotifier lookup context.
  Notifier.append_view_path "#{File.dirname(__FILE__)}/views"

  class Rake

    @notifier_options = {}

    # Whether Rake exception notifications have been configured.
    def self.configured?
      !@notifier_options.empty?
    end

    # Configure Rake exception notifications. Should be called in a config file,
    # usually in config/environments/production.rb for production use.
    # An optional hash of options can be given, which will be passed through
    # unchanged to the underlying ExceptionNotifier.
    def self.configure(options = {})
      @notifier_options.merge!(default_notifier_options)
      @notifier_options.merge!(options)
    end

    def self.default_notifier_options
      {
        :background_sections => %w(rake backtrace),
      }
    end

    def self.notifier_options
      @notifier_options
    end

    # Deliver a notification about the given exception by email, in case
    # notifications have been configured. The additional data hash will
    # be passed through to ExceptionNotifier's data hash and will be availble
    # in templates.
    def self.maybe_deliver_notification(exception, data={})
      if configured?
        options = notifier_options
        if conditionally_ignored(options[:ignore_if], exception) ||
            ignored_exception(options[:ignore_exceptions], exception)
          return
        end

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

    private

    # Duplicated from exception_notification
    def self.conditionally_ignored(ignore_proc, exception)
      ignore_proc.call({}, exception)
    rescue Exception
      false
    end

    # Duplicated from exception_notification
    def self.ignored_exception(ignore_array, exception)
        Array.wrap(ignore_array).map(&:to_s).include?(exception.class.name)
    end
  end
end
