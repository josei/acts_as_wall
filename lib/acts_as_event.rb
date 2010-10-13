module ActiveRecord #:nodoc:
  module Acts #:nodoc:
    module Event
      def self.included(base) # :nodoc:
        base.extend ClassMethods
      end

      module ClassMethods
        def acts_as_event options={}
          self.module_eval <<-EOS
            def event_object
              #{options[:object] || 'self'}
            end
            def event_text
              #{options[:text] || 'event_object'}.to_s
            end
            def event_subobject
              #{options[:subobject] || 'self'}
            end
            def event_subtext
              #{options[:subtext] || 'event_subobject'}.to_s
            end
          EOS
          send :has_many, :events_as_object, :class_name=>'Event', :as=>:object, :dependent=>:destroy
          send :has_many, :events_as_subobject, :class_name=>'Event', :as=>:subobject, :dependent=>:destroy
        end
      end
    end
  end
end

ActiveRecord::Base.send :include, ActiveRecord::Acts::Event
