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

  s.add_runtime_dependency 'exception_notification', '~> 3.0.0'
  # TODO how to specify rake dependency?
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rails', '~> 3.2.0'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ['lib']
end
