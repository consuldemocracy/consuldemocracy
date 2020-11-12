class SDG::Goal < ApplicationRecord
  validates :code, presence: true, uniqueness: true, inclusion: { in: 1..17 }

  def title
    I18n.t("sdg.goals.goal_#{code}.title")
  end

  def description
    I18n.t("sdg.goals.goal_#{code}.description")
  end
end
