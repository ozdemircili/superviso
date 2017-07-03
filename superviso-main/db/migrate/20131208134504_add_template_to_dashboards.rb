class AddTemplateToDashboards < ActiveRecord::Migration
  def change
    add_column :dashboards, :template, :bool, default: false
  end
end
