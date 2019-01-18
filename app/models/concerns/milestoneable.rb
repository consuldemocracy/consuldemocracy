module Milestoneable
  extend ActiveSupport::Concern

  included do
    has_many :milestones, as: :milestoneable, dependent: :destroy

    scope :with_milestones, -> { joins(:milestones).distinct }
  end
end
