# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'guard/mustachejs/version'

Gem::Specification.new do |s|
  s.name        = 'guard-mustachejs'
  s.version     = Guard::MustacheJsVersion::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Nathan Matthews']
  s.email       = ['lowentropy@gmail.com']
  s.homepage    = 'https://github.com/lowentropy/guard-mustachejs'
  s.summary     = 'Guard for mustache.js templates'
  s.description = 'Converts mustache templates (as .* files) into a single .js file.'

  s.required_rubygems_version = '>= 1.3.6'

  s.add_dependency 'guard', '~> 0.3.0'

  s.add_development_dependency 'bundler',     '~> 1.0.9'
  s.add_development_dependency 'guard-rspec', '~> 0.1.9'
  s.add_development_dependency 'rspec',       '~> 2.4.0'

  s.files        = Dir.glob('{lib}/**/*') + %w[LICENSE README.rdoc]
  s.require_path = 'lib'
end
