class CreateLights < ActiveRecord::Migration
  def change
    create_table :lights do |t|
      t.references :house, index: true, null: false, foreign_key: true
      t.references :room, index: true, null: false, foreign_key: true
      t.references :switch, index: true, null: false, foreign_key: true
      t.string :name, null: false
      t.string :connection_type, null: false
      t.boolean :dimmer, null: false, default: false
      t.boolean :motion, null: false, default: false
      t.string :fitting, null: false
      t.string :colour, null: false
      t.string :technology, null: false
      t.string :shape, null: false
      t.string :cap
      t.string :transformer
      t.decimal :wattage, precision: 5, scale: 2, null: false
      t.string :wattage_source, default: "label", null: false
      t.decimal :usage, precision: 4, scale: 1, null: false
      t.text :notes

      t.timestamps null: false
    end
  end
end
