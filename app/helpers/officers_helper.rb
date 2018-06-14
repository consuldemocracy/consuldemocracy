module OfficersHelper

  def officer_label(officer)
    truncate([officer.name, officer.email].compact.join(' - '), length: 100)
  end

  def final_recount_shift?
    current_user.poll_officer.officer_assignments.final.where(date: Time.current.to_date)
  end

end