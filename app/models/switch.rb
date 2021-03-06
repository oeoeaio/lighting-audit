class Switch < ActiveRecord::Base
  belongs_to :house
  belongs_to :room
  has_many :lights, dependent: :destroy

  validates :number, numericality: { only_integer: true }
end
