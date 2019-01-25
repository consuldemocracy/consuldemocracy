include RemoteAvailableLocales
class RemoteTranslationsCaller
  attr_accessor :available_remote_locales

  def call(remote_translation)
    resource = remote_translation.remote_translatable
    fields_values = prepare_fields_values(resource)
    locale_to = remote_translation.locale

    translations = MicrosoftTranslateClient.new.call(fields_values, locale_to)

    update_resource(resource, translations, locale_to)
    destroy_remote_translation(resource, remote_translation)
  end

  def available_remote_locales
    @remote_locales = daily_cache('remote_locales') { RemoteAvailableLocales.load_remote_locales }
  end

  private

  def prepare_fields_values(resource)
    resource.translated_attribute_names.map do |field|
      resource.send(field)
    end
  end

  def update_resource(resource, translations, locale)
    Globalize.with_locale(locale) do
      resource.translated_attribute_names.each_with_index do |field, index|
        resource.send(:"#{field}=", translations[index])
      end
    end
    resource.save
  end

  def destroy_remote_translation(resource, remote_translation)
    if resource.valid?
      remote_translation.destroy
    else
      remote_translation.update(error_message: resource.errors.messages)
    end
  end

  def daily_cache(key, &block)
    Rails.cache.fetch("load_remote_locales/#{Time.current.strftime('%Y-%m-%d')}/#{key}", &block)
  end
end
