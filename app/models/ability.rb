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

      can :flag_as_inappropiate, Comment do |comment|
        comment.author_id != user.id && !InappropiateFlag.flagged?(user, comment)
      end

      can :undo_flag_as_inappropiate, Comment do |comment|
        comment.author_id != user.id && InappropiateFlag.flagged?(user, comment)
      end

      can :flag_as_inappropiate, Debate do |debate|
        debate.author_id != user.id && !InappropiateFlag.flagged?(user, debate)
      end

      can :undo_flag_as_inappropiate, Debate do |debate|
        debate.author_id != user.id && InappropiateFlag.flagged?(user, debate)
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

        can :mark_as_reviewed, Comment, reviewed_at: nil, hidden_at: nil
        cannot :mark_as_reviewed, Comment, user_id: user.id

        can :hide, Debate, hidden_at: nil
        cannot :hide, Debate, author_id: user.id

        can :mark_as_reviewed, Debate, reviewed_at: nil, hidden_at: nil
        cannot :mark_as_reviewed, Debate, author_id: user.id

        can :hide, User
        cannot :hide, User, id: user.id
      end

      if user.administrator?
        can :restore, Comment
        can :restore, Debate
        can :restore, User
      end
    end
  end

end
