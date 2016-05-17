class AddUniqueIndicesToHouseNameAndAuditFile < ActiveRecord::Migration
  def change
    add_index :houses, :name, :unique => true
    add_index :houses, :audit_file, :unique => true
  end
end
