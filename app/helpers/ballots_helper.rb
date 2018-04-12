module BallotsHelper

  def added_to_ballot?(ballot, spending_proposal)
    ballot.spending_proposals.include?(spending_proposal)
  end

  def progress_bar_width(amount_available, amount_spent)
    (amount_spent / amount_available.to_f * 100).to_s + "%"
  end

  def css_for_ballot_geozone(geozone)
    return '' unless current_user.try(:ballot)
    current_user.ballot.geozone == geozone ? 'active' : ''
  end

  def district_wide_amount_spent(ballot)
    ballot.amount_spent(ballot.geozone)
  end

  def city_wide_amount_spent(ballot)
    ballot.amount_spent('all')
  end

end