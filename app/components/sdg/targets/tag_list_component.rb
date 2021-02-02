class SDG::Targets::TagListComponent < ApplicationComponent
  include SDG::TagList

  private

    def association_name
      :sdg_targets
    end

    def related_model
      record.class
    end
end
