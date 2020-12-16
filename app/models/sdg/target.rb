class SDG::Target < ApplicationRecord
  include Comparable
  include SDG::Related

  validates :code, presence: true, uniqueness: true
  validates :goal, presence: true

  belongs_to :goal
  has_many :local_targets, dependent: :destroy

  def title
    I18n.t("sdg.goals.goal_#{goal.code}.targets.target_#{code_key}.title")
  end

  def <=>(target)
    return unless target.class == self.class

    [goal.code, numeric_subcode] <=> [target.goal.code, target.numeric_subcode]
  end

  def self.[](code)
    find_by!(code: code)
  end

  protected

    def numeric_subcode
      if subcode.to_i > 0
        subcode.to_i
      else
        subcode.to_i(36) * 1000
      end
    end

  private

    def code_key
      code.gsub(".", "_").upcase
    end

    def subcode
      code.split(".").last
    end
end
