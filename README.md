# rspec-loop

rspec-loop adds a `:loop` option to run rspec examples multiple times.

## Installation

Install the gem and add to the application's Gemfile by executing:

```bash
bundle add rspec-loop --group test
```

If bundler is not being used to manage dependencies, install the gem by executing:

```bash
gem install rspec-loop
```

## Configuration

Configure the options in your project's `spec_helper.rb`:

```ruby
require "rspec/loop"

RSpec.configure do |config|
  config.default_loop_count = 5
end
```

### Options

| Name | Description | Type | Default |
| --- | --- | --- | --- |
| `default_loop_count` | How many iterations to run each test by default. | Integer | `3` |

## Usage

To configure an individual test to run multiple times:

```ruby
it "runs three times", loop: 3 do
  # test code here
end
```

To configure a group of examples to run multiple times:

```ruby
describe "a group of tests", loop: 3 do
  it "runs three times" do
    # test code here
  end

  it "also runs three times" do
    # test code here
  end
end
```

### Formatter

To use the included formatter, use RSpec's [--format option](https://rspec.info/features/3-13/rspec-core/command-line/format-option/):

```bash
rspec spec --format RSpec::Loop::Formatter
```

Or via a [rake task](https://rspec.info/features/3-13/rspec-core/command-line/rake-task/):

```ruby
RSpec::Core::RakeTask.new(:loop) do |t|
  t.rspec_opts = "--format RSpec::Loop::Formatter"
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake` to run the tests and linter. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

## Contributing

Bug reports and pull requests are welcome on GitHub at <https://github.com/kcboschert/rspec-loop>. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/kcboschert/rspec-loop/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the rspec-loop project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/kcboschert/rspec-loop/blob/main/CODE_OF_CONDUCT.md).
