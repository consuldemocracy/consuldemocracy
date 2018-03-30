class ArticlesController < ApplicationController
  include FeatureFlags
  feature_flag :articles

  skip_authorization_check

  def index
    @articles = Article.published.page(params[:page])
  end

  def show
    article_id = params[:id].to_s[/^(\d+)/]
    @article = Article.published.find(article_id)

    if @article.present?
      render action: :show
    else
      head 404
    end
  end
end
