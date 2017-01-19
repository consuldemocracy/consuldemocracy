module OfficingHelper

  def officer_assignments_select_options(officer_assignments)
    options = []
    officer_assignments.each do |oa|
      options << ["#{oa.booth_assignment.booth.name}: #{l(oa.date.to_date, format: :long)}", oa.id]
    end
    options_for_select(options)
  end

end