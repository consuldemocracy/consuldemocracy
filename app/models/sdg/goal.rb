class SDG::Goal < ApplicationRecord
  translates :title, :description, touch: true
  include Globalizable

  validates :code, presence: true, uniqueness: true
  validates_translation :title, presence: true
  validates_translation :description, presence: true

  class Translation
    validates :title, uniqueness: { scope: [:locale] }
  end
end
