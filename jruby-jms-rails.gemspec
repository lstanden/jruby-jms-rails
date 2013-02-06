lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'jruby-jms-rails'

Gem::Specification.new do |gem|
  gem.name          = 'jruby-jms-rails'
  gem.version       = JRuby::JMS::Rails::VERSION
  gem.authors       = ['Lee Standen']
  gem.email         = ['lee@standen.id.au']
  gem.description   = %q{Extension for jruby-jms to provide rails integration.}
  gem.summary       = %q{}
  gem.homepage      = "https://github.com/lstanden/jruby-jms-rails"
  
  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)})
  gem.require_paths = ['lib']
  
  gem.add_dependency 'jruby-jms'
  gem.add_dependency 'active_support'
end
