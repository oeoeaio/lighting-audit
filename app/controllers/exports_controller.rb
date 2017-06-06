require 'all_houses_exporter'
require 'all_rooms_exporter'
require 'all_lights_exporter'
require 'cap_summary_by_tech_exporter'
require 'cap_summary_by_fitting_exporter'
require 'fitting_summary_by_tech_exporter'

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

  def all_rooms
    exporter = AllRoomsExporter.new
    exporter.go!
    send_data exporter.csv, type: 'text/csv', filename: "all_rooms.csv"
  end

  def all_lights
    exporter = AllLightsExporter.new
    exporter.go!
    send_data exporter.csv, type: 'text/csv', filename: "all_lights.csv"
  end

  def cap_summary_by_tech
    exporter = CapSummaryByTechExporter.new
    exporter.go!
    send_data exporter.csv, type: 'text/csv', filename: "cap_summary_by_tech.csv"
  end

  def cap_summary_by_fitting
    exporter = CapSummaryByFittingExporter.new
    exporter.go!
    send_data exporter.csv, type: 'text/csv', filename: "cap_summary_by_fitting.csv"
  end

  def fitting_summary_by_tech
    exporter = FittingSummaryByTechExporter.new
    exporter.go!
    send_data exporter.csv, type: 'text/csv', filename: "fitting_summary_by_tech.csv"
  end
end
