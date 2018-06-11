class PollsController < ApplicationController
  include PollsHelper

  before_action :load_poll, except: [:index]

  load_and_authorize_resource

  has_filters %w{current expired incoming}
  has_orders %w{most_voted newest oldest}, only: :show

  ::Poll::Answer # trigger autoload

  def index
    @polls = @polls.not_budget.send(@current_filter).includes(:geozones).sort_for_list.page(params[:page])
  end

  def show
    @questions = @poll.questions.for_render.sort_for_list
    @token = poll_voter_token(@poll, current_user)
    @poll_questions_answers = Poll::Question::Answer.where(question: @poll.questions).where.not(description: "").order(:given_order)

    @answers_by_question_id = {}
    poll_answers = ::Poll::Answer.by_question(@poll.question_ids).by_author(current_user.try(:id))
    poll_answers.each do |answer|
      @answers_by_question_id[answer.question_id] = answer.answer
    end

    @commentable = @poll
    @comment_tree = CommentTree.new(@commentable, params[:page], @current_order)
  end

  def stats
    @stats = Poll::Stats.new(@poll).generate
  end

  def results
  end

  def results_2017
  end

  def stats_2017
    @totals = Stat.hash("polls_2017_participation")['totals']

    @poll_1 = ::Poll.where("name ILIKE ?", "%Billete único%").first
    @poll_2 = ::Poll.where("name ILIKE ?", "%Gran Vía%").first
    @poll_3 = ::Poll.where("name ILIKE ?", "%Territorial de Barajas%").first
    @poll_4 = ::Poll.where("name ILIKE ?", "%Territorial de San Blas%").first
    @poll_5 = ::Poll.where("name ILIKE ?", "%Hortaleza%").first
    @poll_6 = ::Poll.where("name ILIKE ?", "%culturales en Retiro%").first
    @poll_7 = ::Poll.where("name ILIKE ?", "%Distrito de Salamanca%").first
    @poll_8 = ::Poll.where("name ILIKE ?", "%Distrito de Vicálvaro%").first

    @poll_stats = Stat.hash("polls_2017_polls")

    @age_stats = Stat.hash("polls_2017_age")
    @gender_stats = Stat.hash("polls_2017_gender")
    @district_stats = Stat.hash("polls_2017_district")
  end

  def info_2017
  end

  def stats_2018
    if Rails.env.development?
      @polls = Poll.expired
    else
      @polls = Poll.where(starts_at: Time.parse('08-10-2017'), ends_at: Time.parse('22-10-2017'))
    end

    @totals = Stat.hash("polls_2018_participation")['totals']
    @poll_stats = Stat.hash("polls_2018_polls")
    @age_stats = Stat.hash("polls_2018_age")
    @gender_stats = Stat.hash("polls_2018_gender")
    @district_stats = Stat.hash("polls_2018_district")
  end

  def results_2018
    if Rails.env.development?
      @polls = Poll.expired
    else
      @polls = Poll.where(starts_at: Time.parse('08-10-2017'), ends_at: Time.parse('22-10-2017'))
    end
  end

  private

    def load_poll
      @poll = Poll.where(slug: params[:id]).first || Poll.where(slug: params[:poll_id]).first
    end
end
