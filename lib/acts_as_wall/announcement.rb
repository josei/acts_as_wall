module ActiveRecord #:nodoc:
  module Acts #:nodoc:
    module Wall
      module Announcement
        def self.included(base)
          base.class_eval do
            belongs_to :event
            belongs_to :wall
          end
        end
      end
    end
  end
end
