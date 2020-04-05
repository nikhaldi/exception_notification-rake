# Copied/adapted from https://github.com/airbrake/airbrake/blob/master/lib/airbrake/rake.rb

if Rake.const_defined?(:TaskManager)
  Rake::TaskManager.record_task_metadata = true
end

module ExceptionNotifier
  module RakeTaskPatch
    # A wrapper around the original +#execute+, that catches all errors and
    # passes them on to ExceptionNotifier.
    #
    # rubocop:disable Lint/RescueException
    def execute(args = nil)
      super(args)
    rescue Exception => ex
      ExceptionNotifier::Rake.maybe_deliver_notification(
        ex,
        task_info,
      )
      raise ex
    end
    # rubocop:enable Lint/RescueException

  private

    # rubocop:disable Metrics/CyclomaticComplexity, Metrics/AbcSize
    def task_info
      info = {}

      info[:rake_command_line] = reconstruct_command_line
      info[:name] = name
      info[:timestamp] = timestamp.to_s
      info[:investigation] = investigation

      info[:full_comment] = full_comment if full_comment
      info[:arg_names] = arg_names if arg_names.any?
      info[:arg_description] = arg_description if arg_description
      info[:locations] = locations if locations.any?
      info[:sources] = sources if sources.any?

      if prerequisite_tasks.any?
        info[:prerequisite_tasks] = prerequisite_tasks.map do |p|
          p.__send__(:task_info)
        end
      end

      info
    end
    # rubocop:enable Metrics/CyclomaticComplexity, Metrics/AbcSize

    def reconstruct_command_line
      "rake #{ARGV.join(' ')}"
    end
  end
end

module Rake
  class Task
    prepend ExceptionNotifier::RakeTaskPatch
  end
end
