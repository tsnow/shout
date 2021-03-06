module Shout

  module Listener #include me

    ## Implementor Methods
    def initialize(observed)
      raise ArgumentError.new("Must be overriden in implementors.")
    end

    ## Internal Methods
    def self.included(mod)
      mod.extend(ClassMethods)
      mod.callbacks = []
    end

    def update_with_shout_event(name, *params)
        a=self.class.callbacks_for_event(name)
        a.map{|meth| self.send(meth,*params) }
    end

    module ClassMethods
      ## Implementor Methods

      # Sets the class which this observer will observe. A required call.
      def observes=(observes)
        @observes = observes
        valid_observable?
        observes_class.observer_class_names_check.push(self.name.to_sym)
      end
      # Registers a callback which will be executed when the
      # observes_class's instances call run_callbacks(name).
      def shout_callback(name, method)
        valid_event?(name)
        callbacks.push([name,method])
      end
      def test_event(name, instance, *params)
        listener = new(instance)
        listener.update_with_shout_event(name, *params)
      end

      ## Internal Methods
      attr_reader :observes
      attr_accessor :callbacks
      def observes_class
        Shout.constantize(self.observes.to_s)
      rescue NameError => e
        nil
      end
      def valid_observable?
        unless observes_class
          raise ArgumentError.new("#{self}.observes = #{observes.inspect}. #{observes.inspect} can't be found as a constant.")
        end
        unless observes_class < ::Shout::Observable
          raise ArgumentError.new("#{self}.observes == #{self.observes} does not inherit from ::Shout::Observable.")
        end
      end
      def valid_event?(event)
        if observes_class.events_notified_misspellings.has_key?(event)
          raise ArgumentError.new("#{self.class}: Well well well, you've found an area of cognitive dissonance! Use #{observes_class.events_notified_misspellings[event].inspect} instead of #{event}.")
        end
        unless observes_class.events_notified.include?(event)
          raise ArgumentError.new("#{self.class}: Oh lordy, this is embarassing. #{event.inspect} is totally not available in #{observes_class}.\nAvailable events:\n#{observes_class.events_notified.inspect}")
        end
      end
      def callbacks_for_event(n)
        self.callbacks.select{|name,method| name == n}.map{|name,method| method}
      end
    end
  end
end
