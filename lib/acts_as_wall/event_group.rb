module ActiveRecord #:nodoc:
  module Acts #:nodoc:
    module Wall
      module EventGroup
        def self.included base
          base.extend ClassMethods
        end

        module ClassMethods
          def arrange all_events
            events = all_events.select { |e| !e.hidden? }
            groups = []
            while !events.empty?
              event = events.first
              
              groups << if event.conditions
                matches = events.select do |e|
                  event.conditions.all? { |at| e.respond_to?(at) and event.respond_to?(at) and e.send(at) == event.send(at) } and
                  e.type == event.type
                end
                raise Exception, "Event group is empty -- this may imply you're trying to group by an impossible condition" if matches.empty?
                events -= matches
                if matches.size > 1
                  ::EventGroup.new matches
                else
                  matches.first
                end
              else
                events.shift
              end
            end
            
            all_events.replace groups
          end
        end
        
        def initialize events
          @events = events
        end
        
        def events
          @events
        end
  
        def type
          "#{@events.first.type}_group"
        end

        def respond_to? name, *args
          super or @events.first.respond_to?(name.to_s.singularize.to_sym) or @events.first.respond_to?(name)
        end

        def method_missing name, *args
          if (singular = name.to_s.singularize.to_sym) != name and @events.first.respond_to?(singular)
            @events.map { |event| event.send singular, *args }
          elsif @events.first.respond_to?(name)
            @events.first.send name, *args
          end
        end
        
      end
    end
  end
end