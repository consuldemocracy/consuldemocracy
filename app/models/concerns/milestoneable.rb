module Milestoneable
  extend ActiveSupport::Concern

  included do
    has_many :milestones, as: :milestoneable, dependent: :destroy
  end
end
