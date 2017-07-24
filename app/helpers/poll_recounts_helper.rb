module PollRecountsHelper

  def booth_assignment_sum_final_recounts(ba)
    ba.final_recounts.any? ? ba.final_recounts.to_a.sum(&:count) : nil
  end

end
