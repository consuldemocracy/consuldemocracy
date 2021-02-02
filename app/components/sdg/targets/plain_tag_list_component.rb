class SDG::Targets::PlainTagListComponent < ApplicationComponent
  include SDG::TagList

  private

    def record
      record_or_name
    end

    def tags
      [*target_tags, see_more_link(:sdg_targets)].select(&:present?)
    end

    def target_tags
      targets.sort[0..(limit.to_i - 1)].map do |target|
        tag.span(render(SDG::TagComponent.new(target)), data: { code: target.code })
      end
    end

    def targets
      record.sdg_targets
    end

    def i18n_namespace
      "targets"
    end
end
