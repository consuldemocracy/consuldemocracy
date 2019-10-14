module Abilities
  class Common
    include CanCan::Ability

    def initialize(user)
      self.merge Abilities::Everyone.new(user)

      can [:read, :update], User, id: user.id

      can :read, Debate
      cannot :update, Debate # GET-53

      can :read, Proposal
      can :update, Proposal do |proposal|
        proposal.editable_by?(user)
      end
      can [:retire_form, :retire], Proposal, author_id: user.id

      can :read, SpendingProposal

      #GET-53
      cannot :create, Comment
      cannot :create, Debate
      cannot :create, Proposal
      cannot :suggest, Debate

      can :suggest, Proposal

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

      cannot :vote, Comment do |comment|
        comment.commentable.try(:likes_disallowed?)
      end

      if user.level_two_or_three_verified?


        can :create, Proposal #GET-104

        can :vote, Proposal
        can :vote_featured, Proposal
        can :vote, SpendingProposal
        can :create, SpendingProposal

        can :create, Budget::Investment,               budget: { phase: "accepting" }
        can :vote,   Budget::Investment,               budget: { phase: "accepting" } #GET-65


        can [:show, :create], Budget::Ballot,          budget: { phase: "balloting" }
        can [:confirm], Budget::Ballot,          budget: { phase: "balloting" }, "completed?" => true #, "confirmed?" => false #GET-125 #GET-125
        can [:commit, :resend_code], Budget::Ballot,          budget: { phase: "balloting" }, "notified?" => true #, "confirmed?" => false #GET-125 #GET-125
        can [:discard], Budget::Ballot,          budget: { phase: "balloting" }, "confirmed_or_notified?" => true #, "confirmed?" => true #GET-125
        can [:create, :destroy], Budget::Ballot::Line, budget: { phase: "balloting" }, ballot: { "unconfirmed?" => true, "not_notified?" => true } #GET-125

        can :create, DirectMessage
        can :show, DirectMessage, sender_id: user.id

        can :answer, Poll do |poll|
          poll.answerable_by?(user)
        end
        can :answer, Poll::Question do |question|
          question.answerable_by?(user)
        end
        can :create, Comment,  parent_id: nil
      end

      if user.verified_organization?
        can :create, Budget::Investment, budget: { phase: "accepting" }
        can :create, Comment,  parent_id: nil
        can :create, Proposal
      end

      can [:create, :show], ProposalNotification, proposal: { author_id: user.id }

      can :create, Annotation

      can [:update, :destroy], Annotation, user_id: user.id

      # GET- 
      can :destroy, Follow, user_id: user.id
      can :create, Follow, user_id: user.id
    end
  end
end
