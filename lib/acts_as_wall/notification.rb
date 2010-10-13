module ActiveRecord #:nodoc:
  module Acts #:nodoc:
    module Wall
      module Notification
        def self.included(base)
          base.class_eval do
            belongs_to :event
            belongs_to :notifee, :polymorphic => true
          end
        end
      end
    end
  end
end