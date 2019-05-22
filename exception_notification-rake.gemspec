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
  s.add_runtime_dependency 'exception_notification', '~> 4.3'
  # NB: Rake before 0.9.0 won't support the exception hook we're using
  s.add_runtime_dependency 'rake', '>= 0.9.0'

  # When developing/testing under various Ruby versions we have to set upper
  # version limits on some direct dependencies of exception_notification (and
  # some indirect dependencies such as nokogiri) because later versions are
  # not supported under the specific Ruby. This makes running tests on Travis
  # under all Rubies 2.0+ possible.
  # Note for future: Travis also supports giving multiple gemspecs:
  # https://docs.travis-ci.com/user/languages/ruby/#Testing-against-multiple-versions-of-dependencies
  if RUBY_VERSION >= '2.2'
    # No restrictions known at this point
  elsif RUBY_VERSION >= '2.1'
    s.add_development_dependency 'actionmailer', '~> 4.2'
    s.add_development_dependency 'activesupport', '~> 4.2'
  else
    s.add_development_dependency 'actionmailer', '~> 4.2'
    s.add_development_dependency 'activesupport', '~> 4.2'
    s.add_development_dependency 'nokogiri', '~> 1.6.0'
  end

  s.files         = Dir['LICENSE.md', 'README.md', 'lib/**/*']
  s.test_files    = Dir['test/**/*.rb']
  s.require_paths = ['lib']
end
