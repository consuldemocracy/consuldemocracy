class Shared::ViewModeComponent < ApplicationComponent
  delegate :default_view_mode?, :current_path_with_query_params, to: :helpers

  private

    def view_mode
      if default_view_mode?
        "default"
      else
        "minimal"
      end
    end

    def secondary_view_mode
      if default_view_mode?
        "minimal"
      else
        "default"
      end
    end

    def secondary_view_mode_path
      current_path_with_query_params(view: secondary_view_mode)
    end
end
