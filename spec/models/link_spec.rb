require "rails_helper"

describe Link do
  let(:action) { build :dashboard_action }

  it "is invalid when label is blank" do
    link = build(:link, linkable: action, label: "")
    expect(link).not_to be_valid
  end

  it "is invalid when url is blank" do
    link = build(:link, linkable: action, url: "")
    expect(link).not_to be_valid
  end
end
