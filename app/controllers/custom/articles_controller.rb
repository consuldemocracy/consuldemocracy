class ArticlesController < ApplicationController
  include FeatureFlags
  feature_flag :articles

  skip_authorization_check

  def index
    @articles = Article.published
  end

  def show
    @article = Article.published.find_by(slug: params[:id])

    if @article.present?
      render action: :show
    else
      head 404
    end
  end
end
