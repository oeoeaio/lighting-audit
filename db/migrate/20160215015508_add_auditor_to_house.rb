class AddAuditorToHouse < ActiveRecord::Migration
  def change
    add_column :houses, :auditor, :string, null: false
  end
end
