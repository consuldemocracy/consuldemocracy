module PollRecountsHelper

  def recount_for_date(recounts, date)
    recounts.select {|r| r.date == date}.first
  end

end