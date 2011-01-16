class CacheBookmarkTagList < ActiveRecord::Migration
  def self.up
    add_column :bookmarks, :cached_tag_list, :string
  end

  def self.down
    remove_column :bookmarks, :cached_tag_list
  end
end
