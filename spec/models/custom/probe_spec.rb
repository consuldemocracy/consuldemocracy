require 'rails_helper'

describe Probe do

  before(:each) do
    @probe = Probe.create(codename: 'test_probe')
    @probe_option = @probe.probe_options.create(code: '01' , name: 'First Option')
    @user = create(:user, :level_two)
  end

  describe "#option_voted_by" do
    it "is nil if user did not vote" do
      expect(@probe.option_voted_by(@user)).to eq(nil)
    end

    it "is nil if probe has no probe_options" do
      expect(Probe.create.option_voted_by(@user)).to eq(nil)
    end

    it "returns the probe_option voted by the user" do
      @probe_option.select(@user)
      expect(@probe.option_voted_by(@user)).to eq(@probe_option)
    end
  end
end