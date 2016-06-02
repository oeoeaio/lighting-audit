require 'all_houses_exporter'
require 'cap_count_exporter'

class ExportsController < ApplicationController

  def index
    room_types = ["all", "living", "sleeping", "indoor-other", "outdoor"]
    @room_types = room_types.each_with_object({}) { |k, room_types| room_types[k.humanize] = k }
  end

  def all_houses
    room_type = params[:room_type] || "all"
    exporter = AllHousesExporter.new(room_type: params[:exports][:room_type])
    exporter.go!
    send_data exporter.csv, type: 'text/csv', filename: "#{params[:exports][:room_type]}.csv"
  end

  def cap_count
    exporter = CapCountExporter.new
    exporter.go!
    send_data exporter.csv, type: 'text/csv', filename: "cap_counts_by_tech.csv"
  end
end
