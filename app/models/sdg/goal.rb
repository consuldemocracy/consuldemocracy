class SDG::Goal < ApplicationRecord
  include SDG::Related

  validates :code, presence: true, uniqueness: true, inclusion: { in: 1..17 }

  has_many :targets, dependent: :destroy

  def title
    I18n.t("sdg.goals.goal_#{code}.title")
  end

  def description
    I18n.t("sdg.goals.goal_#{code}.description")
  end

  def self.[](code)
    find_by!(code: code)
  end

  def code_and_title
    "#{code}. #{title}"
  end
end
