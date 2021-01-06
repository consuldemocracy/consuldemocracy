class Admin::Widget::Cards::TableComponent < ApplicationComponent
  attr_reader :cards, :no_cards_message

  def initialize(cards, no_cards_message:)
    @cards = cards
    @no_cards_message = no_cards_message
  end
end
