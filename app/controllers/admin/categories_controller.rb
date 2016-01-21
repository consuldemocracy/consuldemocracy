class Admin::CategoriesController < Admin::BaseController
  load_and_authorize_resource

  def index
    @categories = @categories.page(params[:page])
  end

  def new
    @category = Category.new({
      name: default_data_for_all_locales,
      description: default_data_for_all_locales
    })
  end

  def create
    @category = Category.new(strong_params)

    if @category.save
      redirect_to admin_categories_url, notice: t('flash.actions.create.notice', resource_name: "Category")
    else
      render :new
    end
  end

  def edit
  end

  def update
    @category.assign_attributes(strong_params)
    if @category.save
      redirect_to admin_categories_url, notice: t('flash.actions.update.notice', resource_name: "Category")
    else
      render :edit
    end
  end

  def destroy
    @category.destroy
    redirect_to admin_categories_url, notice: t('flash.actions.destroy.notice', resource_name: "Category")
  end

  private

  def strong_params
    send("category_params")
  end

  def category_params
    params.require(:category).permit(:position, :name => I18n.available_locales.map(&:to_s), :description => I18n.available_locales.map(&:to_s))
  end

  def default_data_for_all_locales
    I18n.available_locales.inject({}) do |result, locale| 
      result[locale.to_s] = "" 
      result
    end
  end
end
