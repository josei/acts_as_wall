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

            default_scope order('events.start_at desc')
            scope :public, where(:'events.public' => true)
            scope :next, lambda { where('events.start_at > ?', DateTime.now) }
            scope :past, lambda { where('events.start_at < ?', DateTime.now) }
          end
        end
      end
    end
  end
end
