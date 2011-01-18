module ActiveRecord #:nodoc:
  module Acts #:nodoc:
    module Wall
      module Tray
        def self.included(base)
          base.class_eval do
            belongs_to :actor, :polymorphic => true
            has_many :notifications, :dependent=>:destroy
            has_many :events, :through=>:notifications, :uniq=>true
          end
        end
      end
    end
  end
end
