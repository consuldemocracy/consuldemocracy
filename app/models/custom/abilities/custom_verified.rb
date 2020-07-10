module Abilities
  class CustomVerified
    include CanCan::Ability

    def initialize(user)
      if user.level_two_or_three_verified? && user.geozone.present?
        can [:create, :created], Proposal, geozone_id: user.geozone_id
      end
    end
  end
end
