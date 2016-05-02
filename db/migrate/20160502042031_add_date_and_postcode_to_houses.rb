class AddDateAndPostcodeToHouses < ActiveRecord::Migration
  def change
    add_column :houses, :audit_date, :date, null: false
    add_column :houses, :postcode, :string, null: false
  end
end
