module OfficersHelper

  def officer_label(officer)
    truncate([officer.name, officer.email].compact.join(' - '), length: 100)
  end

  def vote_collection_shift?
    current_user.poll_officer.officer_assignments.where(date: Time.current.to_date).any?
  end

  def final_recount_shift?
    current_user.poll_officer.officer_assignments.final.where(date: Time.current.to_date).any?
  end

end
