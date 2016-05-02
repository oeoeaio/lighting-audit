class RemoveLightingFieldsFromRooms < ActiveRecord::Migration
  def up
    remove_column :rooms, :lighting_rennovation
    remove_column :rooms, :lighting_major_change
  end
end
