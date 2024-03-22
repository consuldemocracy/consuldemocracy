module Abilities
  class Everyone
    include CanCan::Ability

    def initialize(user)
      can [:read, :map], Debate
      can [:read, :map, :summary, :share], Proposal
      can :read, Comment
      can :read, Poll
      can :results, Poll, id: Poll.expired.results_enabled.not_budget.ids
      can :stats, Poll, id: Poll.expired.stats_enabled.not_budget.ids
      can :read, Poll::Question
      can :read, User
      can [:read, :welcome], Budget
      can [:read], Budget
      can [:read], Budget::Group
      can [:read, :print], Budget::Investment
      can :read_results, Budget, id: Budget.finished.results_enabled.ids
      can :read_stats, Budget, id: Budget.valuating_or_later.stats_enabled.ids
      can :read_executions, Budget, phase: "finished"
      can [:read, :debate, :draft_publication, :allegations, :result_publication,
           :proposals, :milestones], Legislation::Process, published: true
           
      can :summary, Legislation::Process do |process|
          process.summary_publication_enabled? && 
            (process.summary_publication_date.nil? || process.summary_publication_date <= Date.current) &&
            process.id.in?(Legislation::Process.published.where(summary_publication_enabled: true).ids)
      end
                     
      can [:read, :changes, :go_to_version], Legislation::DraftVersion
      can [:read], Legislation::Question
      can [:read, :share], Legislation::Proposal
      can [:search, :comments, :read, :create, :new_comment], Legislation::Annotation

      can [:read, :help], ::SDG::Goal
      can :read, ::SDG::Phase
    end
  end
end
