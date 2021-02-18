module Admin::Widget::CardsActions
  extend ActiveSupport::Concern
  include Translatable
  include ImageAttributes

  def new
    @card.header = header_card?
    render template: "#{cards_view_path}/new"
  end

  def create
    if @card.save
      redirect_to_index
    else
      render template: "#{cards_view_path}/new"
    end
  end

  def edit
    render template: "#{cards_view_path}/edit"
  end

  def update
    if @card.update(card_params)
      redirect_to_index
    else
      render template: "#{cards_view_path}/edit"
    end
  end

  def destroy
    @card.destroy!
    redirect_to_index
  end

  private

    def card_params
      params.require(:widget_card).permit(
        :link_url, :button_text, :button_url, :alignment, :header, :columns,
        translation_params(Widget::Card),
        image_attributes: image_attributes
      )
    end

    def header_card?
      params[:header_card].present?
    end

    def redirect_to_index
      notice = t("admin.site_customization.pages.cards.#{params[:action]}.notice")

      redirect_to index_path, notice: notice
    end

    def cards_view_path
      "admin/widget/cards"
    end
end
