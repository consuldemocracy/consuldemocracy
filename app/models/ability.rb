class Ability
  include CanCan::Ability

  def initialize(user)

    # If someone can hide something, he can also hide it
    # from the moderation screen
    alias_action :hide_in_moderation_screen, to: :hide

    # Not logged in users
    can :read, Debate
    can :read, Proposal

    if user # logged-in users
      can [:read, :update], User, id: user.id

      can :read, Debate
      can :update, Debate do |debate|
        debate.editable_by?(user)
      end

      can :read, Proposal
      can :update, Proposal do |proposal|
        proposal.editable_by?(user)
      end

      can :create, Comment
      can :create, Debate
      can :create, Proposal

      can [:flag, :unflag], Comment
      cannot [:flag, :unflag], Comment, user_id: user.id

      can [:flag, :unflag], Debate
      cannot [:flag, :unflag], Debate, author_id: user.id

      can [:flag, :unflag], Proposal
      cannot [:flag, :unflag], Proposal, author_id: user.id

      unless user.organization?
        can :vote, Debate
        can :vote, Comment
      end

      if user.level_two_or_three_verified?
        can :vote, Proposal
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

        can :moderate, Debate
        cannot :moderate, Debate, author_id: user.id

        can :hide, Proposal, hidden_at: nil
        cannot :hide, Proposal, author_id: user.id

        can :ignore_flag, Proposal, ignored_flag_at: nil, hidden_at: nil
        cannot :ignore_flag, Proposal, author_id: user.id

        can :moderate, Proposal
        cannot :moderate, Proposal, author_id: user.id

        can :hide, User
        cannot :hide, User, id: user.id

        can :block, User
        cannot :block, User, id: user.id
      end

      if user.moderator?
        can :comment_as_moderator, [Debate, Comment, Proposal]
      end

      if user.administrator?
        can :restore, Comment
        cannot :restore, Comment, hidden_at: nil

        can :restore, Debate
        cannot :restore, Debate, hidden_at: nil

        can :restore, Proposal
        cannot :restore, Proposal, hidden_at: nil

        can :restore, User
        cannot :restore, User, hidden_at: nil

        can :confirm_hide, Comment
        cannot :confirm_hide, Comment, hidden_at: nil

        can :confirm_hide, Debate
        cannot :confirm_hide, Debate, hidden_at: nil

        can :confirm_hide, Proposal
        cannot :confirm_hide, Proposal, hidden_at: nil

        can :confirm_hide, User
        cannot :confirm_hide, User, hidden_at: nil

        can :comment_as_administrator, [Debate, Comment, Proposal]

        can :manage, Moderator
      end
    end
  end

end
