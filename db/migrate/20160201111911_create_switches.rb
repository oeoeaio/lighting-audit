class CreateSwitches < ActiveRecord::Migration
  def change
    create_table :switches do |t|
      t.references :house, index: true, null: false, foreign_key: true
      t.references :room, index: true, null: false, foreign_key: true
      t.string :number, index: true, null: false

      t.timestamps null: false
    end
  end
end
