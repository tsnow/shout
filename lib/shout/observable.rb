require 'observer' # stdlib
module Shout
  module Observable #include me
    
    ## ImplementorMethods
    
    # Really this is for clarity until everyone is cool with the implementation.
    def self.run_callbacks(instance,event,*params)
      instance.run_shout_callbacks(event,*params)
    end
    
    def run_shout_callbacks(event, *params)
                                      # HMMM: not sure how I feel
      self.class.load_observers(self) # about this. See #idemp_observer.
      self.notify_shout_observers(event, *params)
    end
    def notify_shout_observers(event, *params)
      self.shout_observer_list.each do |k,i|
        i.update_with_shout_event(event, *params)
      end
    end
    
    ## Internal Methods
    def self.included(mod)
      mod.send(:extend, ClassMethods)
    end
    
    attr_accessor :shout_observer_list
    
    # This is done this way because I want to be able to #new these
    # up at the time an event comes in, rather than using and
    # after_initialize callback.
    def idemp_observer(k,i)
      self.shout_observer_list ||= []
      return if self.shout_observer_list.assoc(k)
      self.shout_observer_list.push([i.class, i])
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
      self.observer_class_names += listener_classes
    end
    
    ## Internal Methods
    attr_accessor :observer_class_names
    attr_accessor :observer_class_names_check
    attr_accessor :events_notified
    attr_accessor :events_notified_misspellings
    def self.extended(mod)
      mod.observer_class_names = []
      mod.observer_class_names_check = []
      mod.events_notified = []
      mod.events_notified_misspellings = {}
    end
    def check_observer_classes
      return if @checked
      here_not_there = (observer_class_names - observer_class_names_check)
      there_not_here = (observer_class_names_check - observer_class_names)
      unless here_not_there == there_not_here
        missing = (here_not_there + there_not_here)

        meths = "#{self}.shout_observers(#{missing.map(&:inspect)}) and "+
          missing.map{|observer|
            "#{observer}.observes=#{self.name.to_sym.inspect}"
          }.join(' and ')
        
        raise ArgumentError.new("#{self}: Please call both #{meths} to observe #{self}. This is done to ensure determinism in the load order in development, test, and production environments.")
      end
      @checked = true
    end
    def load_observers(instance)
      check_observer_classes
      self.observer_class_names.map{|name|
        k = Shout.constantize(name.to_s)
        instance.idemp_observer(k,k.new(instance))
      }
    end
  end
end
