class Admin::Widget::Cards::TableComponent < ApplicationComponent
  attr_reader :cards, :no_cards_message, :options

  def initialize(cards, no_cards_message:, **options)
    @cards = cards
    @no_cards_message = no_cards_message
    @options = options
  end

  private

    def attribute_name(attribute)
      ::Widget::Card.human_attribute_name(attribute)
    end
end
