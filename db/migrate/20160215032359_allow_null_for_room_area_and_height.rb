class AllowNullForRoomAreaAndHeight < ActiveRecord::Migration
  def change
    change_column :rooms, :area, :decimal, precision: 5, scale: 2, null: true
    change_column :rooms, :height, :decimal, precision: 5, scale: 2, null: true
  end
end
