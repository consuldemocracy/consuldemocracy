class MachineLearning
  attr_reader :user, :script, :previous_modified_date
  attr_accessor :job

  SCRIPTS_FOLDER = Rails.root.join("public", "machine_learning", "scripts").freeze

  def initialize(job)
    @job = job
    @user = job.user
    @previous_modified_date = set_previous_modified_date
  end

  def data_folder
    self.class.data_folder
  end

  def run
    export_proposals_to_json
    export_budget_investments_to_json
    export_comments_to_json

    return unless run_machine_learning_scripts

    if updated_file?(MachineLearning.proposals_taggings_filename) &&
       updated_file?(MachineLearning.proposals_tags_filename)
      cleanup_proposals_tags!
      import_ml_proposals_tags
      update_machine_learning_info_for("tags")
    end

    if updated_file?(MachineLearning.investments_taggings_filename) &&
       updated_file?(MachineLearning.investments_tags_filename)
      cleanup_investments_tags!
      import_ml_investments_tags
      update_machine_learning_info_for("tags")
    end

    if updated_file?(MachineLearning.proposals_related_filename)
      cleanup_proposals_related_content!
      import_proposals_related_content
      update_machine_learning_info_for("related_content")
    end

    if updated_file?(MachineLearning.investments_related_filename)
      cleanup_investments_related_content!
      import_budget_investments_related_content
      update_machine_learning_info_for("related_content")
    end

    if updated_file?(MachineLearning.proposals_comments_summary_filename)
      cleanup_proposals_comments_summary!
      import_ml_proposals_comments_summary
      update_machine_learning_info_for("comments_summary")
    end

    if updated_file?(MachineLearning.investments_comments_summary_filename)
      cleanup_investments_comments_summary!
      import_ml_investments_comments_summary
      update_machine_learning_info_for("comments_summary")
    end

    job.update!(finished_at: Time.current)
    Mailer.machine_learning_success(user).deliver_later
  rescue Exception => e
    handle_error(e)
    raise e
  end
  handle_asynchronously :run, queue: "machine_learning"

  class << self
    def enabled?
      Setting["feature.machine_learning"].present?
    end

    def proposals_filename
      "proposals.json"
    end

    def investments_filename
      "budget_investments.json"
    end

    def comments_filename
      "comments.json"
    end

    def data_folder
      Rails.root.join("public", tenant_data_folder)
    end

    def tenant_data_folder
      Tenant.path_with_subfolder("machine_learning/data")
    end

    def data_output_files
      files = { tags: [], related_content: [], comments_summary: [] }

      if File.exist?(data_folder.join(proposals_tags_filename))
        files[:tags] << proposals_tags_filename
      end
      if File.exist?(data_folder.join(proposals_taggings_filename))
        files[:tags] << proposals_taggings_filename
      end
      if File.exist?(data_folder.join(investments_tags_filename))
        files[:tags] << investments_tags_filename
      end
      if File.exist?(data_folder.join(investments_taggings_filename))
        files[:tags] << investments_taggings_filename
      end

      if File.exist?(data_folder.join(proposals_related_filename))
        files[:related_content] << proposals_related_filename
      end
      if File.exist?(data_folder.join(investments_related_filename))
        files[:related_content] << investments_related_filename
      end

      if File.exist?(data_folder.join(proposals_comments_summary_filename))
        files[:comments_summary] << proposals_comments_summary_filename
      end
      if File.exist?(data_folder.join(investments_comments_summary_filename))
        files[:comments_summary] << investments_comments_summary_filename
      end

      files
    end

    def data_intermediate_files
      excluded = [
        proposals_filename,
        investments_filename,
        comments_filename,
        proposals_tags_filename,
        proposals_taggings_filename,
        investments_tags_filename,
        investments_taggings_filename,
        proposals_related_filename,
        investments_related_filename,
        proposals_comments_summary_filename,
        investments_comments_summary_filename
      ]
      json = Dir[data_folder.join("*.json")].map do |full_path_filename|
        full_path_filename.split("/").last
      end
      csv = Dir[data_folder.join("*.csv")].map do |full_path_filename|
        full_path_filename.split("/").last
      end
      (json + csv - excluded).sort
    end

    def proposals_tags_filename
      "ml_tags_proposals.json"
    end

    def proposals_taggings_filename
      "ml_taggings_proposals.json"
    end

    def investments_tags_filename
      "ml_tags_budgets.json"
    end

    def investments_taggings_filename
      "ml_taggings_budgets.json"
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

    def data_path(filename)
      "/#{tenant_data_folder}/#{filename}"
    end

    def script_kinds
      %w[tags related_content comments_summary]
    end

    def scripts_info
      Dir[SCRIPTS_FOLDER.join("*.py")].map do |full_path_filename|
        {
          name: full_path_filename.split("/").last,
          description: description_from(full_path_filename)
        }
      end.sort_by { |script_info| script_info[:name] }
    end

    def description_from(script_filename)
      description = "" # TODO
      delimiter = '"""'
      break_line = "<br>"
      comment_found = false
      File.readlines(script_filename).each do |line|
        if line.start_with?(delimiter) && !comment_found
          comment_found = true
          line.slice!(delimiter)
          description << line.strip.concat(break_line) if line.present?
        elsif line.include?(delimiter)
          line.slice!(delimiter)
          description << line.strip if line.present?
          break
        elsif comment_found
          description << line.strip.concat(break_line)
        end
      end

      description.delete_suffix(break_line)
    end
  end

  private

    def create_data_folder
      FileUtils.mkdir_p data_folder
    end

    def export_proposals_to_json
      create_data_folder
      filename = data_folder.join(MachineLearning.proposals_filename)
      Proposal::Exporter.new.to_json_file(filename)
    end

    def export_budget_investments_to_json
      create_data_folder
      filename = data_folder.join(MachineLearning.investments_filename)
      Budget::Investment::Exporter.new(Array.new).to_json_file(filename)
    end

    def export_comments_to_json
      create_data_folder
      filename = data_folder.join(MachineLearning.comments_filename)
      Comment::Exporter.new.to_json_file(filename)
    end

    def run_machine_learning_scripts
      command = if Tenant.default?
                  "python #{job.script}"
                else
                  "CONSUL_TENANT=#{Tenant.current_schema} python #{job.script}"
                end

      output = `cd #{SCRIPTS_FOLDER} && #{command} 2>&1`
      result = $?.success?
      if result == false
        job.update!(finished_at: Time.current, error: output)
        Mailer.machine_learning_error(user).deliver_later
      end
      result
    end

    def cleanup_proposals_tags!
      Tagging.where(context: "ml_tags", taggable_type: "Proposal").find_each(&:destroy!)
      Tag.find_each { |tag| tag.destroy! if Tagging.where(tag: tag).empty? }
    end

    def cleanup_investments_tags!
      Tagging.where(context: "ml_tags", taggable_type: "Budget::Investment").find_each(&:destroy!)
      Tag.find_each { |tag| tag.destroy! if Tagging.where(tag: tag).empty? }
    end

    def cleanup_proposals_related_content!
      RelatedContent.with_hidden.for_proposals.from_machine_learning.find_each(&:really_destroy!)
    end

    def cleanup_investments_related_content!
      RelatedContent.with_hidden.for_investments.from_machine_learning.find_each(&:really_destroy!)
    end

    def cleanup_proposals_comments_summary!
      MlSummaryComment.where(commentable_type: "Proposal").find_each(&:destroy!)
    end

    def cleanup_investments_comments_summary!
      MlSummaryComment.where(commentable_type: "Budget::Investment").find_each(&:destroy!)
    end

    def import_ml_proposals_comments_summary
      json_file = data_folder.join(MachineLearning.proposals_comments_summary_filename)
      json_data = JSON.parse(File.read(json_file)).each(&:deep_symbolize_keys!)
      json_data.each do |attributes|
        attributes.delete(:id)
        unless MlSummaryComment.find_by(commentable_id: attributes[:commentable_id],
                                        commentable_type: "Proposal")
          MlSummaryComment.create!(attributes)
        end
      end
    end

    def import_ml_investments_comments_summary
      json_file = data_folder.join(MachineLearning.investments_comments_summary_filename)
      json_data = JSON.parse(File.read(json_file)).each(&:deep_symbolize_keys!)
      json_data.each do |attributes|
        attributes.delete(:id)
        unless MlSummaryComment.find_by(commentable_id: attributes[:commentable_id],
                                        commentable_type: "Budget::Investment")
          MlSummaryComment.create!(attributes)
        end
      end
    end

    def import_proposals_related_content
      json_file = data_folder.join(MachineLearning.proposals_related_filename)
      json_data = JSON.parse(File.read(json_file)).each(&:deep_symbolize_keys!)
      json_data.each do |related|
        id = related.delete(:id)
        score = related.size
        related.each do |_, related_id|
          if related_id.present?
            attributes = {
              parent_relationable_id: id,
              parent_relationable_type: "Proposal",
              child_relationable_id: related_id,
              child_relationable_type: "Proposal"
            }
            related_content = RelatedContent.find_by(attributes)
            if related_content.present?
              related_content.update!(machine_learning_score: score)
            else
              RelatedContent.create!(attributes.merge(machine_learning: true,
                                                      author: user,
                                                      machine_learning_score: score))
            end
          end
          score -= 1
        end
      end
    end

    def import_budget_investments_related_content
      json_file = data_folder.join(MachineLearning.investments_related_filename)
      json_data = JSON.parse(File.read(json_file)).each(&:deep_symbolize_keys!)
      json_data.each do |related|
        id = related.delete(:id)
        score = related.size
        related.each do |_, related_id|
          if related_id.present?
            attributes = {
              parent_relationable_id: id,
              parent_relationable_type: "Budget::Investment",
              child_relationable_id: related_id,
              child_relationable_type: "Budget::Investment"
            }
            related_content = RelatedContent.find_by(attributes)
            if related_content.present?
              related_content.update!(machine_learning_score: score)
            else
              RelatedContent.create!(attributes.merge(machine_learning: true,
                                                      author: user,
                                                      machine_learning_score: score))
            end
          end
          score -= 1
        end
      end
    end

    def import_ml_proposals_tags
      ids = {}
      json_file = data_folder.join(MachineLearning.proposals_tags_filename)
      json_data = JSON.parse(File.read(json_file)).each(&:deep_symbolize_keys!)
      json_data.each do |attributes|
        if attributes[:name].present?
          attributes.delete(:taggings_count)
          if attributes[:name].length >= 150
            attributes[:name] = attributes[:name].truncate(150)
          end
          tag = Tag.find_or_create_by!(name: attributes[:name])
          ids[attributes[:id]] = tag.id
        end
      end

      json_file = data_folder.join(MachineLearning.proposals_taggings_filename)
      json_data = JSON.parse(File.read(json_file)).each(&:deep_symbolize_keys!)
      json_data.each do |attributes|
        if attributes[:tag_id].present?
          tag_id = ids[attributes[:tag_id]]
          if Tag.find_by(id: tag_id) && attributes[:taggable_id].present?
            attributes[:tag_id] = tag_id
            attributes[:taggable_type] = "Proposal"
            attributes[:context] = "ml_tags"
            Tagging.create!(attributes)
          end
        end
      end
    end

    def import_ml_investments_tags
      ids = {}
      json_file = data_folder.join(MachineLearning.investments_tags_filename)
      json_data = JSON.parse(File.read(json_file)).each(&:deep_symbolize_keys!)
      json_data.each do |attributes|
        if attributes[:name].present?
          attributes.delete(:taggings_count)
          if attributes[:name].length >= 150
            attributes[:name] = attributes[:name].truncate(150)
          end
          tag = Tag.find_or_create_by!(name: attributes[:name])
          ids[attributes[:id]] = tag.id
        end
      end

      json_file = data_folder.join(MachineLearning.investments_taggings_filename)
      json_data = JSON.parse(File.read(json_file)).each(&:deep_symbolize_keys!)
      json_data.each do |attributes|
        if attributes[:tag_id].present?
          tag_id = ids[attributes[:tag_id]]
          if Tag.find_by(id: tag_id) && attributes[:taggable_id].present?
            attributes[:tag_id] = tag_id
            attributes[:taggable_type] = "Budget::Investment"
            attributes[:context] = "ml_tags"
            Tagging.create!(attributes)
          end
        end
      end
    end

    def update_machine_learning_info_for(kind)
      MachineLearningInfo.find_or_create_by!(kind: kind)
                         .update!(generated_at: job.started_at, script: job.script)
    end

    def set_previous_modified_date
      proposals_tags_filename = MachineLearning.proposals_tags_filename
      proposals_taggings_filename = MachineLearning.proposals_taggings_filename
      investments_tags_filename = MachineLearning.investments_tags_filename
      investments_taggings_filename = MachineLearning.investments_taggings_filename
      proposals_related_filename = MachineLearning.proposals_related_filename
      investments_related_filename = MachineLearning.investments_related_filename
      proposals_comments_summary_filename = MachineLearning.proposals_comments_summary_filename
      investments_comments_summary_filename = MachineLearning.investments_comments_summary_filename

      {
        proposals_tags_filename => last_modified_date_for(proposals_tags_filename),
        proposals_taggings_filename => last_modified_date_for(proposals_taggings_filename),
        investments_tags_filename => last_modified_date_for(investments_tags_filename),
        investments_taggings_filename => last_modified_date_for(investments_taggings_filename),
        proposals_related_filename => last_modified_date_for(proposals_related_filename),
        investments_related_filename => last_modified_date_for(investments_related_filename),
        proposals_comments_summary_filename => last_modified_date_for(proposals_comments_summary_filename),
        investments_comments_summary_filename => last_modified_date_for(investments_comments_summary_filename)
      }
    end

    def last_modified_date_for(filename)
      return nil unless File.exist? data_folder.join(filename)

      File.mtime data_folder.join(filename)
    end

    def updated_file?(filename)
      return false unless File.exist? data_folder.join(filename)
      return true if previous_modified_date[filename].blank?

      last_modified_date_for(filename) > previous_modified_date[filename]
    end

    def handle_error(error)
      message = error.message
      backtrace = error.backtrace.select { |line| line.include?("machine_learning.rb") }
      full_error = ([message] + backtrace).join("<br>")
      job.update!(finished_at: Time.current, error: full_error)
      Mailer.machine_learning_error(user).deliver_later
    end
end
