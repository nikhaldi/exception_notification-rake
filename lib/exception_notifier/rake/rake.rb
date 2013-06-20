require 'exception_notifier'

module ExceptionNotifier

  class Rake

    @notifier_options = {}

    # Whether Rake exception notifications have been configured.
    def self.configured?
      !@notifier_options.empty?
    end

    # Configure Rake exception notifications. Should be called in a config file,
    # usually in config/environments/production.rb for production use.
    # An optional hash of options can be given, which will be passed through
    # unchanged to the underlying notifiers.
    def self.configure(options = {})
      @notifier_options.merge!(default_notifier_options)
      @notifier_options.merge!(options)

      # Append view path for this gem, assuming that the client is using
      # ActionMailer::Base. This isn't ideal but there doesn't seem to be
      # a different way to extend the path.
      require 'action_mailer'
      ActionMailer::Base.append_view_path "#{File.dirname(__FILE__)}/views"
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
        if !data.empty?
          options = options.dup
          options[:data] = data.merge(options[:data] || {})
        end
        ExceptionNotifier.notify_exception(exception, options)
      end
    end

    def self.reset_for_test
      @notifier_options = {}
    end
  end
end
