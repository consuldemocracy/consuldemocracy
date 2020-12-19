class Abilities::SDG::Manager
  include CanCan::Ability

  def initialize(user)
    merge Abilities::Common.new(user)

    can :read, ::SDG::Target
  end
end
