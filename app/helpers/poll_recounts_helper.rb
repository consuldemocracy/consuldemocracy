module PollRecountsHelper

  def total_recounts_by_booth(booth_assignment)
    booth_assignment.total_results.any? ? booth_assignment.total_results.to_a.sum(&:amount) : nil
  end

end
