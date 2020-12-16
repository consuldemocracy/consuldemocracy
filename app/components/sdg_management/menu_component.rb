class SDGManagement::MenuComponent < ApplicationComponent
  include LinkListHelper

  private

    def sdg?
      %w[goals targets local_targets].include?(controller_name)
    end
end
