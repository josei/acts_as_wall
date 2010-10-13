class Event < ActiveRecord::Base
  include ActiveRecord::Acts::Wall::Event
end
