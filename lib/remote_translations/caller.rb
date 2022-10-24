class RemoteTranslations::Caller
  attr_reader :remote_translation

  def initialize(remote_translation)
    @remote_translation = remote_translation
  end

  def call
    update_resource
    destroy_remote_translation
  end

  private

    def update_resource
      Globalize.with_locale(locale) do
        resource.translated_attribute_names.each_with_index do |field, index|
          resource.send(:"#{field}=", translations[index])
        end
      end
      resource.save
    end

    def destroy_remote_translation
      if resource.valid?
        remote_translation.destroy
        resource.save!
      else
        remote_translation.update(error_message: resource.errors.messages)
      end
    end

    def resource
      @resource ||= remote_translation.remote_translatable
    end

    def translations
      @translations ||= RemoteTranslations::Microsoft::Client.new.call(fields_values, locale)
    end

    def fields_values
      resource.translated_attribute_names.map do |field|
        WYSIWYGSanitizer.new.sanitize(resource.send(field))
      end
    end

    def locale
      remote_translation.locale
    end
end
