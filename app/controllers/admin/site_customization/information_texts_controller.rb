class Admin::SiteCustomization::InformationTextsController < Admin::SiteCustomization::BaseController
  include Translatable

  def index
    fetch_existing_keys
    append_or_create_keys
    @content = @content[@tab.to_s]
  end

  def update
    content_params.each do |content|
      values = content[:values].slice(*translation_params(content[:values]))

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
                notice: t('flash.actions.update.translation')
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
      languages_to_delete = params[:delete_translations].select { |k, v| params[:delete_translations][k] == '1' }.keys
      languages_to_delete.each do |locale|
        I18nContentTranslation.destroy_all(locale: locale)
      end
    end

    def fetch_existing_keys
      @existing_keys = {}
      @tab = params[:tab] || :debates

      I18nContent.begins_with_key(@tab)
                 .all
                 .map{ |content| @existing_keys[content.key] = content }
    end

    def append_or_create_keys
      @content = {}
      I18n.backend.send(:init_translations) unless I18n.backend.initialized?

      locale = params[:locale] || I18n.locale
      translations = I18n.backend.send(:translations)[locale.to_sym]

      translations.each do |k, v|
        @content[k.to_s] = flat_hash(v).keys
                                       .map { |s| @existing_keys["#{k.to_s}.#{s}"].nil? ?
                                              I18nContent.new(key: "#{k.to_s}.#{s}") :
                                              @existing_keys["#{k.to_s}.#{s}"] }
      end
    end

    def flat_hash(h, f = nil, g = {})
      return g.update({ f => h }) unless h.is_a? Hash
      h.each { |k, r| flat_hash(r, [f,k].compact.join('.'), g) }
      return g
    end

end
