class Admin::Sensemaker::JobsController < Admin::BaseController
  def index
    @running_jobs = Sensemaker::Job.running.includes(:children).order(created_at: :desc)
    @sensemaker_jobs = Sensemaker::Job.where(parent_job_id: nil)
                                      .includes(:children)
                                      .where.not(id: @running_jobs.pluck(:id))
                                      .order(created_at: :desc)
  end

  def show
    @sensemaker_job = Sensemaker::Job.find(params[:id])
    @child_jobs = @sensemaker_job.children.includes(:analysable).order(:created_at)
  end

  def new
    @sensemaker_job = Sensemaker::Job.new

    if params[:target_type].present?
      @sensemaker_job.analysable_type = params[:target_type]
      @sensemaker_job.analysable_id = params[:target_id] if params[:target_id].present?
      if @sensemaker_job.analysable_type.present?
        conversation = @sensemaker_job.conversation
        @sensemaker_job.additional_context = conversation.compile_context if conversation.target.present?
      end
    end

    @search_results = []
    target_query = params.fetch(:query, nil)
    if target_query.present?
      case params[:query_type]
      when "Legislation::Process"
        processes = Legislation::Process.includes(:questions, :proposals).search(target_query)
        processes.each do |process|
          unless process.proposals.empty?
            @search_results << { group_title: process.title + " Proposals", results: process.proposals }
          end
          unless process.questions.empty?
            @search_results << { group_title: process.title + " Questions", results: process.questions }
          end
        end
      when "Budget"
        budgets = Budget.published
                       .with_translations(Globalize.fallbacks(I18n.locale))
                       .where("budget_translations.name ILIKE ?", "%#{target_query}%")
                       .order(created_at: :desc)
        budgets.each do |budget|
          budget_results = []
          budget_results << budget
          #budget.groups.includes(:translations).each do |group|
          #  budget_results << group
          #end
          @search_results << {
            group_title: budget.name,
            results: budget_results
          } unless budget_results.empty?
        end
      else
        results = params[:query_type].constantize.search(target_query)
        @search_results = [{
          group_title: I18n.t("activerecord.models.#{params[:query_type].underscore}.other"),
          results: results
        }] unless results.empty?
      end
    end
  end

  def create
    valid_params = sensemaker_job_params.to_h
    valid_params.merge!(user: current_user, started_at: Time.current)
    @sensemaker_job = Sensemaker::Job.create!(valid_params)

    if Rails.env.test?
      Sensemaker::JobRunner.new(@sensemaker_job).run_synchronously
    else
      Sensemaker::JobRunner.new(@sensemaker_job).run
    end

    redirect_to admin_sensemaker_jobs_path,
                notice: I18n.t("admin.sensemaker.notice.script_info")
  end

  def preview
    valid_params = sensemaker_job_params.to_h
    valid_params.merge!(user: current_user)
    sensemaker_job = Sensemaker::Job.new(valid_params)

    @result = ""; csv_result = ""
    status = 200
    begin
      conversation = sensemaker_job.conversation
      target_persisted = conversation.target.is_a?(Class) ||
                         (conversation.target.present? && conversation.target.persisted?)
      raise ActiveRecord::RecordNotFound unless target_persisted

      @result += "---------Additional context---------\n\n"
      @result += conversation.compile_context
      @result += "\n\n---------Input CSV--------\n\n"
      csv_result = Sensemaker::CsvExporter.new(conversation).export_to_string
      @result += csv_result

      filename = conversation.target_filename_label.parameterize
    rescue ActiveRecord::RecordNotFound
      @result += "Error: Target not found"
      status = 404
    rescue Exception => e
      Rails.logger.error "Error: #{e.message}"
      @result += "Error: #{e.message}"
      status = 500
    end

    respond_to do |format|
      format.html { render plain: @result, layout: false, status: status }
      format.js
      format.csv { send_data csv_result, filename: "#{filename}-input.csv", status: status }
    end
  end

  def destroy
    @sensemaker_job = Sensemaker::Job.find(params[:id])
    @sensemaker_job.destroy!

    redirect_to admin_sensemaker_jobs_path,
                notice: I18n.t("admin.sensemaker.notice.deleted_job")
  end

  def download
    @sensemaker_job = Sensemaker::Job.find(params[:id])
    if File.exist?(@sensemaker_job.persisted_output)
      filename = File.basename(@sensemaker_job.persisted_output)
      send_file @sensemaker_job.persisted_output, filename: filename
    else
      redirect_to admin_sensemaker_jobs_path,
                  alert: I18n.t("admin.sensemaker.notice.output_file_not_found")
    end
  end

  def cancel
    Delayed::Job.where(queue: "sensemaker").destroy_all
    running_jobs = Sensemaker::Job.running.all
    running_jobs.each(&:cancel!)

    redirect_to admin_sensemaker_jobs_path,
                notice: I18n.t("admin.sensemaker.notice.cancelled_jobs")
  end

  def publish
    @sensemaker_job = Sensemaker::Job.find(params[:id])

    unless @sensemaker_job.finished? && !@sensemaker_job.errored? && @sensemaker_job.has_output?
      redirect_to admin_sensemaker_job_path(@sensemaker_job),
                  alert: I18n.t("admin.sensemaker.notice.cannot_publish")
      return
    end

    @sensemaker_job.update!(published: true)
    redirect_to admin_sensemaker_job_path(@sensemaker_job),
                notice: I18n.t("admin.sensemaker.notice.published")
  end

  def unpublish
    @sensemaker_job = Sensemaker::Job.find(params[:id])
    @sensemaker_job.update!(published: false)
    redirect_to admin_sensemaker_job_path(@sensemaker_job),
                notice: I18n.t("admin.sensemaker.notice.unpublished")
  end

  def help
    # Help action for sensemaker documentation
  end

  private

    def sensemaker_job_params
      params.require(:sensemaker_job).permit(:analysable_type, :analysable_id, :script, :additional_context)
    end
end
