class Activity < ActiveRecord::Base

  belongs_to :actionable, polymorphic: true
  belongs_to :user

  VALID_ACTIONS = %w( hide block restore )

  validates :action, inclusion: {in: VALID_ACTIONS}

  def self.log(user, action, actionable)
    create(user: user, action: action.to_s, actionable: actionable)
  end

  def self.on(actionable)
    where(actionable_type: actionable.class.name, actionable_id: actionable.id)
  end

  def self.by(user)
    where(user: user)
  end

end
