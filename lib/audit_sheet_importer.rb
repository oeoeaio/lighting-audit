require 'roo'

class AuditSheetImporter
  attr_accessor :files, :issues

  def initialize(opts={})
    @issues = {}
    opts.select{ |k,o| [:files].include? k }.each do |key, option|
      instance_variable_set("@#{key}", option)
    end
  end

  def go!
    files.each do |file|
      ActiveRecord::Base.transaction do
        original_filename = file.original_filename
        house_file = Roo::Excelx.new(file.path)

        begin
          raise HouseExistsException.new("House already exists!") if House.find_by_audit_file(original_filename)
          house = create_house_for(house_file, original_filename)
          rooms = create_rooms_for(house_file, house)
          lights = create_lights_for(house_file, house)
        rescue HouseExistsException => hie
          @issues[original_filename] ||= {}
          @issues[original_filename][:house_exists] ||= []
          @issues[original_filename][:house_exists] << hie.message
        rescue LightCountException => lce
          @issues[original_filename] ||= {}
          @issues[original_filename][:light_count] ||= []
          @issues[original_filename][:light_count] << lce.message
          raise ActiveRecord::Rollback
        rescue ActiveRecord::RecordInvalid => e
          case e.record
          when House
            @issues[original_filename] ||= {}
            @issues[original_filename][:house] ||= []
            message = "House #{e.record.name}: #{e.record.errors.full_messages.join(', ')}"
            @issues[original_filename][:house] << message
          when Room
            @issues[original_filename] ||= {}
            @issues[original_filename][:rooms] ||= []
            message = "Room #{e.record.number}: #{e.record.errors.full_messages.join(', ')}"
            @issues[original_filename][:rooms] << message
          when Switch
            @issues[original_filename] ||= {}
            @issues[original_filename][:switches] ||= []
            message = "Switch #{e.record.number}: #{e.record.errors.full_messages.join(', ')}"
            @issues[original_filename][:switches] << message
          when Light
            @issues[original_filename] ||= {}
            @issues[original_filename][:lights] ||= []
            message = "Light #{e.record.name}: #{e.record.errors.full_messages.join(', ')}"
            @issues[original_filename][:lights] << message
          end
          raise ActiveRecord::Rollback
        end
      end
    end
  end

  private

  def create_house_for(file, original_filename)
    sheet = file.sheet('Room')
    name = sheet.cell('B',3)
    auditor = sheet.cell('B',4)
    audit_date = sheet.cell('B',5)
    postcode = sheet.cell('B',6)
    house_type = sheet.cell('F',3)
    storey_count = sheet.cell('F',4)
    raise HouseExistsException.new("House already exists!") if House.find_by_name(name)
    House.create!(name: name, audit_file: original_filename, auditor: auditor, house_type: house_type, storey_count: storey_count, audit_date: audit_date, postcode: postcode)
  end

  def create_rooms_for(file, house)
    room_attrs = file.sheet('Room').parse(number: 'Room ID', room_type: 'Room Type', indoors: 'In/Out', area: 'Area', height: 'Height', missing_light_count: 'by room', notes: 'Notes')
    room_attrs.delete_at(0) # Remove header row
    room_attrs.keep_if { |r| r[:room_type].present? }

    rooms = []
    # Fixing up data
    room_attrs.each do |attrs|
      attrs[:indoors] = (attrs[:indoors] == "Indoor")
      attrs[:house] = house
      attrs[:number] = attrs[:number].to_int
      rooms << Room.create!(attrs)
    end

    rooms
  end

  def create_lights_for(file, house)
    light_attrs = file.sheet('Light').parse(light_table_column_mappings)
    light_attrs.delete_at(0) # Remove header row
    light_attrs.keep_if { |row| row[:house].present? }

    efficacy_attrs = file.sheet('Efficacy').parse(efficacy_table_column_mappings)
    efficacy_attrs.delete_at(0) # Remove header row
    efficacy_attrs.keep_if { |row| row[:house].present? }

    unless efficacy_attrs.count == light_attrs.count
      raise LightCountException.new("Number of lights listed on efficacy and light tables do not match")
    end

    unless efficacy_attrs.map{ |ea| ea[:name]} == light_attrs.map{ |la| la[:name] }
      raise LightCountException.new("Light order on efficacy and light tables do not match")
    end

    lights = []
    light_attrs.each_with_index do |attrs, i|
      room = house.reload.rooms.find_by_number(attrs[:room].to_int)
      next room.increment(:missing_light_count) if attrs[:technology] == "No lamp"

      ef_attrs = efficacy_attrs[i]
      attrs[:house] = house
      attrs[:room] = room
      attrs[:switch] = Switch.find_or_create_by(house: attrs[:house], room: attrs[:room], number: attrs[:switch].to_int)
      attrs[:connection_type] = attrs[:connection_type].upcase
      attrs[:dimmer] = attrs[:dimmer].in? truthy_values
      attrs[:motion] = attrs[:motion].in? truthy_values
      attrs[:colour] = attrs[:colour].upcase
      attrs[:wattage_source] = wattage_source_from(attrs[:wattage_source])
      attrs[:cap] ||= default_cap_for(attrs[:technology])
      attrs[:transformer] ||= default_transformer_for(attrs[:technology])
      ef_attrs[:power_adj] = attrs[:wattage] if attrs[:wattage_source] == 'Measurement'
      lights << Light.create!(attrs.merge(ef_attrs.except(:house)))
    end

    lights
  end


  def wattage_source_from(wattage_source)
    return 'Label' if wattage_source.blank?
    case wattage_source
    when 'L', 'l'
      'Label'
    when 'M', 'm'
      'Measurement'
    when 'G', 'g'
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

  def light_table_column_mappings
    { house: 'House ID', name: 'Light', room: 'Room ID', switch: 'Switch', connection_type: 'Conn Type',
      dimmer: 'Dimmer', motion: 'Motion', fitting: 'Fitting', colour: ' Colour', technology: 'Lamp Tech',
      shape: 'Lamp Shape', cap: 'Lamp Cap', transformer: 'Transf/ballast', wattage: 'W power',
      wattage_source: 'W source', usage: 'USAGE', notes: 'Comments and notes' }
  end

  def efficacy_table_column_mappings
    { house: 'House ID', name: "Light", tech_mod: "Tech-mod", mains_reflector: "Reflector", row: 'Row',
      power_multiplier: "Multiplier", power_add: "Add", log_multiplier: "Log Multiplier", log_add: "log Adder",
      power_adj: "Power-adj", efficacy: "Efficacy", lumens: "Lumens", lumens_round: "Lumens-round" }
  end
end

class HouseExistsException < StandardError
end

class LightCountException < StandardError
end
