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

      can :flag_as_inappropiate, Comment do |comment|
        comment.author != user && !InappropiateFlag.flagged?(user, comment)
      end

      can :undo_flag_as_inappropiate, Comment do |comment|
        comment.author != user && InappropiateFlag.flagged?(user, comment)
      end

      can :flag_as_inappropiate, Debate do |debate|
        debate.author != user && !InappropiateFlag.flagged?(user, debate)
      end

      can :undo_flag_as_inappropiate, Debate do |debate|
        debate.author != user && InappropiateFlag.flagged?(user, debate)
      end

      unless user.organization?
        can :vote, Debate
        can :vote, Comment
      end

      if user.moderator? || user.administrator?
        can :read, Organization
        can(:verify, Organization){ |o| !o.verified? }
        can(:reject, Organization){ |o| !o.rejected? }

        can :hide, Comment
        can :hide, Debate
      end

      if user.administrator?
        can :restore, Comment
        can :restore, Debate
      end
    end
  end

end
