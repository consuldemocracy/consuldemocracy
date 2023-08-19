class Budgets::Investments::ContentBlocksComponent < ApplicationComponent
  attr_reader :heading

  def initialize(heading)
    @heading = heading
  end

  def render?
    heading&.allow_custom_content && content_blocks.any?
  end

  private

    def content_blocks
      heading.content_blocks.where(locale: I18n.locale)
    end
end
