require "rails_helper"

describe Layout::FooterComponent do
  describe "description links" do
    it "generates links that open in the same tab" do
      render_inline Layout::FooterComponent.new

      page.find(".info") do |info|
        expect(info).to have_css "a", count: 2
        expect(info).to have_css "a[rel~=nofollow]", count: 2
        expect(info).to have_css "a[rel~=external]", count: 2
        expect(info).not_to have_css "a[target]"
      end
    end
  end

  it "is not rendered when multitenancy_management_mode is enabled" do
    allow(Rails.application.config).to receive(:multitenancy_management_mode).and_return(true)
    render_inline Layout::FooterComponent.new

    expect(page).not_to be_rendered
  end
end
