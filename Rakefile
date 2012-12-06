lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

raise "jruby-jms must be built with JRuby: try again with `jruby -S rake'" unless defined?(JRUBY_VERSION)

require 'rake/clean'
require 'rake/testtask'
require 'date'
require 'java'
require 'jms-rails/version'

desc "Build gem"
task :gem  do |t|
  gemspec = Gem::Specification.new do |s|
    s.name = 'jruby-jms-rails'
    s.version = JMS::Rails::VERSION
    s.author = 'Lee Standen'
    s.email = 'lee@standen.id.au'
    s.homepage = 'https://github.com/lstanden/jruby-jms-rails'
    s.date = Date.today.to_s
    s.description = 'jruby-jms-rails is a utility library which makes it easy to create JMS subscribers in a Rails controller-like method.'
    s.summary = 'Rails-Like Interface to JRuby-JMS'
    s.files = FileList["./**/*"].exclude('*.gem', './nbproject/*').map{|f| f.sub(/^\.\//, '')}
    s.add_dependency 'jruby-jms'
    s.has_rdoc = true
  end
  Gem::Builder.new(gemspec).build
end

task :test do

  Rake::TestTask.new(:functional) do |t|
    t.test_files = FileList['test/*_test.rb']
    t.verbose    = true
  end

  Rake::Task['functional'].invoke
end

desc "Generate RDOC documentation"
task :doc do
  system "rdoc --main README.md --inline-source --quiet README.md `find lib -name '*.rb'`"
end
