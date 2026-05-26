require "rails_helper"

describe "Consent for embedded videos" do
  let(:factory) { [:proposal, :legislation_proposal].sample }
  let(:proposal) { create(factory, video_url: "http://www.youtube.com/watch?v=a7UFm6ErMPU") }
  let(:youtube_embed_url) { "https://www.youtube-nocookie.com/embed/a7UFm6ErMPU" }

  scenario "requires confirmation before loading the video when the feature is enabled" do
    Setting["feature.gdpr.require_consent_for_embedded_videos"] = true

    visit polymorphic_path(proposal)

    within ".embedded-video" do
      expect(page).to have_content "you agree that your data may be transferred"
      expect(page).not_to have_css "iframe"
    end

    click_button "Watch video"

    within ".embedded-video" do
      expect(page).to have_css "iframe[src='#{youtube_embed_url}']"
    end
  end

  scenario "loads the video directly when the feature is disabled" do
    Setting["feature.gdpr.require_consent_for_embedded_videos"] = false

    visit polymorphic_path(proposal)

    within ".embedded-video" do
      expect(page).to have_css "iframe[src='#{youtube_embed_url}']"
      expect(page).not_to have_button "Watch video"
    end
  end

  scenario "expires the cache when the value of the feature changes", :admin, :with_cache do
    Setting["feature.gdpr.require_consent_for_embedded_videos"] = false

    visit polymorphic_path(proposal)

    within ".embedded-video" do
      expect(page).to have_css "iframe[src='#{youtube_embed_url}']"
      expect(page).not_to have_button "Watch video"
    end

    visit admin_settings_path(anchor: "tab-feature-flags")

    within("tr", text: "Consent for embedded videos") do
      click_button "No"

      expect(page).to have_button "Yes"
    end

    visit polymorphic_path(proposal)

    within ".embedded-video" do
      expect(page).to have_button "Watch video"
      expect(page).not_to have_css "iframe"
    end
  end
end
