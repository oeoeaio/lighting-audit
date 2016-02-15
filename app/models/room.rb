class Room < ActiveRecord::Base
  belongs_to :house
  has_many :switches, dependent: :destroy
  has_many :lights, dependent: :destroy

  validates :house, :room_type, :number, :area, :height, presence: true
  validates :indoors, inclusion: { in: [true, false], message: "must be true or false" }
  validates :number, numericality: { only_integer: true }
  validates :room_type, inclusion: { in: ["Bathroom", "Bedroom", "Dining", "Foyer-inside",
    "Hallway", "Kitchen", "Kitchen/Living", "Laundry", "Living-other", "Lounge",
    "Media-room", "Other-inside", "Pantry", "Storage-Room", "Study", "Toilet", "Walk-in-Robe"], if: "indoors?", message: "%{value} is not a valid indoor room type" }
  validates :room_type, inclusion: { in: ["Garage", "Outside-general", "Outside-other", "Verandah"], if: "!indoors?", message: "%{value} is not a valid outdoor room type" }
  validates :area, numericality: { greater_than_or_equal_to: 1.0 }
  validates :height, numericality: { greater_than_or_equal_to: 0.0 }
end
