require "rails_helper"

describe Shared::MapLocationComponent do
  describe "remove marker button" do
    it "is not rendered when there's no form" do
      map_location = build(:map_location, proposal: Proposal.new)

      render_inline Shared::MapLocationComponent.new(map_location)

      expect(page).not_to have_button "Remove map marker"
    end

    it "is not rendered when there's no mappable" do
      map_location = build(:map_location)
      form = ConsulFormBuilder.new(:map_location, map_location, ApplicationController.new.view_context, {})

      render_inline Shared::MapLocationComponent.new(map_location, form: form)

      expect(page).not_to have_button "Remove map marker"
    end

    it "is rendered when there's a form and a mappable" do
      map_location = build(:map_location, proposal: Proposal.new)
      form = ConsulFormBuilder.new(:map_location, map_location, ApplicationController.new.view_context, {})

      render_inline Shared::MapLocationComponent.new(map_location, form: form)

      expect(page).to have_button "Remove map marker"
    end
  end
end
