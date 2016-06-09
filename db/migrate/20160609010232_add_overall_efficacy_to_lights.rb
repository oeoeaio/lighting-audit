class AddOverallEfficacyToLights < ActiveRecord::Migration
  def change
    add_column :lights, :overall_efficacy, :decimal, precision: 10, scale: 6
  end
end
