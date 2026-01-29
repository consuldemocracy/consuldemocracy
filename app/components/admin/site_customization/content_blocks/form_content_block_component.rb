class Admin::SiteCustomization::ContentBlocks::FormContentBlockComponent < ApplicationComponent
  attr_reader :content_block
  delegate :valid_blocks, to: :helpers

  def initialize(content_block)
    @content_block = content_block
  end

  private

    def selected_content_block
      content_block.name
    end
end
