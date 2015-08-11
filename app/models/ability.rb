class Ability
  include CanCan::Ability

  def initialize(user)
    # Not logged in users
    can :read, Debate

    if user # logged-in users
      can [:read, :update], User, id: user.id

      can :read, Debate
      can :update, Debate do |debate|
        debate.editable_by?(user)
      end

      unless user.organization?
        can :vote, Debate
        can :vote, Comment
      end

      if !user.organization? || user.verified_organization?
        can :create, Comment
        can :create, Debate
      end

      if user.moderator? || user.administrator?

      elsif user.administrator?

      end
    end
  end

end
