module Age
  def self.in_years(dob, now = Time.now.utc.to_date)
    return nil unless dob.present?
    # reference: http://stackoverflow.com/questions/819263/get-persons-age-in-ruby#comment21200772_819263
    now.year - dob.year - ((now.month > dob.month || (now.month == dob.month && now.day >= dob.day)) ? 0 : 1)
  end
end
