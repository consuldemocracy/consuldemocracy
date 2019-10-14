module ConsulAssemblies
  module Abilities
    class Common
      include CanCan::Ability

      def initialize(user)


        # not verified with census permissions
        cannot :create, ConsulAssemblies::Proposal
        cannot :read, ConsulAssemblies::Meeting do |meeting|
          meeting.unpublished?
        end

        # Verified with census permissions
        if user.level_two_or_three_verified?

          can :create, ConsulAssemblies::Proposal, meeting: { accepting_proposals?: true }
        end
      end
    end
  end
end
