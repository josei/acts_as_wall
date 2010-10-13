module ActiveRecord # :nodoc:
  module Acts # :nodoc:
    module Wall
      module Controller
        def self.included(base) # :nodoc:
          base.extend ClassMethods
        end

        module ClassMethods
          def announce wallables, options={}
            options[:only] = [ options[:only] ].flatten if options[:only]
            options[:except] = [ options[:except]].flatten if options[:except]
            options[:wallables] = wallables
            cattr_accessor :announce_options
            self.announce_options ||= []
            self.announce_options << options
          end

          def notify wallables, options={}
            announce wallables, options.merge(:notification=>true)
          end
        end

        def fire_event resource, action=action_name.to_sym, controller=controller_name.to_sym
          [resource].flatten.map do |object| # Support for collections
            event = nil
            published = false

            Kernel.const_get("#{controller}_controller".camelcase).announce_options.each do |options|
              next if options[:except] and options[:except].include?(action.to_sym)
              next if options[:only]   and !options[:only].include?(action.to_sym)
              next if options[:unless] and options[:unless].call(resource, self)
              next if options[:if]     and options[:if].call(resource, self)

              # Process options
              wallables = if options[:wallables].is_a? Proc
                options[:wallables].call(object, self)
              else
                [options[:wallables]].flatten.map do |name|
                  if object.respond_to?(name)
                    object.send(name)
                  elsif self.respond_to?(name)
                    self.send(name)
                  end
                end
              end.flatten

              # Create event (only one)
              event ||= ::Event.create :actor=>current_user, :public=>false,
                                       :object=>object.event_object, :text=>object.event_text,
                                       :subobject=>object.event_subobject, :subtext=>object.event_subtext,
                                       :controller=>controller.to_s, :action=>action.to_s

              # Create announcements and notifications
              wallables.each do |wallable|
                if options[:notification]
                  # Create notification
                  event.notifications.create :notifee=>wallable

                  # Send mail if a mailer is defined
                  if mailer = ActiveRecord::Acts::Listener.mailers[wallable.class.name]
                    Kernel.const_get(mailer).send("#{controller}_#{action}".to_sym, wallable, event).deliver
                  end
                else
                  # Create announcement
                  event.announcements.create :wall=>wallable.wall

                  # Mark event as published if announced on a wall
                  published = true unless wallable.wall.private
                end

              end
            end

            # Show events in public timeline if they've been publicly announced on a wall
            event.update_attribute(:public, true) if event and published

            event
          end
        end
      end
    end
  end
end

ActionController::Base.send :include, ActiveRecord::Acts::Wall::Controller
