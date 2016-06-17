class AllHousesExporter
  attr_accessor :room_types, :csv

  def initialize(opts={})
    @room_types = Room::CATEGORIES[opts[:room_type]]
  end

  def go!
    @csv = CSV.generate do |csv|
      csv << header_line1
      csv << header_line2
      House.order(name: :asc).each do |house|
        line = headline_for(house)
        line += by_tech_for(house, lambda { |lights| lights.count }, 0)
        line += [scoped_rooms_for(house).sum(:missing_light_count)]
        line += by_tech_for(house, lambda { |lights| lights.sum(:power_adj) })
        line += by_tech_for(house, lambda { |lights| lights.sum(:lumens) })
        line += by_tech_for(house, lambda { |lights| lights.sum(:usage) } )
        line += by_tech_for(house, lambda { |lights| lights.map{ |l| l.power_adj * l.usage }.sum } )
        line += by_tech_for(house, lambda { |lights| lights.map{ |l| l.overall_efficacy * l.usage }.sum } )
        line += by_tech_for(house, lambda { |lights| lights.map{ |l| l.lumens * l.usage }.sum } )
        line += by_tech_for(house, lambda { |lights| lights.dimmer.count }, 0 )
        line += dimmer_counts_by_tech_for(house)
        line += switch_counts_by_tech_for(house)
        line += headline2_for(house)
        line += by_tech_for(house, lambda { |lights| lights.fixed.count }, 0 )
        line += by_tech_for(house, lambda { |lights| lights.plug.count }, 0 )
        csv << line
      end
    end
  end

  def headline_for(house)
    total_floor_area = scoped_rooms_for(house).sum(:area)
    indoor_floor_area = scoped_rooms_for(house).indoor.sum(:area)
    total_room_count = scoped_rooms_for(house).count.to_f
    indoor_room_count = scoped_rooms_for(house).indoor.count.to_f
    switch_count = scoped_switches_for(house).count.to_f
    total_light_count = scoped_lights_for(house).count.to_f
    indoor_light_count = scoped_lights_for(house).indoor.count.to_f
    outdoor_light_count = scoped_lights_for(house).outdoor.count.to_f
    total_watts = scoped_lights_for(house).sum(:power_adj)
    fixed_watts = scoped_lights_for(house).fixed.sum(:power_adj)
    plug_watts = scoped_lights_for(house).plug.sum(:power_adj)
    indoor_total_watts = scoped_lights_for(house).indoor.sum(:power_adj)
    indoor_fixed_watts = scoped_lights_for(house).indoor.fixed.sum(:power_adj)
    indoor_plug_watts = scoped_lights_for(house).indoor.plug.sum(:power_adj)
    total_lumens = scoped_lights_for(house).sum(:lumens)
    fixed_lumens = scoped_lights_for(house).fixed.sum(:lumens)
    plug_lumens = scoped_lights_for(house).plug.sum(:lumens)
    indoor_total_lumens = scoped_lights_for(house).indoor.sum(:lumens)
    indoor_fixed_lumens = scoped_lights_for(house).indoor.fixed.sum(:lumens)
    indoor_plug_lumens = scoped_lights_for(house).indoor.plug.sum(:lumens)

    line = []
    line << house.name
    line << house.house_type
    line << total_floor_area
    line << indoor_floor_area
    line << total_room_count
    line << indoor_room_count
    line << switch_count
    line << total_light_count
    line << indoor_light_count
    line << outdoor_light_count
    line << (indoor_light_count / indoor_floor_area).round(2)
    line << (indoor_light_count / indoor_room_count).round(2)
    line << total_watts
    line << fixed_watts
    line << plug_watts
    line << (indoor_total_watts / indoor_floor_area).round(2)
    line << (indoor_fixed_watts / indoor_floor_area).round(2)
    line << (indoor_plug_watts / indoor_floor_area).round(2)
    line << total_lumens
    line << fixed_lumens
    line << plug_lumens
    line << (indoor_total_lumens / indoor_floor_area).round(2)
    line << (indoor_fixed_lumens / indoor_floor_area).round(2)
    line << (indoor_plug_lumens / indoor_floor_area).round(2)
    line << scoped_lights_for(house).sum(:usage)
    line << scoped_lights_for(house).map{ |l| l.power_adj * l.usage }.sum
    line << scoped_lights_for(house).map{ |l| l.overall_efficacy * l.usage }.sum
    line << scoped_lights_for(house).map{ |l| l.lumens * l.usage }.sum
    line << scoped_lights_for(house).dimmer.count
    line << scoped_lights_for(house).dimmer.map(&:switch).uniq.count
    line
  end

  def headline2_for(house)
    line = []
    line << scoped_lights_for(house).motion.count
    line << scoped_lights_for(house).motion.map(&:switch).uniq.count
    line << scoped_lights_for(house).fixed.count.to_f
    line << scoped_lights_for(house).plug.count.to_f
    line
  end

  def by_tech_for(house, callback, val_if_empty="NULL")
    Light::TECHNOLOGIES.map do |technology|
      lights = scoped_lights_for(house).where(tech_mod: technology)
      next val_if_empty if lights.empty?
      callback.call(scoped_lights_for(house).where(tech_mod: technology))
    end
  end

  def dimmer_counts_by_tech_for(house)
    dimmer_counts_by_tech = Light::TECHNOLOGIES.each_with_object({}) { |tech, dimmer_counts| dimmer_counts[tech] = 0 }
    dimmer_counts_by_tech["Mixed"] = 0

    scoped_switches_for(house).each do |switch|
      light_grouping = switch.lights.dimmer.group(:tech_mod).count
      if light_grouping.keys.count == 1
        dimmer_counts_by_tech[light_grouping.keys.first] += 1
      elsif light_grouping.keys.count > 1
        dimmer_counts_by_tech["Mixed"] += 1
      end
    end

    dimmer_counts_by_tech.values
  end

  def switch_counts_by_tech_for(house)
    switch_counts_by_tech = Light::TECHNOLOGIES.each_with_object({}) { |tech, switch_counts| switch_counts[tech] = 0 }
    switch_counts_by_tech["Mixed"] = 0

    scoped_switches_for(house).each do |switch|
      light_grouping = switch.lights.group(:tech_mod).count
      if light_grouping.keys.count == 1
        switch_counts_by_tech[light_grouping.keys.first] += 1
      elsif light_grouping.keys.count > 1
        switch_counts_by_tech["Mixed"] += 1
      end
    end

    switch_counts_by_tech.values
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

  def header_line1
    ["", "", "Total", "Indoor", "Total", "Indoor", "Total", "Total",
      "Indoor", "Outdoor", "Indoor", "Indoor", "Total", "Total", "Total",
      "Indoor", "Indoor", "Indoor", "Total", "Total", "Total", "Indoor", "Indoor", "Indoor",
      "", "", "", "", "", ""] +
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
    ["Mixed"] +
    Light::TECHNOLOGIES +
    ["Mixed"] +
    ["Total", "Total", "Total", "Total"] +
    Light::TECHNOLOGIES +
    Light::TECHNOLOGIES
  end

  def header_line2
    ["House ID", "HH Type", "Floor Area", "Floor Area", "Room Count", "Room Count", "Switch Count", "Lights Count",
      "Lights Count", "Lights Count", "Lights/sqm", "Lights/Room", "Watts", "W Fixed", "W Plug",
      "W/sqm", "W/sqm Fixed", "W/sqm Plug", "Lumens", "L Fixed", "L Plug", "L/sqm", "L/sqm Fixed", "L/sqm Plug",
      "h/day", "Wh/day", "eff h/day", "Lh/day", "Dimmer Lamp Count", "Dimmer Switch Count"] +
    Light::TECHNOLOGIES.count.times.map { "Lamp Count" } +
    ["Count"] +
    Light::TECHNOLOGIES.count.times.map { "Watts" } +
    Light::TECHNOLOGIES.count.times.map { "Lumens" } +
    Light::TECHNOLOGIES.count.times.map { "h/day" } +
    Light::TECHNOLOGIES.count.times.map { "Wh/day" } +
    Light::TECHNOLOGIES.count.times.map { "eff h/day" } +
    Light::TECHNOLOGIES.count.times.map { "Lh/day" } +
    Light::TECHNOLOGIES.count.times.map { "Dimmer Lamp Count" } +
    Light::TECHNOLOGIES.count.times.map { "Dimmer Switch Count" } +
    ["Dimmer Switch Count"] +
    Light::TECHNOLOGIES.count.times.map { "Switch Count" } +
    ["Switch Count"] +
    ["Motion Lamp Count", "Motion Switch Count"] +
    ["Fixed Count", "Plug Count"] +
    Light::TECHNOLOGIES.count.times.map { "Fixed Count" } +
    Light::TECHNOLOGIES.count.times.map { "Plug Count" }
  end
end
