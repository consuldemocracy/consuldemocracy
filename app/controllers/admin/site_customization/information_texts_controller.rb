class Admin::SiteCustomization::InformationTextsController < Admin::SiteCustomization::BaseController
  before_action :delete_translations, only: [:update]

  def index
    @tab = params[:tab] || :basic
    @content = I18nContent.content_for(@tab)
  end

  def update
    content_params.each do |content|
      values = content[:values].slice(*translation_params)

      unless values.empty?
        values.each do |key, value|
          locale = key.split("_").last

          if value == t(content[:id], locale: locale) || value.match(/translation missing/)
            next
          else
            text = I18nContent.find_or_create_by(key: content[:id])
            Globalize.locale = locale
            text.update(value: value)
          end
        end
      end

    end

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
      languages_to_delete = params[:enabled_translations].select { |_, v| v == "0" }
                                                         .keys

      languages_to_delete.each do |locale|
        I18nContentTranslation.where(locale: locale).destroy_all
      end
    end

    def translation_params
      I18nContent.translated_attribute_names.product(enabled_translations).map do |attr_name, loc|
        I18nContent.localized_attr_name_for(attr_name, loc)
      end
    end

    def enabled_translations
      params.fetch(:enabled_translations, {})
            .select { |_, v| v == "1" }
            .keys
    end
end
