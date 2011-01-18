module ActiveRecord #:nodoc:
  module Acts #:nodoc:
    module Wall
      module Feed
        def self.included(base)
          base.class_eval do
            belongs_to :actor, :polymorphic => true
            has_many :listeners, :dependent=>:destroy
          end
        end

        def events
          ::Event.includes(:announcements=>{:wall=>:listeners}).
            where(:'listeners.feed_id'=>self.id)
        end
      end
    end
  end
end
