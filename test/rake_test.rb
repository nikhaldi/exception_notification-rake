require "minitest/autorun"

require 'exception_notifier/rake'

class RakeTest < Minitest::Test

  class Notifier
    attr_accessor :exception, :options
    def call(exception, options)
      @exception = exception
      @options = options
    end
  end

  class IgnoredException < Exception
  end

  def setup
    ExceptionNotifier::Rake.reset_for_test
    assert !ExceptionNotifier::Rake.configured?
    @notifier = Notifier.new
    ExceptionNotifier.add_notifier 'test_notifier', @notifier
  end

  def assert_not_notified
    assert_nil @notifier.exception
    assert_nil @notifier.options
  end

  def assert_notified(exception, options)
    assert_equal exception, @notifier.exception
    assert_equal options, @notifier.options
  end

  def test_configure_only_default_options
    ExceptionNotifier::Rake.configure
    assert ExceptionNotifier::Rake.configured?
    assert_equal({}, ExceptionNotifier::Rake.notifier_options)
  end

  def test_configure_custom_options
    some_options = {
      :sender_address => 'foo@example.com',
      :exception_recipients => ['bar@example.com'],
    }
    ExceptionNotifier::Rake.configure some_options
    assert ExceptionNotifier::Rake.configured?
    assert_equal some_options, ExceptionNotifier::Rake.notifier_options
  end

  def test_maybe_deliver_notifications_without_configuration
    ExceptionNotifier::Rake.maybe_deliver_notification(Exception.new)
    assert_not_notified
  end

  def test_maybe_deliver_notifications_with_config
    ExceptionNotifier::Rake.configure
    ex = Exception.new
    ExceptionNotifier::Rake.maybe_deliver_notification(ex)
    assert_notified ex, ExceptionNotifier::Rake.notifier_options
  end

  def test_maybe_deliver_notifications_with_data
    ExceptionNotifier::Rake.configure
    data = {:foo => :bar}
    options = ExceptionNotifier::Rake.notifier_options
    original_options = options.dup
    ex = Exception.new
    ExceptionNotifier::Rake.maybe_deliver_notification(ex, data)
    assert_notified ex, options.merge({:data => data})
    assert_equal original_options, options
  end

  def test_maybe_deliver_notifications_with_ignore_if
    ExceptionNotifier::Rake.configure(
      ignore_if: lambda { |env, exception| true })
    ExceptionNotifier::Rake.maybe_deliver_notification(Exception.new)
    assert_not_notified
  end

  def test_maybe_deliver_notifications_with_passing_ignore_if
    ExceptionNotifier::Rake.configure(
      ignore_if: lambda { |env, exception| false })
    ex = Exception.new
    ExceptionNotifier::Rake.maybe_deliver_notification(ex)
    assert_notified ex, ExceptionNotifier::Rake.notifier_options
  end

  def test_maybe_deliver_notifications_with_ignore_exceptions
    ExceptionNotifier::Rake.configure(
      ignore_exceptions: ['RakeTest::IgnoredException'])
    ExceptionNotifier::Rake.maybe_deliver_notification(IgnoredException.new)
    assert_not_notified

    ex = Exception.new
    ExceptionNotifier::Rake.maybe_deliver_notification(ex)
    assert_notified ex, ExceptionNotifier::Rake.notifier_options
  end
end
