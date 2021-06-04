class SDG::Target < ApplicationRecord
  include SDG::Related

  validates :code, presence: true, uniqueness: true
  validates :goal, presence: true

  belongs_to :goal
  has_many :local_targets, dependent: :destroy

  def title
    I18n.t("sdg.goals.goal_#{goal.code}.targets.target_#{code_key}.title")
  end

  def self.[](code)
    find_by!(code: code)
  end

  private

    def code_key
      code.gsub(".", "_").upcase
    end
end
