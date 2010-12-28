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
          has_many :events_as_actor, :class_name=>'Event', :as=>:actor, :dependent=>:destroy
          has_many :notifications, :as=>:notifee
          has_many :events, :through=>:notifications, :uniq=>true
          has_many :listeners, :as=>:actor, :dependent=>:destroy

          send :include, ActiveRecord::Acts::Listener::InstanceMethods

          after_create :add_self_listener if options[:self]
          ActiveRecord::Acts::Listener.mailers[self.name] = "#{self.name}Mailer" if options[:mailer] == true
          ActiveRecord::Acts::Listener.mailers[self.name] = options[:mailer].camelcase if options[:mailer] and options[:mailer] != true
        end
      end

      module InstanceMethods
        def listen_to wall
          listeners.create :wall=>wall
        end
                
        def feed
          ::Event.includes(:announcements=>{:wall=>:listeners}).
            where(:'listeners.actor_id'=>self.id, :'listeners.actor_type'=>self.class.name)
        end

        protected
        def add_self_listener
          listen_to self.wall
        end
      end
    end
  end
end

ActiveRecord::Base.send :include, ActiveRecord::Acts::Listener
