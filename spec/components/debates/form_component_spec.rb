require "rails_helper"

describe Debates::FormComponent do
  before { sign_in(create(:user)) }

  describe "voice input hint" do
    it "is shown for the description field" do
      render_inline Debates::FormComponent.new(Debate.new)

      expect(page).to have_css ".help-text", text: "You can dictate using your device's voice typing."
    end
  end
end
