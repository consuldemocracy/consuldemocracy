require "rails_helper"

describe Ahoy::DataSource do
  describe "#build" do
    let(:january_first) { Time.zone.local(2015, 01, 01) }
    let(:january_second) { Time.zone.local(2015, 01, 02) }
    let(:january_third) { Time.zone.local(2015, 01, 03) }

    it "works without data sources" do
      ds = Ahoy::DataSource.new
      expect(ds.build).to eq x: []
    end

    it "works with single data sources" do
      ds = Ahoy::DataSource.new
      ds.add "foo", { january_first => 2, january_second => 1 }
      expect(ds.build).to eq :x => ["2015-01-01", "2015-01-02"], "foo" => [2, 1]
    end

    it "combines data sources" do
      ds = Ahoy::DataSource.new
      ds.add "foo", { january_first => 2, january_second => 1 }
      ds.add "bar", { january_first => 1, january_third => 2 }
      expect(ds.build).to eq :x => ["2015-01-01", "2015-01-02", "2015-01-03"],
                             "foo" => [2, 1, 0],
                             "bar" => [1, 0, 2]
    end

    it "returns data ordered by dates" do
      ds = Ahoy::DataSource.new
      ds.add "foo", { january_third => 2, january_second => 1 }
      ds.add "bar", { january_first => 2, january_second => 1 }

      expect(ds.build).to eq :x => ["2015-01-01", "2015-01-02", "2015-01-03"],
                             "foo" => [0, 1, 2],
                             "bar" => [2, 1, 0]
    end
  end
end
