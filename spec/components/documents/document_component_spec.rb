require "rails_helper"

describe Documents::DocumentComponent do
  let(:user) { create(:user) }
  let(:proposal) { create(:proposal, author: user) }
  let(:document) { create(:document, documentable: proposal) }
  let(:component) { Documents::DocumentComponent.new(document, show_destroy_link: true) }

  describe "Destroy action" do
    it "is not able when no user logged in" do
      render_inline component

      expect(page).not_to have_button "Delete document"
    end

    it "is able when documentable author is logged in" do
      sign_in(user)
      render_inline component

      expect(page).to have_button "Delete document"
    end

    it "administrators cannot destroy documentables they have not authored", :admin do
      render_inline component

      expect(page).not_to have_button "Delete document"
    end

    it "users cannot destroy documentables they have not authored" do
      login_as(create(:user))

      render_inline component

      expect(page).not_to have_button "Delete document"
    end
  end
end
