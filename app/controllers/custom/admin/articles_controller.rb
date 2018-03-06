class Admin::ArticlesController < Admin::BaseController

  respond_to :html

  load_and_authorize_resource

  def index
    @articles = Article.all.order(:id)
  end

  def new
  end

  def edit
  end

  def create
    @article = Article.new(article_params)
    @article.author = current_user

    if @article.save
      redirect_to admin_articles_path
    else
      render :new
    end
  end

  def update
    if @article.update(article_params)
      redirect_to admin_articles_path
    else
      render :edit
    end
  end

  def destroy
    if @article.safe_to_destroy?
      @article.destroy
      redirect_to admin_articles_path, notice: t('admin.geozones.delete.success')
    else
      redirect_to admin_articles_path, flash: { error: t('admin.geozones.delete.error') }
    end
  end

  private

    def article_params
      params.require(:article).permit(:title, :slug, :subtitle, :content, :status)
    end
end
