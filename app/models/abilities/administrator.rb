module Abilities
  class Administrator
    include CanCan::Ability

    def initialize(user)
      merge Abilities::Moderation.new(user)

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

      can :mark_featured, Debate
      can :unmark_featured, Debate

      can :comment_as_administrator, [Debate, Comment, Proposal, Poll::Question, Budget::Investment,
                                      Legislation::Question, Legislation::Annotation]

      can [:search, :create, :index, :destroy], ::Administrator
      can [:search, :create, :index, :destroy], ::Moderator
      can [:search, :create, :index, :summary], ::Valuator
      can [:search, :create, :index, :destroy], ::Manager
      can [:search, :index], ::User

      can :manage, Annotation

      can [:read, :update, :valuate, :destroy, :summary], SpendingProposal

      can [:index, :read, :new, :create, :update, :destroy, :calculate_winners], Budget
      can [:read, :create, :update, :destroy], Budget::Group
      can [:read, :create, :update, :destroy], Budget::Heading
      can [:hide, :update, :toggle_selection], Budget::Investment
      can :valuate, Budget::Investment
      can :create, Budget::ValuatorAssignment

      can [:search, :edit, :update, :create, :index, :destroy], Banner

      can [:index, :create, :edit, :update, :destroy], Geozone

      can [:read, :create, :update, :destroy, :add_question, :remove_question, :search_booths, :search_questions, :search_officers], Poll
      can [:read, :create, :update, :destroy], Poll::Booth
      can [:search, :create, :index, :destroy], ::Poll::Officer
      can [:create, :destroy], ::Poll::BoothAssignment
      can [:create, :destroy], ::Poll::OfficerAssignment
      can [:read, :create, :update], Poll::Question
      can :destroy, Poll::Question # , comments_count: 0, votes_up: 0

      can :manage, SiteCustomization::Page
      can :manage, SiteCustomization::Image
      can :manage, SiteCustomization::ContentBlock

      can [:manage], ::Legislation::Process
      can [:manage], ::Legislation::DraftVersion
      can [:manage], ::Legislation::Question
      cannot :comment_as_moderator, [::Legislation::Question, Legislation::Annotation]

      can [:create, :destroy], Document
    end
  end
end
