class IncreaseScaleOfUsageAndWattage < ActiveRecord::Migration
  def change
    change_column :lights, :wattage, :decimal, precision: 10, scale: 6, null: false
    change_column :lights, :usage, :decimal, precision: 5, scale: 3, null: false
  end
end
