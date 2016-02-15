require 'rails_helper'

RSpec.describe House, type: :model do
  describe "validation" do
    let(:house1) { House.create(name: "House1", auditor: "DY", house_type: "Some disallowed value", storey_count: 0) }
    let(:house2) { House.create(name: "", auditor: "", house_type: "", storey_count: nil) }
    let(:house3) { House.create(name: "House3", auditor: "NR", house_type: "Detached house", storey_count: 4) }

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
end
