exception_notification-rake - ExceptionNotifier for Rake tasks
==============================================================

This Ruby gem is an extension of the [exception_notification gem](http://rubygems.org/gems/exception_notification) to support sending mail upon failures in Rake tasks. This is useful if you run Rake tasks as batch jobs on a schedule, particularly if you're using the [Heroku Scheduler add-on](http://addons.heroku.com/scheduler).

## Usage

### Basic Configuration

Exception notification must be set up in your Rails config files. In general, you'll want to do this in environment-specific config files, such as `config/environments/production.rb`. Minimal configuration:

    # config/environments/production.rb
    require 'exception_notifier/rake'

    YourApp::Application.configure do
      # Other configuration here, including ActionMailer config ...

      config.middleware.use ExceptionNotifier,
        :sender_address       => %{"notifier" <sender.address@example.com>},
        :exception_recipients => %w{your.email@example.com},
        :ignore_if            => lambda { true }

      ExceptionNotifier::Rake.configure
    end

**Note:** This uses `:ignore_if` to suppress all exception notifications triggered by the Rails server itself (as opposed to Rake). If you want those notifications as well, omit the `:ignore_if` option.

If you are already using `ExceptionNotifier` anyway, you don't need to configure it again and all you need is:

	# config/environments/production.rb
	require 'exception_notifier/rake'

	YourApp::Application.configure do
	  # Other configuration here, including ExceptionNotifer and ActionMailer config ...

	  ExceptionNotifier::Rake.configure
	end

**Note:** As a prerequisite for sending mail your Rails Action Mailer needs to be configured in the environment where you're using exception notification. See the [Rails guide on Action Mailer](http://guides.rubyonrails.org/action_mailer_basics.html#action-mailer-configuration).


### Notification Example

TODO


### Usage with Heroku Scheduler

If you're using Heroku, the [Scheduler add-on](http://addons.heroku.com/scheduler) is a very convenient and cheap (i.e., free) way to run scheduled batch jobs. In a Rails environment it's easiest to define batch jobs as Rake tasks. However, the only way to find out whether a job run by the scheduler succeeded or failed is generally reading the logs.

This gem fixes this issue. If you configure exception notification as described above it should work out of the box with the Heroku Scheduler. (Provided you have email delivery set up - you could try the [SendGrid add-on](https://addons.heroku.com/sendgrid) which comes in a free version that should be good enough for notifications.)


### Customization

You can pass configuration options to `ExceptionNotifier::Rake.configure`. It accepts all the same options as standard `ExceptionNotifier` (see [its documentation](https://github.com/smartinez87/exception_notification)). These options will be applied only to notifications sent as a result of Rake failures.

The most likely options you'll want to use are `:email_prefix` and `:exception_recpients`. Example:

    ExceptionNotifier::Rake.configure(
	  :email_prefix => "[Cron Failure] ",
	  :exception_recipients => %w{user1@example.com user2@example.com})

This will prefix the email subjects of Rake failure notifications with `[Cron Failure]` and will send them to the two given email addresses. Note that if you set the same options when you configure `ExceptionNotifier` itself, they will be overridden but for Rake failures only.

If you want to configure sections, which is unlikely, note that by default the sections `['rake', 'backtrace']` are used (where `rake` is a custom section introduced by this gem).


## Installation

    gem install exception_notification-rake


## License

Distributed under an [MIT license](https://github.com/nikhaldi/exception_notification-rake/blob/master/LICENSE.md).
