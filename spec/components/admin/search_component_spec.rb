require "rails_helper"

describe Admin::SearchComponent do
  describe "#hidden_current_filter_tag" do
    context "controller responds to current_filter", controller: ApplicationController do
      it "is present when the controller has a current filter" do
        allow(vc_test_controller).to receive(:current_filter).and_return("all")

        render_inline Admin::SearchComponent.new(label: "Search")

        expect(page).to have_field "filter", type: :hidden, with: "all"
      end

      it "is not present when the controller has no current filter" do
        render_inline Admin::SearchComponent.new(label: "Search")

        expect(page).not_to have_field "filter", type: :hidden
        expect(page).not_to have_field "filter"
      end
    end

    context "controller does not respond to current_filter", controller: ActionController::Base do
      it "is not present" do
        render_inline Admin::SearchComponent.new(label: "Search")

        expect(page).not_to have_field "filter", type: :hidden
        expect(page).not_to have_field "filter"
      end
    end
  end
end
