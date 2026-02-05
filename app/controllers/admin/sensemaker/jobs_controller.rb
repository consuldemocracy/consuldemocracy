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

    target_query = params.fetch(:query, nil)
    query_type = params.fetch(:query_type, "Legislation::Process")
    limit = 20

    @search_results = []
    @result_count = 0

    case query_type
    when "Legislation::Process"
      scope = Legislation::Process.includes(:questions, :proposals)
      if target_query.present?
        processes = scope.search(target_query)
      else
        processes = scope.order(created_at: :desc).limit(limit)
      end

      processes.each do |process|
        collection = []

        unless process.proposals.empty?
          collection << {
            title: I18n.t("activerecord.models.legislation/proposal.other"),
            collection: process.proposals.map { |p| { title: result_title_for(p), object: p } }
          }
          @result_count += process.proposals.count
        end

        unless process.questions.empty?
          question_collection = []

          process.questions.each do |q|
            @result_count += 1
            question_collection << { title: result_title_for(q), object: q }
            question_options = q.question_options.map { |qo| { title: result_title_for(qo), object: qo } }
            @result_count += question_options.size
            question_collection << { title: I18n.t("admin.sensemaker.new.segment_by_option"),
                                     collection: question_options } unless question_options.empty?
          end

          collection << { title: I18n.t("activerecord.models.legislation/questions.other"),
                          collection: question_collection } unless question_collection.empty?
        end

        @search_results << {
          title: process.title,
          collection: collection
        }
      end
    when "Budget"
      scope = Budget.published.with_translations(Globalize.fallbacks(I18n.locale))
      if target_query.present?
        budgets = scope.where("budget_translations.name ILIKE ?", "%#{target_query}%")
      else
        budgets = scope.order(created_at: :desc).limit(limit)
      end

      collection = []
      budgets.each do |budget|
        collection << { title: result_title_for(budget), object: budget }
        @result_count += 1

        group_entries = budget.groups.includes(:translations).map do |group|
          { title: result_title_for(group), object: group }
        end
        unless group_entries.empty?
          @result_count += group_entries.size
          collection << { title: I18n.t("admin.sensemaker.new.groups"), collection: group_entries }
        end
      end

      @search_results << {
        title: I18n.t("activerecord.models.budget.other"),
        collection: collection
      }
    when "Poll"
      scope = Poll.not_budget.includes(questions: :question_options)
      if target_query.present?
        polls = scope.search(target_query)
      else
        polls = scope.order(created_at: :desc).limit(limit)
      end

      collection = []
      polls.each do |poll|
        collection << { title: result_title_for(poll), object: poll }
        @result_count += 1

        question_entries = poll.questions.map do |q|
          @result_count += 1
          entry = { title: result_title_for(q), object: q }
          entry = entry.merge({
            disabled: I18n.t("admin.sensemaker.new.no_free_text_to_analyse")
          }) unless q.open?
          entry
        end
        unless question_entries.empty?
          collection << { title: I18n.t("activerecord.models.legislation/questions.other"),
                          collection: question_entries }
        end
      end

      @search_results << {
        title: I18n.t("activerecord.models.poll.other"),
        collection: collection
      }
    else
      if target_query.present?
        results = query_type.constantize.search(target_query)
      else
        results = query_type.constantize.order(created_at: :desc).limit(limit)
      end

      unless results.empty?
        @search_results = [{
          title: I18n.t("activerecord.models.#{query_type.underscore}.other"),
          collection: results.map { |obj| { title: result_title_for(obj), object: obj } }
        }]
        @result_count += results.size
      end
    end
  end

  def create
    valid_params = sensemaker_job_params.to_h

    if params[:quick_action].in?(%w[summary report])
      valid_params[:script] = params[:quick_action] == "summary" ? "runner.ts" : "single-html-build.js"
    elsif valid_params[:script].blank?
      return redirect_to(
        new_admin_sensemaker_job_path(
          target_type: valid_params[:analysable_type],
          target_id: valid_params[:analysable_id]
        ),
        alert: I18n.t("admin.sensemaker.notice.script_required")
      )
    end

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
    artefacts = @sensemaker_job.output_artifact_paths.select { |p| File.exist?(p) }

    if params[:artefact].present?
      requested = File.join(Sensemaker::Paths.sensemaker_data_folder, params[:artefact])
      if artefacts.include?(requested)
        return send_file requested, filename: File.basename(requested)
      else
        return redirect_to admin_sensemaker_job_path(@sensemaker_job),
                           alert: I18n.t("admin.sensemaker.notice.output_file_not_found")
      end
    end

    if @sensemaker_job.persisted_output.present? && File.exist?(@sensemaker_job.persisted_output)
      return send_file @sensemaker_job.persisted_output,
                       filename: File.basename(@sensemaker_job.persisted_output)
    end

    redirect_to admin_sensemaker_jobs_path,
                alert: I18n.t("admin.sensemaker.notice.output_file_not_found")
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

    if @sensemaker_job.update(published: true)
      redirect_to admin_sensemaker_job_path(@sensemaker_job),
                  notice: I18n.t("admin.sensemaker.notice.published")
    else
      redirect_to admin_sensemaker_job_path(@sensemaker_job),
                  alert: I18n.t("admin.sensemaker.notice.cannot_publish")
    end
  end

  def unpublish
    @sensemaker_job = Sensemaker::Job.find(params[:id])
    @sensemaker_job.update!(published: false)
    redirect_to admin_sensemaker_job_path(@sensemaker_job),
                notice: I18n.t("admin.sensemaker.notice.unpublished")
  end

  def help
  end

  private

    def sensemaker_job_params
      params.require(:sensemaker_job).permit(:analysable_type, :analysable_id, :script, :additional_context)
    end

    def result_title_for(obj)
      if obj.respond_to?(:title) && obj.title.present?
        "##{obj.id} #{obj.title}"
      elsif obj.respond_to?(:name) && obj.name.present?
        "##{obj.id} #{obj.name}"
      elsif obj.respond_to?(:value) && obj.value.present?
        "##{obj.id} #{obj.value}"
      else
        "##{obj.id} #{obj}"
      end
    end
end
