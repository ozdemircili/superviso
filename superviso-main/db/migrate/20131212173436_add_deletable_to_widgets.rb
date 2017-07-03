class AddDeletableToWidgets < ActiveRecord::Migration
  def change
    add_column :widgets, :deletable, :bool, default: true
  end
end
