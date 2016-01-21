class Admin::SubcategoriesController < Admin::BaseController
  load_and_authorize_resource

  before_filter :load_category

  def index
    @subcategories = @category.subcategories.page(params[:page])
  end

  def new
    @subcategory = @category.subcategories.build({
      name: default_data_for_all_locales,
      description: default_data_for_all_locales
    })
  end

  def create
    @subcategory = @category.subcategories.build(strong_params)

    if @subcategory.save
      redirect_to admin_category_subcategories_url(@category), notice: t('flash.actions.create.notice', resource_name: "Subcategory")
    else
      render :new
    end
  end

  def edit
  end

  def update
    @subcategory.assign_attributes(strong_params)
    if @subcategory.save
      redirect_to admin_category_subcategories_url(@category), notice: t('flash.actions.update.notice', resource_name: "Subcategory")
    else
      render :edit
    end
  end

  private

  def load_category
    @category = Category.find(params[:category_id])
  end

  def strong_params
    send("subcategory_params")
  end

  def subcategory_params
    params.require(:subcategory).permit(:position, :name => I18n.available_locales.map(&:to_s), :description => I18n.available_locales.map(&:to_s))
  end

  def default_data_for_all_locales
    I18n.available_locales.inject({}) do |result, locale| 
      result[locale.to_s] = "" 
      result
    end
  end
end
