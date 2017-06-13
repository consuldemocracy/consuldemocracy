module Age
  def self.in_years(dob, now = Date.current)
    return nil if dob.blank?
    # reference: http://stackoverflow.com/questions/819263/get-persons-age-in-ruby#comment21200772_819263
    now.year - dob.year - (now.month > dob.month || (now.month == dob.month && now.day >= dob.day) ? 0 : 1)
  end
end
