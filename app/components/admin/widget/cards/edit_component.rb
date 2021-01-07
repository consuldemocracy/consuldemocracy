class Admin::Widget::Cards::EditComponent < ApplicationComponent
  include Header
  attr_reader :card, :index_path

  def initialize(card, index_path:)
    @card = card
    @index_path = index_path
  end

  private

    def title
      if card.header?
        t("admin.homepage.edit.header_title")
      else
        t("admin.homepage.edit.card_title")
      end
    end
end
