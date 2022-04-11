class RemoteTranslationsController < ApplicationController
  skip_authorization_check
  respond_to :html, :js

  before_action :set_remote_translations, only: :create

  def create
    @remote_translations.each do |remote_translation|
      RemoteTranslation.create!(remote_translation) unless translations_enqueued?(remote_translation)
    end
    redirect_to request.referer, notice: t("remote_translations.create.enqueue_remote_translation")
  end

  private

    def remote_translations_params
      params.permit(allowed_params)
    end

    def allowed_params
      [:remote_translations]
    end

    def set_remote_translations
      remote_translations = remote_translations_params["remote_translations"]
      decoded_remote_translations = ActiveSupport::JSON.decode(remote_translations)
      @remote_translations = decoded_remote_translations.map do |remote_translation|
        remote_translation.slice("remote_translatable_id", "remote_translatable_type", "locale")
      end
    end

    def translations_enqueued?(remote_translation)
      RemoteTranslation.remote_translation_enqueued?(remote_translation)
    end
end
