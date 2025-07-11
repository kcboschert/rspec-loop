# frozen_string_literal: true

require_relative "lib/rspec/loop/version"

Gem::Specification.new do |spec|
  spec.name = "rspec-loop"
  spec.version = RSpec::Loop::VERSION
  spec.authors = ["kcboschert"]

  spec.summary = "Run RSpec tests multiple times"
  spec.description = "Run RSpec tests multiple times"
  spec.homepage = "https://github.com/kcboschert/rspec-loop"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/kcboschert/rspec-loop"
  spec.metadata["changelog_uri"] = "https://github.com/kcboschert/rspec-loop/blob/main/CHANGELOG.md"
  spec.metadata["rubygems_mfa_required"] = "true"

  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "rspec-core", "~> 3.10"

  spec.add_development_dependency "appraisal"
  spec.add_development_dependency "pry-byebug"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.10.0"
  spec.add_development_dependency "rubocop", "~> 1.21"
end
