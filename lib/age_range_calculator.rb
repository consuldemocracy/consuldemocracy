class AgeRangeCalculator

  MIN_AGE = 16
  MAX_AGE = 1.0/0.0 # Infinity
  RANGES = [ (MIN_AGE..25), (26..40), (41..60), (61..MAX_AGE) ]

  def self.range_from_birthday(dob)
    # Inspired by: http://stackoverflow.com/questions/819263/get-persons-age-in-ruby/2357790#2357790
    now = Time.current.to_date
    age = now.year - dob.year - ((now.month > dob.month || (now.month == dob.month && now.day >= dob.day)) ? 0 : 1)

    index = RANGES.find_index { |range| range.include?(age) }
    index ? RANGES[index] : nil
  end
end
