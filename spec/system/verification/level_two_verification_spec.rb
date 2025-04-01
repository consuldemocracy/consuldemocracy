require "rails_helper"

describe "Level two verification" do
  context "In Spanish, with no fallbacks" do
    before { allow(I18n.fallbacks).to receive(:[]).and_return([:es]) }

    scenario "Works normally" do
      user = create(:user)
      login_as(user)

      visit verification_path(locale: :es)
      verify_residence
    end
  end
end
