module Abilities
  module Officing
    class Voter
      include CanCan::Ability

      def initialize(user)
        can [:new, :thanks], Poll::Nvote
      end
    end
  end
end