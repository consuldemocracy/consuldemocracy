class RemoteTranslation < ApplicationRecord
  belongs_to :remote_translatable, polymorphic: true

  validates :remote_translatable_id, presence: true
  validates :remote_translatable_type, presence: true
  validates :locale, presence: true
  validates :locale, inclusion: { in: RemoteTranslations::Microsoft::AvailableLocales.available_locales }
  validate :already_translated_resource
  after_create :enqueue_remote_translation

  def enqueue_remote_translation
    RemoteTranslations::Caller.new(self).delay.call
  end

  def self.remote_translation_enqueued?(remote_translation)
    where(remote_translatable_id: remote_translation["remote_translatable_id"],
          remote_translatable_type: remote_translation["remote_translatable_type"],
          locale: remote_translation["locale"],
          error_message: nil).any?
  end

  def already_translated_resource
    if remote_translatable&.translations&.where(locale: locale).present?
      errors.add(:locale, :already_translated)
    end
  end
end
