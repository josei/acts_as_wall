class Notification < ActiveRecord::Base
  include ActiveRecord::Acts::Wall::Notification
end
