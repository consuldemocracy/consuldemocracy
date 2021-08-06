class Admin::SiteCustomization::InformationTextsController < Admin::SiteCustomization::BaseController
  before_action :delete_translations, only: [:update]

  def index
    @tab = params[:tab] || :basic
    @content = I18nContent.content_for(@tab)
  end

  def update
    I18nContent.update(content_params, enabled_translations)

    redirect_to admin_site_customization_information_texts_path,
                notice: t("flash.actions.update.translation")
  end

  private

    def resource
      I18nContent.find(content_params[:id])
    end

    def content_params
      params.require(:contents).values
    end

    def delete_translations
      languages_to_delete = params[:enabled_translations].select { |_, v| v == "0" }.keys

      languages_to_delete.each do |locale|
        I18nContentTranslation.where(locale: locale).destroy_all
      end
    end

    def enabled_translations
      params.fetch(:enabled_translations, {}).select { |_, v| v == "1" }.keys
    end
end
