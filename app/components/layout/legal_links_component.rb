require "consul/repository"

class Layout::LegalLinksComponent < ApplicationComponent
  delegate :content_block, to: :helpers

  def footer_legal_content_block
    content_block("footer_legal")
  end

  private

    def privacy_link
      link_to t("layouts.footer.privacy"), page_path("privacy")
    end

    def conditions_link
      link_to t("layouts.footer.conditions"), page_path("conditions")
    end

    def accessibility_link
      link_to t("layouts.footer.accessibility"), page_path("accessibility")
    end

    # This link makes it easy to comply with the AGPL. Remember that,
    # to comply with the AGPL, any person visiting your website must
    # also have (read) access to your source code.
    def repo_link
      link_to t("layouts.footer.source_code"), repo_url, rel: "nofollow external"
    end

    def repo_url
      Consul::Repository.url.delete_suffix(".git")
    end
end
