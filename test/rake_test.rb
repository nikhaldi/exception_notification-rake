require 'test/unit'
require 'exception_notifier/rake'

class RakeTest < Test::Unit::TestCase

  def setup
    ExceptionNotifier::Rake.reset_for_test
    assert !ExceptionNotifier::Rake.configured?
  end

  def test_configure_only_default_options
    ExceptionNotifier::Rake.configure({})
    assert ExceptionNotifier::Rake.configured?
    assert_equal ExceptionNotifier::Rake.default_notifier_options,
      ExceptionNotifier::Rake.notifier_options
  end

  def test_configure_custom_options
    some_options = {
      :sender_address => 'foo@example.com',
      :exception_recipients => ['bar@example.com'],
    }
    ExceptionNotifier::Rake.configure({}, some_options)
    assert ExceptionNotifier::Rake.configured?
    assert_equal some_options.merge(ExceptionNotifier::Rake.default_notifier_options),
      ExceptionNotifier::Rake.notifier_options
  end
end
