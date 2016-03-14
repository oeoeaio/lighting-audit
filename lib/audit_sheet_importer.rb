require 'roo'

class AuditSheetImporter
  attr_accessor :files, :issues, :file_issues

  def initialize(opts={})
    @issues = {}
    @file_issues = []
    opts.select{ |k,o| [:files].include? k }.each do |key, option|
      instance_variable_set("@#{key}", option)
    end
  end

  def go!
    begin
      ActiveRecord::Base.transaction do
        files.each do |file|
          original_filename = file.original_filename
          house_file = Roo::Excelx.new(file.path)

          begin
            raise HouseExistsException.new(original_filename) if House.find_by_audit_file(original_filename)
            house = create_house_for(house_file, original_filename)
            rooms = create_rooms_for(house_file, house)
            lights = create_lights_for(house_file, house)
          rescue HouseExistsException => hie
            @file_issues << hie.file_name
          end
        end
      end
    rescue ActiveRecord::RecordInvalid => e
      case e.record
      when House
        @issues[e.record.audit_file] ||= {}
        @issues[e.record.audit_file][:house] ||= []
        message = "Room #{e.record.name}: #{e.record.errors.full_messages.join(', ')}"
        @issues[e.record.audit_file][:house] << message
      when Room
        @issues[e.record.house.audit_file] ||= {}
        @issues[e.record.house.audit_file][:rooms] ||= []
        message = "Room #{e.record.number}: #{e.record.errors.full_messages.join(', ')}"
        @issues[e.record.house.audit_file][:rooms] << message
      when Switch
        @issues[e.record.house.audit_file] ||= {}
        @issues[e.record.house.audit_file][:switches] ||= []
        message = "Switch #{e.record.number}: #{e.record.errors.full_messages.join(', ')}"
        @issues[e.record.house.audit_file][:switches] << message
      when Light
        @issues[e.record.house.audit_file] ||= {}
        @issues[e.record.house.audit_file][:lights] ||= []
        message = "Light #{e.record.name}: #{e.record.errors.full_messages.join(', ')}"
        @issues[e.record.house.audit_file][:lights] << message
      end
    end
  end

  private

  def create_house_for(file, original_filename)
    sheet = file.sheet('Room')
    name = sheet.cell('B',3)
    auditor = sheet.cell('B',4)
    house_type = sheet.cell('F',3)
    storey_count = sheet.cell('F',4)
    raise HouseExistsException.new(original_filename) if House.find_by_name(name)
    House.create!(name: name, audit_file: original_filename, auditor: auditor, house_type: house_type, storey_count: storey_count)
  end

  def create_rooms_for(file, house)
    sheet = file.sheet('Room')
    room_attrs = sheet.parse(number: 'Room ID', room_type: 'Room Type', indoors: 'In/Out', area: 'Area', height: 'Height', notes: 'Notes')
    room_attrs.delete_at(0) # Remove header row
    room_attrs.keep_if { |r| r[:room_type].present? }

    rooms = []
    # Fixing up data
    room_attrs.each do |attrs|
      attrs[:indoors] = attrs[:indoors] == "Indoor"
      attrs[:house] = house
      attrs[:number] = attrs[:number].to_int
      rooms << Room.create!(attrs)
    end

    rooms
  end

  def create_lights_for(file, house)
    sheet = file.sheet('Light')

    light_attrs = sheet.parse({
      house: 'House ID', name: 'Light', room: 'Room ID', room_type: 'Room Type', area: 'Area', height: 'height', switch: 'Switch', same: "Same ",
      connection_type: 'Conn Type', dimmer: 'Dimmer', motion: 'Motion', fitting: 'Fitting', colour: ' Colour',
      technology: 'Lamp Tech', shape: 'Lamp Shape', cap: 'Lamp Cap', transformer: 'Transf/ballast',
      wattage: 'W power', wattage_source: 'W source', usage: 'USAGE', notes: 'Comments and notes'
    })

    light_attrs.delete_at(0) # Remove header row
    light_attrs.keep_if { |r| r[:house].present? }
    ignored_attributes = [:room_type, :area, :height, :same]

    lights = []
    light_attrs.each do |attrs|
      attrs.delete_if{ |k,v| k.in? ignored_attributes }
      attrs[:house] = house
      attrs[:room] = house.reload.rooms.find_by_number(attrs[:room].to_int)
      attrs[:switch] = Switch.find_or_create_by(house: attrs[:house], room: attrs[:room], number: attrs[:switch].to_int)
      attrs[:dimmer] = attrs[:dimmer].in? truthy_values
      attrs[:motion] = attrs[:motion].in? truthy_values
      attrs[:wattage_source] = wattage_source_from(attrs[:wattage_source])
      attrs[:cap] ||= default_cap_for(attrs[:technology])
      attrs[:transformer] ||= default_transformer_for(attrs[:technology])
      lights << Light.create!(attrs)
    end

    lights
  end


  def wattage_source_from(wattage_source)
    return 'Label' if wattage_source.blank?
    case wattage_source
    when 'L'
      'Label'
    when 'M'
      'Measurement'
    when 'G'
      'Guess'
    end
  end

  def default_cap_for(technology)
    if technology.in? ["Incandescent (tungsten)", "Halogen - mains voltage", "Halogen - low voltage", "CFL - integral ballast", "LED directional", "LED non-directional"]
      "Cannot identify"
    else
      "N/A"
    end
  end

  def default_transformer_for(technology)
    if technology.in? ["Halogen - low voltage", "CFL - separate ballast", "Linear fluorescent", "Circular fluorescent", "LED directional", "LED non-directional"]
      "Cannot identify"
    else
      "N/A"
    end
  end

  def truthy_values
    ['Y', 'y', 'T', 't', 'True', 'TRUE', 'true']
  end
end

class HouseExistsException < StandardError
  attr_accessor :file_name

  def initialize(file_name)
    @file_name = file_name
  end
end
