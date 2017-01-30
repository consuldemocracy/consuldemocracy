module Abilities
  class Officing::Voter
    include CanCan::Ability

    def initialize(user)
      can :new, Poll::Nvote, {user_id: user.id}#{ |poll| user.has_not_voted?(poll) }
      can :thanks, Poll::Nvote
    end
  end
end