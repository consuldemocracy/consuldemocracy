class Shared::FlagActionsComponent < ApplicationComponent
  attr_reader :flaggable, :divider
  alias_method :divider?, :divider
  use_helpers :current_user

  def initialize(flaggable, divider: nil)
    @flaggable = flaggable
    @divider = divider
  end

  private

    def show_flag_action?
      current_user && !own_flaggable? && !flagged?
    end

    def show_unflag_action?
      current_user && !own_flaggable? && flagged?
    end

    def own_flaggable?
      if flaggable.is_a?(Comment)
        flaggable.user_id == current_user.id
      else
        flaggable.author_id == current_user.id
      end
    end

    def flagged?
      Flag.flagged?(current_user, flaggable)
    end
end
