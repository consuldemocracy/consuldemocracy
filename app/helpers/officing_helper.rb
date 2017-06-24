module OfficingHelper

  def officer_assignments_select_options(officer_assignments)
    options = []
    officer_assignments.each do |oa|
      options << ["#{oa.booth_assignment.booth.name}: #{l(oa.date.to_date, format: :long)}", oa.id]
    end
    options_for_select(options)
  end

  def booths_for_officer_select_options(officer_assignments)
    options = []
    officer_assignments.each do |oa|
      options << [oa.booth_assignment.booth.name.to_s, oa.id]
    end
    options.sort! {|x, y| x[0]<=>y[0]}
    options_for_select(options, params[:oa])
  end

  def recount_to_compare_with_final_recount(final_recount)
    recount = final_recount.booth_assignment.recounts.select {|r| r.date == final_recount.date}.first
    recount.present? ? recount.count : "-"
  end

  def system_recount_to_compare_with_final_recount(final_recount)
    final_recount.booth_assignment.voters.select {|v| v.created_at.to_date == final_recount.date}.size
  end

  def answer_result_value(question_id, answer_index)
    return nil if params.blank?
    return nil if params[:questions].blank?
    return nil if params[:questions][question_id.to_s].blank?
    params[:questions][question_id.to_s][answer_index.to_s]
  end

end