module OfficingHelper

  def booths_for_officer_select_options(officer_assignments)
    options = []
    officer_assignments.each do |oa|
      options << [oa.booth_assignment.booth.name.to_s, oa.id]
    end
    options.sort! {|x, y| x[0] <=> y[0]}
    options_for_select(options, params[:oa])
  end

  def answer_result_value(question_id, answer_index)
    return nil if params.blank?
    return nil if params[:questions].blank?
    return nil if params[:questions][question_id.to_s].blank?
    params[:questions][question_id.to_s][answer_index.to_s]
  end

end
