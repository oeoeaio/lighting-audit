class Switch < ActiveRecord::Base
  belongs_to :house
  belongs_to :room

  validates :number, numericality: { only_integer: true }
end
