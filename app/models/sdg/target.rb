class SDG::Target < ApplicationRecord
  include SDG::Related

  validates :code, presence: true, uniqueness: true
  validates :goal, presence: true

  belongs_to :goal
  has_many :local_targets, dependent: :destroy

  def title
    I18n.t("#{i18n_key}.short_title", default: long_title, fallback: nil)
  end

  def long_title
    I18n.t("#{i18n_key}.long_title")
  end

  def self.[](code)
    find_by!(code: code)
  end

  private

    def i18n_key
      "sdg.goals.goal_#{goal.code}.targets.target_#{code_key}"
    end

    def code_key
      code.gsub(".", "_").upcase
    end
end
