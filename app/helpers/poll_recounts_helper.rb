module PollRecountsHelper

  def recount_for_date(recounts, date)
    recounts.select {|r| r.date.to_date == date}.first
  end

end