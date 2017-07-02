require 'rails_helper'

describe Ahoy::DataSource do
  describe '#build' do
    before :each do
      time_1 = DateTime.parse("2015-01-01").in_time_zone
      time_2 = DateTime.parse("2015-01-02").in_time_zone
      time_3 = DateTime.parse("2015-01-03").in_time_zone

      create :ahoy_event, name: 'foo', time: time_1
      create :ahoy_event, name: 'foo', time: time_1
      create :ahoy_event, name: 'foo', time: time_2
      create :ahoy_event, name: 'bar', time: time_1
      create :ahoy_event, name: 'bar', time: time_3
      create :ahoy_event, name: 'bar', time: time_3
    end

    it 'should work without data sources' do
      ds = Ahoy::DataSource.new
      expect(ds.build).to eq x: []
    end

    it 'should work with single data sources' do
      ds = Ahoy::DataSource.new
      ds.add 'foo', Ahoy::Event.where(name: 'foo').group_by_day(:time).count
      expect(ds.build).to eq :x => ["2015-01-01", "2015-01-02"], "foo" => [2, 1]
    end

    it 'should combine data sources' do
      ds = Ahoy::DataSource.new
      ds.add 'foo', Ahoy::Event.where(name: 'foo').group_by_day(:time).count
      ds.add 'bar', Ahoy::Event.where(name: 'bar').group_by_day(:time).count
      expect(ds.build).to eq :x => ["2015-01-01", "2015-01-02", "2015-01-03"], "foo" => [2, 1, 0], "bar" => [1, 0, 2]
    end
  end
end
