require "rails_helper"

describe Admin::MenuComponent, :admin, controller: Admin::NewslettersController do
  it "disables all buttons when JavaScript isn't available" do
    render_inline Admin::MenuComponent.new

    expect(page).to have_button disabled: true
    expect(page).not_to have_button disabled: false
  end

  it "expands the current section" do
    render_inline Admin::MenuComponent.new

    expect(page).to have_css "button[aria-expanded='true']", exact_text: "Messages to users"
  end

  it "does not expand other sections" do
    render_inline Admin::MenuComponent.new

    expect(page).to have_css "button[aria-expanded='false']", exact_text: "Settings"
  end

  it "only renders the multitenancy and administrators sections in multitenancy management mode" do
    allow(Rails.application.config).to receive(:multitenancy_management_mode).and_return(true)

    render_inline Admin::MenuComponent.new

    expect(page).to have_css "#admin_menu"
    expect(page).to have_link "Multitenancy"
    expect(page).to have_link "Administrators"
    expect(page).to have_css "a", count: 2
  end

  describe "#polls_link" do
    it "is marked as current when managing poll options",
       controller: Admin::Poll::Questions::OptionsController do
      render_inline Admin::MenuComponent.new

      expect(page).to have_css "[aria-current]", exact_text: "Polls"
    end

    it "is marked as current when managing poll options content",
       controller: Admin::Poll::Questions::Options::VideosController do
      render_inline Admin::MenuComponent.new

      expect(page).to have_css "[aria-current]", exact_text: "Polls"
    end
  end

  describe "#locales_link" do
    it "is present when two or more locales are available" do
      render_inline Admin::MenuComponent.new

      expect(page).to have_link "Languages"
    end

    it "is present when two or more locales are available but only one is enabled" do
      Setting["locales.enabled"] = "en"

      render_inline Admin::MenuComponent.new

      expect(page).to have_link "Languages"
    end

    it "is not present when only one locale is available" do
      allow(I18n).to receive(:available_locales).and_return([:en])

      render_inline Admin::MenuComponent.new

      expect(page).not_to have_link "Languages"
    end
  end
end
