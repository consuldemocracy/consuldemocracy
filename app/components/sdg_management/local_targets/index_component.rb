class SDGManagement::LocalTargets::IndexComponent < ApplicationComponent
  include SDGManagement::Header

  attr_reader :local_targets

  def initialize(local_targets)
    @local_targets = local_targets
  end

  private

    def title
      SDG::LocalTarget.model_name.human(count: 2).titleize
    end

    def attribute_name(attribute)
      SDG::LocalTarget.human_attribute_name(attribute)
    end

    def header_id(object)
      "#{dom_id(object)}_header"
    end

    def actions(local_target)
      render Admin::TableActionsComponent.new(
        local_target,
        edit_path: edit_sdg_management_local_target_path(local_target),
        destroy_path: sdg_management_local_target_path(local_target))
    end
end
