require "rails_helper"

describe Shared::BannerComponent, type: :component do
  it "renders given a banner" do
    render_inline Shared::BannerComponent.new(create(:banner, title: "Vote now!"))

    expect(page.find(".banner")).to have_content "Vote now!"
  end

  it "renders given a section" do
    create(:banner, web_sections: [WebSection.find_by!(name: "debates")], title: "Debate banner")
    create(:banner, web_sections: [WebSection.find_by!(name: "proposals")], title: "Proposal banner")

    render_inline Shared::BannerComponent.new("debates")

    expect(page.find(".banner")).to have_content "Debate banner"
    expect(page).not_to have_content "Proposal banner"
  end

  context "several banners available in the same section" do
    before do
      create(:banner,
             web_sections: [WebSection.find_by!(name: "debates")],
             title: "First banner",
             description: "First description",
             target_url: "/first_target"
            )

      create(:banner,
             web_sections: [WebSection.find_by!(name: "debates")],
             title: "Second banner",
             description: "Second description",
             target_url: "/second_target"
            )
    end

    it "only renders one banner" do
      render_inline Shared::BannerComponent.new("debates")

      expect(page).to have_css ".banner", count: 1
    end

    it "consistently renders one banner" do
      render_inline Shared::BannerComponent.new("debates")

      if page.has_content?("First banner")
        expect(page).to have_content "First description"
        expect(page).to have_css "[href='/first_target']"
        expect(page).not_to have_content "Second banner"
      else
        expect(page).to have_content "Second description"
        expect(page).to have_css "[href='/second_target']"
      end
    end

    it "only renders active banners" do
      Banner.first.update!(post_ended_at: 1.day.ago)

      render_inline Shared::BannerComponent.new("debates")

      expect(page).to have_content "Second banner"
      expect(page).not_to have_content "First banner"
    end

    it "does not render anything with no active banners" do
      Banner.all.each { |banner| banner.update!(post_ended_at: 1.day.ago) }

      render_inline Shared::BannerComponent.new("debates")

      expect(page).not_to have_css ".banner"
    end
  end

  it "does not render anything given nil" do
    render_inline Shared::BannerComponent.new(nil)

    expect(page).not_to have_css ".banner"
  end
end
