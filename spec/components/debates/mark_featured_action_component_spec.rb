require "rails_helper"

describe Debates::MarkFeaturedActionComponent do
  let(:debate) { create(:debate) }

  it "is not rendered for regular users" do
    sign_in(create(:user, :verified))

    render_inline Debates::MarkFeaturedActionComponent.new(debate)

    expect(page).not_to be_rendered
  end

  context "administradors", :admin do
    it "renders a button to mark debates as featured" do
      render_inline Debates::MarkFeaturedActionComponent.new(debate)

      expect(page).to have_button "Featured"
      expect(page).to have_button count: 1
    end

    it "renders a button to unmark featured debates" do
      debate = create(:debate, featured_at: Time.current)

      render_inline Debates::MarkFeaturedActionComponent.new(debate)

      expect(page).to have_button "Unmark featured"
      expect(page).to have_button count: 1
    end
  end
end
