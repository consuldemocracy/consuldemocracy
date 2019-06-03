module Abilities
  class Tracker
    include CanCan::Ability

    def initialize(user)
      tracker = user.tracker

      can :index, Budget
      can [:index, :show, :edit], Budget::Investment
      can :manage, Milestone
      can :manage, ProgressBar
    end
  end
end
