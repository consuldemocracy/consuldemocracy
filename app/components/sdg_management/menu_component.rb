class SDGManagement::MenuComponent < ApplicationComponent
  private

    def sdg?
      controller_name == "goals" || controller_name == "targets"
    end
end
