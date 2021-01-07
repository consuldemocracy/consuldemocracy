class Admin::Widget::Cards::NewComponent < ApplicationComponent
  include Header
  attr_reader :card, :index_path

  def initialize(card, index_path:)
    @card = card
    @index_path = index_path
  end

  private

    def title
      if card.header?
        t("admin.homepage.new.header_title")
      else
        t("admin.homepage.new.card_title")
      end
    end
end
