class DebatesController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  load_and_authorize_resource

  def index
    if params[:tag]
      @debates = Debate.tagged_with(params[:tag]).order(id: :desc)
      set_voted_values @debates.map(&:id)
    else
      @debates = Debate.all.order(id: :desc)
      set_voted_values @debates.map(&:id)
    end
  end

  def show
    set_voted_values [@debate.id]
  end

  def new
    @debate = Debate.new
    load_featured_tags
  end

  def edit
    load_featured_tags
  end

  def create
    @debate = Debate.new(debate_params)
    @debate.author = current_user
    if @debate.save_with_captcha
      redirect_to @debate, notice: t('flash.actions.create.notice', resource_name: 'Debate')
    else
      load_featured_tags
      render :new
    end
  end

  def update
    if @debate.update(debate_params)
      redirect_to @debate, notice: t('flash.actions.update.notice', resource_name: 'Debate')
    else
      load_featured_tags
      render :edit
    end
  end

  def vote
    @debate.vote_by(voter: current_user, vote: params[:value])
    set_voted_values [@debate.id]
  end


  private
    def debate_params
      params.require(:debate).permit(:title, :description, :tag_list, :terms_of_service, :captcha, :captcha_key)
    end

    def load_featured_tags
      @featured_tags = ActsAsTaggableOn::Tag.where(featured: true)
    end

end
