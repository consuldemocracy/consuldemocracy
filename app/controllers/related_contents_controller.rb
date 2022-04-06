class RelatedContentsController < ApplicationController
  skip_authorization_check

  respond_to :html, :js

  def create
    related_content = current_user.related_contents.new(
      parent_relationable_id: params[:relationable_id],
      parent_relationable_type: params[:relationable_klass],
      child_relationable_id: child_relationable_params[:id],
      child_relationable_type: child_relationable_params[:type]
    )

    if related_content.save
      flash[:success] = t("related_content.success")
    elsif related_content.same_parent_and_child?
      flash[:error] = t("related_content.error_itself")
    elsif related_content.duplicate?
      flash[:error] = t("related_content.error_duplicate")
    else
      flash[:error] = t("related_content.error", url: Setting["url"])
    end
    redirect_to polymorphic_path(related_content.parent_relationable)
  end

  def score_positive
    score(:positive)
  end

  def score_negative
    score(:negative)
  end

  private

    def score(action)
      @related = RelatedContent.find params[:id]
      @related.send("score_#{action}", current_user)

      render template: "relationable/_refresh_score_actions"
    end

    def valid_url?
      params[:url].start_with?(Setting["url"])
    end

    def child_relationable_params
      @child_relationable_params ||=
        if valid_url?
          related_params = Rails.application.routes.recognize_path(params[:url])

          if RelatedContent::RELATIONABLE_MODELS.include?(related_params[:controller].split("/").last)
            {
              id: related_params[:id],
              type: related_params[:controller].split("/").map(&:singularize).join("/").classify
            }
          else
            {}
          end
        else
          {}
        end
    rescue ActionController::RoutingError
      {}
    end
end
