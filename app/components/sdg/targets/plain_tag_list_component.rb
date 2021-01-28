class SDG::Targets::PlainTagListComponent < ApplicationComponent
  include SDG::TagList

  private

    def record
      record_or_name
    end

    def tags
      [*target_tags, see_more_link].compact
    end

    def see_more_link
      options = super(targets)

      link_to(*options) if options.present?
    end

    def target_tags
      targets.sort[0..(limit.to_i - 1)].map do |target|
        tag.span(text(target), data: { code: target.code })
      end
    end

    def targets
      record.sdg_targets
    end

    def text(target)
      "#{SDG::Target.model_name.human} #{target.code}"
    end

    def i18n_namespace
      "targets"
    end
end
