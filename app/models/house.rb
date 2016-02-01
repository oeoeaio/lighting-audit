class House < ActiveRecord::Base
  validates :name, presence: true
  validates :house_type, presence: true, inclusion: ["Detached house", "Attached (town house)", "Flat"]
  validates :storey_count, presence: true, numericality: { greater_than_or_equal_to: 1 }
end
