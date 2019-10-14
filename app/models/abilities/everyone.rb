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
      can :read, Budget::Investment
      can :read, SpendingProposal
      if Setting["feature.spending_proposal_features.open_results_page"].present?
        can [:stats, :results], SpendingProposal
      end
      can :read, Legislation
      can :read, User
      can [:search, :read], Annotation
      can [:read], Budget
      can [:read, :results], Budget, phase: "finished"
      can [:read], Budget::Group
      can [:read, :print], Budget::Investment
      can :new, DirectMessage
      can [:read, :debate, :draft_publication, :allegations, :final_version_publication], Legislation::Process
      can [:read, :changes, :go_to_version], Legislation::DraftVersion
      can [:read], Legislation::Question
      can [:create], Legislation::Answer
      can [:search, :comments, :read, :create, :new_comment], Legislation::Annotation
      can :project,   Budget::Investment,               budget: { phase: "finished" } #GET-XX
      can :project,   SpendingProposal
      
      cannot [:read], Budget, phase: "configuring"      
#      cannot [:read], Budget::Group, budget: { phase: "configuring" }
#      cannot [:read, :print], Budget::Investment, budget: { phase: "configuring" }
    end
  end
end
