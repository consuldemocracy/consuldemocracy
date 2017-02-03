module AgeInYears
  def age_in_years(now = Time.now.utc.to_date)
    # reference: http://stackoverflow.com/questions/819263/get-persons-age-in-ruby#comment21200772_819263
    now.year - year - ((now.month > month || (now.month == month && now.day >= day)) ? 0 : 1)
  end
end

Date.include(AgeInYears)
