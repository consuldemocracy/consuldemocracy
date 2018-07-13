class ProposalDashboardAction < ActiveRecord::Base
  include Documentable
  documentable max_documents_allowed: 3,
               max_file_size: 3.megabytes,
               accepted_content_types: [ 'application/pdf' ]

  include Linkable

  acts_as_paranoid column: :hidden_at
  include ActsAsParanoidAliases

  has_many :proposal_executed_dashboard_actions, dependent: :restrict_with_error
  has_many :proposals, through: :proposal_executed_dashboard_actions

  enum action_type: [:proposed_action, :resource]

  validates :title, 
            presence: true,
            allow_blank: false,
            length: { in: 4..80 }

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

  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }
  scope :resources, -> { where(action_type: 1) }
  scope :proposed_actions, -> { where(action_type: 0) }
  scope :active_for, ->(proposal) do 
    published_at = proposal.published_at&.to_date || Date.today

    active
      .where('required_supports <= ?', proposal.votes_for.size)
      .where('day_offset <= ?', (Date.today - published_at).to_i)
  end

  scope :course_for, lambda { |proposal|
    active
      .resources
      .where('required_supports > ?', proposal.votes_for.size)
      .order(required_supports: :asc)
  }

  def active_for?(proposal)
    published_at = proposal.published_at&.to_date || Date.today

    required_supports <= proposal.votes_for.size && day_offset <= (Date.today - published_at).to_i
  end

  def self.next_goal_for(proposal)
    course_for(proposal).first
  end

  def request_to_administrators?
    request_to_administrators || false
  end

  def request_to_administrators?
    request_to_administrators
  end
end
