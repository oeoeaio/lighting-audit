require 'all_houses_exporter'

class ExportsController < ApplicationController

  def index
    room_types = ["all", "living", "sleeping", "indoor-other", "outdoor"]
    @room_types = room_types.each_with_object({}) { |k, room_types| room_types[k.humanize] = k }
  end

  def all_houses
    room_type = params[:room_type] | "all"
    exporter = AllHousesExporter.new(room_type: params[:exports][:room_type])
    exporter.go!
    send_data exporter.csv, type: 'text/csv', filename: "#{params[:exports][:room_type]}.csv"
  end
end
