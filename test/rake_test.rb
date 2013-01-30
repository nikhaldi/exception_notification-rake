require 'rails/application/configuration'
require 'test/unit'

require 'exception_notifier/rake'

class RakeTest < Test::Unit::TestCase

  def setup
    ExceptionNotifier::Rake.reset_for_test
    assert !ExceptionNotifier::Rake.configured?
    @mock_config = Rails::Application::Configuration.new
    @mock_config.middleware = ActionDispatch::MiddlewareStack.new
  end

  def assert_has_notifier_middleware
    assert ExceptionNotifier::Rake.notifier_middleware_configured? @mock_config
  end

  def test_configure_only_default_options
    ExceptionNotifier::Rake.configure(@mock_config)
    assert ExceptionNotifier::Rake.configured?
    assert_equal ExceptionNotifier::Rake.default_notifier_options,
      ExceptionNotifier::Rake.notifier_options
    assert_has_notifier_middleware
  end

  def test_configure_custom_options
    some_options = {
      :sender_address => 'foo@example.com',
      :exception_recipients => ['bar@example.com'],
    }
    ExceptionNotifier::Rake.configure(@mock_config, some_options)
    assert ExceptionNotifier::Rake.configured?
    assert_equal some_options.merge(ExceptionNotifier::Rake.default_notifier_options),
      ExceptionNotifier::Rake.notifier_options
    assert_has_notifier_middleware
  end

  def test_configure_with_middleware_installed
    @mock_config.middleware.use ExceptionNotifier
    assert_has_notifier_middleware
    ExceptionNotifier::Rake.configure(@mock_config)
    assert ExceptionNotifier::Rake.configured?
    assert_has_notifier_middleware
  end

  def test_configure_with_middleware_installed_skips_ignore_if
    @mock_config.middleware.use ExceptionNotifier
    ExceptionNotifier::Rake.configure(@mock_config)
    assert ExceptionNotifier::Rake.configured?
    assert !ExceptionNotifier::Rake.notifier_options[:ignore_if]
  end
end
