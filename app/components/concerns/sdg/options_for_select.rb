module SDG::OptionsForSelect
  extend ActiveSupport::Concern

  def goal_options(selected_code = nil)
    options_from_collection_for_select(SDG::Goal.order(:code), :code, :code_and_title, selected_code)
  end

  def target_options(selected_code = nil)
    targets = SDG::Target.all + SDG::LocalTarget.all

    options_from_collection_for_select(targets.sort, :code, :code, selected_code)
  end
end
