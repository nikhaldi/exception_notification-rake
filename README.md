exception_notification-rake - ExceptionNotifier for Rake tasks
==============================================================

This Ruby gem is an extension of the [exception_notification gem](http://rubygems.org/gems/exception_notification) to support sending mail (or other sorts of notifications) upon failures in Rake tasks. This is useful if you run Rake tasks as batch jobs on a schedule, particularly if you're using the [Heroku Scheduler add-on](http://addons.heroku.com/scheduler).

[![Build Status](https://travis-ci.org/nikhaldi/exception_notification-rake.png)](https://travis-ci.org/nikhaldi/exception_notification-rake)

## Installation

If you're using Rails 4.2 or higher, including Rails 5 and 6 (or you're not using Rails at all), use the latest version of the gem:

    gem 'exception_notification-rake', '~> 0.3.0'

If you're using Rails 4.1.x, use the 0.2.x line of versions:

    gem 'exception_notification-rake', '~> 0.2.2'

If you're using Rails 4.0.x, use the 0.1.x line of versions:

    gem 'exception_notification-rake', '~> 0.1.3'

If you're using Rails 3, use the 0.0.x line of versions:

    gem 'exception_notification-rake', '~> 0.0.7'


## Usage

### Configuration for Email Notifications

**Note:** These examples are for the latest version of the gem (using exception_notification 4+ and Rails 4+). For a Rails 3.2 example [see below](#rails-32-configuration-example).

Exception notification must be set up in your Rails config files. In general, you'll want to do this in environment-specific config files, such as `config/environments/production.rb`. Minimal configuration:

    # config/environments/production.rb

    YourApp::Application.configure do
      # Other configuration here, including ActionMailer config ...

      config.middleware.use ExceptionNotification::Rack,
        :ignore_if => lambda { |env, exception| !env.nil? },
        :email => {
          :sender_address => %{"notifier" <sender.address@example.com>},
          :exception_recipients => %w{your.email@example.com}
        }

      ExceptionNotifier::Rake.configure
    end

**Note:** This uses `:ignore_if` to suppress all exception notifications not triggered by a background exception (identified by a `nil` environment). If you want to see all notifications (i.e., also those triggered by requests to the Rails server), omit the `:ignore_if` option.

If you are already using `ExceptionNotifier` anyway, you don't need to configure it again and all you need is:

    # config/environments/production.rb

    YourApp::Application.configure do
      # Other configuration here, including ExceptionNotifer and ActionMailer config ...

      ExceptionNotifier::Rake.configure
    end

**Note:** As a prerequisite for sending mail your Rails Action Mailer needs to be configured in the environment where you're using exception notification. See the [Rails guide on Action Mailer](http://guides.rubyonrails.org/action_mailer_basics.html#action-mailer-configuration).


### Other Notifiers

exception_notificatons supports a bunch of notifiers other than email. See [its documentation](http://smartinez87.github.io/exception_notification/#notifiers) for details. This gem should generally work out of the box with all notifiers. The Rake command line that led to the failure is available at the `:rake_command_line` key in the `data` dictionary.


### Rails 3.2 Configuration Example

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


### Email Notification Example

Email sent upon a failure will include the Rake tasks executed and a stacktrace. This is the result from calling an undefined method `khaaaaan!` in a task called `failing_task` (the data section contains the executed Rake command line in the `:rake_command_line` key):

    Subject: [ERROR] (NoMethodError) "undefined method `khaaaaan!' for main:Object"
    From: "notifier" <sender.address@example.com>
    To: <your.email@example.com>

    A NoMethodError occurred in background at 2014-07-20 21:25:00 UTC :

      undefined method `khaaaaan!' for main:Object
      /Users/haldimann/Projects/nikhaldimann.com/lib/tasks/scheduler.rake:33:in `block in <top (required)>'

    -------------------------------
    Backtrace:
    -------------------------------

      lib/tasks/scheduler.rake:33:in `block in <top (required)>'
      .rvm/gems/ruby-1.9.3-p327/gems/rake-10.3.2/lib/rake/task.rb:240:in `call'
      .rvm/gems/ruby-1.9.3-p327/gems/rake-10.3.2/lib/rake/task.rb:240:in `block in execute'
      .rvm/gems/ruby-1.9.3-p327/gems/rake-10.3.2/lib/rake/task.rb:235:in `each'
      .rvm/gems/ruby-1.9.3-p327/gems/rake-10.3.2/lib/rake/task.rb:235:in `execute'
      .rvm/gems/ruby-1.9.3-p327/gems/rake-10.3.2/lib/rake/task.rb:179:in `block in invoke_with_call_chain'
      .rvm/rubies/ruby-1.9.3-p327/lib/ruby/1.9.1/monitor.rb:211:in `mon_synchronize'
      .rvm/gems/ruby-1.9.3-p327/gems/rake-10.3.2/lib/rake/task.rb:172:in `invoke_with_call_chain'
      .rvm/gems/ruby-1.9.3-p327/gems/rake-10.3.2/lib/rake/task.rb:165:in `invoke'
      .rvm/gems/ruby-1.9.3-p327/gems/rake-10.3.2/lib/rake/application.rb:150:in `invoke_task'
      .rvm/gems/ruby-1.9.3-p327/gems/rake-10.3.2/lib/rake/application.rb:106:in `block (2 levels) in top_level'
      .rvm/gems/ruby-1.9.3-p327/gems/rake-10.3.2/lib/rake/application.rb:106:in `each'
      .rvm/gems/ruby-1.9.3-p327/gems/rake-10.3.2/lib/rake/application.rb:106:in `block in top_level'
      .rvm/gems/ruby-1.9.3-p327/gems/rake-10.3.2/lib/rake/application.rb:115:in `run_with_threads'
      .rvm/gems/ruby-1.9.3-p327/gems/rake-10.3.2/lib/rake/application.rb:100:in `top_level'
      .rvm/gems/ruby-1.9.3-p327/gems/rake-10.3.2/lib/rake/application.rb:78:in `block in run'
      .rvm/gems/ruby-1.9.3-p327/gems/rake-10.3.2/lib/rake/application.rb:176:in `standard_exception_handling'
      .rvm/gems/ruby-1.9.3-p327/gems/rake-10.3.2/lib/rake/application.rb:75:in `run'
      .rvm/gems/ruby-1.9.3-p327/gems/rake-10.3.2/bin/rake:33:in `<top (required)>'
      .rvm/gems/ruby-1.9.3-p327/bin/rake:19:in `load'
      .rvm/gems/ruby-1.9.3-p327/bin/rake:19:in `<main>'
      .rvm/gems/ruby-1.9.3-p327/bin/ruby_noexec_wrapper:14:in `eval'
      .rvm/gems/ruby-1.9.3-p327/bin/ruby_noexec_wrapper:14:in `<main>'

    -------------------------------
    Data:
    -------------------------------

      * data: {:rake_command_line=>"rake failing_task"}


### Usage with Heroku Scheduler

If you're using Heroku, the [Scheduler add-on](http://addons.heroku.com/scheduler) is a very convenient and cheap way to run scheduled batch jobs. In a Rails environment it's easiest to define batch jobs as Rake tasks. However, the only way to find out whether a task run by the scheduler succeeded or failed is generally reading the logs.

This gem fixes this issue. [Here is a detailed guide](http://blog.nikhaldimann.com/2013/02/19/failure-notifications-for-rake-tasks-on-the-heroku-scheduler/) about configuring it on Heroku. In summary: If you configure exception notification as described above it should work out of the box with the Heroku Scheduler. (Provided you have email delivery set up in your Heroku app - you could try the [SendGrid add-on](https://addons.heroku.com/sendgrid) which comes in a free version that should be good enough for notifications.)


### Customization

You can pass configuration options to `ExceptionNotifier::Rake.configure`. These will be
passed through to each notifier you configured with `ExceptionNotifier` (see [its documentation](https://github.com/smartinez87/exception_notification) for details on options). The options will be applied only to notifications sent as a result of Rake failures.

The most likely options you'll want to use are `:email_prefix` and `:exception_recipients`. Example:

    ExceptionNotifier::Rake.configure(
      :email => {
        :email_prefix => "[Rake Failure] ",
        :exception_recipients => %w{user1@example.com user2@example.com}})

This will prefix the email subjects of Rake failure notifications with `[Rake Failure]` and will send them to the two given email addresses. Note that if you set the same options when you configure `ExceptionNotifier` mail notifier itself, they will be overridden but for Rake failures only.

`:ignore_if` and `:ignore_exceptions` are also supported. But note that the `:ignore_if` block will be evaluated for all exceptions, not just the ones triggered by Rake (this is unavoidable because of the design of exception_notification). The first argument to the block passed to `:ignore_if` is the environment - for all Rake failures and other background exceptions this will be `nil`, giving you some way to distinguish them.


## License

Distributed under an [MIT license](https://github.com/nikhaldi/exception_notification-rake/blob/master/LICENSE.md).
