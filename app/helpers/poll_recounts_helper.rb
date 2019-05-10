module PollRecountsHelper

  def total_recounts_by_booth(booth_assignment)
    booth_assignment.recounts.any? ? booth_assignment.recounts.to_a.sum(&:total_amount) : nil
  end

end
