class SDGManagement::LocalTargets::FormComponent < ApplicationComponent
  include Header
  include TranslatableFormHelper
  include GlobalizeHelper

  attr_reader :local_target

  def initialize(local_target)
    @local_target = local_target
  end

  private

    def title
      if local_target.persisted?
        t("sdg_management.local_targets.edit.title")
      else
        t("sdg_management.local_targets.new.title")
      end
    end

    def form_url
      if local_target.persisted?
        sdg_management_local_target_path(local_target)
      else
        sdg_management_local_targets_path
      end
    end

    def target_options
      grouped_targets = SDG::Goal.order(:code).map do |goal|
        [
          goal.code_and_title,
          goal.targets.sort.map { |target| [target.code_and_title, target.id] }
        ]
      end
      grouped_options_for_select(grouped_targets, local_target.target_id)
    end
end
