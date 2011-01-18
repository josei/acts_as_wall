module ActiveRecord #:nodoc:
  module Acts #:nodoc:
    module Wall
      module Event

        def self.included(base)
          base.class_eval do
            has_many :announcements, :dependent=>:destroy
            has_many :notifications, :dependent=>:destroy
            has_many :walls, :through => :announcements
            has_many :notifees, :through => :notifications
            belongs_to :actor, :polymorphic=>true
            belongs_to :object, :polymorphic=>true
            belongs_to :subobject, :polymorphic=>true
            
            after_update  :touch_acts_as_event
            after_destroy :touch_acts_as_event

            scope :public, where(:'events.public' => true)
            scope :next, lambda { where('events.start_at > ?', DateTime.now).order('events.start_at asc') }
            scope :past, lambda { where('events.start_at < ?', DateTime.now).order('events.start_at desc') }
          end
        end
      
        def creator
          @creator ||= Kernel.const_get(creator_type)
        end
        
        def conditions
          @conditions ||= [(creator.event_group.is_a?(Hash) ? creator.event_group[event.action] : creator.event_group)].flatten if creator.event_group
        end
        
        def type
          @type ||= :"#{controller}_#{action}"
        end

        def respond_to? name, *args
          super or
          ( creator.event_data[name] ? respond_to?(creator.event_data[name]) : false ) or
          ( (singular = name.to_s.singularize.to_sym) != name and respond_to?(singular))
        end
        
        def hidden?
          creator.event_hide(self)
        end
        
        def method_missing name, *args
          if name!=:creator_type and creator.event_data[name]
            send creator.event_data[name], *args
          elsif (singular = name.to_s.singularize.to_sym) != name and respond_to?(singular)
            [send singular, *args]
          else
            super
          end
        end

        protected
          def touch_acts_as_event
            c = ActiveRecord::Base.connection
            
            # Touch walls
            c.update """UPDATE walls SET updated_at='#{DateTime.now.to_formatted_s(:db)}'
                        FROM announcements
                        WHERE announcements.event_id='#{self.id}' AND announcements.wall_id=walls.id"""
            
            # Touch feeds
            c.update """UPDATE feeds SET updated_at='#{DateTime.now.to_formatted_s(:db)}'
                        FROM announcements, walls, listeners
                        WHERE announcements.event_id='#{self.id}' AND announcements.wall_id=walls.id AND
                              walls.id=listeners.wall_id AND listeners.feed_id=feeds.id"""

            # Touch trays
            c.update """UPDATE trays SET updated_at='#{DateTime.now.to_formatted_s(:db)}'
                        FROM notifications
                        WHERE notifications.event_id='#{self.id}' AND notifications.tray_id=trays.id"""
          end
        
      end
    end
  end
end
