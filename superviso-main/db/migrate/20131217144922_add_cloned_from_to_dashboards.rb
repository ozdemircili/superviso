class AddClonedFromToDashboards < ActiveRecord::Migration
  def change
    add_reference :dashboards, :cloned_from, index: true
  end
end
