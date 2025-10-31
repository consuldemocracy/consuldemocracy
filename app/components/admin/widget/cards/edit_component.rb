class Admin::Widget::Cards::EditComponent < ApplicationComponent
  include Header

  attr_reader :card, :index_path, :form_path

  def initialize(card, index_path:, form_path: nil)
    @card = card
    @index_path = index_path
    @form_path = form_path
  end

  private

    def title
      if card.header_or_sdg_header?
        t("admin.homepage.edit.header_title")
      else
        t("admin.homepage.edit.card_title")
      end
    end
end
