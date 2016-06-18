class AllLightsExporter
  attr_accessor :csv

  def go!
    @csv = CSV.generate do |csv|
      csv << headers
      lights = Light.joins(:house, :room, :switch).order('houses.name ASC, rooms.number ASC, switches.number ASC, lights.name ASC').select(select_string)
      lights.each { |light| csv << line_for(light) }
    end
  end

  private

  def headers
    ["House","Room","Room Type","Room Category","Switch"] + light_attrs.map(&:humanize) + ["Notes"]
  end

  def select_string
    list = ["houses.name as house_name","rooms.number as room_number","rooms.room_type as room_type","switches.number as switch_number"]
    light_attrs.each do |attr|
      list << "lights.#{attr}"
    end
    list << "lights.notes"
    list.join(",")
  end

  def report_attrs
    return @report_attrs unless @report_attrs.nil?
    list = ["house_name","room_number","room_type","room_category","switch_number"]
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
      if attr == "room_category"
        line << room_category_for(light["room_type"])
      else
        line << light[attr]
      end
    end
  end

  def room_category_for(room_type)
    Room::CATEGORIES.except("all").each do |room_category,room_types|
      return room_category.humanize if room_types.include? room_type
    end
  end
end
