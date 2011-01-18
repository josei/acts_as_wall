class Feed < ActiveRecord::Base
  include ActiveRecord::Acts::Wall::Feed
end