class AUE::Goals::TagListComponent < ApplicationComponent
  include AUE::TagList

  private

    def association_name
      :aue_goals
    end

    def related_model
      record.class
    end
end
