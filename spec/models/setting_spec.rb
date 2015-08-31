require 'rails_helper'

describe Setting do

  it "should be accesible by key" do
    create(:setting, key: "Important Setting", value: "42")

    expect(Setting.value_for("Important Setting")).to eq("42")
  end

  it "should be nil if key does not exist" do
    expect(Setting.value_for("Undefined key")).to be_nil
  end

end