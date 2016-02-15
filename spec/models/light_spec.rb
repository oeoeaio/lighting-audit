require 'rails_helper'

RSpec.describe Light, type: :model do
  let(:house) { House.create(name: "House3", auditor: "OD", house_type: "Detached house", storey_count: 4) }
  let(:room) { Room.create(house: house, number: "12", indoors: true, room_type: "Bedroom", area: "12.45", height: "2.34") }
  let(:switch) { Switch.create(house: house, room: room, number: "3") }
  let(:light) { Light.create(house: house, room: room, switch: switch, name: "L1", connection_type: "F", fitting: "Batton Holder", colour: "C", technology: "LED directional", shape: "Reflector - R", cap: "GU10", transformer: "N/A (240V)", wattage: "5", wattage_source: "Label", usage: "5") }

  describe "associations" do
    it "creates associations" do
      expect(light).to be_valid
      expect(light.switch).to eq switch
      expect(light.room).to eq room
      expect(light.house).to eq house
      expect(house.lights).to eq [light]
      expect(room.lights).to eq [light]
      expect(switch.lights).to eq [light]
    end
  end

  describe "validation" do
    let(:light_invalid1) { Light.create(house: nil, room: nil, switch: nil, name: nil, connection_type: nil, fitting: nil, colour: nil, technology: nil, shape: nil, wattage: nil, wattage_source: nil, usage: nil) }
    let(:light_invalid2) { Light.create(house: house, room: room, switch: switch, name: "L3", connection_type: "W", fitting: "Batton Haha", colour: "P", technology: "LED directional", shape: "A-shape frosted", cap: "E14", transformer: "N/A", wattage: "0", wattage_source: "Labal", usage: "25") }

    it "requires a connection_type to be either 'P' or 'F'" do
      expect(light_invalid1.errors[:connection_type]).to eq ["can't be blank", "'' is not a valid connection type (must be 'F' or 'P')"]
      expect(light_invalid2.errors[:connection_type]).to eq ["'W' is not a valid connection type (must be 'F' or 'P')"]
    end

    it "requires a known fitting type" do
      expect(light_invalid1.errors[:fitting]).to eq ["can't be blank", "'' is not a valid fitting type"]
      expect(light_invalid2.errors[:fitting]).to eq ["'Batton Haha' is not a valid fitting type"]
    end

    it "requires a colour to be either 'C' or 'W'" do
      expect(light_invalid1.errors[:colour]).to eq ["can't be blank", "'' is not a valid lamp colour (must be 'C' or 'W')"]
      expect(light_invalid2.errors[:colour]).to eq ["'P' is not a valid lamp colour (must be 'C' or 'W')"]
    end

    it "requires a known technology type" do
      expect(light_invalid1.errors[:technology]).to eq ["can't be blank", "'' is not a valid technology"]
      expect(light_invalid2.errors[:technology]).to eq []
    end

    it "requires a valid shape for a given technology type" do
      expect(light_invalid1.errors[:shape]).to eq ["can't be blank"]
      expect(light_invalid2.errors[:shape]).to eq ["'A-shape frosted' is not a valid shape when light technology is 'LED directional'"]
    end

    it "requires a valid cap for a given technology type" do
      expect(light_invalid1.errors[:cap]).to eq []
      expect(light_invalid2.errors[:cap]).to eq ["'E14' is not a valid cap when light technology is 'LED directional'"]
    end

    it "requires a valid transformer for a given technology type" do
      expect(light_invalid1.errors[:transformer]).to eq []
      expect(light_invalid2.errors[:transformer]).to eq ["'N/A' is not a valid transformer when light technology is 'LED directional'"]
    end

    it "requires a wattage to be greater than zero" do
      expect(light_invalid1.errors[:wattage]).to eq ["can't be blank", "is not a number"]
      expect(light_invalid2.errors[:wattage]).to eq ["must be greater than 0"]
    end

    it "requires a wattage source to be 'Label', 'Measurement' or 'Guess'" do
      expect(light_invalid1.errors[:wattage_source]).to eq ["can't be blank", "must be one of 'Label', 'Measurement' or 'Guess'"]
      expect(light_invalid2.errors[:wattage_source]).to eq ["must be one of 'Label', 'Measurement' or 'Guess'"]
    end

    it "requires a usage between 0 and 24" do
      expect(light_invalid1.errors[:usage]).to eq ["can't be blank", "is not a number"]
      expect(light_invalid2.errors[:usage]).to eq ["must be less than or equal to 24"]
    end
  end
end
