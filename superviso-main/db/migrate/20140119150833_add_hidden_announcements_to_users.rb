class AddHiddenAnnouncementsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :hidden_announcements, :string
  end
end
