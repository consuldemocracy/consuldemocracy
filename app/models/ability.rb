class Ability
  include CanCan::Ability

  def initialize(user)
    # Not logged in users
    can :read, Debate

    if user # logged-in users
      can [:read, :update], User, id: user.id

      can [:read, :create, :vote], Debate
      can :update, Debate do |debate|
        debate.editable_by?(user)
      end

      can [:create, :vote], Comment

      if user.moderator?
        can [:hide], Comment
        can [:hide], Debate

      elsif user.administrator?
        can [:restore], Comment
        can [:restore], Debate
      end
    end
  end

end
