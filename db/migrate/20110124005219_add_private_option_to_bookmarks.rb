class AddPrivateOptionToBookmarks < ActiveRecord::Migration
  def self.up
    add_column :bookmarks, :private, :integer, :default => 0
  end

  def self.down
    remove_column :bookmarks, :private
  end
end
