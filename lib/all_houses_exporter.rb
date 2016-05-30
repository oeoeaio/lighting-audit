class AllHousesExporter
  attr_accessor :room_types, :csv

  def initialize(opts={})
    @room_types = room_type_options[opts[:room_type]]
  end

  def go!
    @csv = CSV.generate do |csv|
      csv << header_line1
      csv << header_line2
      House.order(name: :asc).each do |house|
        line = headline_for(house)
        line += by_tech_for(house, lambda { |lights| lights.count })
        line += [scoped_rooms_for(house).sum(:missing_light_count)]
        line += by_tech_for(house, lambda { |lights| lights.sum(:wattage) })
        line += by_tech_for(house, lambda { |lights| lights.sum(:lumens) })
        line += by_tech_for(house, lambda { |lights| lights.sum(:usage) } )
        line += by_tech_for(house, lambda { |lights| lights.map{ |l| l.wattage * l.usage }.sum } )
        line += by_tech_for(house, lambda { |lights| lights.map{ |l| l.efficacy * l.usage }.sum } )
        line += by_tech_for(house, lambda { |lights| lights.map{ |l| l.lumens * l.usage }.sum } )
        line += by_tech_for(house, lambda { |lights| lights.dimmer.count } )
        line += dimmer_counts_by_tech_for(house)
        csv << line
      end
    end
  end

  def headline_for(house)
    floor_area = scoped_rooms_for(house).sum(:area)
    room_count = scoped_rooms_for(house).count.to_f
    switch_count = scoped_switches_for(house).count.to_f
    light_count = scoped_lights_for(house).count.to_f
    total_watts = scoped_lights_for(house).sum(:wattage)
    fixed_watts = scoped_lights_for(house).fixed.sum(:wattage)
    plug_watts = scoped_lights_for(house).plug.sum(:wattage)
    total_lumens = scoped_lights_for(house).sum(:lumens)
    fixed_lumens = scoped_lights_for(house).fixed.sum(:lumens)
    plug_lumens = scoped_lights_for(house).plug.sum(:lumens)

    line = []
    line << house.name
    line << house.house_type
    line << floor_area
    line << room_count
    line << switch_count
    line << light_count
    line << (light_count / floor_area).round(2)
    line << (light_count / room_count).round(2)
    line << total_watts
    line << fixed_watts
    line << plug_watts
    line << (total_watts / floor_area).round(2)
    line << (fixed_watts / floor_area).round(2)
    line << (plug_watts / floor_area).round(2)
    line << total_lumens
    line << fixed_lumens
    line << plug_lumens
    line << (total_lumens / floor_area).round(2)
    line << (fixed_lumens / floor_area).round(2)
    line << (plug_lumens / floor_area).round(2)
    line << scoped_lights_for(house).sum(:usage)
    line << scoped_lights_for(house).map{ |l| l.wattage * l.usage }.sum
    line << scoped_lights_for(house).map{ |l| l.efficacy * l.usage }.sum
    line << scoped_lights_for(house).map{ |l| l.lumens * l.usage }.sum
    line << scoped_lights_for(house).dimmer.count
    line << scoped_lights_for(house).dimmer.map(&:switch).uniq.count
    line

  end

  def by_tech_for(house, callback)
    Light::TECHNOLOGIES.map do |technology|
      lights = scoped_lights_for(house).where(technology: technology)
      next "NULL" if lights.empty?
      callback.call(scoped_lights_for(house).where(technology: technology))
    end
  end

  def dimmer_counts_by_tech_for(house)
    dimmer_counts_by_tech = Light::TECHNOLOGIES.each_with_object({}) { |tech, dimmer_counts| dimmer_counts[tech] = 0 }
    dimmer_counts_by_tech["Mixed"] = 0

    scoped_switches_for(house).each do |switch|
      light_grouping = switch.lights.dimmer.group(:technology).count
      if light_grouping.keys.count == 1
        dimmer_counts_by_tech[light_grouping.keys.first] += 1
      elsif light_grouping.keys.count > 1
        dimmer_counts_by_tech["Mixed"] += 1
      end
    end

    dimmer_counts_by_tech.values
  end

  def scoped_lights_for(house)
    house.lights.where(room: scoped_rooms_for(house))
  end

  def scoped_switches_for(house)
    house.switches.where(room: scoped_rooms_for(house))
  end

  def scoped_rooms_for(house)
    house.rooms.where(room_type: room_types)
  end

  def room_type_options
    {
      "all" => ["Bathroom", "Bedroom", "Dining", "Foyer-inside", "Hallway", "Kitchen (open plan)", "Kitchen (separate)", "Kitchen/Living", "Laundry", "Living-other", "Lounge", "Media-room", "Other-inside", "Pantry", "Stairwell", "Storage-Room", "Study", "Toilet", "Walk-in-Robe", "Garage", "Outside-general", "Outside-other", "Verandah"],
      "living" => ["Dining", "Kitchen (open plan)", "Kitchen (separate)", "Kitchen/Living", "Living-other", "Lounge", "Media-room", "Pantry"],
      "sleeping" => ["Bathroom", "Study"],
      "indoor-other" => ["Bathroom", "Foyer-inside", "Hallway", "Laundry", "Other-inside", "Stairwell", "Storage-Room", "Toilet", "Walk-in-Robe"],
      "outdoor" => ["Garage", "Outside-general", "Outside-other", "Verandah"]
    }
  end

  def header_line1
    26.times.map { "" } +
    Light::TECHNOLOGIES +
    ["Missing"] +
    Light::TECHNOLOGIES +
    Light::TECHNOLOGIES +
    Light::TECHNOLOGIES +
    Light::TECHNOLOGIES +
    Light::TECHNOLOGIES +
    Light::TECHNOLOGIES +
    Light::TECHNOLOGIES +
    Light::TECHNOLOGIES +
    ["Mixed"]
  end

  def header_line2
    ["House ID", "HH Type", "Floor Area", "No. Rooms", "No. Switches", "No. Lights", "Lights/sqm", "Lights/Room",
    "Total Watts", "W Fixed", "W Plug", "W/sqm", "W/sqm Fixed", "W/sqm Plug", "Total Lumens", "L Fixed", "L Plug",
    "L/sqm", "L/sqm Fixed", "L/sqm Plug", "h/day", "Wh/day", "eff h/day", "Lh/day", "No. Dim Lamps", "No. Dim Switches"] +
    Light::TECHNOLOGIES.count.times.map { "Count" } +
    ["Count"] +
    Light::TECHNOLOGIES.count.times.map { "Watts" } +
    Light::TECHNOLOGIES.count.times.map { "Lumens" } +
    Light::TECHNOLOGIES.count.times.map { "h/day" } +
    Light::TECHNOLOGIES.count.times.map { "Wh/day" } +
    Light::TECHNOLOGIES.count.times.map { "eff h/day" } +
    Light::TECHNOLOGIES.count.times.map { "Lh/day" } +
    Light::TECHNOLOGIES.count.times.map { "Dimmer Lamps" } +
    Light::TECHNOLOGIES.count.times.map { "Dimmer Switches" } +
    ["DimmerSwitches"]
  end
end
