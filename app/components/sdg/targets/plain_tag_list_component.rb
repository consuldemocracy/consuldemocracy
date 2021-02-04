class SDG::Targets::PlainTagListComponent < ApplicationComponent
  include SDG::TagList

  private

    def tags
      [*target_tags, see_more_link].select(&:present?)
    end

    def target_tags
      tag_records.map do |target|
        tag.span(render(SDG::TagComponent.new(target)), data: { code: target.code })
      end
    end

    def association_name
      :sdg_targets
    end
end
