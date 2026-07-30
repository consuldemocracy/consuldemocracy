class Officing::Results::FormComponent < ApplicationComponent
  attr_reader :poll, :officer_assignments
  delegate :booths_for_officer_select_options, to: :helpers

  def initialize(poll, officer_assignments)
    @poll = poll
    @officer_assignments = officer_assignments
  end

  private

    def answer_result_value(question_id, option_id)
      params.dig(:questions, question_id.to_s, option_id.to_s).to_i
    end
end
