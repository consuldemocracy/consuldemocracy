require "rails_helper"

describe Shared::DetailedInfoComponent do
  describe "flag actions" do
    it "is not shown to anonymous users" do
      render_inline Shared::DetailedInfoComponent.new(create(:debate))

      expect(page).not_to have_css ".flag-content"
    end

    it "is not shown when the record can't be flagged" do
      sign_in(create(:user))

      render_inline Shared::DetailedInfoComponent.new(create(:topic))

      expect(page).not_to have_css ".flag-content"
    end

    it "is not shown on previews" do
      sign_in(create(:user))

      render_inline Shared::DetailedInfoComponent.new(create(:debate), preview: true)

      expect(page).not_to have_css ".flag-content"
    end

    it "is shown to identified users when the record can be flagged" do
      sign_in(create(:user))

      render_inline Shared::DetailedInfoComponent.new(create(:debate))

      expect(page).to have_css ".flag-content"
    end
  end
end
