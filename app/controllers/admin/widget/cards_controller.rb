class Admin::Widget::CardsController < Admin::BaseController

  def new
    @card = ::Widget::Card.new(header: header_card?)
  end

  def create
    @card = ::Widget::Card.new(card_params)
    if @card.save
      notice = "Success"
      redirect_to admin_homepage_url, notice: notice
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
      redirect_to admin_homepage_url, notice: notice
    else
      render :edit
    end
  end

  def destroy
    @card = ::Widget::Card.find(params[:id])
    @card.destroy

    notice = "Removed"
    redirect_to admin_homepage_url, notice: notice
  end

  private

  def card_params
    image_attributes = [:id, :title, :attachment, :cached_attachment, :user_id, :_destroy]

    params.require(:widget_card).permit(
      :label, :title, :description, :link_text, :link_url,
      :button_text, :button_url, :alignment, :header,
      image_attributes: image_attributes
    )
  end

  def header_card?
    params[:header_card].present?
  end

end
