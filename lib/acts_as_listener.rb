module ActiveRecord #:nodoc:
  module Acts #:nodoc:
    module Listener
      mattr_accessor :mailers
      self.mailers = {}
      
      def self.included(base) # :nodoc:
        base.extend ClassMethods
      end

      module ClassMethods
        def acts_as_listener options={}
          has_one :feed, :as=>:actor, :dependent=>:destroy
          has_one :tray, :as=>:actor, :dependent=>:destroy
          has_many :events_as_actor, :class_name=>'Event', :as=>:actor, :dependent=>:destroy

          send :include, ActiveRecord::Acts::Listener::InstanceMethods

          after_create :create_feed_and_tray
          after_create :add_self_listener if options[:self]
          ActiveRecord::Acts::Listener.mailers[self.name] = "#{self.name}Mailer" if options[:mailer] == true
          ActiveRecord::Acts::Listener.mailers[self.name] = options[:mailer].camelcase if options[:mailer] and options[:mailer] != true
        end
      end

      module InstanceMethods
        def listen_to wall
          feed.listeners.create :wall=>wall
        end
                
        protected
        def create_feed_and_tray
          Feed.create :actor=>self
          Tray.create :actor=>self
        end
        def add_self_listener
          listen_to self.wall
        end
      end
    end
  end
end

ActiveRecord::Base.send :include, ActiveRecord::Acts::Listener
