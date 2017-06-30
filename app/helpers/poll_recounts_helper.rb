module PollRecountsHelper

  def recount_for_date(recounts, date)
    recounts.select {|r| r.date == date}.first
  end

  def booth_assignment_sum_recounts(ba)
    ba.recounts.any? ? ba.recounts.to_a.sum(&:count) : nil
  end

  def booth_assignment_sum_final_recounts(ba)
    ba.final_recounts.any? ? ba.final_recounts.to_a.sum(&:count) : nil
  end

end