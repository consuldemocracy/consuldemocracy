class Ability
  include CanCan::Ability

  def initialize(user)

    # If someone can hide something, he can also hide it
    # from the moderation screen
    alias_action :hide_in_moderation_screen, to: :hide

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

      can :flag, Comment do |comment|
        comment.author_id != user.id && !Flag.flagged?(user, comment)
      end

      can :unflag, Comment do |comment|
        comment.author_id != user.id && Flag.flagged?(user, comment)
      end

      can :flag, Debate do |debate|
        debate.author_id != user.id && !Flag.flagged?(user, debate)
      end

      can :unflag, Debate do |debate|
        debate.author_id != user.id && Flag.flagged?(user, debate)
      end

      unless user.organization?
        can :vote, Debate
        can :vote, Comment
      end

      if user.moderator? || user.administrator?
        can :read, Organization
        can(:verify, Organization){ |o| !o.verified? }
        can(:reject, Organization){ |o| !o.rejected? }

        can :read, Comment

        can :hide, Comment, hidden_at: nil
        cannot :hide, Comment, user_id: user.id

        can :ignore_flag, Comment, ignored_flag_at: nil, hidden_at: nil
        cannot :ignore_flag, Comment, user_id: user.id

        can :hide, Debate, hidden_at: nil
        cannot :hide, Debate, author_id: user.id

        can :ignore_flag, Debate, ignored_flag_at: nil, hidden_at: nil
        cannot :ignore_flag, Debate, author_id: user.id

        can :hide, User
        cannot :hide, User, id: user.id
      end

      if user.moderator?
        can :comment_as_moderator, [Debate, Comment]
      end

      if user.administrator?
        can :restore, Comment
        can :restore, Debate
        can :restore, User
        can :comment_as_administrator, [Debate, Comment]
      end
    end
  end

end
