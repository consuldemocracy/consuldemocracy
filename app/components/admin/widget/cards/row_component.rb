class Admin::Widget::Cards::RowComponent < ApplicationComponent
  attr_reader :card, :options

  def initialize(card, **options)
    @card = card
    @options = options
  end

  private

    def header_section?
      card.header_or_sdg_header?
    end
end
