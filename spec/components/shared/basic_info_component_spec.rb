require "rails_helper"

describe Shared::BasicInfoComponent do
  it "uses a <time> tag for the date" do
    render_inline Shared::BasicInfoComponent.new(
      create(:debate, created_at: Time.zone.local(2019, 6, 15, 17, 20, 0))
    )

    expect(page).to have_css "time", exact_text: "2019-06-15"
  end
end
