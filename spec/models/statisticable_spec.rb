require "rails_helper"

describe Statisticable do
  before do
    dummy_stats = Class.new do
      include Statisticable
      attr_accessor :total
      stats_cache :total

      def full_cache_key_for(key)
        "dummy_stats/#{object_id}/#{key}"
      end

      def participants
        User.all
      end
      alias_method :participants_from_original_table, :participants

      def total_participants
        User.count
      end

      def participation_date
        Time.current
      end
    end

    stub_const("DummyStats", dummy_stats)
  end

  let(:resource) { double(id: 1, class: double(table_name: "")) }
  let(:stats) { DummyStats.new(resource) }

  describe "#gender?" do
    context "No participants" do
      it "is false" do
        expect(stats.gender?).to be false
      end
    end

    context "All participants have no defined gender" do
      before { create(:user, gender: nil) }

      it "is false" do
        expect(stats.gender?).to be false
      end
    end

    context "There's a male participant" do
      before { create(:user, gender: "male") }

      it "is true" do
        expect(stats.gender?).to be true
      end
    end

    context "There's a female participant" do
      before { create(:user, gender: "female") }

      it "is true" do
        expect(stats.gender?).to be true
      end
    end
  end

  describe "#age?" do
    context "No participants" do
      it "is false" do
        expect(stats.age?).to be false
      end
    end

    context "All participants have no defined age" do
      before { create(:user, date_of_birth: nil) }

      it "is false" do
        expect(stats.age?).to be false
      end
    end

    context "All participants have impossible ages" do
      before do
        create(:user, date_of_birth: 3.seconds.ago)
        create(:user, date_of_birth: 3000.years.ago)
      end

      it "is false" do
        expect(stats.age?).to be false
      end
    end

    context "There's a participant with a defined age" do
      before { create(:user, date_of_birth: 30.years.ago) }

      it "is true" do
        expect(stats.age?).to be true
      end
    end

    context "Partipation took place a long time ago" do
      before do
        create(:user, date_of_birth: 2000.years.ago)
        allow(stats).to receive(:participation_date).and_return(1900.years.ago)
      end

      it "is true" do
        expect(stats.age?).to be true
      end
    end
  end

  describe "#geozone?" do
    context "No participants" do
      it "is false" do
        expect(stats.geozone?).to be false
      end
    end

    context "All participants have no defined geozone" do
      before { create(:user, geozone: nil) }

      it "is false" do
        expect(stats.geozone?).to be false
      end
    end

    context "There's a participant with a defined geozone" do
      before { create(:user, geozone: create(:geozone)) }

      it "is true" do
        expect(stats.geozone?).to be true
      end
    end
  end

  describe "#total_no_demographic_data" do
    it "returns users with no defined gender" do
      create(:user, gender: nil)

      expect(stats.total_no_demographic_data).to be 1
    end

    it "returns users with no defined age" do
      create(:user, gender: "female", date_of_birth: nil)

      expect(stats.total_no_demographic_data).to be 1
    end

    it "returns users with no defined geozone" do
      create(:user, gender: "female", geozone: nil)

      expect(stats.total_no_demographic_data).to be 1
    end

    it "returns users with no defined gender, age nor geozone" do
      create(:user, gender: nil, date_of_birth: nil, geozone: nil)

      expect(stats.total_no_demographic_data).to be 1
    end

    it "doesn't return users with defined gender, age and geozone" do
      create(:user, gender: "male", date_of_birth: 20.years.ago, geozone: create(:geozone))

      expect(stats.total_no_demographic_data).to be 0
    end
  end

  describe "#stats_methods" do
    it "includes total participants" do
      expect(stats.stats_methods).to include(:total_participants)
    end

    context "no gender stats" do
      before { allow(stats).to receive(:gender?).and_return(false) }

      it "doesn't include gender methods" do
        expect(stats.stats_methods).not_to include(:total_male_participants)
      end
    end

    context "no age stats" do
      before { allow(stats).to receive(:age?).and_return(false) }

      it "doesn't include age methods" do
        expect(stats.stats_methods).not_to include(:participants_by_age)
      end
    end

    context "no geozone stats" do
      before { allow(stats).to receive(:geozone?).and_return(false) }

      it "doesn't include age methods" do
        expect(stats.stats_methods).not_to include(:participants_by_geozone)
      end
    end

    context "all gender, age and geozone stats" do
      before do
        allow(stats).to receive_messages(gender?: true, age?: true, geozone?: true)
      end

      it "includes all stats methods" do
        expect(stats.stats_methods).to include(:total_male_participants)
        expect(stats.stats_methods).to include(:participants_by_age)
        expect(stats.stats_methods).to include(:participants_by_geozone)
      end
    end
  end

  describe "#generate" do
    it "drops the temporary table after finishing" do
      stats.generate

      expect { stats.send(:participants_class).first }.to raise_exception(ActiveRecord::StatementInvalid)
    end

    it "can be executed twice without errors" do
      stats.generate

      expect { stats.generate }.not_to raise_exception
    end

    it "can be executed twice in parallel since it uses a transaction" do
      other_stats = DummyStats.new(stats.resource)

      [stats, other_stats].map do |stat|
        Thread.new { stat.generate }
      end.each(&:join)
    end
  end

  describe "cache", :with_cache do
    it "expires the cache at the end of the day by default" do
      time = Time.current

      travel_to(time) do
        stats.total = 6

        expect(stats.total).to eq 6

        stats.total = 7

        expect(stats.total).to eq 6
      end

      travel_to(time.end_of_day) do
        expect(stats.total).to eq 6
      end

      travel_to(time.end_of_day + 1.second) do
        expect(stats.total).to eq 7
      end
    end

    it "does not use the cache with cache: false" do
      stats = DummyStats.new(resource, cache: false)
      time = Time.current

      travel_to(time) do
        stats.total = 6

        expect(stats.total).to eq 6

        stats.total = 7

        expect(stats.total).to eq 7
      end
    end
  end
end
