class Layout::FooterComponent < ApplicationComponent
  use_helpers :content_block

  def render?
    !Rails.application.multitenancy_management_mode?
  end

  def footer_legal_content_block
    content_block("footer_legal")
  end

  private

    def open_source_link
      external_link_to(t("layouts.footer.open_source"), t("layouts.footer.open_source_url"))
    end

    def repository_link
      external_link_to(t("layouts.footer.consul"), t("layouts.footer.consul_url"))
    end

    def instance_repository_link
      url = Setting["instance_repository_url"].to_s.strip
      return if url.blank?

      external_link_to(t("layouts.footer.instance_repository_text"), url)
    end

    def external_link_to(text, url)
      link_to(text, url, rel: "nofollow external")
    end

    def allowed_link_attributes
      self.class.sanitized_allowed_attributes + ["rel"]
    end
end
