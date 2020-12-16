module Abilities
  class SDG::Manager
    include CanCan::Ability

    def initialize(user)
      merge Abilities::Common.new(user)

      can :read, ::SDG::Goal
      can :read, ::SDG::Target
    end
  end
end
