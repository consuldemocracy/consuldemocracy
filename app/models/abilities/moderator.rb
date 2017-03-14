module Abilities
  class Moderator
    include CanCan::Ability

    def initialize(user)
      self.merge Abilities::Moderation.new(user)

      can [:valuate], Budget::Investment
      can [:hide], Budget::Investment
      can :comment_as_moderator, [Debate, Comment, Proposal, Budget::Investment]

      can :create, DirectMessage
      can :show, DirectMessage, sender_id: user.id
    end
  end
end
