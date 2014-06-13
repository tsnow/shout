# Shout

A class-level observer pattern for ActiveRecord.


## Installation

Add this line to your application's Gemfile:

    gem 'shout'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install shout

## Usage

Shout provides two mixins: Observable, and Listener.


## Observable

``` ruby
class Snowcone < Struct.new(:state, :flavors)

  # To publish events, include the Observable module.
  include Shout::Observable
  
  # List the events you'll publish. This cuts down on typos in the
  # observing classes.
  shout_events([
                    :empty, 
                    :filled, 
                    :flavored, 
                    :purchased, 
                    :eaten, 
                    :thrown_away,
                    ])
  # List your observing classes. This ensures that callbacks run in 
  # a deterministic order across all environments.
  shout_observers(Accounting)

  # Then in your instances, use the #run_callbacks method
  # to notify Listeners that an event has occurred.
  def state!(event)
      self.run_callbacks(event)
  end
end
```

## Listener

``` ruby
class Accounting
  
  # To listen to events on other objects, include Listener.
  include Shout::Listener

  # And reference the class name you'll be observing. 
  # You can only observe one class.
  self.observes= :Snowcone

  # Implement the initialize method with an argument for the 
  # observed instance.
  def initialize(snowcone)
  end

  # Set callbacks for the events you'd like to listen to.
  shout_callback :purchased, :credit_bank_account
  shout_callback :flavored, :mark_flavor_used
  shout_callback :filled, :mark_ice_used

  # And point them at methods in your class.
  def credit_bank_account(cash)
  end
  def mark_flavor_used(flavor)
  end
  def mark_ice_used
  end
end
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
