require 'rails_helper'

describe Setting do
  before do
    Setting["official_level_1_name"] = 'Stormtrooper'
  end

  it "should return the overriden setting" do
    expect(Setting['official_level_1_name']).to eq('Stormtrooper')
  end

  it "should should return nil" do
    expect(Setting['undefined_key']).to eq(nil)
  end

  it "should persist a setting on the db" do
    expect(Setting.where(key: 'official_level_1_name', value: 'Stormtrooper')).to exist
  end
end
