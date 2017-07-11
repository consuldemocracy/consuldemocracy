module Abilities
  class Everyone
    include CanCan::Ability

    def initialize(user)
      can [:read, :map], Debate
      can [:read, :map, :summary, :share], Proposal
      can :read, Comment
      can :read, Poll
      can :read, Poll::Question
      can [:read, :welcome], Budget
      can :read, SpendingProposal
      can :read, LegacyLegislation
      can :read, User
      can [:search, :read], Annotation
      can [:read], Budget
      can [:read], Budget::Group
      can [:read, :print], Budget::Investment
      can :read_results, Budget, phase: "finished"
      can :new, DirectMessage
      can [:read, :debate, :draft_publication, :allegations, :result_publication], Legislation::Process, published: true
      can [:read, :changes, :go_to_version], Legislation::DraftVersion
      can [:read], Legislation::Question
      can [:create], Legislation::Answer
      can [:search, :comments, :read, :create, :new_comment], Legislation::Annotation
    end
  end
end
