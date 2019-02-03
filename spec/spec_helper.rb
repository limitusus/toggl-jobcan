# frozen_string_literal: true

require 'bundler/setup'
require 'toggl/jobcan'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # From erikhuda/thor
  def capture(stream)
    begin
      stream = stream.to_s
      eval "$#{stream} = StringIO.new" # rubocop:disable Security/Eval
      yield
      result = eval("$#{stream}").string # rubocop:disable Security/Eval
    ensure
      eval("$#{stream} = #{stream.upcase}") # rubocop:disable Security/Eval
    end

    result
  end
end
