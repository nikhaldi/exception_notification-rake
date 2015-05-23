require 'exception_notifier'

module ExceptionNotifier

  class Rake

    @notifier_options = {}
    @configured = false

    # Whether Rake exception notifications have been configured.
    def self.configured?
      @configured
    end

    # Configure Rake exception notifications. Should be called in a config file,
    # usually in config/environments/production.rb for production use.
    # An optional hash of options can be given, which will be passed through
    # unchanged to the underlying notifiers.
    def self.configure(options = {})
      @configured = true
      @notifier_options.merge!(options)

      # There is only a single static list registered ignore_ifs. We make
      # ignore_ifs passed to just this configuration only effective for
      # background exceptions (the enviornment will be nil). That's the
      # best we can do, there isn't really a way to identify just our exceptions.
      if options[:ignore_if]
        ExceptionNotifier.ignore_if do |exception, passed_options|
          passed_options[:env].nil? && options[:ignore_if].call({}, exception)
        end
      end
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
      @configured = false
      ExceptionNotifier.clear_ignore_conditions!
    end
  end
end
