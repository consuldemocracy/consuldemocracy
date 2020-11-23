class SDG::LocalTarget < ApplicationRecord
  include Comparable
  include SDG::Related

  delegate :goal, to: :target

  translates :title, touch: true
  translates :description, touch: true
  include Globalizable

  validates_translation :title, presence: true
  validates_translation :description, presence: true

  validates :code, presence: true, uniqueness: true,
    format: ->(local_target) { /\A#{local_target.target&.code}\.\d+/ }
  validates :target, presence: true

  belongs_to :target

  def <=>(local_target)
    return unless local_target.class == self.class

    [target, numeric_subcode] <=> [local_target.target, local_target.numeric_subcode]
  end

  protected

    def numeric_subcode
      subcode.to_i
    end

  private

    def subcode
      code.split(".").last
    end
end
