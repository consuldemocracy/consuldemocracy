class Ability
  include CanCan::Ability

  def initialize(user)
    # Not logged in users
    can :read, Debate

    if user # logged-in users
      can [:read, :create, :vote], Debate
      can :edit, Debate do |debate|
        debate.editable_by?(user)
      end

      if user.moderator? or user.administrator?

      elsif user.administrator?

      end
    end
  end

end
