module AUE::OptionsForSelect
  extend ActiveSupport::Concern

  def aue_goal_options(selected_code = nil)
    options_from_collection_for_select(AUE::Goal.order(:code), :code, :code_and_title, selected_code)
  end
end
