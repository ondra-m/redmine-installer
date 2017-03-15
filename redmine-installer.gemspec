# coding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'redmine-installer/version'

Gem::Specification.new do |spec|
  spec.name          = 'redmine-installer'
  spec.version       = RedmineInstaller::VERSION
  spec.authors       = ['Ondřej Moravčík']
  spec.email         = ['moravcik.ondrej@gmail.com']
  spec.summary       = %q{Easy way how install/upgrade Redmine, EasyRedmine or EasyProject.}
  spec.description   = %q{}
  spec.homepage      = 'https://github.com/easyredmine/redmine-installer'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.1.0'

  spec.add_runtime_dependency 'commander'
  spec.add_runtime_dependency 'tty-prompt', '~> 0.11.0'
  spec.add_runtime_dependency 'tty-spinner', '~> 0.4.1'
  spec.add_runtime_dependency 'tty-progressbar', '~> 0.10.1'
  spec.add_runtime_dependency 'rubyzip'
  spec.add_runtime_dependency 'pastel'

  spec.add_development_dependency 'bundler', '~> 1.11'
  spec.add_development_dependency 'rake'
end
