module OfficersHelper

  def officer_label(officer)
    truncate([officer.name, officer.email].compact.join(' - '), length: 100)
  end

end