class House < ActiveRecord::Base
  has_many :rooms, dependent: :destroy
  has_many :switches, dependent: :destroy
  has_many :lights, dependent: :destroy

  validates :name, presence: true
  validates :auditor, presence: true
  validates :house_type, presence: true, inclusion: ["Detached house", "Attached (town house)", "Flat"]
  validates :storey_count, presence: true, numericality: { greater_than_or_equal_to: 1 }
end
