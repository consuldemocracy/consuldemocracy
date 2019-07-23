class RemoteTranslation < ApplicationRecord

  belongs_to :remote_translatable, polymorphic: true

  validates :remote_translatable_id, presence: true
  validates :remote_translatable_type, presence: true
  validates :locale, presence: true

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
end
