require "rails_helper"

describe Ahoy::DataSource do
  describe "#build" do
    before do
      time_1 = Time.zone.local(2015, 01, 01)
      time_2 = Time.zone.local(2015, 01, 02)
      time_3 = Time.zone.local(2015, 01, 03)

      create :ahoy_event, name: "foo", time: time_1
      create :ahoy_event, name: "foo", time: time_1
      create :ahoy_event, name: "foo", time: time_2
      create :ahoy_event, name: "bar", time: time_1
      create :ahoy_event, name: "bar", time: time_3
      create :ahoy_event, name: "bar", time: time_3
    end

    it "works without data sources" do
      ds = described_class.new
      expect(ds.build).to eq x: []
    end

    it "works with single data sources" do
      ds = described_class.new
      ds.add "foo", Ahoy::Event.where(name: "foo").group_by_day(:time).count
      expect(ds.build).to eq :x => ["2015-01-01", "2015-01-02"], "foo" => [2, 1]
    end

    it "combines data sources" do
      ds = described_class.new
      ds.add "foo", Ahoy::Event.where(name: "foo").group_by_day(:time).count
      ds.add "bar", Ahoy::Event.where(name: "bar").group_by_day(:time).count
      expect(ds.build).to eq :x => ["2015-01-01", "2015-01-02", "2015-01-03"], "foo" => [2, 1, 0], "bar" => [1, 0, 2]
    end
  end
end
