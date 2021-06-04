class Admin::MenuComponent < ApplicationComponent
  include LinkListHelper

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

    def messages_menu_active?
      messages_sections.include?(controller_name)
    end

    def messages_sections
      %w[newsletters emails_download admin_notifications system_emails]
    end

    def sdg_managers?
      controller_name == "managers" && controller.class.parent ==  Admin::SDG
    end

    def managers?
      controller_name == "managers" && controller.class.parent ==  Admin
    end

    def officers_link
      [
        t("admin.menu.poll_officers"),
        admin_officers_path,
        %w[officers officer_assignments].include?(controller_name)
      ]
    end

    def booths_link
      [
        t("admin.menu.poll_booths"),
        admin_booths_path,
        controller_name == "booths" && action_name != "available"
      ]
    end

    def booth_assignments_link
      [
        t("admin.menu.poll_booth_assignments"),
        booth_assignments_admin_polls_path,
        controller_name == "polls" && action_name == "booth_assignments" || controller_name == "booth_assignments" && action_name == "manage"
      ]
    end

    def shifts_link
      [
        t("admin.menu.poll_shifts"),
        available_admin_booths_path,
        %w[shifts booths].include?(controller_name) && %w[available new].include?(action_name)
      ]
    end

    def newsletters_link
      [
        t("admin.menu.newsletters"),
        admin_newsletters_path,
        controller_name == "newsletters"
      ]
    end

    def admin_notifications_link
      [
        t("admin.menu.admin_notifications"),
        admin_admin_notifications_path,
        controller_name == "admin_notifications"
      ]
    end

    def system_emails_link
      [
        t("admin.menu.system_emails"),
        admin_system_emails_path,
        controller_name == "system_emails"
      ]
    end

    def emails_download_link
      [
        t("admin.menu.emails_download"),
        admin_emails_download_index_path,
        controller_name == "emails_download"
      ]
    end

    def homepage_link
      [
        t("admin.menu.site_customization.homepage"),
        admin_homepage_path,
        homepage?
      ]
    end

    def pages_link
      [
        t("admin.menu.site_customization.pages"),
        admin_site_customization_pages_path,
        pages? || controller_name == "pages"
      ]
    end

    def banners_link
      [
        t("admin.menu.banner"),
        admin_banners_path,
        controller_name == "banners"
      ]
    end

    def information_texts_link
      [
        t("admin.menu.site_customization.information_texts"),
        admin_site_customization_information_texts_path,
        controller_name == "information_texts"
      ]
    end

    def documents_link
      [
        t("admin.menu.site_customization.documents"),
        admin_site_customization_documents_path,
        controller_name == "documents"
      ]
    end

    def hidden_proposals_link
      [
        t("admin.menu.hidden_proposals"),
        admin_hidden_proposals_path,
        controller_name == "hidden_proposals"
      ]
    end

    def hidden_debates_link
      [
        t("admin.menu.hidden_debates"),
        admin_hidden_debates_path,
        controller_name == "hidden_debates"
      ]
    end

    def hidden_budget_investments_link
      [
        t("admin.menu.hidden_budget_investments"),
        admin_hidden_budget_investments_path,
        controller_name == "hidden_budget_investments"
      ]
    end

    def hidden_comments_link
      [
        t("admin.menu.hidden_comments"),
        admin_hidden_comments_path,
        controller_name == "hidden_comments"
      ]
    end

    def hidden_proposal_notifications_link
      [
        t("admin.menu.hidden_proposal_notifications"),
        admin_hidden_proposal_notifications_path,
        controller_name == "hidden_proposal_notifications"
      ]
    end

    def hidden_users_link
      [
        t("admin.menu.hidden_users"),
        admin_hidden_users_path,
        controller_name == "hidden_users"
      ]
    end

    def activity_link
      [
        t("admin.menu.activity"),
        admin_activity_path,
        controller_name == "activity"
      ]
    end

    def administrators_link
      [
        t("admin.menu.administrators"),
        admin_administrators_path,
        controller_name == "administrators"
      ]
    end

    def organizations_link
      [
        t("admin.menu.organizations"),
        admin_organizations_path,
        controller_name == "organizations"
      ]
    end

    def officials_link
      [
        t("admin.menu.officials"),
        admin_officials_path,
        controller_name == "officials"
      ]
    end

    def moderators_link
      [
        t("admin.menu.moderators"),
        admin_moderators_path,
        controller_name == "moderators"
      ]
    end

    def valuators_link
      [
        t("admin.menu.valuators"),
        admin_valuators_path,
        controller_name == "valuators"
      ]
    end

    def managers_link
      [
        t("admin.menu.managers"),
        admin_managers_path,
        managers?
      ]
    end

    def users_link
      [
        t("admin.menu.users"),
        admin_users_path,
        controller_name == "users"
      ]
    end

    def settings_link
      [
        t("admin.menu.settings"),
        admin_settings_path,
        controller_name == "settings"
      ]
    end

    def tags_link
      [
        t("admin.menu.proposals_topics"),
        admin_tags_path,
        controller_name == "tags"
      ]
    end

    def geozones_link
      [
        t("admin.menu.geozones"),
        admin_geozones_path,
        controller_name == "geozones"
      ]
    end

    def images_link
      [
        t("admin.menu.site_customization.images"),
        admin_site_customization_images_path,
        controller_name == "images" && controller.class.parent != Admin::Poll::Questions::Answers
      ]
    end

    def content_blocks_link
      [
        t("admin.menu.site_customization.content_blocks"),
        admin_site_customization_content_blocks_path,
        controller_name == "content_blocks"
      ]
    end

    def local_census_records_link
      [
        t("admin.menu.local_census_records"),
        admin_local_census_records_path,
        local_census_records?
      ]
    end

    def administrator_tasks_link
      [
        t("admin.menu.administrator_tasks"),
        admin_dashboard_administrator_tasks_path,
        controller_name == "administrator_tasks"
      ]
    end

    def dashboard_actions_link
      [
        t("admin.menu.dashboard_actions"),
        admin_dashboard_actions_path,
        controller_name == "actions"
      ]
    end

    def sdg_managers_link
      [
        t("admin.menu.sdg_managers"),
        admin_sdg_managers_path,
        sdg_managers?
      ]
    end
end
