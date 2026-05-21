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
end
