require "rails_helper"

describe Documents::DocumentComponent do
  let(:user) { create(:user) }
  let(:proposal) { create(:proposal, author: user) }
  let(:document) { create(:document, documentable: proposal) }
  let(:component) { Documents::DocumentComponent.new(document, show_destroy_link: true) }

  describe "Delete document button" do
    it "is not shown when no user is logged in" do
      render_inline component

      expect(page).not_to have_button "Delete document"
    end

    it "is shown when the author is logged in" do
      sign_in(user)
      render_inline component

      expect(page).to have_button "Delete document"
    end

    it "is not shown when an administrator that isn't the author is logged in", :admin do
      render_inline component

      expect(page).not_to have_button "Delete document"
    end

    it "is not shown when a user that isn't the author is logged in" do
      login_as(create(:user))

      render_inline component

      expect(page).not_to have_button "Delete document"
    end
  end
end
