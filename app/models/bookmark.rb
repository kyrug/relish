class Bookmark < ActiveRecord::Base
  # Associations / Relationships
  belongs_to :user
end
