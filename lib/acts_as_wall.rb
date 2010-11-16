module ActiveRecord #:nodoc:
  module Acts #:nodoc:
    module Wall
      def self.included(base) # :nodoc:
        base.extend ClassMethods
      end

      module ClassMethods
        def acts_as_wall(options = {}, &block)
          send :include, ActiveRecord::Acts::Wall::InstanceMethods

          self.module_eval <<-EOS
            def wall_private
              #{options[:private] || 'false'}
            end
          EOS

          has_one :wall, :as=>:wallable, :dependent=>:destroy
          before_create :create_wall
        end
      end

      module InstanceMethods
        protected
        def create_wall
          self.wall = Wall.new :wallable=>self, :private=>wall_private
        end
      end
    end
  end
end

ActiveRecord::Base.send :include, ActiveRecord::Acts::Wall
