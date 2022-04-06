class SDG::Goal < ApplicationRecord
  include SDG::Related

  validates :code, presence: true, uniqueness: true, inclusion: { in: 1..17 }

  has_many :targets, dependent: :destroy
  has_many :local_targets, dependent: :destroy

  def title
    I18n.t("sdg.goals.goal_#{code}.title")
  end
  alias_method :long_title, :title

  def title_in_two_lines
    I18n.t("sdg.goals.goal_#{code}.title_in_two_lines")
  end

  def description
    I18n.t("sdg.goals.goal_#{code}.description")
  end

  def self.[](code)
    find_by!(code: code)
  end
end
