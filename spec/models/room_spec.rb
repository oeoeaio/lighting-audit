require 'rails_helper'

RSpec.describe Room, type: :model do
  describe "validation" do
    let(:house) { House.create(name: "House3", auditor: "OD", house_type: "Detached house", storey_count: 4) }
    let(:room1) { Room.create(house: house, number: "r12", indoors: false, room_type: "Bedroom", area: "12.b", height: "m") }
    let(:room2) { Room.create(house: nil, number: "", indoors: nil, room_type: "", area: "", height: "") }
    let(:room3) { Room.create(house: house, number: "12", indoors: true, room_type: "Bedroom", area: "12.45", height: "2.34") }

    it "requires that a house is present" do
      expect(room1.errors[:house]).to eq []
      expect(room2.errors[:house]).to eq ["can't be blank"]
      expect(room3.errors[:house]).to eq []
    end

    it "requires that a room number is present" do
      expect(room1.errors[:number]).to eq ["is not a number"]
      expect(room2.errors[:number]).to eq ["can't be blank", "is not a number"]
      expect(room3.errors[:number]).to eq []
    end

    it "requires that a indoors flag is provided" do
      expect(room1.errors[:indoors]).to eq []
      expect(room2.errors[:indoors]).to eq ["must be true or false"]
      expect(room3.errors[:indoors]).to eq []
    end

    it "requires that a room_type is present and valid given the indoors flag" do
      expect(room1.errors[:room_type]).to eq ["Bedroom is not a valid outdoor room type"]
      expect(room2.errors[:room_type]).to eq ["can't be blank", " is not a valid outdoor room type"]
      expect(room3.errors[:room_type]).to eq []
    end
  end
end
