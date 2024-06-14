require "rails_helper"

describe Admin::MenuComponent, controller: Admin::NewslettersController do
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
end
