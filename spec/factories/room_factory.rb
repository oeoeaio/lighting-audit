FactoryGirl.define do
  factory :room do
    house
    number "12"
    indoors true
    room_type "Bedroom"
    area "12.45"
    height "2.34"
  end
end
