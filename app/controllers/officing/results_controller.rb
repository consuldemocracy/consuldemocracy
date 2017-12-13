class Officing::ResultsController < Officing::BaseController
  before_action :load_poll

  before_action :load_officer_assignments, only: :new
  before_action :load_partial_results, only: :new

  before_action :load_officer_assignment, only: :create
  before_action :check_officer_assignment, only: :create
  before_action :build_results, only: :create

  def new
  end

  def create
    @results.each { |result| result.save! }

    notice = t("officing.results.flash.create")
    redirect_to new_officing_poll_result_path(@poll), notice: notice
  end

  def index
    @booth_assignment = ::Poll::BoothAssignment.includes(:booth).find(index_params[:booth_assignment_id])
    if current_user.poll_officer.officer_assignments.final.
                    where(booth_assignment_id: @booth_assignment.id).exists?

      @partial_results = ::Poll::PartialResult.includes(:question).
                                            where(booth_assignment_id: index_params[:booth_assignment_id]).
                                            where(date: index_params[:date])
      @recounts = ::Poll::Recount.where(booth_assignment_id: @booth_assignment.id, date: index_params[:date])
    end
  end

  private

    def check_officer_assignment
      if @officer_assignment.blank?
        go_back_to_new(t("officing.results.flash.error_wrong_booth"))
      end
    end

    def build_results
      @results = []

      params[:questions].each_pair do |question_id, results|
        question = @poll.questions.find(question_id)
        go_back_to_new if question.blank?

        results.each_pair do |answer_index, count|
          next if count.blank?
          answer = question.question_answers.where(given_order: answer_index.to_i + 1).first.title
          go_back_to_new if question.blank?

          partial_result = ::Poll::PartialResult.find_or_initialize_by(booth_assignment_id: @officer_assignment.booth_assignment_id,
                                                                       date: Date.current,
                                                                       question_id: question_id,
                                                                       answer: answer)
          partial_result.officer_assignment_id = @officer_assignment.id
          partial_result.amount = count.to_i
          partial_result.author = current_user
          partial_result.origin = 'booth'
          @results << partial_result
        end
      end

      build_recounts
    end

    def build_recounts
      recount = ::Poll::Recount.find_or_initialize_by(booth_assignment_id: @officer_assignment.booth_assignment_id,
                                                      date: Date.current)
      recount.officer_assignment_id = @officer_assignment.id
      recount.author = current_user
      recount.origin = 'booth'
      [:whites, :nulls, :total].each do |recount_type|
        if results_params[recount_type].present?
          recount["#{recount_type.to_s.singularize}_amount"] = results_params[recount_type].to_i
        end
      end
      @results << recount
    end

    def go_back_to_new(alert = nil)
      params[:d] = Date.current
      params[:oa] = results_params[:officer_assignment_id]
      flash.now[:alert] = (alert || t("officing.results.flash.error_create"))
      load_officer_assignments
      load_partial_results
      render :new
    end

    def load_poll
      @poll = ::Poll.includes(:questions).find(params[:poll_id])
    end

    def load_officer_assignment
      @officer_assignment = current_user.poll_officer.
                            officer_assignments.final.find_by(id: results_params[:officer_assignment_id])
    end

    def load_officer_assignments
      @officer_assignments = ::Poll::OfficerAssignment.
                  includes(booth_assignment: [:booth]).
                  joins(:booth_assignment).
                  final.
                  where(id: current_user.poll_officer.officer_assignment_ids).
                  where("poll_booth_assignments.poll_id = ?", @poll.id).
                  where(date: Date.current)
    end

    def load_partial_results
      if @officer_assignments.present?
        @partial_results = ::Poll::PartialResult.where(officer_assignment_id: @officer_assignments.map(&:id))
                                                .order(:booth_assignment_id, :date)
      end
    end

    def results_params
      params.permit(:officer_assignment_id, :questions, :whites, :nulls, :total)
    end

    def index_params
      params.permit(:booth_assignment_id, :date)
    end

end
