class Layout::FooterComponent < ApplicationComponent
  delegate :content_block, to: :helpers

  def footer_legal_content_block
    content_block("footer_legal")
  end
end
