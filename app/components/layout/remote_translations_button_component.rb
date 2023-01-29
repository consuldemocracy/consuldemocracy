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

    def translations_in_progress?
      remote_translations.any?(&:enqueued?)
    end
end
