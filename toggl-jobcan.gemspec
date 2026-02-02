# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'toggl/jobcan/version'

Gem::Specification.new do |spec|
  spec.name          = 'toggl-jobcan'
  spec.version       = Toggl::Jobcan::VERSION
  spec.authors       = ['Tomoya Kabe']
  spec.email         = ['limit.usus@gmail.com']

  spec.summary       = 'Sync toggl worktime to JobCan.'
  spec.description   = 'Sync toggl worktime to JobCan.'
  spec.homepage      = 'https://github.com/limitusus/toggl-jobcan'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 3.1'
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'ferrum'
  spec.add_dependency 'thor'
  spec.add_dependency 'toggl-worktime', '~> 0.7.0', '>= 0.7.0'
end
