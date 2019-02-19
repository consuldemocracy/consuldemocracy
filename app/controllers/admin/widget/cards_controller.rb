class Admin::Widget::CardsController < Admin::BaseController
  include Translatable
  include ImageAttributes

  def new
    if header_card?
      @card = ::Widget::Card.new(header: header_card?)
    else
      @card = ::Widget::Card.new(site_customization_page_id: params[:page_id])
    end
  end

  def create
    @card = ::Widget::Card.new(card_params)
    if @card.save
      redirect_to_customization_page_cards_or_homepage
    else
      render :new
    end
  end

  def edit
    @card = ::Widget::Card.find(params[:id])
  end

  def update
    @card = ::Widget::Card.find(params[:id])
    if @card.update(card_params)
      redirect_to_customization_page_cards_or_homepage
    else
      render :edit
    end
  end

  def destroy
    @card = ::Widget::Card.find(params[:id])
    @card.destroy

    redirect_to_customization_page_cards_or_homepage
  end

  private

    def card_params
      params.require(:widget_card).permit(
        :label, :title, :description, :link_text, :link_url,
        :button_text, :button_url, :alignment, :header, :site_customization_page_id,
        :columns,
        translation_params(Widget::Card),
        image_attributes: image_attributes
      )
    end

    def header_card?
      params[:header_card].present?
    end

    def redirect_to_customization_page_cards_or_homepage
      notice = t("admin.site_customization.pages.cards.#{params[:action]}.notice")

      if @card.site_customization_page_id
        redirect_to admin_site_customization_page_cards_path(page), notice: notice
      else
        redirect_to admin_homepage_url, notice: notice
      end
    end

    def page
      ::SiteCustomization::Page.find(@card.site_customization_page_id)
    end

    def resource
      Widget::Card.find(params[:id])
    end
end
