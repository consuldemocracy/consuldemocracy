class Layout::TopLinksComponent < ApplicationComponent
  use_helpers :content_block

  def render?
    top_links_content_block.present?
  end

  private

    def top_links_content_block
      content_block("top_links")
    end
end
