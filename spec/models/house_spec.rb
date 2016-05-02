require 'rails_helper'

RSpec.describe House, type: :model do
  describe "validation" do
    let(:house1) { build(:house, name: "House1", auditor: "DY", house_type: "Some disallowed value", storey_count: 0) }
    let(:house2) { build(:house, name: "", auditor: "", house_type: "", storey_count: nil) }
    let(:house3) { build(:house, name: "House3", auditor: "NR", house_type: "Detached house", storey_count: 4) }

    before do
      expect(house1.valid?).to be false
      expect(house2.valid?).to be false
      expect(house3.valid?).to be true
    end

    it "requires that a name is present" do
      expect(house1.errors[:name]).to eq []
      expect(house2.errors[:name]).to eq ["can't be blank"]
      expect(house3.errors[:name]).to eq []
    end

    it "requires that an auditor is present" do
      expect(house1.errors[:auditor]).to eq []
      expect(house2.errors[:auditor]).to eq ["can't be blank"]
      expect(house3.errors[:auditor]).to eq []
    end

    it "only allows specific house types" do
      expect(house1.errors[:house_type]).to eq ["is not included in the list"]
      expect(house2.errors[:house_type]).to eq ["can't be blank", "is not included in the list"]
      expect(house3.errors[:house_type]).to eq []
    end

    it "only allows storeys greater than 1" do
      expect(house1.errors[:storey_count]).to eq ["must be greater than or equal to 1"]
      expect(house2.errors[:storey_count]).to eq ["can't be blank", "is not a number"]
      expect(house3.errors[:storey_count]).to eq []
    end
  end

  describe "desctruction" do
    let(:house) { create(:house) }
    let(:room) { create(:room, house: house) }
    let(:switch) { create(:switch, house: house, room: room) }
    let(:light) { create(:light, house: house, room: room, switch: switch) }

    it "destroys all dependent switches, rooms and lights" do
      expect(house).to be
      expect(room).to be
      expect(switch).to be
      expect(light).to be
      house.destroy
      expect(House.find_by_id(house.id)).to be_nil
      expect(Room.find_by_id(room.id)).to be_nil
      expect(Switch.find_by_id(switch.id)).to be_nil
      expect(Light.find_by_id(light.id)).to be_nil
    end
  end
end
