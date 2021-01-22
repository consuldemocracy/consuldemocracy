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

  def <=>(any_target)
    if any_target.class == self.class
      [goal.code, numeric_subcode] <=> [any_target.goal.code, any_target.numeric_subcode]
    elsif any_target.class.name == "SDG::LocalTarget"
      [self, -1] <=> [any_target.target, 1]
    end
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
