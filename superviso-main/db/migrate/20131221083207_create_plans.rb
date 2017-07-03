class CreatePlans < ActiveRecord::Migration
  def change
    create_table :plans do |t|
      t.string :name
      t.text :description
      t.integer :dashboard_quota
      t.integer :widget_quota
      t.integer :update_rate

      t.timestamps
    end
  end
end
