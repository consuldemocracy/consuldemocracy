class SDG::Targets::TagListComponent < ApplicationComponent
  include SDG::TagList

  private

    def record
      record_or_name
    end

    def links
      [*target_links, see_more_link(targets)]
    end

    def target_links
      targets.sort[0..(limit.to_i - 1)].map do |target|
        [
          "#{SDG::Target.model_name.human} #{target.code}",
          index_by_target(target),
          title: filter_text(target),
          data: { code: target.code }
        ]
      end
    end

    def targets
      record.sdg_targets
    end

    def index_by_target(target)
      index_by(target: target.code)
    end

    def i18n_namespace
      "targets"
    end
end
