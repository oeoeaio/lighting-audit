class Room < ActiveRecord::Base
  belongs_to :house
  has_many :switches, dependent: :destroy
  has_many :lights, dependent: :destroy

  validates :house, :room_type, :number, presence: true
  validates :area, :height, presence: true, if: "indoors?"
  validates :indoors, inclusion: { in: [true, false], message: "must be true or false" }
  validates :number, numericality: { only_integer: true }
  validates :room_type, inclusion: { in: ["Bathroom", "Bedroom", "Dining", "Foyer-inside", "Hallway",
    "Kitchen (open plan)", "Kitchen (separate)", "Kitchen/Living", "Laundry", "Living-other", "Lounge",
    "Media-room", "Other-inside", "Pantry", "Stairwell", "Storage-Room", "Study", "Toilet", "Walk-in-Robe"], if: "indoors?", message: "%{value} is not a valid indoor room type" }
  validates :room_type, inclusion: { in: ["Garage", "Outside-general", "Outside-other", "Verandah"], if: "!indoors?", message: "%{value} is not a valid outdoor room type" }
  validates :area, numericality: { greater_than_or_equal_to: 1.0, if: "indoors?" }
  validates :height, numericality: { greater_than_or_equal_to: 0.0, if: "indoors?" }

  scope :indoor, -> { where(indoors: true) }
  scope :outdoor, -> { where(indoors: false) }

  CATEGORIES = {
    "all" => ["Bathroom", "Bedroom", "Dining", "Foyer-inside", "Hallway", "Kitchen (open plan)", "Kitchen (separate)", "Kitchen/Living", "Laundry", "Living-other", "Lounge", "Media-room", "Other-inside", "Pantry", "Stairwell", "Storage-Room", "Study", "Toilet", "Walk-in-Robe", "Garage", "Outside-general", "Outside-other", "Verandah"],
    "living" => ["Dining", "Kitchen (open plan)", "Kitchen (separate)", "Kitchen/Living", "Living-other", "Lounge", "Media-room", "Pantry"],
    "sleeping" => ["Bedroom", "Study"],
    "indoor-other" => ["Bathroom", "Foyer-inside", "Hallway", "Laundry", "Other-inside", "Stairwell", "Storage-Room", "Toilet", "Walk-in-Robe"],
    "outdoor" => ["Garage", "Outside-general", "Outside-other", "Verandah"]
  }
end
