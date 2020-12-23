class Abilities::SDG::Manager
  include CanCan::Ability

  def initialize(user)
    merge Abilities::Common.new(user)

    can :read, ::SDG::Goal
    can :read, ::SDG::Target
    can :manage, ::SDG::LocalTarget
  end
end
