class Shared::FlagActionsComponent < ApplicationComponent
  attr_reader :flaggable

  def initialize(flaggable)
    @flaggable = flaggable
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
