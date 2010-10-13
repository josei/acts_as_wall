module ActiveRecord #:nodoc:
  module Acts #:nodoc:
    module Wall
      module Model
        def self.included(base) # :nodoc:
          base.extend ClassMethods
        end

        module ClassMethods
          def keeps_listener options
            self.module_eval <<-EOS
              def keeps_listener_options
                #{options.inspect}
              end
            EOS
            has_many :listeners_kept, :class_name=>'Listener', :as=>:creator, :dependent=>:destroy
            after_save :keep_listener
            include ActiveRecord::Acts::Wall::Model::InstanceMethods
          end
        end

        module InstanceMethods

          def keep_listener
            keeps_listener_options.each do |actor_label, wall_label|
              actor = send(actor_label)
              wall = (wall_label == :self ? self : send(wall_label)).wall
              listener = listeners_kept.select { |l| l.actor_type==actor.class.name }.first

              if listener_needed_for?(actor, wall)
                listeners_kept.create :wall=>wall, :actor=>actor unless listener
              else
                listener.destroy if listener
              end
            end
          end
          
          def listener_needed_for? actor, wall
            respond_to?('accepted?') ? accepted? : true
          end
          
        end
      end
    end
  end
end

ActiveRecord::Base.send :include, ActiveRecord::Acts::Wall::Model
