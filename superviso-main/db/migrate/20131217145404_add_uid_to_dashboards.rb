class AddUidToDashboards < ActiveRecord::Migration
  def change
    add_column :dashboards, :uid, :string
  end
end
