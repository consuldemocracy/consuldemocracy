class SDG::Goals::TagListComponent < ApplicationComponent
  include SDG::TagList

  private

    def association_name
      :sdg_goals
    end

    def related_model
      record.class
    end
end
