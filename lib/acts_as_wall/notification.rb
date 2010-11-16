module ActiveRecord #:nodoc:
  module Acts #:nodoc:
    module Wall
      module Notification
        def self.included(base)
          base.class_eval do
            belongs_to :event
            belongs_to :notifee, :polymorphic => true

            default_scope order('notifications.created_at desc')
          end
        end
      end
    end
  end
end
