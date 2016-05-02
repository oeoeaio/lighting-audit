class HousePolicy < ApplicationPolicy
  def create_multiple?
    true
  end

  def new_multiple?
    create_multiple?
  end
end
