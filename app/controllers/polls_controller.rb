class PollsController < ApplicationController

  load_and_authorize_resource

  has_filters %w{current expired incoming}

  ::Poll::Answer # trigger autoload

  def index
    @polls = @polls.send(@current_filter).includes(:geozones).sort_for_list.page(params[:page])
  end

  def show
    @questions = @poll.questions.for_render.sort_for_list

    @answers_by_question_id = {}
    poll_answers = ::Poll::Answer.by_question(@poll.question_ids).by_author(current_user.try(:id))
    poll_answers.each do |answer|
      @answers_by_question_id[answer.question_id] = answer.answer
    end
  end

  def results_2017
    @poll_1 = ::Poll.where("name ILIKE ?", "%Billete único%").first
    @poll_2 = ::Poll.where("name ILIKE ?", "%Gran Vía%").first
    @poll_3 = ::Poll.where("name ILIKE ?", "%Territorial de Barajas%").first
    @poll_4 = ::Poll.where("name ILIKE ?", "%Territorial de San Blas%").first
    @poll_5 = ::Poll.where("name ILIKE ?", "%Hortaleza%").first
    @poll_6 = ::Poll.where("name ILIKE ?", "%culturales en Retiro%").first
    @poll_7 = ::Poll.where("name ILIKE ?", "%Distrito de Salamanca%").first
    @poll_8 = ::Poll.where("name ILIKE ?", "%Distrito de Vicálvaro%").first
  end

  def stats_2017
    @participantes_totales = ::Poll::Voter.select(:user_id).distinct.count
    @votos_totales = ::Poll::Voter.count

    @votos_total_web = ::Poll::Voter.web.count
    @votos_total_booth = ::Poll::Voter.booth.count
    @votos_total_letter = ::Poll::Voter.letter.count

    @participantes_total_web = ::Poll::Voter.web.select(:user_id).distinct.count
    @participantes_total_booth = ::Poll::Voter.booth.select(:user_id).distinct.count
    @participantes_total_letter = ::Poll::Voter.letter.select(:user_id).distinct.count

    @poll_1 = ::Poll.where("name ILIKE ?", "%Billete único%").first
    @poll_2 = ::Poll.where("name ILIKE ?", "%Gran Vía%").first
    @poll_3 = ::Poll.where("name ILIKE ?", "%Territorial de Barajas%").first
    @poll_4 = ::Poll.where("name ILIKE ?", "%Territorial de San Blas%").first
    @poll_5 = ::Poll.where("name ILIKE ?", "%Hortaleza%").first
    @poll_6 = ::Poll.where("name ILIKE ?", "%culturales en Retiro%").first
    @poll_7 = ::Poll.where("name ILIKE ?", "%Distrito de Salamanca%").first
    @poll_8 = ::Poll.where("name ILIKE ?", "%Distrito de Vicálvaro%").first

    load_demographic_stats
  end

  private

    def age_group(age)
      age_group = ::Poll::AGE_STEPS.first
      ::Poll::AGE_STEPS.each do |step|
        if age >= step
          age_group = step
        end
      end
      age_group
    end

    def load_demographic_stats
      @age_stats = {}

      ::Poll::AGE_STEPS.each do |age_step|
        @age_stats[age_step] = {}
        @age_stats[age_step]['total'] = 0
        @age_stats['total'] = 0
        ::Poll::Voter::VALID_ORIGINS.each { |valid_origin| @age_stats[age_step][valid_origin] = 0 }
      end

      user_ids = ::Poll::Voter.pluck(:user_id)

      ::Poll::Voter.find_each do |voter|
        if user_ids.include?(voter.user_id)
          user_ids.delete(voter.user_id)
          origin = voter.origin

          if voter.age.present?
            voter_age_group = age_group(voter.age)
            @age_stats[voter_age_group][origin] += 1
            @age_stats[voter_age_group]['total'] += 1
            @age_stats['total'] += 1
          end
        end
      end

    end
end
