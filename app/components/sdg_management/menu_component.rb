class SDGManagement::MenuComponent < ApplicationComponent
  include LinkListHelper

  private

    def links
      [goals_link, *relatable_links]
    end

    def goals_link
      [t("sdg_management.menu.sdg_content"), sdg_management_goals_path, sdg?, class: "goals-link"]
    end

    def relatable_links
      SDG::Related::RELATABLE_TYPES.map do |type|
        next unless setting["process.#{process_name(type)}"] && setting["sdg.process.#{process_name(type)}"]

        [
          t("sdg_management.menu.#{table_name(type)}"),
          relatable_type_path(type),
          controller_name == "relations" && params[:relatable_type] == type.tableize,
          class: "#{table_name(type).tr("_", "-")}-link"
        ]
      end
    end

    def sdg?
      %w[goals targets local_targets].include?(controller_name)
    end

    def relatable_type_path(type)
      {
        controller: "sdg_management/relations",
        action: :index,
        relatable_type: type.tableize
      }
    end

    def table_name(type)
      type.constantize.table_name
    end

    def process_name(type)
      process_name = type.split("::").first

      if process_name == "Legislation"
        "legislation"
      else
        process_name.constantize.table_name
      end
    end
end
