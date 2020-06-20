class Admin::MenuComponent < ApplicationComponent
  private

    def moderated_content?
      moderated_sections.include?(controller_name) && controller.class.parent != Admin::Legislation
    end

    def moderated_sections
      ["hidden_proposals", "hidden_debates", "hidden_comments", "hidden_users", "activity",
       "hidden_budget_investments", "hidden_proposal_notifications"]
    end

    def budgets?
      controller_name.starts_with?("budget")
    end

    def polls?
      controller.class.parent == Admin::Poll::Questions::Answers ||
        %w[polls active_polls recounts results questions answers].include?(controller_name) &&
        action_name != "booth_assignments"
    end

    def booths?
      %w[officers booths shifts booth_assignments officer_assignments].include?(controller_name) ||
        controller_name == "polls" && action_name == "booth_assignments"
    end

    def profiles?
      %w[administrators organizations officials moderators valuators managers users].include?(controller_name)
    end

    def settings?
      controllers_names = ["settings", "tags", "geozones", "images", "content_blocks",
                           "local_census_records", "imports"]
      controllers_names.include?(controller_name) &&
        controller.class.parent != Admin::Poll::Questions::Answers
    end

    def customization?
      ["pages", "banners", "information_texts", "documents"].include?(controller_name) ||
        homepage? || pages?
    end

    def homepage?
      ["homepage", "cards"].include?(controller_name) && params[:page_id].nil?
    end

    def pages?
      ["pages", "cards"].include?(controller_name) && params[:page_id].present?
    end

    def dashboard?
      ["actions", "administrator_tasks"].include?(controller_name)
    end

    def local_census_records?
      controller_name == "local_census_records" ||
        (controller_name == "imports" && controller.class.parent == Admin::LocalCensusRecords)
    end
end
