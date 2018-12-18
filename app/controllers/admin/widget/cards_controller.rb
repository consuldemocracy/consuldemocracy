class Admin::Widget::CardsController < Admin::BaseController
  include Translatable

  def new
    if header_card?
      @card = ::Widget::Card.new(header: header_card?)
    elsif params[:page_id] != 0
      @card = ::Widget::Card.new(site_customization_page_id: params[:page_id])
    else
      @card = ::Widget::Card.new
    end
  end

  def create
    @card = ::Widget::Card.new(card_params)
    if @card.save
      notice = "Success"
      if params[:page_id] != 0
        redirect_to admin_site_customization_page_cards_path(page), notice: notice
      else
        redirect_to admin_homepage_url, notice: notice
      end
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
      notice = "Updated"
      if params[:page_id] != 0
        redirect_to admin_site_customization_page_cards_path(page), notice: notice
      else
        redirect_to admin_homepage_url, notice: notice
      end
    else
      render :edit
    end
  end

  def destroy
    @card = ::Widget::Card.find(params[:id])
    @card.destroy

    notice = "Removed"
    if params[:page_id] != 0
      redirect_to admin_site_customization_page_cards_path(page), notice: notice
    else
      redirect_to admin_homepage_url, notice: notice
    end
  end

  private

  def card_params
    image_attributes = [:id, :title, :attachment, :cached_attachment, :user_id, :_destroy]

    params.require(:widget_card).permit(
      :link_url, :button_text, :button_url, :alignment, :header, :ods, :site_customization_page_id,
      translation_params(Widget::Card),
      image_attributes: image_attributes
    )
  end

  def header_card?
    params[:header_card].present?
  end
  def page
    ::SiteCustomization::Page.find(@card.site_customization_page_id)
  end

  def resource
    Widget::Card.find(params[:id])
  end
end