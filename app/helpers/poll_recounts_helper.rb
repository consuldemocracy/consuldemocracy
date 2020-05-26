module PollRecountsHelper
  def total_recounts_by_booth(booth_assignment)
    if booth_assignment.recounts.any?
      booth_assignment.recounts.sum(:total_amount) +
      booth_assignment.recounts.sum(:white_amount) +
      booth_assignment.recounts.sum(:null_amount)
    end
  end
end
