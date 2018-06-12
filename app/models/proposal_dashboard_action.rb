# frozen_string_literal: true

class ProposalDashboardAction < ActiveRecord::Base
  acts_as_paranoid column: :hidden_at
  include ActsAsParanoidAliases

  enum action_type: %i[proposed_action resource]

  validates :title, 
            presence: true,
            allow_blank: false,
            length: { in: 4..80 }

  validates :description,
            presence: true,
            allow_blank: false,
            length: { in: 4..255 }

  validates :action_type, presence: true

  validates :day_offset,
            presence: true,
            numericality: {
              only_integer: true,
              greater_than_or_equal_to: 0
            }

  validates :required_supports,
            presence: true,
            numericality: {
              only_integer: true,
              greater_than_or_equal_to: 0
            }

  validates :link,
            presence: true,
            allow_blank: false,
            unless: :request_to_administrators?

  default_scope { order(order: :asc, title: :asc) }

  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }

  def request_to_administrators?
    request_to_administrators || false
  end
end
