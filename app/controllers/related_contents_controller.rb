class RelatedContentsController < ApplicationController
  skip_authorization_check

  respond_to :html, :js

  def create
    related_content = RelatedContent.new(
      parent_relationable: relationable_object,
      child_relationable: related_object,
      author: current_user
    )

    if related_content.save
      flash[:success] = t("related_content.success")
    elsif related_content.same_parent_and_child?
      flash[:error] = t("related_content.error_itself")
    else
      flash[:error] = t("related_content.error", url: Setting["url"])
    end
    redirect_to polymorphic_path(relationable_object)
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

    def relationable_object
      @relationable ||= params[:relationable_klass].singularize.camelize.constantize.find_by(id: params[:relationable_id])
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
