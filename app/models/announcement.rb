class Announcement < ActiveRecord::Base
  include ActiveRecord::Acts::Wall::Announcement
end
