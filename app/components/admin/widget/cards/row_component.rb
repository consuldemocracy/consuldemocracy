class Admin::Widget::Cards::RowComponent < ApplicationComponent
  attr_reader :card, :options

  def initialize(card, **options)
    @card = card
    @options = options
  end
end
