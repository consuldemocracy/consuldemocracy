class SDGManagement::MenuComponent < ApplicationComponent
  private

    def sdg?
      controller_name == "goals"
    end
end
