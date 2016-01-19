module ExceptionNotifier
  module RakePatch
    def self.patch!
      ::Rake::Application.class_eval do
        alias_method :display_error_message_without_notifications, :display_error_message

        def display_error_message(ex)
          display_error_message_without_notifications(ex)
          ExceptionNotifier::Rake.maybe_deliver_notification(ex,
            :rake_command_line => reconstruct_command_line)
        end

        def reconstruct_command_line
          "rake #{ARGV.join(' ')}"
        end
      end
    end
  end
end

# Only do this if we're actually in a Rake context. In some contexts (e.g.,
# in the Rails console) Rake might not be defined.
if Object.const_defined? :Rake
  ExceptionNotifier::RakePatch.patch!
end
