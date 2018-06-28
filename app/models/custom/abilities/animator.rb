module Abilities
  class Animator
    include CanCan::Ability

    def initialize(user)
      merge Abilities::Common.new(user)
      
      can [:search, :index], ::User
      
      # Debates / Idées -----------------------------------
      
      # Proposals / Projets -------------------------------
      can :create, Proposal
      can :create, Legislation::Proposal
      
      # Polls / Votes -------------------------------------
      can [:read, :create, :update, :destroy, :add_question, :results, :stats], Poll
      can [:read, :create, :update], Poll::Question
      can :destroy, Poll::Question # , comments_count: 0, votes_up: 0

      # Articles / Actualité ------------------------------
      can [:manage], Article
      
      # User management -----------------------------------

      # Modération ----------------------------------------

      # comments
      can :read, Comment
      can :hide, Comment, hidden_at: nil
      cannot :hide, Comment, user_id: user.id
      can :ignore_flag, Comment, ignored_flag_at: nil, hidden_at: nil
      cannot :ignore_flag, Comment, user_id: user.id
      can :moderate, Comment
      cannot :moderate, Comment, user_id: user.id
      can :restore, Comment
      cannot :restore, Comment, hidden_at: nil

      # debates
      can :hide, Debate, hidden_at: nil
      cannot :hide, Debate, author_id: user.id
      can :ignore_flag, Debate, ignored_flag_at: nil, hidden_at: nil
      cannot :ignore_flag, Debate, author_id: user.id
      can :moderate, Debate
      cannot :moderate, Debate, author_id: user.id
      can :restore, Debate
      cannot :restore, Debate, hidden_at: nil

      # proposals
      can :hide, Proposal, hidden_at: nil
      cannot :hide, Proposal, author_id: user.id
      can :ignore_flag, Proposal, ignored_flag_at: nil, hidden_at: nil
      cannot :ignore_flag, Proposal, author_id: user.id
      can :moderate, Proposal
      cannot :moderate, Proposal, author_id: user.id
      can :restore, Proposal
      cannot :restore, Proposal, hidden_at: nil

      # user
      can :hide, User
      cannot :hide, User, id: user.id
      can :block, User
      cannot :block, User, id: user.id
      can :restore, User
      cannot :restore, User, hidden_at: nil

      # Communication -------------------------------------
      can [:deliver], Newsletter, hidden_at: nil
      can [:search, :edit, :update, :create, :index, :destroy], Banner

    end
  end
end
