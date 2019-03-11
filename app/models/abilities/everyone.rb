module Abilities
  class Everyone
    include CanCan::Ability

    def initialize(user)
      can [:read, :map], Debate
      can [:read, :map, :summary, :share], Proposal
      can :read, Comment

      can [:read, :welcome, :results, :stats, :progress], Budget
      # can [:read, :welcome], Budget
      can :read, Budget::Investment

      can :read, Poll
      can :results, Poll do |poll|
        poll.show_results?
      end
      can :stats, Poll do |poll|
        poll.show_stats?
      end
      can :current_cartell, Poll do |poll|
        true
      end
      can :read, Poll::Question
      can :read, SpendingProposal
      can :read, LegacyLegislation
      can :read, User
      can [:search, :read], Annotation
      can [:read], Budget
      can [:read], Budget::Group
      can [:read, :print, :json_data], Budget::Investment
      can [:read_results, :read_executions], Budget, phase: "finished"
      can :new, DirectMessage
      can [:read, :debate, :draft_publication, :allegations, :result_publication,
           :proposals, :milestones], Legislation::Process, published: true
      can [:read, :changes, :go_to_version], Legislation::DraftVersion
      can [:read], Legislation::Question
      can [:read, :map, :share], Legislation::Proposal
      can [:search, :comments, :read, :create, :new_comment], Legislation::Annotation
    end
  end
end
