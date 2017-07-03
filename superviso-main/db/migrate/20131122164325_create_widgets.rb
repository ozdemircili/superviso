class CreateWidgets < ActiveRecord::Migration
  def change
    create_table :widgets do |t|
      t.references :dashboard, index: true
      t.string :name
      t.string :secret_token

      t.timestamps
    end
  end
end
