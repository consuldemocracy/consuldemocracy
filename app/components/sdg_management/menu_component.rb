class SDGManagement::MenuComponent < ApplicationComponent
  private

    def sdg?
      %w[goals targets local_targets].include?(controller_name)
    end
end
