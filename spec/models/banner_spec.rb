require "rails_helper"

describe Banner do

  let(:banner) { build(:banner) }

  describe "Concerns" do
    it_behaves_like "acts as paranoid", :banner
  end

  it "is valid" do
    expect(banner).to be_valid
  end

end
