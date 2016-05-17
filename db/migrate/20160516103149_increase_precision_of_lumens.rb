class IncreasePrecisionOfLumens < ActiveRecord::Migration
  def change
    change_column :lights, :lumens, :decimal, precision: 11, scale: 6, null: false
  end
end
