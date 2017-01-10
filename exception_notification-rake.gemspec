$:.push File.expand_path("../lib", __FILE__)
require 'exception_notifier/rake/version'

Gem::Specification.new do |s|
  s.name        = 'exception_notification-rake'
  s.version     = ExceptionNotifier::Rake::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Nik Haldimann']
  s.email       = ['nhaldimann@gmail.com']
  s.homepage    = 'https://github.com/nikhaldi/exception_notification-rake'
  s.summary     = 'Sending exception notifications upon Rake task failures'
  s.description = 'An extension of the exception_notification gem to support' +
    ' sending mail upon failures in Rake tasks'

  s.required_ruby_version = '>= 2.0'
  s.add_runtime_dependency 'exception_notification', '~> 4.1.0'
  # NB: Rake before 0.9.0 won't support the exception hook we're using
  s.add_runtime_dependency 'rake', '>= 0.9.0'
  s.add_development_dependency 'rails', '~> 4.1.0'

  s.files         = Dir['LICENSE.md', 'README.md', 'lib/**/*']
  s.test_files    = Dir['test/**/*.rb']
  s.require_paths = ['lib']
end
