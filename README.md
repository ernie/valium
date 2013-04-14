# Valium [![Build Status](https://secure.travis-ci.org/ernie/valium.png)](http://travis-ci.org/ernie/valium)

Suffering from ActiveRecord instantiation anxiety? Try Valium. It
saves your CPU and memory for more important things, retrieving
just the values you're interested in seeing.

## Usage

### In your Gemfile:

    gem 'valium'
    
### In your code:

You can select a single value...

```ruby
Post.where(:published => true).value_of :title
# => ["First Post", "Another Awesome Post", ...]
```

... or several ...

```ruby
Employee.where(:title => 'Sr. Monkey Wrangler').values_of :first_name, :last_name, :hired_at
# => [["Ernie", "Miller", 2009-09-21 08:00:00 -0400],
      ["Herb", "Myers", 2002-02-13 09:00:00 -0400], ...]
```

Values returned by Valium will be the data types you'd expect, just
as though you instantiated the ActiveRecord object and used the
accessor. This includes serialized attributes:

```ruby
class Animal < ActiveRecord::Base
  serialize :extra_info
end

Animal.where(:genus => 'felis').values_of :species, :extra_info
# => [["catus", {:domestic => true}], ["lolcatus", {:can_has_cheezburger => true}], ...]
```

## Why would I use this?

It's not uncommon for Rails apps to need only one or two attributes
from a bunch of ActiveRecord objects. They'll have code like this:

```ruby
MyModel.some_scope.map(&:id)
```

Or, if the developer is a bit more clever about saving memory, he
might use code like this:

```ruby
MyModel.some_scope.select(:id).map(&:id)
```

This helps a good deal with memory usage, but even if we cut down 
on the memory usage a bit, the truth is that no matter what we try,
**instantiating ActiveRecord objects is slow.**

This is because ActiveRecord provides all kinds of awesome stuff,
none of which we need, if we're just looking to grab one or two
values and print them out, or perform a quick calculation, or
something.

Check out [this gist of a benchmark script and results](https://gist.github.com/1166964)
to see just how much it can hurt when you're instantiating
unnecessary ActiveRecord objects.

TL;DR: It hurts *a lot*. For retrieving a single value, using Valium
is nearly 10x faster than mapping over ActiveRecord objects.
For multiple values, it's about 5x faster. Even if you're
deserializing attributes, where more time, proportionally, gets
spent in the deserialization process than with normal attributes,
Valium can be up to twice as fast as mapping over ActiveRecord
objects, in my tests.

## Easily Find where Valium can Help

Ack away to find likely spots in your app where Valium should be injested:

    ack map\\\(\&\\:\\w+\\\)

## Limitations

Valium will only retrieve columns from the model you are querying against.
Joined associations may be used to limit the scope of the query, but their
attribute values can't be selected. There's a bit of discussion on 
[issue #2](https://github.com/ernie/valium/issues/2) about why this is, 
if you're interested in reading more.

## Conclusion

You knew everything I mentioned above, already. In fact,
you're probably mocking me right now:

"ZOMG OBJECTS USE MEMORY AND INSTANTIATION TAKES CPU CYCLES!
I R GENIUS!"

Yeah. It's not rocket science. This is just a quick little
(seriously, around 100 LOC) gem that provides some intuitive 
syntax around a common pattern and doesn't stomp on any
existing ActiveRecord functionality. It "just works."

Give it a try. Your code will thank you for it.

## Copyright

Copyright &copy; 2011 [Ernie Miller](http://twitter.com/erniemiller)