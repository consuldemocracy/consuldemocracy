class RelatedContentsController < ApplicationController
  skip_authorization_check

  respond_to :html, :js

  def create
    related_content = current_user.related_contents.new(
      parent_relationable_id: params[:relationable_id],
      parent_relationable_type: params[:relationable_klass],
      child_relationable: related_object
    )

    if related_content.save
      flash[:success] = t("related_content.success")
    elsif related_content.same_parent_and_child?
      flash[:error] = t("related_content.error_itself")
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

    def related_object
      if valid_url?
        url = params[:url]

        related_klass = url.scan(/\/(#{RelatedContent::RELATIONABLE_MODELS.join("|")})\//)
                           .flatten.map { |i| i.to_s.singularize.camelize }.join("::")
        related_id = url.match(/\/(\d+)(?!.*\/\d)/)[1]

        related_klass.singularize.camelize.constantize.find_by(id: related_id)
      end
    rescue
      nil
    end
end
