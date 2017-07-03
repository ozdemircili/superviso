class AddBasePlanToPlans < ActiveRecord::Migration
  def change
    add_column :plans, :base_plan, :boolean
  end
end
