# SupportsPointer
The SupportsPointer gem loads a concern to allow support for parsing and generation of various pointer types

## Usage
Add the following to your model:
```ruby
  parses_pointer :pointer_name_as_symbol,
    template:/regexp(?<with_captures>.*)for(?<each_field>)/,
    resolve:{|data| data[:with_captures].find_by(some_param:data[:other_capture]),
    generate:{|target| "#{target.some_attr}:#{target.other_attr}"}
```

if the pointer being declared is a model pointer, or model_instance pointer, simply declare:
```ruby
  parses_pointer :model
# and/or
  parses_pointer :model_instance
```
if you use a model or model instance pointer that requires special handling (ie:alternate index param)
you can overwrite the default resolver or generator with
```ruby
pointer_resolution {|data| some_block_to_resolve_pointer}
# or
pointer_generation {|data| some_block_to_generate_pointer}
```

Pointers are inherited like any other method. For instance, model & model instance
can be declared on ApplicationRecord to allow parsing from any model in the project.
However, pointers can also be parsed by
other classes where the declaration is outside the class hierarchy.
Lets say you have a "handle" pointer defined directly on class User,
of the format "@username"

```ruby
parses_pointer :handle, template:/\^(?<handle>\w*)/, resolve:{|data| User.find_by handle:data[:handle]}
pointer_generation :handle do |data| # feel free to mix-and-match between single-statement declarations
  "@#{data.handle}"                  # and using pointer_resolution or pointer_generation methods.
end
```

In the above example only the "User" model will be able to generate, parse or resolve
handle pointers. To allow another model (say, "Widget", for example) you'd add the following
to class Widget:

```ruby
uses_pointer :handle, from:User
```

This will allow the Widget class to access the handle pointer.

A pointer can be parsed by calling ```parse_pointer``` on any model or object
which supports the pointer type in question.

When declaring model & model instance pointers, it may be helpful to declare a ```to_pointer``` method, returning ```generate_model_pointer``` and ```generate_model_instance_pointer```
respectively:

```ruby
  def self.to_pointer
    return generate_model_pointer(self)
  end
  def to_pointer
    return generate_model_instance_pointer(self)
  end
```

## Installation
Add this line to your application's Gemfile:

```ruby
gem "supports_pointer"
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install supports_pointer
```

## Contributing
Contribution directions go here.

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
