module Abilities
  class Common
    include CanCan::Ability

    def initialize(user)
      merge Abilities::Everyone.new(user)

      can [:read, :update], User, id: user.id

      can :read, Debate
      can :update, Debate do |debate|
        debate.editable_by?(user)
      end

      can :read, Proposal
      can :update, Proposal do |proposal|
        proposal.editable_by?(user)
      end
      can [:retire_form, :retire], Proposal, author_id: user.id

      can :read, Legislation::Proposal
      cannot [:edit, :update], Legislation::Proposal do |proposal|
        proposal.editable_by?(user)
      end
      can [:retire_form, :retire], Legislation::Proposal, author_id: user.id

      can :create, Comment
      can :create, Debate
      can :create, Proposal
      can :create, Legislation::Proposal

      can :suggest, Debate
      can :suggest, Proposal
      can :suggest, Legislation::Proposal
      can :suggest, ActsAsTaggableOn::Tag

      can [:flag, :unflag], Comment
      cannot [:flag, :unflag], Comment, user_id: user.id

      can [:flag, :unflag], Debate
      cannot [:flag, :unflag], Debate, author_id: user.id

      can [:flag, :unflag], Proposal
      cannot [:flag, :unflag], Proposal, author_id: user.id

      can [:flag, :unflag], Legislation::Proposal
      cannot [:flag, :unflag], Legislation::Proposal, author_id: user.id

      can [:create, :destroy], Follow

      can [:destroy], Document, documentable: { author_id: user.id }

      can [:destroy], Image, imageable: { author_id: user.id }

      can [:create, :destroy], DirectUpload

      unless user.organization?
        can :vote, Debate
        can :vote, Comment
      end

      if user.level_two_or_three_verified?
        can :vote, Proposal
        can :vote_featured, Proposal
        can :vote, SpendingProposal
        can :create, SpendingProposal






        # TODO: no dejar crear si ya se ha creado
        if true || user
           .budget_investments
           .includes(:budget)
           .where(budgets: { phase: 'accepting'})
           .where(budget_investments: { feasibility: ['undecided', 'feasible']}).count < 1
          #  .where(budget_investments: { hidden_at: nil }).count < 1

          can :create, Budget::Investment, budget: { phase: "accepting" }

          if user.organization? && !user.organization.verified?
            cannot :create, Budget::Investment
          end

        end

        can :suggest, Budget::Investment,              budget: { phase: "accepting" }
        can :destroy, Budget::Investment,              budget: { phase: ["accepting", "reviewing"] }, author_id: user.id
        budgets_current = Budget.includes(:investments).where(phase: 'selecting')
        investment_ids = budgets_current.map { |b| b.investment_ids }.flatten
        if user.votes.for_type(Budget::Investment).where(votable_id: investment_ids).size < 3
          can :vote,   Budget::Investment,               budget: { phase: "selecting" }
        end

        can :vote, Legislation::Proposal
        can :vote_featured, Legislation::Proposal
        can :create, Legislation::Answer

        # can :create, Budget::Investment,               budget: { phase: "accepting" }
        # can :suggest, Budget::Investment,              budget: { phase: "accepting" }
        # can :destroy, Budget::Investment,              budget: { phase: ["accepting", "reviewing"] }, author_id: user.id
        # can :vote, Budget::Investment,                 budget: { phase: "selecting" }
        # can [:show, :create], Budget::Ballot,          budget: { phase: "balloting" }
        # can [:create, :destroy], Budget::Ballot::Line, budget: { phase: "balloting" }

        can :create, DirectMessage
        can :show, DirectMessage, sender_id: user.id

        can :answer, Poll do |poll|
          poll.answerable_by?(user)
        end
        can :answer, Poll::Question do |question|
          question.answerable_by?(user)
        end
      end

      can [:create, :show], ProposalNotification, proposal: { author_id: user.id }

      can :create, Annotation
      can [:update, :destroy], Annotation, user_id: user.id

      can [:create], Topic
      can [:update, :destroy], Topic, author_id: user.id
    end
  end
end
