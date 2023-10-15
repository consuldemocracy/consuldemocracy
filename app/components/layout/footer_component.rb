class Layout::FooterComponent < ApplicationComponent
  delegate :content_block, to: :helpers

  def footer_legal_content_block
    content_block("footer_legal")
  end

  private

    def open_source_link
      link_to(t("layouts.footer.open_source"), t("layouts.footer.open_source_url"), rel: "nofollow")
    end

    def repository_link
      link_to(t("layouts.footer.consul"), t("layouts.footer.consul_url"), rel: "nofollow")
    end
end
