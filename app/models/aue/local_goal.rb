class AUE::LocalGoal < ApplicationRecord
  include AUE::Related

  translates :title, touch: true
  translates :description, touch: true
  include Globalizable

  validates_translation :title, presence: true

  validates :code, presence: true, uniqueness: true

  def altcode
    "local-#{code}"
  end

  def self.[](code)
    find_by!(code: code)
  end
end
