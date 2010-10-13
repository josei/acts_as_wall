module ActiveRecord #:nodoc:
  module Acts #:nodoc:
    module Wall
      module Listener
        def self.included(base)
          base.class_eval do
            belongs_to :creator, :polymorphic => true
            belongs_to :actor, :polymorphic => true
            belongs_to :wall

            scope :private, where(:'listeners.private'=>true)
          end
        end
      end
    end
  end
end
