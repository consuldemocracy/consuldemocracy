class Officing::Results::FormComponent < ApplicationComponent
  attr_reader :poll, :officer_assignments
  use_helpers :booths_for_officer_select_options

  def initialize(poll, officer_assignments)
    @poll = poll
    @officer_assignments = officer_assignments
  end

  private

    def answer_result_value(question_id, option_index)
      return nil if params.blank?
      return nil if params[:questions].blank?
      return nil if params[:questions][question_id.to_s].blank?

      params[:questions][question_id.to_s][option_index.to_s]
    end
end
