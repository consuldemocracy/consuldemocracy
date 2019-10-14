module PollFinalRecountsHelper

  def final_recount_for_date(final_recounts, date)
    final_recounts.select {|f| f.date == date}.first
  end

end