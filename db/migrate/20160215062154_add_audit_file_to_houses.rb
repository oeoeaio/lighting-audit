class AddAuditFileToHouses < ActiveRecord::Migration
  def change
    add_column :houses, :audit_file, :string, null: false
  end
end
