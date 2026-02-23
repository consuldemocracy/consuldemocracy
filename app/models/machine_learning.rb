require "csv"
require "fileutils"

class MachineLearning
  attr_reader :job, :ml_config

  # Maps the UI script keys to internal processing methods and categories
  AVAILABLE_SCRIPTS = {
    "proposal_tags" => { method: :generate_proposal_tags, kind: "tags" },
    "proposal_related_content" => {
      method: :generate_proposal_related_content, kind: "related_content"
    },
    "proposal_summary_comments" => {
      method: :generate_proposal_summary_comments, kind: "comments_summary"
    },
    "investment_tags" => { method: :generate_investment_tags, kind: "tags" },
    "investment_related_content" => {
      method: :generate_investment_related_content, kind: "related_content"
    },
    "investment_summary_comments" => {
      method: :generate_investment_summary_comments, kind: "comments_summary"
    },
    "legislation_summary_comments" => {
      method: :generate_legislation_summary_comments, kind: "comments_summary"
    }
  }.freeze

  # --- CLASS METHODS (Admin UI & Legacy Support) ---

  class << self
    def enabled?
      Setting["feature.machine_learning"].present? && Setting["llm.model"].present?
    end

    def script_kinds
      AVAILABLE_SCRIPTS.values.map { |v| v[:kind] }.uniq.sort
    end

    def script_select_options
      AVAILABLE_SCRIPTS.keys.map do |k|
        [I18n.t("admin.machine_learning.scripts.#{k}.label", default: k.humanize), k]
      end
    end

    def data_folder
      Rails.root.join("public", Tenant.path_with_subfolder("machine_learning/data"))
    end

    def data_path(filename)
      "/#{Tenant.path_with_subfolder("machine_learning/data")}/#{filename}"
    end

    # Legacy Filename Constants
    def proposals_tags_filename
      "ml_tags_proposals.json"
    end

    def investments_tags_filename
      "ml_tags_budgets.json"
    end

    def proposals_related_filename
      "ml_related_content_proposals.json"
    end

    def investments_related_filename
      "ml_related_content_budgets.json"
    end

    def proposals_comments_summary_filename
      "ml_comments_summaries_proposals.json"
    end

    def investments_comments_summary_filename
      "ml_comments_summaries_budgets.json"
    end

    def legislation_comments_summary_filename
      "ml_comments_summaries_legislation.json"
    end

    def data_output_files
      files = { tags: [], related_content: [], comments_summary: [] }

      # Mapping our constants to the categories the UI expects
      mappings = [
        [proposals_tags_filename, :tags],
        [investments_tags_filename, :tags],
        [proposals_related_filename, :related_content],
        [investments_related_filename, :related_content],
        [proposals_comments_summary_filename, :comments_summary],
        [investments_comments_summary_filename, :comments_summary],
        [legislation_comments_summary_filename, :comments_summary]
      ]

      mappings.each do |filename, kind|
        # Check if the file actually exists in the tenant's data folder
        files[kind] << filename if File.exist?(data_folder.join(filename))
      end

      files.with_indifferent_access
    end

    def data_intermediate_files
      return [] unless Dir.exist?(data_folder)

      # Collect any JSON/CSV that aren't the main output files
      all_files = Dir.glob(data_folder.join("*.{json,csv}")).map { |f| File.basename(f) }
      output_files = [
        proposals_tags_filename, investments_tags_filename,
        proposals_related_filename, investments_related_filename,
        proposals_comments_summary_filename, investments_comments_summary_filename,
        legislation_comments_summary_filename
      ]

      (all_files - output_files).sort
    end
  end

  # --- INSTANCE METHODS ---

  def initialize(job)
    @job = job
    @ml_config = (job.config || {}).with_indifferent_access
    @force = @ml_config[:force_update] == "1"
    @dry_run = job.dry_run
    @total_tokens_used = 0
    @records_processed = 0
  end

  def run
    script_info = AVAILABLE_SCRIPTS[job.script]
    if script_info
      clear_existing_ml_data(script_info[:kind]) if @force
      send(script_info[:method])

      job.update!(
        finished_at: Time.current,
        total_tokens: @total_tokens_used,
        records_processed: @records_processed
      )

      Mailer.machine_learning_success(job.user).deliver_now unless @dry_run
    else
      raise "Unknown script: #{job.script}"
    end
  rescue => e
    job.update!(error: e.message, finished_at: Time.current)
    Mailer.machine_learning_error(job.user).deliver_later
    raise e
  end

  private

    # --- CORE PROCESSING LOOPS ---

    def process_tags_for(scope, record_type, filename)
      export_data = []
      scope.find_each do |record|
        next unless should_reprocess_record?(record, "tags")

        result = MlHelper.generate_tags("#{record.title} #{record.description}", 5, config: ml_config)
        if result && result["tags"]
          unless @dry_run
            record.set_tag_list_on(:ml_tags, result["tags"])
            record.save!(validate: false)
            export_data << { id: record.id, name: result["tags"].join(", "), kind: record_type }
          end
          track_usage(result)
        end
      end
      finalize_batch("tags", export_data, filename)
    end

    def process_summaries_for(scope, record_type, filename)
      export_data = []
      scope.find_each do |record|
        comments = Comment.where(commentable: record).pluck(:body).compact_blank
        next if comments.empty? || !should_reprocess_record?(record, "summary")

        result = MlHelper.summarize_comments(comments, record.title, config: ml_config)
        if result && result["summary_markdown"]
          unless @dry_run
            summary = MlSummaryComment.find_or_initialize_by(commentable: record)
            summary.update!(
              body: result["summary_markdown"],
              sentiment_analysis: result["sentiment"]
            )
            export_data << {
              commentable_id: record.id, commentable_type: record_type, body: result["summary_markdown"]
            }
          end
          track_usage(result)
        end
      end
      finalize_batch("comments_summary", export_data, filename)
    end

    def process_related_content_for(scope, record_type, filename)
      # RAM Safety: Limit candidate pool for comparisons
      records = scope.order(created_at: :desc).limit(100).to_a
      export_data = []

      records.each do |record|
        next unless should_reprocess_record?(record, "related_content")

        candidates = records.reject { |r| r.id == record.id }
        candidate_texts = candidates.map { |c| "#{c.title} #{c.description}" }

        result = MlHelper.find_similar_content(
          "#{record.title} #{record.description}", candidate_texts, 3, config: ml_config
        )
        if result && result["indices"]
          related_ids = result["indices"].map { |i| candidates[i]&.id }.compact
          save_related_content(record, related_ids, record_type) unless @dry_run

          res = { id: record.id }
          related_ids.each_with_index { |rid, i| res["related_#{i + 1}"] = rid }
          export_data << res
          track_usage(result)
        end
      end
      finalize_batch("related_content", export_data, filename)
    end

    # --- DATA INTEGRITY HELPERS ---

    def save_related_content(record, related_ids, record_type)
      score = related_ids.size
      related_ids.each do |child_id|
        child_id = child_id.to_i
        next if record.id == child_id

        # UniqueViolation Fix: Check with_hidden because of acts_as_paranoid
        existing = RelatedContent.with_hidden.find_by(
          parent_relationable_id: record.id, parent_relationable_type: record_type,
          child_relationable_id: child_id, child_relationable_type: record_type
        )

        if existing
          existing.update!(
            machine_learning: true, machine_learning_score: score, author_id: job.user_id, hidden_at: nil
          )
        else
          # Callback creates the opposite record automatically
          RelatedContent.create!(
            parent_relationable_id: record.id, parent_relationable_type: record_type,
            child_relationable_id: child_id, child_relationable_type: record_type,
            machine_learning: true, machine_learning_score: score, author_id: job.user_id
          )
        end
        score -= 1
      end
    end

    def clear_existing_ml_data(kind)
      case kind
      when "tags"
        Tagging.where(context: "ml_tags").delete_all
      when "comments_summary"
        MlSummaryComment.delete_all
      when "related_content"
        ml_scope = RelatedContent.with_hidden.where(machine_learning: true)
        ml_ids = ml_scope.ids
        if ml_ids.any?
          # ForeignKey Fix: Delete scores first
          RelatedContentScore.where(related_content_id: ml_ids).delete_all
          # StackLevelTooDeep Fix: Use delete_all to skip recursive callbacks
          ml_scope.delete_all
        end
      end
    end

    def should_reprocess_record?(record, type)
      return true if @force

      case type
      when "tags" then !record.taggings.where(context: "ml_tags").exists?
      when "summary" then MlSummaryComment.where(commentable: record).empty?
      when "related_content"
        # Bi-directional check: is this record involved in any ML relationship?
        !RelatedContent.with_hidden.where(machine_learning: true)
                       .where("parent_relationable_id = :id OR child_relationable_id = :id", id: record.id)
                       .exists?
      else true
      end
    end

    # --- EXPORT & UTILITY ---

    def finalize_batch(kind, export_data, filename)
      return if @dry_run

      save_results_to_json(export_data, filename)
      update_machine_learning_info_for(kind)
    end

    def save_results_to_json(results, filename)
      return if results.empty?

      path = self.class.data_folder.join(filename)
      FileUtils.mkdir_p(File.dirname(path))

      File.write(path, JSON.pretty_generate(results))

      # CSV Mirroring for legacy Open Data support
      csv_path = path.to_s.sub(".json", ".csv")
      CSV.open(csv_path, "wb") do |csv|
        csv << results.first.keys
        results.each { |r| csv << r.values }
      end
    end

    def update_machine_learning_info_for(kind)
      MachineLearningInfo.find_or_create_by!(kind: kind).update!(
        generated_at: Time.current, script: job.script
      )
    end

    def track_usage(result)
      @total_tokens_used += result.dig("usage", "total_tokens").to_i
      @records_processed += 1
    end

    # --- WRAPPERS ---

    def generate_proposal_tags
      process_tags_for(Proposal.all, "Proposal", self.class.proposals_tags_filename)
    end

    def generate_proposal_related_content
      process_related_content_for(Proposal.all, "Proposal", self.class.proposals_related_filename)
    end

    def generate_proposal_summary_comments
      process_summaries_for(Proposal.all, "Proposal", self.class.proposals_comments_summary_filename)
    end

    def generate_investment_tags
      process_tags_for(Budget::Investment.all, "Budget::Investment", self.class.investments_tags_filename)
    end

    def generate_investment_related_content
      process_related_content_for(
        Budget::Investment.all, "Budget::Investment", self.class.investments_related_filename
      )
    end

    def generate_investment_summary_comments
      process_summaries_for(
        Budget::Investment.all, "Budget::Investment", self.class.investments_comments_summary_filename
      )
    end

    def generate_legislation_summary_comments
      process_summaries_for(
        Legislation::Question.all, "Legislation::Question", self.class.legislation_comments_summary_filename
      )
    end
end
