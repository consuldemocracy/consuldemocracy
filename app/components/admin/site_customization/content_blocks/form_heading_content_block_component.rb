class Admin::SiteCustomization::ContentBlocks::FormHeadingContentBlockComponent < ApplicationComponent
  attr_reader :content_block
  use_helpers :valid_blocks

  def initialize(content_block)
    @content_block = content_block
  end

  private

    def selected_content_block
      "hcb_#{content_block.heading_id}"
    end
end
