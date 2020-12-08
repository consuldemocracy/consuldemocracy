class SDGManagement::MenuComponent < ApplicationComponent
  include LinkListHelper

  private

    def links
      [goals_link]
    end

    def goals_link
      [t("sdg_management.menu.sdg_content"), sdg_management_goals_path, sdg?, class: "goals-link"]
    end

    def sdg?
      %w[goals targets local_targets].include?(controller_name)
    end
end
