require "rails_helper"

describe Polls::PollHeaderComponent do
  describe "geozones" do
    it "shows a text when the poll is geozone-restricted" do
      render_inline Polls::PollHeaderComponent.new(create(:poll, geozone_restricted_to: [create(:geozone)]))

      expect(page).to have_content "Only residents in the following areas can participate"
    end

    it "does not show the text when the poll isn't geozone-restricted" do
      render_inline Polls::PollHeaderComponent.new(create(:poll))

      expect(page).not_to have_content "Only residents in the following areas can participate"
    end
  end
end
