module Abilities
  class Tracker
    include CanCan::Ability

    def initialize(user)
      can :index, Budget
      can [:index, :show, :edit], Budget::Investment
      can :manage, Milestone
      can :manage, ProgressBar
    end
  end
end
