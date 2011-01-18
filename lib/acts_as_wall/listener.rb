module ActiveRecord #:nodoc:
  module Acts #:nodoc:
    module Wall
      module Listener
        def self.included(base)
          base.class_eval do
            belongs_to :creator, :polymorphic => true
            belongs_to :feed, :touch=>true
            belongs_to :wall
          end
        end
      end
    end
  end
end
