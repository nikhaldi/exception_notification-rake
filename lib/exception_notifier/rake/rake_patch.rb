# Monkey patching patterns lifted from
# https://github.com/thoughtbot/airbrake/blob/master/lib/airbrake/rake_handler.rb
module ExceptionNotifier
  module RakePatch
    def display_error_message(ex)
      super(ex)
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
if Object.const_defined?(:Rake) && Rake.respond_to?(:application)
  Rake.application.instance_eval do
    class << self
      prepend ExceptionNotifier::RakePatch
    end
  end
end
