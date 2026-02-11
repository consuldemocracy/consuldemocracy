require "rails_helper"

describe Shared::CheckAllNoneComponent do
  it "generates buttons with data-check-all and data-check-none" do
    render_inline Shared::CheckAllNoneComponent.new

    expect(page).to have_button count: 2

    page.find("li:first-child") do |check_all|
      expect(check_all).to have_button "Select all"
      expect(check_all).to have_css "button[type='button'][data-check-all]"
      expect(check_all).not_to have_css "[data-check-none]"
    end

    page.find("li:last-child") do |check_none|
      expect(check_none).to have_button "Select none"
      expect(check_none).to have_css "button[type='button'][data-check-none]"
      expect(check_none).not_to have_css "[data-check-all]"
    end
  end
end
