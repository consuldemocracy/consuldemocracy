class Admin::SiteCustomization::InformationTextsController < Admin::SiteCustomization::BaseController
  include Translatable

  def index
    @contents = I18nContent.all
  end

  def update
    content_params.each do |content|
      text = I18nContent.find(content[:id])
      text.update(content[:values].slice(*translation_params(content[:values])))
    end
    redirect_to admin_site_customization_information_texts_path
  end

  private

  def i18n_content_params
    attributes = [:key, :value]
    params.require(:information_texts).permit(*attributes, translation_params(params[:information_texts]))
  end

  def resource_model
    I18nContent
  end

  def resource
    resource_model.find(content_params[:id])
  end

  def content_params
    params.require(:contents).values
  end

  def delete_translations
    languages_to_delete = params[:delete_translations].select { |k, v| params[:delete_translations][k] == "1" }.keys
    languages_to_delete.each do |locale|
      I18nContentTranslation.destroy_all(locale: locale)
    end
  end
end
