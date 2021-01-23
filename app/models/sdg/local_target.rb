class SDG::LocalTarget < ApplicationRecord
  include Comparable
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

  def <=>(goal_or_target)
    if goal_or_target.class == self.class
      [target, numeric_subcode] <=> [goal_or_target.target, goal_or_target.numeric_subcode]
    elsif [target.class, goal.class].include?(goal_or_target.class)
      -1 * (goal_or_target <=> self)
    end
  end

  protected

    def numeric_subcode
      subcode.to_i
    end

  private

    def subcode
      code.split(".").last
    end

    def set_related_goal
      self.goal ||= target&.goal
    end
end
