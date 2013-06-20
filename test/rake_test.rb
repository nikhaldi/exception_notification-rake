require 'test/unit'
require 'mocha/setup'

require 'active_support/core_ext'
require 'exception_notifier/rake'

class RakeTest < Test::Unit::TestCase

  def setup
    ExceptionNotifier::Rake.reset_for_test
    assert !ExceptionNotifier::Rake.configured?
  end

  def expect_delivery(exception, options)
    ExceptionNotifier.expects(:notify_exception).with(exception, options)
  end

  def test_configure_only_default_options
    ExceptionNotifier::Rake.configure
    assert ExceptionNotifier::Rake.configured?
    assert_equal ExceptionNotifier::Rake.default_notifier_options,
      ExceptionNotifier::Rake.notifier_options
  end

  def test_configure_custom_options
    some_options = {
      :sender_address => 'foo@example.com',
      :exception_recipients => ['bar@example.com'],
    }
    ExceptionNotifier::Rake.configure some_options
    assert ExceptionNotifier::Rake.configured?
    assert_equal some_options.merge(ExceptionNotifier::Rake.default_notifier_options),
      ExceptionNotifier::Rake.notifier_options
  end

  def test_maybe_deliver_notifications_without_configuration
    ExceptionNotifier::Rake.maybe_deliver_notification(Exception.new)
  end

  def test_maybe_deliver_notifications_with_config
    ExceptionNotifier::Rake.configure
    ex = Exception.new
    expect_delivery(ex, ExceptionNotifier::Rake.notifier_options)
    ExceptionNotifier::Rake.maybe_deliver_notification(ex)
  end

  def test_maybe_deliver_notifications_with_data
    ExceptionNotifier::Rake.configure
    data = {:foo => :bar}
    options = ExceptionNotifier::Rake.notifier_options
    original_options = options.dup
    ex = Exception.new
    expect_delivery(ex, options.merge({:data => data}))
    ExceptionNotifier::Rake.maybe_deliver_notification(ex, data)
    assert_equal(original_options, options)
  end
end
