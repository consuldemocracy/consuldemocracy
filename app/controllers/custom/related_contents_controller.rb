require_dependency Rails.root.join("app", "controllers", "related_contents_controller").to_s
require 'uri'

class RelatedContentsController < ApplicationController
  def create
    if relationable_object && related_object
      if relationable_object.url != related_object.url
        RelatedContent.create!(parent_relationable: @relationable, child_relationable: @related, author: current_user)

        flash[:success] = t("related_content.success")
      else
        flash[:error] = t("related_content.error_itself")
      end
    else
      actualUrl = Setting["url"]
      if Rails.application.config.respond_to?(:participacion_iframe_source)
        actualUrl = Rails.application.config.participacion_iframe_source
      end

      flash[:error] = t("related_content.error", url: actualUrl)
    end
    redirect_to @relationable.url
  end


  private
    # Las URLS son válidas si comienzan con la URL configurada, o bien con el participacion_iframe_source
    def valid_url?
      params[:url].start_with?(Setting["url"]) or (Rails.application.config.respond_to?(:participacion_iframe_source) and params[:url].start_with?(Rails.application.config.participacion_iframe_source.strip+'#'))
    end

    def related_object
      if valid_url?
        url = params[:url]
        if Rails.application.config.respond_to?(:participacion_iframe_source) and url.start_with?(Rails.application.config.participacion_iframe_source.strip+'#')
          # Tendriamos que decodificar la URI de la peticion en este punto para generarla adecuadamente
          encodedUrl = URI.decode(url.slice((Rails.application.config.participacion_iframe_source.strip.length + 1)...-1))
          # Una vez decodificada la convertimos a una URL estándar del sistema, para que el sistema de
          # escaneado y match funcione correctamente
          url = Setting["url"]+encodedUrl
        end
        related_klass = url.scan(/\/(#{RelatedContent::RELATIONABLE_MODELS.join("|")})\//)
                           .flatten.map { |i| i.to_s.singularize.camelize }.join("::")
        related_id = url.match(/\/(\d+)(?!.*\/\d)/)[1]

        @related = related_klass.singularize.camelize.constantize.find_by(id: related_id)
      end
    rescue => error
      nil
    end
end
