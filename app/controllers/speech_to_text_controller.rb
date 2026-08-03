class SpeechToTextController < ApplicationController
  ACCEPTED_AUDIO_CONTENT_TYPES = /\Aaudio\//

  before_action :authenticate_user!
  before_action :ensure_speech_to_text_configured!, only: :create
  skip_authorization_check

  rate_limit to: 120,
             within: 15.minutes,
             by: -> { current_user.id },
             only: :create,
             with: -> { render_rate_limit_response }

  def create
    return render_audio_required_error if params[:audio_file].blank?
    return render_invalid_audio_type_error unless accepted_audio_type?
    return render_audio_too_large_error if params[:audio_file].size > 10.megabytes

    transcription = SpeechToText::Llm::Client.call(
      audio_file: params[:audio_file],
      locale: params[:locale]
    )

    if transcription.errors.any?
      render json: { errors: transcription.errors.join(", ") }, status: :unprocessable_content
    else
      render json: { text: transcription.text }
    end
  end

  private

    def ensure_speech_to_text_configured!
      return if Llm::Config.speech_to_text_configured?

      render json: { errors: I18n.t("speech_to_text.errors.llm_not_configured") },
             status: :unprocessable_content
    end

    def accepted_audio_type?
      params[:audio_file].content_type&.match?(ACCEPTED_AUDIO_CONTENT_TYPES)
    end

    def render_rate_limit_response
      render json: { errors: I18n.t("speech_to_text.errors.rate_limit_exceeded") }, status: :too_many_requests
    end

    def render_audio_required_error
      render json: { errors: I18n.t("speech_to_text.errors.audio_required") },
             status: :unprocessable_content
    end

    def render_invalid_audio_type_error
      render json: { errors: I18n.t("speech_to_text.errors.invalid_audio_type") },
             status: :unprocessable_content
    end

    def render_audio_too_large_error
      render json: { errors: I18n.t("speech_to_text.errors.audio_too_large") },
             status: :unprocessable_content
    end
end
