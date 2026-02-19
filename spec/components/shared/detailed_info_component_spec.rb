require "rails_helper"

describe Shared::DetailedInfoComponent do
  it "uses a <time> tag for the date" do
    render_inline Shared::DetailedInfoComponent.new(
      create(:debate, created_at: Time.zone.local(2019, 6, 15, 17, 20, 0))
    )

    expect(page).to have_css "time", exact_text: "2019-06-15"
  end

  describe "flag actions" do
    it "is not shown to anonymous users" do
      render_inline Shared::DetailedInfoComponent.new(create(:debate))

      expect(page).not_to have_css ".flag-actions"
    end

    it "is not shown when the record can't be flagged" do
      sign_in(create(:user))

      render_inline Shared::DetailedInfoComponent.new(create(:topic))

      expect(page).not_to have_css ".flag-actions"
    end

    it "is not shown on previews" do
      sign_in(create(:user))

      render_inline Shared::DetailedInfoComponent.new(create(:debate), preview: true)

      expect(page).not_to have_css ".flag-actions"
    end

    it "is shown to identified users when the record can be flagged" do
      sign_in(create(:user))

      render_inline Shared::DetailedInfoComponent.new(create(:debate))

      expect(page).to have_css ".flag-actions"
    end
  end
end
