class SDGManagement::MenuComponent < ApplicationComponent
  include LinkListHelper

  private

    def links
      [goals_link, homepage_link, *relatable_links]
    end

    def goals_link
      [item_text("sdg_content"), sdg_management_goals_path, sdg?, class: "goals-link"]
    end

    def homepage_link
      [item_text("sdg_homepage"), sdg_management_homepage_path, homepage?, class: "homepage-link"]
    end

    def relatable_links
      SDG::Related::RELATABLE_TYPES.map do |type|
        next unless SDG::ProcessEnabled.new(type).enabled?

        [
          item_text(table_name(type)),
          relatable_type_path(type),
          controller_name == "relations" && params[:relatable_type] == type.tableize,
          class: "#{table_name(type).tr("_", "-")}-link"
        ]
      end
    end

    def sdg?
      %w[goals targets local_targets].include?(controller_name)
    end

    def homepage?
      controller_name == "homepage"
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

    def item_text(item)
      t("sdg_management.menu.#{item}")
    end
end
