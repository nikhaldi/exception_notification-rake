exception_notification-rake - ExceptionNotifier for Rake tasks
==============================================================

This Ruby gem is an extension of the [exception_notification gem](http://rubygems.org/gems/exception_notification) to support sending mail upon failures in Rake tasks. This is useful if you run Rake tasks as batch jobs on a schedule, particularly if you're using the [Heroku Scheduler add-on](http://addons.heroku.com/scheduler).

[![Build Status](https://travis-ci.org/nikhaldi/exception_notification-rake.png)](https://travis-ci.org/nikhaldi/exception_notification-rake)

## Installation

If you're using Rails 4 (or you're not using Rails at all), use the latest version of the gem:

    gem 'exception_notification-rake', '~> 0.1.2'

If you're using Rails 3, use the 0.0.x line of versions:

    gem 'exception_notification-rake', '~> 0.0.6'


## Usage

### Basic Configuration

**Note:** These examples are for the latest version of the gem (using exception_notification 4 and Rails 4). For a Rails 3.2 example [see below](#rails-32-configuration-example).

Exception notification must be set up in your Rails config files. In general, you'll want to do this in environment-specific config files, such as `config/environments/production.rb`. Minimal configuration:

    # config/environments/production.rb

    YourApp::Application.configure do
      # Other configuration here, including ActionMailer config ...

      config.middleware.use ExceptionNotification::Rack,
	    :ignore_if => lambda { |env, exception| !env[:rake?] },
        :email => {
          :sender_address => %{"notifier" <sender.address@example.com>},
          :exception_recipients => %w{your.email@example.com}
        }

      ExceptionNotifier::Rake.configure
    end

**Note:** This uses `:ignore_if` to suppress all exception notifications not triggered by Rake (identified by the `:rake?` property set in the environment of all Rake failures). If you want to see all notifications (i.e., also those triggered by requests to the Rails server), omit the `:ignore_if` option.

If you are already using `ExceptionNotifier` anyway, you don't need to configure it again and all you need is:

	# config/environments/production.rb

	YourApp::Application.configure do
	  # Other configuration here, including ExceptionNotifer and ActionMailer config ...

	  ExceptionNotifier::Rake.configure
	end

**Note:** As a prerequisite for sending mail your Rails Action Mailer needs to be configured in the environment where you're using exception notification. See the [Rails guide on Action Mailer](http://guides.rubyonrails.org/action_mailer_basics.html#action-mailer-configuration).


#### Rails 3.2 Configuration Example

	# config/environments/production.rb

	YourApp::Application.configure do
	  # Other configuration here, including ActionMailer config ...

	  config.middleware.use ExceptionNotifier,
	    :sender_address       => %{"notifier" <sender.address@example.com>},
	    :exception_recipients => %w{your.email@example.com},
	    :ignore_if            => lambda { true }

	  ExceptionNotifier::Rake.configure
	end

For complete documentation on the Rails 3.2 version see the [corresponding branch on GitHub](https://github.com/nikhaldi/exception_notification-rake/tree/rails3.2).


### Notification Example

Email sent upon a failure will include the Rake tasks executed and a stacktrace. This is the result from calling an undefined method `khaaaaan!` in a task called `failing_task`:

	Subject: [ERROR] (NoMethodError) "undefined method `khaaaaan!' for main:Object"
	From: "notifier" <sender.address@example.com>
	To: <your.email@example.com>

	A NoMethodError occurred in background at 2013-02-07 18:31:57 UTC :

	  undefined method `khaaaaan!&#x27; for main:Object
	  lib/tasks/scheduler.rake:33:in `block in &lt;top (required)&gt;&#x27;

	-------------------------------
	Rake:
	-------------------------------

	  rake failing_task

	-------------------------------
	Backtrace:
	-------------------------------

	  lib/tasks/scheduler.rake:33:in `block in <top (required)>'
	  .rvm/gems/ruby-1.9.3-p327/gems/rake-10.0.3/lib/rake/task.rb:228:in `call'
	  .rvm/gems/ruby-1.9.3-p327/gems/rake-10.0.3/lib/rake/task.rb:228:in `block in execute'
	  .rvm/gems/ruby-1.9.3-p327/gems/rake-10.0.3/lib/rake/task.rb:223:in `each'
	  .rvm/gems/ruby-1.9.3-p327/gems/rake-10.0.3/lib/rake/task.rb:223:in `execute'
	  .rvm/gems/ruby-1.9.3-p327/gems/rake-10.0.3/lib/rake/task.rb:166:in `block in invoke_with_call_chain'
	  .rvm/rubies/ruby-1.9.3-p327/lib/ruby/1.9.1/monitor.rb:211:in `mon_synchronize'
	  .rvm/gems/ruby-1.9.3-p327/gems/rake-10.0.3/lib/rake/task.rb:159:in `invoke_with_call_chain'
	  .rvm/gems/ruby-1.9.3-p327/gems/rake-10.0.3/lib/rake/task.rb:152:in `invoke'
	  .rvm/gems/ruby-1.9.3-p327/gems/rake-10.0.3/lib/rake/application.rb:143:in `invoke_task'
	  .rvm/gems/ruby-1.9.3-p327/gems/rake-10.0.3/lib/rake/application.rb:101:in `block (2 levels) in top_level'
	  .rvm/gems/ruby-1.9.3-p327/gems/rake-10.0.3/lib/rake/application.rb:101:in `each'
	  .rvm/gems/ruby-1.9.3-p327/gems/rake-10.0.3/lib/rake/application.rb:101:in `block in top_level'
	  .rvm/gems/ruby-1.9.3-p327/gems/rake-10.0.3/lib/rake/application.rb:110:in `run_with_threads'
	  .rvm/gems/ruby-1.9.3-p327/gems/rake-10.0.3/lib/rake/application.rb:95:in `top_level'
	  .rvm/gems/ruby-1.9.3-p327/gems/rake-10.0.3/lib/rake/application.rb:73:in `block in run'
	  .rvm/gems/ruby-1.9.3-p327/gems/rake-10.0.3/lib/rake/application.rb:160:in `standard_exception_handling'
	  .rvm/gems/ruby-1.9.3-p327/gems/rake-10.0.3/lib/rake/application.rb:70:in `run'
	  .rvm/gems/ruby-1.9.3-p327/gems/rake-10.0.3/bin/rake:33:in `<top (required)>'
	  .rvm/gems/ruby-1.9.3-p327/bin/rake:23:in `load'
	  .rvm/gems/ruby-1.9.3-p327/bin/rake:23:in `<main>'

(If you're spotting encoding issues here, those appear to be a problem upstream in the exception_notification gem.)


### Usage with Heroku Scheduler

If you're using Heroku, the [Scheduler add-on](http://addons.heroku.com/scheduler) is a very convenient and cheap way to run scheduled batch jobs. In a Rails environment it's easiest to define batch jobs as Rake tasks. However, the only way to find out whether a task run by the scheduler succeeded or failed is generally reading the logs.

This gem fixes this issue. [Here is a detailed guide](http://blog.nikhaldimann.com/2013/02/19/failure-notifications-for-rake-tasks-on-the-heroku-scheduler/) about configuring it on Heroku. In summary: If you configure exception notification as described above it should work out of the box with the Heroku Scheduler. (Provided you have email delivery set up in your Heroku app - you could try the [SendGrid add-on](https://addons.heroku.com/sendgrid) which comes in a free version that should be good enough for notifications.)


### Customization

You can pass configuration options to `ExceptionNotifier::Rake.configure`. These will be
passed through to each notifier you configured with `ExceptionNotifier` (see [its documentation](https://github.com/smartinez87/exception_notification) for details on options). The options will be applied only to notifications sent as a result of Rake failures.

The most likely options you'll want to use are `:email_prefix` and `:exception_recpients`. Example:

    ExceptionNotifier::Rake.configure(
	  :email_prefix => "[Rake Failure] ",
	  :exception_recipients => %w{user1@example.com user2@example.com})

This will prefix the email subjects of Rake failure notifications with `[Rake Failure]` and will send them to the two given email addresses. Note that if you set the same options when you configure `ExceptionNotifier` mail notifier itself, they will be overridden but for Rake failures only.

`:ignore_if` and `:ignore_exceptions` are also supported. But note that the `:ignore_if` block will be evaluated for all exceptions, not just the ones triggered by Rake (this is unavoidable because of the design of exception_notification). The first argument to the block passed to `:ignore_if` is the environment - for all Rake failures this will be a dictionary with a single `:rake?` key (i.e., `{:rake? => true}`) so that you can distinguish them.

If you want to configure sections, which is unlikely, note that by default the sections `['rake', 'backtrace']` are used (where `rake` is a custom section introduced by this gem).


## License

Distributed under an [MIT license](https://github.com/nikhaldi/exception_notification-rake/blob/master/LICENSE.md).
