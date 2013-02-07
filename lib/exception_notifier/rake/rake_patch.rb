# Monkey patching patterns lifted from
# https://github.com/thoughtbot/airbrake/blob/master/lib/airbrake/rake_handler.rb
class ExceptionNotifier
  module RakePatch
    def self.included(klass)
      klass.class_eval do
        alias_method :display_error_message_without_notifications, :display_error_message
        alias_method :display_error_message, :display_error_message_with_notifications
      end
    end

    def display_error_message_with_notifications(ex)
      display_error_message_without_notifications(ex)
      ExceptionNotifier::Rake.maybe_deliver_notification(ex,
        :rake_command_line => reconstruct_command_line)
    end

    def reconstruct_command_line
      "rake #{ARGV.join(' ')}"
    end
  end
end

# Only do this if we're actually in a Rake context. In some contexts (e.g.,
# in the Rails console) Rake might not be defined.
if Object.const_defined? :Rake
  Rake.application.instance_eval do
    class << self
      include ExceptionNotifier::RakePatch
    end
  end
end
