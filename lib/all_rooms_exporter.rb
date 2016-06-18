class AllRoomsExporter
  attr_accessor :csv

  def go!
    @csv = CSV.generate do |csv|
      csv << headers
      rooms = Room.joins(:house)
      .joins('LEFT OUTER JOIN switches ON switches.room_id = rooms.id')
      .joins('LEFT OUTER JOIN lights ON lights.room_id = rooms.id')
      .order('houses.name ASC, rooms.number ASC').select(select_string).group('rooms.id, houses.name')
      rooms.each { |rooms| csv << line_for(rooms) }
    end
  end

  private

  def headers
    ["House","Room","Room Type","Room Category","Indoors?","Area","Height","Switch Count","Light Count","Missing","Notes"]
  end

  def select_string
    list = ["houses.name as house_name","rooms.number","rooms.room_type"]
    list += ["rooms.indoors","rooms.area","rooms.height"]
    list += ["COUNT(DISTINCT switches.id) as switch_count","COUNT(DISTINCT lights.id) as light_count"]
    list += ["rooms.missing_light_count","rooms.notes"]
    list.join(",")
  end

  def report_attrs
    return @report_attrs unless @report_attrs.nil?
    list = ["house_name","number","room_type","category"]
    list += ["indoors","area","height"]
    list += ["switch_count","light_count","missing_light_count","notes"]
    @report_attrs = list
  end

  def line_for(room)
    report_attrs.each_with_object([]) do |attr, line|
      if attr == "category"
        line << room_category_for(room["room_type"])
      else
        line << room[attr]
      end
    end
  end

  def room_category_for(room_type)
    Room::CATEGORIES.except("all").each do |room_category,room_types|
      return room_category.humanize if room_types.include? room_type
    end
  end
end
