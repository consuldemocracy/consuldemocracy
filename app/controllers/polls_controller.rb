

class PollsController < ApplicationController
  include PollsHelper

  load_and_authorize_resource

  has_filters %w{current expired incoming}
  has_orders %w{most_voted newest oldest}, only: [:show, :answer]

  ::Poll::Answer # trigger autoload

  def index
    @polls = @polls.send(@current_filter).includes(:geozones).sort_for_list.page(params[:page])
  end

  def show
    @questions = @poll.questions.for_render.sort_for_list
    @token = poll_voter_token(@poll, current_user)
    @poll_questions_answers = Poll::Question::Answer.where(question: @poll.questions).where.not(description: "").order(:given_order)
    @answers_by_question_id = {}     
    ::Poll::Answer.by_question(@poll.question_ids).by_author(current_user.try(:id)).each do |answer|
      @answers_by_question_id[answer.question_id] = answer.answer
    end    
    @commentable = @poll
    @comment_tree = CommentTree.new(@commentable, params[:page], @current_order)
  end

  def answer    
    @questions = @poll.questions.for_render.sort_for_list
    
    @answers_by_question_id = {}     
    @found_error = false
    @questions.each do |question|
      if(question.answers.count()==0)
        next
      end        
      answer_title = params['answer_question_' + question.id.to_s]        
      unless (answer_title)
        @found_error = true        
      end
      @answers_by_question_id[question.id] = answer_title              
    end
    @token = params[:token]

    unless @found_error
      @questions.each do |question|       
        answer = question.answers.find_or_initialize_by(author: current_user)
        answer.answer = params['answer_question_' + question.id.to_s]
        answer.touch if answer.persisted?        
        answer.save!        
        answer.record_voter_participation(@token)        
        question.question_answers.where(question_id: question).each do |question_answer|
          question_answer.set_most_voted
        end
      end
      return redirect_to poll_path(@poll), notice: t("flash.actions.save_changes.notice")      
    else
      @poll_questions_answers = Poll::Question::Answer.where(question: @poll.questions).where.not(description: "").order(:given_order)
      @commentable = @poll
      @comment_tree = CommentTree.new(@commentable, params[:page], @current_order)
      render :action => 'show'      
      return true
    end  
  end

  def stats
    @stats = Poll::Stats.new(@poll).generate
  end

  def results
  end

end
