class Shared::FlagActionsComponent < ApplicationComponent
  attr_reader :flaggable, :divider
  alias_method :divider?, :divider
  use_helpers :can?, :current_user

  def initialize(flaggable, divider: nil)
    @flaggable = flaggable
    @divider = divider
  end

  def render?
    can?(:flag, flaggable)
  end

  private

    def show_flag_action?
      !flagged?
    end

    def show_unflag_action?
      flagged?
    end

    def flagged?
      Flag.flagged?(current_user, flaggable)
    end
end
