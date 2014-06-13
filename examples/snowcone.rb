require 'shout'
BANK_ACCOUNT = {
             :credits => [],
             }
INVENTORY = {
       :banana_syrup => 1,
       :blue_raspberry_syrup => 3,
       :bubblegum_syrup => 5,
       :ice => 1000,
       }

class Accounting
  def initialize(snowcone)
    @snowcone = snowcone
  end
  def credit_bank_account(cash)
    BANK_ACCOUNT[:credits].push(cash)
  end
  def mark_flavor_used(flavor)
    INVENTORY[:"#{flavor}_syrup"] -= 1
  end
  def mark_ice_used
    INVENTORY[:ice] -= 1
  end
end

class Snowcone < Struct.new(:state, :flavors)
  include Shout::Observable
  shout_events([
                    :empty, 
                    :filled, 
                    :flavored, 
                    :purchased, 
                    :eaten, 
                    :thrown_away,
               ])
  shout_observers([
                   Accounting,
                  ])
  def initialize
    @state = :empty
    @flavors = []
  end
  def flavor(flavor)
    @flavors.push(flavor)
    self.run_callbacks(:flavored, flavor)
  end
  def state!(event)
    self.run_callbacks(event)
    self.state = event
  end
  def purchase(cost)
    self.run_callbacks(:purchased, cost)
    self.state= :purchased
  end
end

class Accounting
  include Shout::Listener
  self.observes= :Snowcone

  shout_callback :purchased, :credit_bank_account
  shout_callback :flavored, :mark_flavor_used
  shout_callback :filled, :mark_ice_used
end

class Barista
  def self.order(*flavors)
    s=Snowcone.new
    s.state!(:filled)
    flavors.map{|i| s.flavor(i)}
    s
  end
end
