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
          code_and_title(goal),
          goal.targets.sort.map { |target| [code_and_title(target), target.id] }
        ]
      end
      grouped_options_for_select(grouped_targets, local_target.target_id)
    end

    def code_and_title(resource)
      "#{resource.code} #{resource.title}"
    end
end
