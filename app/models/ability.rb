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

      can :create, Comment
      can :create, Debate

      unless user.organization?
        can :vote, Debate
        can :vote, Comment
      end

      if user.moderator? || user.administrator?

        can :read, Organization
        can(:verify, Organization){ |o| !o.verified? }
        can(:reject, Organization){ |o| !o.rejected? }

      elsif user.administrator?

      end
    end
  end

end
