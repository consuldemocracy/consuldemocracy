class RelatedContentsController < ApplicationController
  VALID_URL = /#{Setting['url']}\/.*\/.*/

  skip_authorization_check

  respond_to :html, :js

  def create
    if relationable_object && related_object
      RelatedContent.create(parent_relationable: @relationable, child_relationable: @related, author: current_user)

      flash[:success] = t('related_content.success')
    else
      flash[:error] = t('related_content.error', url: Setting['url'])
    end

    redirect_to @relationable
  end

  def score_positive
    score(:positive)
  end

  def score_negative
    score(:negative)
  end

  private

  def score(action)
    @related = RelatedContent.find_by(id: params[:id])
    @related.send("score_#{action}", current_user)

    render template: 'relationable/_refresh_score_actions'
  end

  def valid_url?
    params[:url].match(VALID_URL)
  end

  def relationable_object
    @relationable = params[:relationable_klass].singularize.camelize.constantize.find_by(id: params[:relationable_id])
  end

  def related_object
      if valid_url?
        url = params[:url]

        related_klass = url.match(/\/(#{RelatedContent::RELATIONABLE_MODELS.join("|")})\//)[0].delete("/")
        related_id = url.match(/\/[0-9]+/)[0].delete("/")

        @related = related_klass.singularize.camelize.constantize.find_by(id: related_id)
      end
  rescue
      nil
  end
end
