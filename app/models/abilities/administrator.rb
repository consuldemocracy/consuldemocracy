module Abilities
  class Administrator
    include CanCan::Ability

    def initialize(user)
      self.merge Abilities::Moderation.new(user)

      can :restore, Comment
      cannot :restore, Comment, hidden_at: nil

      can :restore, Debate
      cannot :restore, Debate, hidden_at: nil

      can :restore, Medida
      cannot :restore, Medida, hidden_at: nil

      can :restore, Proposal
      cannot :restore, Proposal, hidden_at: nil

      can :restore, User
      cannot :restore, User, hidden_at: nil

      can :confirm_hide, Comment
      cannot :confirm_hide, Comment, hidden_at: nil

      can :confirm_hide, Debate
      cannot :confirm_hide, Debate, hidden_at: nil

      can :confirm_hide, Medida
      cannot :confirm_hide, Medida, hidden_at: nil

      can :confirm_hide, Proposal
      cannot :confirm_hide, Proposal, hidden_at: nil

      can :confirm_hide, User
      cannot :confirm_hide, User, hidden_at: nil

      can :comment_as_administrator, [Debate, Medida, Comment, Proposal]

      can [:search, :create, :index, :destroy], ::Moderator
    end
  end
end
