class Layout::TopLinksComponent < ApplicationComponent
  delegate :content_block, to: :helpers

  def render?
    top_links_content_block.present?
  end

  private

    def top_links_content_block
      content_block("top_links")
    end
end
