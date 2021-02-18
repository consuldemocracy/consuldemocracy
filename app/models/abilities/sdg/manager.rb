class Abilities::SDG::Manager
  include CanCan::Ability

  def initialize(user)
    merge Abilities::Common.new(user)

    can :read, ::SDG::Target
    can :manage, ::SDG::LocalTarget
    can [:read, :update, :destroy], Widget::Card, cardable_type: "SDG::Phase"
    can(:create, Widget::Card) { |card| card.cardable_type == "SDG::Phase" }
  end
end
