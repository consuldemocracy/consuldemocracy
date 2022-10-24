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
      can :publish, Proposal do |proposal|
        proposal.draft? && proposal.author.id == user.id && !proposal.retired?
      end
      can :dashboard, Proposal do |proposal|
        proposal.author.id == user.id
      end
      can :manage_polls, Proposal do |proposal|
        proposal.author.id == user.id
      end
      can :manage_mailing, Proposal do |proposal|
        proposal.author.id == user.id
      end
      can :manage_poster, Proposal do |proposal|
        proposal.author.id == user.id
      end

      can :results, Poll do |poll|
        poll.related&.author&.id == user.id
      end

      can [:retire_form, :retire], Proposal, author_id: user.id

      can :read, Legislation::Proposal
      can [:retire_form, :retire], Legislation::Proposal, author_id: user.id

      can :create, Comment
      can :create, Debate
      can [:create, :created], Proposal
      can :create, Legislation::Proposal

      can :hide, Comment, user_id: user.id

      can :suggest, Debate
      can :suggest, Proposal
      can :suggest, Legislation::Proposal
      can :suggest, Tag

      can [:flag, :unflag], Comment
      cannot [:flag, :unflag], Comment, user_id: user.id

      can [:flag, :unflag], Debate
      cannot [:flag, :unflag], Debate, author_id: user.id

      can [:flag, :unflag], Proposal
      cannot [:flag, :unflag], Proposal, author_id: user.id

      can [:flag, :unflag], Legislation::Proposal
      cannot [:flag, :unflag], Legislation::Proposal, author_id: user.id

      can [:flag, :unflag], Budget::Investment
      cannot [:flag, :unflag], Budget::Investment, author_id: user.id

      can [:create, :destroy], Follow, user_id: user.id

      can [:destroy], Document do |document|
        document.documentable_type != "Poll::Question::Answer" && document.documentable&.author_id == user.id
      end

      can [:destroy], Image do |image|
        image.imageable_type != "Poll::Question::Answer" && image.imageable&.author_id == user.id
      end

      can [:create, :destroy], DirectUpload

      unless user.organization?
        can :vote, Debate
        can :vote, Comment
      end

      can :suggest, Budget::Investment,              budget: { phase: "accepting" }

      if user.level_two_or_three_verified?
        can :vote, Proposal, &:published?


####################################################### mio
        # Dejar solamente una propuesta por grupo.
        if true || user
           .budget_investments
           .includes(:budget)
           .where(budgets: { phase: 'accepting'})
           .where(budget_investments: { feasibility: ['undecided', 'feasible']}).count < 1
          #  .where(budget_investments: { hidden_at: nil }).count < 1



          can :create, Budget::Investment do |investment|
            if investment.heading_id
              heading_brothers = investment.heading.group.heading_ids
              investment_brothers_group = Budget::Investment.where(author_id: user.id).where(heading_id: heading_brothers)
              investment.budget.phase == "accepting" && investment_brothers_group.size < 1
            end

          end

          if Budget.current.investments.where(author_id: user.id).where(feasibility: ['undecided', 'feasible']).count < 2
            can :new, Budget::Investment
          else
            cannot :new, Budget::Investment
            cannot :create, Budget::Investment
          end

          if user.organization? && !user.organization.verified?
            cannot :create, Budget::Investment
          end

        end
####################################################### fin mio
        can :vote, Legislation::Proposal
        can :create, Legislation::Answer

        can :create, Budget::Investment,               budget: { phase: "accepting" }
        can :update, Budget::Investment,               budget: { phase: "accepting" }, author_id: user.id
        can :suggest, Budget::Investment,              budget: { phase: "accepting" }
        can :destroy, Budget::Investment,              budget: { phase: ["accepting", "reviewing"] }, author_id: user.id
        can [:create, :destroy], ActsAsVotable::Vote,
          voter_id: user.id,
          votable_type: "Budget::Investment",
          votable: { budget: { phase: "selecting" }}

        budgets_current = Budget.includes(:investments).where(phase: ['selecting'])
        investment_ids = budgets_current.map { |b| b.investment_ids }.flatten

        if user.votes.for_budget_investments(investment_ids).size < 3
          can :vote, Budget::Investment, budget: { phase: "selecting" }
        else
          cannot :vote, Budget::Investment
        end

        can :vote, Legislation::Proposal
        can :vote_featured, Legislation::Proposal
        can :create, Legislation::Answer

        # can :create, Budget::Investment,               budget: { phase: "accepting" }
        # can :suggest, Budget::Investment,              budget: { phase: "accepting" }
        # can :destroy, Budget::Investment,              budget: { phase: ["accepting", "reviewing"] }, author_id: user.id
        # can :vote, Budget::Investment,                 budget: { phase: "selecting" }
        can [:show, :create], Budget::Ballot,          budget: { phase: "balloting" }
        can [:create, :destroy], Budget::Ballot::Line, budget: { phase: "balloting" }

        can :create, DirectMessage
        can :show, DirectMessage, sender_id: user.id

        can :answer, Poll do |poll|
          poll.answerable_by?(user)
        end
        can :answer, Poll::Question do |question|
          question.answerable_by?(user)
        end
        can :destroy, Poll::Answer do |answer|
          answer.author == user && answer.question.answerable_by?(user)
        end
      end

      can [:create, :show], ProposalNotification, proposal: { author_id: user.id }

      can [:create], Topic
      can [:update, :destroy], Topic, author_id: user.id

      can :disable_recommendations, [Debate, Proposal]
    end
  end
end
