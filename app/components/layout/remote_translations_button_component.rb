class Layout::RemoteTranslationsButtonComponent < ApplicationComponent
  attr_reader :remote_translations

  def initialize(remote_translations)
    @remote_translations = remote_translations
  end

  def render?
    remote_translations.present? &&
      RemoteTranslations::Microsoft::AvailableLocales.include_locale?(I18n.locale)
  end

  private

    def display_remote_translation_button?
      remote_translations.none? do |remote_translation|
        RemoteTranslation.remote_translation_enqueued?(remote_translation)
      end
    end
end
