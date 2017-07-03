class AddRoleToWidgets < ActiveRecord::Migration
  def change
    add_column :widgets, :role, :string
  end
end
