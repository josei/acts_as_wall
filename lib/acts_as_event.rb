module ActiveRecord #:nodoc:
  module Acts #:nodoc:
    module Event
      def self.included(base) # :nodoc:
        base.extend ClassMethods
      end

      module ClassMethods
        def acts_as_event options={}
          defaults = { :object=>name.underscore.to_sym, :subobject=>name.underscore.to_sym }
          
          (class << self; self; end).instance_eval do
            define_method :event_hide, (options[:hide] || Proc.new { |event| false })
          end
          
          self.module_eval <<-EOS
            def self.event_data
              #{defaults.merge(options).reject { |k,v| ![:object, :subobject].include?(k) }.invert.inspect}
            end
            def self.event_group
              #{options[:group_by].inspect}
            end

            def event_object
              #{options[:object] || 'self'}
            end
            def event_subobject
              #{options[:subobject] || 'self'}
            end
            
            def touch_acts_as_event
              c = ActiveRecord::Base.connection
              
              # Touch walls
              c.update """UPDATE walls SET updated_at='\#{DateTime.now.to_formatted_s(:db)}'
                          FROM events, announcements
                          WHERE events.id=announcements.event_id AND announcements.wall_id=walls.id AND
                                ( events.object_id='\#{self.id}' AND events.object_type='\#{self.class.name}' OR
                                  events.subobject_id='\#{self.id}' AND events.subobject_type='\#{self.class.name}' )"""
              
              # Touch feeds
              c.update """UPDATE feeds SET updated_at='\#{DateTime.now.to_formatted_s(:db)}'
                          FROM events, announcements, walls, listeners
                          WHERE events.id=announcements.event_id AND announcements.wall_id=walls.id AND
                                walls.id=listeners.wall_id AND listeners.feed_id=feeds.id AND
                                ( events.object_id='\#{self.id}' AND events.object_type='\#{self.class.name}' OR
                                  events.subobject_id='\#{self.id}' AND events.subobject_type='\#{self.class.name}' )"""

              # Touch trays
              c.update """UPDATE trays SET updated_at='\#{DateTime.now.to_formatted_s(:db)}'
                          FROM events, notifications
                          WHERE events.id=notifications.event_id AND notifications.tray_id=trays.id AND
                                ( events.object_id='\#{self.id}' AND events.object_type='\#{self.class.name}' OR
                                  events.subobject_id='\#{self.id}' AND events.subobject_type='\#{self.class.name}' )"""
              
              # Touch events
              c.update """UPDATE events SET updated_at='\#{DateTime.now.to_formatted_s(:db)}'
                          WHERE ( events.object_id='\#{self.id}' AND events.object_type='\#{self.class.name}' OR
                                  events.subobject_id='\#{self.id}' AND events.subobject_type='\#{self.class.name}' )"""
            end
          EOS
          
          send :has_many, :events_as_object, :class_name=>'Event', :as=>:object, :dependent=>:destroy
          send :has_many, :events_as_subobject, :class_name=>'Event', :as=>:subobject, :dependent=>:destroy
          
          # Only touch objects on update or destroy. It doesn't make sense to touch
          # objects on create because events are always fired after models are persisted
          send :after_update,  :touch_acts_as_event
          send :after_destroy, :touch_acts_as_event
        end
      end
    end
  end
end

ActiveRecord::Base.send :include, ActiveRecord::Acts::Event
