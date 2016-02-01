class CreateHouses < ActiveRecord::Migration
  def change
    create_table :houses do |t|
      t.string :name, null: false
      t.string :house_type, null: false
      t.integer :storey_count, null: false

      t.timestamps null: false
    end
  end
end
