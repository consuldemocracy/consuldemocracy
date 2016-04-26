module BallotsHelper

  def added_to_ballot?(ballot, spending_proposal)
    ballot.spending_proposals.include?(spending_proposal)
  end

  def progress_bar_width(amount_available, amount_spent)
    (amount_spent/amount_available.to_f * 100).to_s + "%"
  end

end