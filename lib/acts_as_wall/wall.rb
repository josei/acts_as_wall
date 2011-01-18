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
          !actor.nil? and !actor.feed.listeners.where(:wall_id=>id).empty?
        end

        def showable_by? actor
          !private? or listened_by?(actor)
        end
      end
    end
  end
end
