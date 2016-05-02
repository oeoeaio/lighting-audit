FactoryGirl.define do
  sequence :number

  factory :switch do
    house
    room
    number
  end
end
