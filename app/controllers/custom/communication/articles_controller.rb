class Communication::ArticlesController < Communication::BaseController

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
      redirect_to action: :index
    else
      render :new
    end
  end

  def update
    if @article.update(article_params)
      redirect_to action: :index
    else
      render :edit
    end
  end

  def destroy
    if @article.destroy
      redirect_to action: :index, notice: t('admin.articles.delete.success')
    else
      redirect_to action: :index, flash: { error: t('admin.articles.delete.error') }
    end
  end

  private

    def article_params
      image_attributes = [:id, :title, :attachment, :cached_attachment, :user_id, :_destroy]
      params.require(:article).permit(:title, :subtitle, :content, :status, image_attributes: image_attributes)
    end
end
