class Admin::Widget::Cards::RowComponent < ApplicationComponent
  attr_reader :card

  def initialize(card)
    @card = card
  end
end
