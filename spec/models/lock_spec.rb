require "rails_helper"

describe Lock do

  let(:lock) { create(:lock) }

  describe "#locked?" do
    it "returns true if locked_until is after the current time" do
      lock.locked_until = 1.day.from_now
      expect(lock.locked?).to be true
    end

    it "return false if locked_until is before current time" do
      lock.locked_until = 1.day.ago
      expect(lock.locked?).to be false
    end
  end

  describe "#lock_time" do
    it "increases exponentially with number of tries" do
      lock.tries = 5
      lock.save
      expect(lock.reload.lock_time).to be_between(30.minutes.from_now, 35.minutes.from_now)

      lock.tries = 10
      lock.save
      expect(lock.reload.lock_time).to be_between(16.hours.from_now, 18.hours.from_now)

      lock.tries = 15
      lock.save
      expect(lock.reload.lock_time).to be_between(21.days.from_now, 23.days.from_now)
    end
  end

  describe "#too_many_tries?" do
    it "returns true if number of tries is multiple of 5" do
      lock.tries = 5
      expect(lock.too_many_tries?).to be true

      lock.tries = 10
      expect(lock.too_many_tries?).to be true

      lock.tries = 15
      expect(lock.too_many_tries?).to be true
    end

    it "returns false if number of tries is not multiple of 5" do
      lock.tries = 0
      expect(lock.too_many_tries?).to be false

      lock.tries = 1
      expect(lock.too_many_tries?).to be false

      lock.tries = 6
      expect(lock.too_many_tries?).to be false
    end
  end

end
