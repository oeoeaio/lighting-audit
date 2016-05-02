class AddEfficacyFieldsToLights < ActiveRecord::Migration
  def change
    add_column :lights, :tech_mod, :string, null: false
    add_column :lights, :mains_reflector, :decimal, precision: 2, scale: 1, null: false
    add_column :lights, :row, :integer, null: false
    add_column :lights, :power_multiplier, :decimal, precision: 10, scale: 6, null: false
    add_column :lights, :power_add, :integer, null: false
    add_column :lights, :log_multiplier, :decimal, precision: 10, scale: 6, null: false
    add_column :lights, :log_add, :decimal, precision: 10, scale: 6, null: false
    add_column :lights, :power_adj, :decimal, precision: 10, scale: 6, null: false
    add_column :lights, :efficacy, :decimal, precision: 10, scale: 6, null: false
    add_column :lights, :lumens, :decimal, precision: 10, scale: 6, null: false
    add_column :lights, :lumens_round, :integer, null: false
  end
end
