# Based on/adapted from https://github.com/airbrake/airbrake/blob/master/lib/airbrake/rails.rb

module ExceptionNotifier
  class Rake
    class Railtie < ::Rails::Railtie
      rake_tasks do
        # Report exceptions occurring in Rake tasks.
        require 'exception_notifier/rake/rake_patch'
        # Work around https://github.com/nikhaldi/exception_notification-rake/issues/26
        # Rake::TaskManager won't have been defined when rake_patch.rb was first loaded.
        if Rails.env.development?
          load 'exception_notifier/rake/rake_patch.rb'
        end
      end
    end
  end
end
