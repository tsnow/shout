require 'observer' # stdlib
module Shout
  module Observable #include me
    
    ## ImplementorMethods
    
    # Really this is for clarity until everyone is cool with the implementation.
    def self.run_callbacks(instance,event,*params)
      instance.run_callbacks(event,*params)
    end
    
    def run_callbacks(event, *params)
                                      # HMMM: not sure how I feel
      self.class.load_observers(self) # about this. See #idemp_observer.
    end
    
    ## Internal Methods
    def self.included(mod)
      mod.send(:extend, ClassMethods)
    end
    
    attr_accessor :observer_list
    
    # This is done this way because I want to be able to #new these
    # up at the time an event comes in, rather than using and
    # after_initialize callback.
    def idemp_observer(k,i)
      self.observer_list ||= []
      return if self.observer_list.assoc(k)
      self.observer_list.push([i.class, i])
    end
  end
  
  module ClassMethods #extend me
    
    ## Implementor Methods
    def shout_events(event_names)
      self.events_notified += event_names.map(&:to_sym)
    end
    def shout_misspellings(event_misspellings)
      self.events_notified_misspellings.merge!(event_misspellings)
    end
    def shout_observers(listener_classes)
      self.observer_classes += listener_classes
    end
    
    ## Internal Methods
    attr_accessor :observer_classes
    attr_accessor :events_notified
    attr_accessor :events_notified_misspellings
    def self.extended(mod)
      mod.observer_classes = []
      mod.events_notified = []
      mod.events_notified_misspellings = {}
    end
    def load_observers(instance)
      self.observer_classes.map{|k|
        instance.idemp_observer(k,k.new(instance))
      }
    end
  end
end
