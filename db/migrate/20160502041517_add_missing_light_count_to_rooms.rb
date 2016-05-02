class AddMissingLightCountToRooms < ActiveRecord::Migration
  def change
    add_column :rooms, :missing_light_count, :integer, default: 0
  end
end
