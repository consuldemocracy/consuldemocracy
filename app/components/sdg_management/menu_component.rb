class SDGManagement::MenuComponent < ApplicationComponent
  include LinkListHelper

  private

    def sdg?
      controller_name == "goals" || controller_name == "targets"
    end
end
