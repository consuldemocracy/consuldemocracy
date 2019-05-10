require "rails_helper"

describe Age do
  describe ".in_years" do
    it "handles nils" do
      expect(described_class.in_years(nil)).to be_nil
    end

    it "calculates age correctly for common dates" do
      d = Date.new(1980, 3, 13)
      expect(described_class.in_years(d, Date.new(2000, 3, 12))).to eq(19)
      expect(described_class.in_years(d, Date.new(2000, 3, 13))).to eq(20)
      expect(described_class.in_years(d, Date.new(2000, 3, 14))).to eq(20)
    end

    it "calculates age correctly for people born near a year's limit" do
      d = Date.new(1980, 12, 31)
      expect(described_class.in_years(d, Date.new(2000, 12, 30))).to eq(19)
      expect(described_class.in_years(d, Date.new(2000, 12, 31))).to eq(20)
      expect(described_class.in_years(d, Date.new(2001, 1,  1))).to eq(20)

      d = Date.new(1980, 1, 1)
      expect(described_class.in_years(d, Date.new(2000, 12, 31))).to eq(20)
      expect(described_class.in_years(d, Date.new(2001,  1,  1))).to eq(21)
      expect(described_class.in_years(d, Date.new(2001,  1,  2))).to eq(21)
    end

    it "calculates age correctly for people born around February the 29th" do
      # 1980 and 2000 are leap years. 2001 is a regular year
      d = Date.new(1980, 2, 29)
      expect(described_class.in_years(d, Date.new(2000,  2, 27))).to eq(19)
      expect(described_class.in_years(d, Date.new(2000,  2, 28))).to eq(19)
      expect(described_class.in_years(d, Date.new(2000,  2, 29))).to eq(20)
      expect(described_class.in_years(d, Date.new(2000,  3, 1))).to eq(20)
      expect(described_class.in_years(d, Date.new(2001,  2, 27))).to eq(20)
      expect(described_class.in_years(d, Date.new(2001,  2, 28))).to eq(20)
      expect(described_class.in_years(d, Date.new(2001,  3, 1))).to eq(21)

      d = Date.new(1980, 2, 28)
      expect(described_class.in_years(d, Date.new(2000,  2, 27))).to eq(19)
      expect(described_class.in_years(d, Date.new(2000,  2, 28))).to eq(20)
      expect(described_class.in_years(d, Date.new(2000,  2, 29))).to eq(20)
      expect(described_class.in_years(d, Date.new(2000,  3, 1))).to eq(20)
      expect(described_class.in_years(d, Date.new(2001,  2, 27))).to eq(20)
      expect(described_class.in_years(d, Date.new(2001,  2, 28))).to eq(21)
      expect(described_class.in_years(d, Date.new(2001,  3, 1))).to eq(21)

      d = Date.new(1980, 3, 1)
      expect(described_class.in_years(d, Date.new(2000,  2, 27))).to eq(19)
      expect(described_class.in_years(d, Date.new(2000,  2, 28))).to eq(19)
      expect(described_class.in_years(d, Date.new(2000,  2, 29))).to eq(19)
      expect(described_class.in_years(d, Date.new(2000,  3, 1))).to eq(20)
      expect(described_class.in_years(d, Date.new(2001,  2, 27))).to eq(20)
      expect(described_class.in_years(d, Date.new(2001,  2, 28))).to eq(20)
      expect(described_class.in_years(d, Date.new(2001,  3, 1))).to eq(21)
    end
  end
end
