class AllLightsExporter
  attr_accessor :csv

  def go!
    @csv = CSV.generate do |csv|
      csv << headers
      lights = Light.joins(:house, :room, :switch).order('houses.name ASC, rooms.number ASC, switches.number ASC').select(select_string)
      lights.each { |light| csv << line_for(light) }
    end
  end

  private

  def headers
    ["House","Room","Switch"] + light_attrs.map(&:humanize) + ["Notes"]
  end

  def select_string
    list = ["houses.name as house_name","rooms.number as room_number","switches.number as switch_number"]
    light_attrs.each do |attr|
      list << "lights.#{attr}"
    end
    list << "lights.notes"
    list.join(",")
  end

  def report_attrs
    return @report_attrs unless @report_attrs.nil?
    list = ["house_name","room_number","switch_number"]
    light_attrs.each_with_object(list) do |attr, list|
      list << attr
    end
    list << "notes"
    @report_attrs = list
  end

  def light_attrs
    Light.attribute_names - ["id","house_id","room_id","switch_id","updated_at","created_at","notes"]
  end


  def line_for(light)
    report_attrs.each_with_object([]) do |attr, line|
      line << light[attr]
    end
  end
    # line = []
    # line << light.house.name
    # line << light.room.number
    # line << light.switch.number
    # line << name: string
    # line << connection_type.to_s
    # line << dimmer? ? "Yes" : "No"
    # line << motion: boolean, fitting: string, colour: string, technology: string, shape: string, cap: string, transformer: string, wattage: decimal, wattage_source: string, usage: decimal, notes: text, created_at: datetime, updated_at: datetime, tech_mod: string, mains_reflector: decimal, row: integer, power_multiplier: decimal, power_add: integer, log_multiplier: decimal, log_add: decimal, power_adj: decimal, efficacy: decimal, lumens: decimal, lumens_round: integer, overall_efficacy: decimal
    # light_attrs.each do |attr|
    #   line << light[attr]
    # end
    # line
end
