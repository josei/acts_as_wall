module ActiveRecord #:nodoc:
  module Acts #:nodoc:
    module Wall
      module Wall
        def self.included(base)
          base.class_eval do
            has_many :listeners, :dependent=>:destroy
            has_many :announcements
            has_many :events, :through => :announcements, :uniq=>true
            belongs_to :wallable, :polymorphic => true
          end
          base.send :include, InstanceMethods
        end

        def listened_by? actor
          !actor.nil? and actor.listeners.where(:wall_id=>id).first
        end
      end
    end
  end
end
