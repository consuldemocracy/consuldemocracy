class DebatesController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]

  load_and_authorize_resource
  respond_to :html, :js

  def index
    @debates = Debate.includes(:tags).search(params).page(params[:page])
    set_debate_votes(@debates)
  end

  def show
    set_debate_votes(@debate)
    @comments = @debate.root_comments.with_hidden.recent.page(params[:page])
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
      ahoy.track :debate_created, debate_id: @debate.id
      redirect_to @debate, notice: t('flash.actions.create.notice', resource_name: 'Debate')
    else
      load_featured_tags
      render :new
    end
  end

  def update
    @debate.assign_attributes(debate_params)
    if @debate.save_with_captcha
      redirect_to @debate, notice: t('flash.actions.update.notice', resource_name: 'Debate')
    else
      load_featured_tags
      render :edit
    end
  end

  def vote
    @debate.vote_by(voter: current_user, vote: params[:value])
    set_debate_votes(@debate)
  end

  def flag_as_inappropiate
    InappropiateFlag.flag!(current_user, @debate)
    respond_with @debate, template: 'debates/_refresh_flag_as_inappropiate_actions'
  end

  def undo_flag_as_inappropiate
    InappropiateFlag.unflag!(current_user, @debate)
    respond_with @debate, template: 'debates/_refresh_flag_as_inappropiate_actions'
  end

  private

    def debate_params
      params.require(:debate).permit(:title, :description, :tag_list, :terms_of_service, :captcha, :captcha_key)
    end

    def load_featured_tags
      @featured_tags = ActsAsTaggableOn::Tag.where(featured: true)
    end

end
