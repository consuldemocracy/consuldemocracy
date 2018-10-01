class Dashboard::Action < ActiveRecord::Base
  include Documentable
  documentable max_documents_allowed: 3,
               max_file_size: 3.megabytes,
               accepted_content_types: [ 'application/pdf' ]

  include Linkable

  acts_as_paranoid column: :hidden_at
  include ActsAsParanoidAliases

  has_many :executed_actions, dependent: :restrict_with_error, class_name: 'Dashboard::ExecutedAction'
  has_many :proposals, through: :executed_actions

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

  def self.active_for(proposal) 
    published_at = proposal.published_at&.to_date || Date.today

    active
      .where('required_supports <= ?', proposal.cached_votes_up)
      .where('day_offset <= ?', (Date.today - published_at).to_i)
  end

  def self.course_for(proposal)
    active
      .resources
      .where('required_supports > ?', proposal.cached_votes_up)
      .order(required_supports: :asc)
  end

  def active_for?(proposal)
    published_at = proposal.published_at&.to_date || Date.today

    required_supports <= proposal.cached_votes_up && day_offset <= (Date.today - published_at).to_i
  end

  def requested_for?(proposal)
    executed_action = executed_actions.find_by(proposal: proposal)
    return false if executed_action.nil?

    executed_action.administrator_tasks.any?
  end

  def executed_for?(proposal)
    executed_action = executed_actions.find_by(proposal: proposal)
    return false if executed_action.nil?

    executed_action.administrator_tasks.where.not(executed_at: nil).any?
  end

  def self.next_goal_for(proposal)
    course_for(proposal).first
  end
end
