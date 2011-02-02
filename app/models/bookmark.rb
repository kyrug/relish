class Bookmark < ActiveRecord::Base
  # Associations / Relationships
  acts_as_taggable
  belongs_to :user
end
