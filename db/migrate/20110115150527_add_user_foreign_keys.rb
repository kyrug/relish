class AddUserForeignKeys < ActiveRecord::Migration
  def self.up
    add_column :bookmarks, :user_id, :integer
  end

  def self.down
    remove_column :bookmarks, :user_id
  end
end
