class Admin::Widget::Cards::TableComponent < ApplicationComponent
  attr_reader :cards, :no_cards_message

  def initialize(cards, no_cards_message:)
    @cards = cards
    @no_cards_message = no_cards_message
  end

  private

    def attribute_name(attribute)
      ::Widget::Card.human_attribute_name(attribute)
    end
end
