# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'github_changelog_generator/task'

RSpec::Core::RakeTask.new(:spec)

task default: :spec

GitHubChangelogGenerator::RakeTask.new :changelog do |config|
  config.user = 'limitusus'
  config.project = 'toggl-jobcan'
  config.since_tag = 'v0.1.0'
  config.future_release = '0.5.0'
end
