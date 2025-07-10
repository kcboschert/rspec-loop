# frozen_string_literal: true

require "rspec/loop"
require "rspec/core/sandbox"

RSpec.configure do |config|
  config.default_loop_count = 1

  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.around(:each) do |example|
    RSpec::Core::Sandbox.sandboxed do |_cfg|
      RSpec::Loop.setup
      example.run
    end
  end
end
