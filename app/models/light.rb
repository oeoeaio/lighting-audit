class Light < ActiveRecord::Base
  belongs_to :house
  belongs_to :room
  belongs_to :switch

  validates :house, :room, :switch, :name, :connection_type, :fitting, :colour, :technology, :shape, :wattage, :wattage_source, :usage, presence: true
  validates :connection_type, inclusion: { in: ["F", "P"], message: "'%{value}' is not a valid connection type (must be 'F' or 'P')" }
  validates :fitting, inclusion: { in: ["Batton Holder", "Batton Holder with Shade", "Bedside Lamp", "Chandelier", "Desk Lamp", "Downlight/Flush Mounted", "Fan light", "Fixed Floor Light", "Floodlight/External Spotlight", "Floor/Standard Lamp", "Garden Light", "Heat Lamp", "Indoor Spotlight", "Linear batton/strip", "Nightlight", "Other", "Oyster", "Pool Light", "Rangehood", "Skylight-with-lamp", "Pendant", "Table Lamp", "Under bench", "Uplight", "Wall Light"], message: "'%{value}' is not a valid fitting type" }
  validates :colour, inclusion: { in: ["C", "W"], message: "'%{value}' is not a valid lamp colour (must be 'C' or 'W')" }
  validates :technology, inclusion: { in: ["Incandescent (tungsten)", "Halogen - mains voltage", "Halogen - low voltage", "CFL - integral ballast", "CFL - separate ballast", "Linear fluorescent", "Circular fluorescent", "LED directional", "LED non-directional", "Heat Lamp", "Other", "Cannot identify low eff", "Cannot identify high eff"], message: "'%{value}' is not a valid technology" }
  validate :shape_for_technology
  validate :cap_for_technology
  validate :transformer_for_technology
  validates :wattage, numericality: { greater_than: 0 }
  validates :wattage_source, inclusion: { in: ["Label", "Measurement", "Guess"], message: "must be one of 'Label', 'Measurement' or 'Guess'" }
  validates :usage, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 24 }

  private

  def shape_for_technology
    unless technology.blank? || allowed_values_for_technology[:shape].include?(shape)
      errors.add :shape, "'#{shape}' is not a valid shape when light technology is '#{technology}'"
    end
  end

  def cap_for_technology
    unless technology.blank? || allowed_values_for_technology[:cap].include?(cap)
      errors.add :cap, "'#{cap}' is not a valid cap when light technology is '#{technology}'"
    end
  end

  def transformer_for_technology
    unless technology.blank? || allowed_values_for_technology[:transformer].include?(transformer)
      errors.add :transformer, "'#{transformer}' is not a valid transformer when light technology is '#{technology}'"
    end
  end

  def allowed_values_for_technology
    case technology
    when "Incandescent (tungsten)"
      return {
        shape: ["A-shape frosted", "A-shape clear", "Fancy Round frosted", "Fancy Round clear", "Globe (sphere) frosted", "Globe (sphere) clear", "Candle frosted", "Candle clear", "Pilot", "Reflector - R", "Reflector - PAR", "Filament", "Other", "Cannot identify"],
        cap: ["E14", "E27", "B15", "B22", "GU10", "Other", "Cannot identify"],
        transformer: ["N/A"]
      }
    when "Halogen - mains voltage"
      return {
        shape: ["A-shape frosted", "A-shape clear", "Fancy Round frosted", "Fancy Round clear", "Globe (sphere) frosted", "Globe (sphere) clear", "Candle frosted", "Candle clear", "Pilot", "Capsule", "Reflector - R", "Reflector - PAR", "Reflector - MR 50mm", "Double ended (lin halogen)", "Other", "Cannot identify"],
        cap: ["E14", "E27", "B15", "B22", "GU10", "R7", "Other", "Cannot identify"],
        transformer: ["N/A"]
      }
    when "Halogen - low voltage"
      return {
        shape: ["Capsule", "Reflector - MR 30mm", "Reflector - MR 50mm", "Double ended (lin halogen)", "Other", "Cannot identify"],
        cap: ["G4-5.3", "Cannot identify"],
        transformer: ["Magnetic", "Electronic", "Cannot identify"]
      }
    when "CFL - integral ballast"
      return {
        shape: ["A-shape frosted", "Fancy Round frosted", "Globe (sphere) frosted", "Globe (sphere) clear", "Candle frosted", "Candle clear", "Reflector - R", "Reflector - PAR", "Reflector - MR 50mm", "CFL bare stick", "CFL bare spiral", "Other", "Cannot identify"],
        cap: ["E14", "E27", "B15", "B22", "GU10", "Other", "Cannot identify"],
        transformer: ["N/A"]
      }
    when "CFL - separate ballast"
      return {
        shape: ["CFL bare stick/ U shape"],
        cap: ["N/A"],
        transformer: ["Magnetic", "Electronic", "Cannot identify"]
      }
    when "Linear fluorescent"
      return {
        shape: ["Linear tube"],
        cap: ["N/A"],
        transformer: ["Magnetic", "Electronic", "Cannot identify"]
      }
    when "Circular fluorescent"
      return {
        shape: ["Circular tube"],
        cap: ["N/A"],
        transformer: ["Magnetic", "Electronic", "Cannot identify"]
      }
    when "LED directional"
      return {
        shape: ["Reflector - R", "Reflector - PAR", "Reflector - MR 50mm", "Reflector - MR 30mm", "Integrated light", "Other", "Cannot indentify"],
        cap: ["GU10", "G4-5.3", "Other", "No cap", "Cannot identify", "N/A"],
        transformer: ["Magnetic (12V)", "Electronic (12V)", "Cannot identify", "N/A (240V)"]
      }
    when "LED non-directional"
      return {
        shape: ["A-shape frosted", "A-shape clear", "Fancy Round frosted", "Fancy Round clear", "Globe (sphere) frosted", "Globe (sphere) clear", "Candle frosted", "Candle clear", "Pilot", "Capsule", "Double ended (repl lin halogen)", "Bare stick repl CFL", "Linear tube (repl flouro)", "Circular tube (repl fluoro)", "LED strip light", "Filament (LED replacement)", "Other", "Cannot identify"],
        cap: ["E14", "E27", "B15", "B22", "R7", "Other", "No cap", "Cannot identify", "N/A"],
        transformer: ["Magnetic (12V)", "Electronic (12V)", "Cannot identify", "N/A (240V)"]
      }
    when "Heat Lamp"
      return {
        shape: ["Reflector - R", "Reflector - PAR"],
        cap: ["N/A"],
        transformer: ["N/A"]
      }
    else
      return {
        shape: ["N/A"],
        cap: ["N/A"],
        transformer: ["N/A"]
      }
    end
  end
end
