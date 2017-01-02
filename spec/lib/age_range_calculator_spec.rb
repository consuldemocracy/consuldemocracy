require 'rails_helper'

describe AgeRangeCalculator do
  subject { AgeRangeCalculator }

  describe '::range_from_birthday' do
    it 'returns the age range' do
      expect(subject::range_from_birthday(Time.current - 1.year)).to eq(nil)
      expect(subject::range_from_birthday(Time.current - 26.year)).to eq(26..40)
      expect(subject::range_from_birthday(Time.current - 60.year)).to eq(41..60)
      expect(subject::range_from_birthday(Time.current - 200.year)).to eq(61..subject::MAX_AGE)
    end
  end
end
