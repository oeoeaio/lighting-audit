class CreateRooms < ActiveRecord::Migration
  def change
    create_table :rooms do |t|
      t.references :house, index: true, null: false, foreign_key: true
      t.integer :number, null: false
      t.string :room_type, null: false
      t.boolean :indoors, null: false
      t.decimal :area, precision: 5, scale: 2, null: false
      t.decimal :height, precision: 5, scale: 2, null: false
      t.boolean :lighting_rennovation, default: false
      t.boolean :lighting_major_change, default: false
      t.text :notes

      t.timestamps null: false
    end
  end
end
