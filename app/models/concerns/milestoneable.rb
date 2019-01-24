module Milestoneable
  extend ActiveSupport::Concern

  included do
    has_many :milestones, as: :milestoneable, dependent: :destroy

    scope :with_milestones, -> { joins(:milestones).distinct }

    has_many :progress_bars, as: :progressable
  end
end
