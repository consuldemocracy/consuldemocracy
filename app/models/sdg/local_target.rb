class SDG::LocalTarget < ApplicationRecord
  include SDG::Related

  translates :title, touch: true
  translates :description, touch: true
  include Globalizable

  validates_translation :title, presence: true
  validates_translation :description, presence: true

  validates :code, presence: true, uniqueness: true,
    format: ->(local_target) { /\A#{local_target.target&.code}\.\d+/ }
  validates :target, presence: true
  validates :goal, presence: true

  belongs_to :target
  belongs_to :goal

  before_validation :set_related_goal

  def self.[](code)
    find_by!(code: code)
  end

  private

    def set_related_goal
      self.goal ||= target&.goal
    end
end
