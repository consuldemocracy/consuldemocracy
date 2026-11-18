class ClassificationSuggestionsController < ApplicationController
  before_action :authenticate_user!
  skip_authorization_check

  rate_limit to: 10,
             within: 15.minutes,
             by: -> { current_user.id },
             only: :create,
             with: -> { render_rate_limit_response }

  def create
    @suggestions = ClassificationSuggestions::Llm::Client.call(
      title: draft_params[:title],
      description: draft_params[:description],
      summary: draft_params[:summary],
      selected_tags: selected_tags,
      selected_sdgs: selected_sdgs,
      locale: I18n.locale,
      resource_type: params[:resource_type]
    )

    render json: @suggestions
  end

  private

    def render_rate_limit_response
      suggestions = ClassificationSuggestions::Llm::Client::Response.new
      suggestions.errors << I18n.t("classification_suggestions.errors.messages.rate_limit_exceeded")

      render json: suggestions
    end

    def draft_params
      @draft_params ||= extract_draft_params
    end

    def resource_params
      @resource_params ||= params.require(params[:resource_type].parameterize.underscore)
    end

    def extract_draft_params
      translation = Array(resource_params[:translations_attributes]&.values).first

      {
        title: translation&.dig(:title) || resource_params[:title],
        description: translation&.dig(:description) || resource_params[:description],
        summary: translation&.dig(:summary) || resource_params[:summary]
      }
    end

    def selected_tags
      ActsAsTaggableOn::TagList.new.add(resource_params[:tag_list].to_s, parse: true).to_a
    end

    def selected_sdgs
      resource_params[:related_sdg_list].to_s.split(",").map(&:strip).compact_blank
    end
end
