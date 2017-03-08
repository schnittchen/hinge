# Hinge

Hinge is a trivial dependency resolver. With Hinge, you can write down object dependencies
in a linear fashion to have a simple overview of them.

```
class Deps
  # This method implements building a logger. It has no dependencies.
  def build_logger
    Logger.new($stdout)
  end

  # This method builds an instance of the `Processor` class you want to use,
  # initialized with the logger from the previous method.
  # This matching is done by the name of the parameter!
  def build_processor(logger)
    Processor.new(logger)
  end

  # Named parameters can be used as well!
  def build_runner(logger:)
    Runner.new(logger)
  end
end

deps = Deps.new
resolver = Hinge.resolver(deps)
processor = resolver.resolve(:processor)
resolver.resolve(:processor).equal?(processor) # => true (the same object is returned as last time)
```

And that's all!

Varying dependencies depending on the environment can now easily be handled in a number of ways,
ranging from `if/else` or `case` constructs to inheritance or overriding methods of `Deps`.


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'hinge'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install hinge

## Development

Tests are written in RSpec.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/schnittchen/hinge.
