class Activity < ActiveRecord::Base

  belongs_to :actionable,  -> { with_hidden }, polymorphic: true
  belongs_to :user, -> { with_hidden }

  VALID_ACTIONS = %w( hide block restore )

  validates :action, inclusion: {in: VALID_ACTIONS}

  scope :on_proposals, -> { where(actionable_type: 'Proposal') }
  scope :on_debates, -> { where(actionable_type: 'Debate') }
  scope :on_medidas, -> { where(actionable_type: 'Medida') }
  scope :on_users, -> { where(actionable_type: 'User') }
  scope :on_comments, -> { where(actionable_type: 'Comment') }
  scope :for_render, -> { includes(user: [:moderator, :administrator]).includes(:actionable) }

  def self.log(user, action, actionable)
    create(user: user, action: action.to_s, actionable: actionable)
  end

  def self.on(actionable)
    where(actionable: actionable)
  end

  def self.by(user)
    where(user: user)
  end

end
