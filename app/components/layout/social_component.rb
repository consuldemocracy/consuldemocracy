class Layout::SocialComponent < ApplicationComponent
  delegate :content_block, to: :helpers

  def render?
    sites.any? || footer_content_block.present?
  end

  private

    def sites
      {
        twitter: "https://twitter.com",
        facebook: "https://www.facebook.com",
        youtube: "https://www.youtube.com",
        telegram: "https://www.telegram.me",
        instagram: "https://www.instagram.com"
      }.select { |name, _| setting["#{name}_handle"].present? }
    end

    def link_title(site_name)
      t("shared.go_to_page") + link_text(site_name) + t("shared.target_blank")
    end

    def link_text(site_name)
      t("social.#{site_name}", org: setting["org_name"])
    end

    def footer_content_block
      content_block("footer")
    end
end
