module Responders
  module WallResponder
    def initialize(controller, resources, options={})
      super
      @event = options[:event].nil? ? true : options[:event]
    end

    def to_html
      super
      return unless @event
      return unless controller.respond_to? :announce_options
      return if get? or controller.current_user.nil? or has_errors?

      controller.fire_event resource
    end
  end
end
