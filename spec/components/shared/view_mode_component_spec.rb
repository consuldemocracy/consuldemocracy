require "rails_helper"

describe Shared::ViewModeComponent do
  describe "main element" do
    it "uses a default class by default" do
      with_request_url("/example") do
        render_inline Shared::ViewModeComponent.new

        expect(page).to have_css ".view-mode.default"
        expect(page).not_to have_css ".view-mode.minimal"
      end
    end

    it "uses a default class when the defaut mode is specified" do
      with_request_url("/example?view=default") do
        render_inline Shared::ViewModeComponent.new

        expect(page).to have_css ".view-mode.default"
        expect(page).not_to have_css ".view-mode.minimal"
      end
    end

    it "uses a minimal class the minimal mode is specified" do
      with_request_url("/example?view=minimal") do
        render_inline Shared::ViewModeComponent.new

        expect(page).to have_css ".view-mode.minimal"
        expect(page).not_to have_css ".view-mode.default"
      end
    end
  end

  describe "view mode list" do
    it "links to the list mode and marks cards mode as active by default" do
      with_request_url("/example") do
        render_inline Shared::ViewModeComponent.new

        expect(page).to have_css "li", count: 2
        expect(page).to have_link "List", href: "/example?view=minimal"
        expect(page).to have_link count: 1
        expect(page).to have_css "li.is-active", exact_text: "Cards", normalize_ws: true
      end
    end

    it "links to the list mode and marks cards mode as active when default is specified" do
      with_request_url("/example?view=default") do
        render_inline Shared::ViewModeComponent.new

        expect(page).to have_css "li", count: 2
        expect(page).to have_link "List", href: "/example?view=minimal"
        expect(page).to have_link count: 1
        expect(page).to have_css "li.is-active", exact_text: "Cards", normalize_ws: true
      end
    end

    it "links to the cards mode and marks list mode asactive when minimal is specified" do
      with_request_url("/example?view=minimal") do
        render_inline Shared::ViewModeComponent.new

        expect(page).to have_css "li", count: 2
        expect(page).to have_link "Cards", href: "/example?view=default"
        expect(page).to have_link count: 1
        expect(page).to have_css "li.is-active", exact_text: "List", normalize_ws: true
      end
    end
  end
end
