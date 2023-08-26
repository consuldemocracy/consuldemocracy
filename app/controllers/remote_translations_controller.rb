class RemoteTranslationsController < ApplicationController
  skip_authorization_check
  respond_to :html, :js

  def create
    RemoteTranslation.create_all(remote_translations_params)

    redirect_to request.referer, notice: t("remote_translations.create.enqueue_remote_translation")
  end

  private

    def remote_translations_params
      ActiveSupport::JSON.decode(params["remote_translations"]).map do |remote_translation_params|
        remote_translation_params.slice(*allowed_params)
      end
    end

    def allowed_params
      ["remote_translatable_id", "remote_translatable_type", "locale"]
    end
end
