module ActiveRecord #:nodoc:
  module Acts #:nodoc:
    module Event
      def self.included(base) # :nodoc:
        base.extend ClassMethods
      end

      module ClassMethods
        def acts_as_event options={}
          defaults = { :object=>name.underscore.to_sym, :subobject=>name.underscore.to_sym }
          
          (class << self; self; end).instance_eval do
            define_method :event_hide, (options[:hide] || Proc.new { |event| false })
          end
          
          self.module_eval <<-EOS
            def self.event_data
              #{defaults.merge(options).reject { |k,v| ![:object, :subobject].include?(k) }.invert.inspect}
            end
            def self.event_group
              #{options[:group_by].inspect}
            end

            def event_object
              #{options[:object] || 'self'}
            end
            def event_subobject
              #{options[:subobject] || 'self'}
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
