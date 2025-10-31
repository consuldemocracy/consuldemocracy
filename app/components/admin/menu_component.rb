class Admin::MenuComponent < ApplicationComponent
  include LinkListHelper

  use_helpers :can?

  def links
    if Rails.application.multitenancy_management_mode?
      multitenancy_management_links
    else
      default_links
    end
  end

  private

    def default_links
      [
        (proposals_link if feature?(:proposals)),
        (debates_link if feature?(:debates)),
        comments_link,
        (polls_link if feature?(:polls)),
        (legislation_link if feature?(:legislation)),
        (budgets_link if feature?(:budgets)),
        booths_links,
        (signature_sheets_link if feature?(:signature_sheets)),
        messages_links,
        site_customization_links,
        moderated_content_links,
        profiles_links,
        stats_link,
        settings_links,
        dashboard_links,
        (machine_learning_link if ::MachineLearning.enabled?)
      ]
    end

    def multitenancy_management_links
      [tenants_link, administrators_link]
    end

    def moderated_content?
      moderated_sections.include?(controller_name) && controller.class.module_parent != Admin::Legislation
    end

    def moderated_sections
      ["hidden_proposals", "hidden_debates", "hidden_comments", "hidden_users", "activity",
       "hidden_budget_investments", "hidden_proposal_notifications"]
    end

    def budgets?
      controller_name.starts_with?("budget") || controller_path =~ /budgets_wizard/
    end

    def polls?
      controller.class.module_parent == Admin::Poll::Questions::Options ||
        %w[polls active_polls recounts results questions options].include?(controller_name) &&
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
      controllers_names = %w[settings tenants tags locales geozones local_census_records imports]
      controllers_names.include?(controller_name)
    end

    def customization?
      controllers_names = ["pages", "banners", "information_texts", "documents", "images", "content_blocks"]

      (controllers_names.include?(controller_name) || homepage? || pages?) &&
        controller.class.module_parent != Admin::Poll::Questions::Options
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
        (controller_name == "imports" && controller.class.module_parent == Admin::LocalCensusRecords)
    end

    def messages_menu_active?
      messages_sections.include?(controller_name)
    end

    def messages_sections
      %w[newsletters emails_download admin_notifications system_emails]
    end

    def sdg_managers?
      controller_name == "managers" && controller.class.module_parent == Admin::SDG
    end

    def managers?
      controller_name == "managers" && controller.class.module_parent == Admin
    end

    def proposals_link
      [
        t("admin.menu.proposals"),
        admin_proposals_path,
        controller_name == "proposals",
        class: "proposals-link"
      ]
    end

    def debates_link
      [
        t("admin.menu.debates"),
        admin_debates_path,
        controller_name == "debates",
        class: "debates-link"
      ]
    end

    def polls_link
      [
        t("admin.menu.polls"),
        admin_polls_path,
        polls?,
        class: "polls-link"
      ]
    end

    def comments_link
      [
        t("admin.menu.comments"),
        admin_comments_path,
        controller_name == "comments",
        class: "comments-link"
      ]
    end

    def legislation_link
      [
        t("admin.menu.legislation"),
        admin_legislation_processes_path,
        controller.class.module_parent == Admin::Legislation,
        class: "legislation-link"
      ]
    end

    def budgets_link
      [
        t("admin.menu.budgets"),
        admin_budgets_path,
        budgets?,
        class: "budgets-link"
      ]
    end

    def booths_links
      section(t("admin.menu.title_booths"), active: booths?, class: "booths-link") do
        link_list(
          officers_link,
          booths_link,
          booth_assignments_link,
          shifts_link,
          id: "booths_menu"
        )
      end
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
        controller_name == "polls" && action_name == "booth_assignments" ||
          controller_name == "booth_assignments" && action_name == "manage"
      ]
    end

    def shifts_link
      [
        t("admin.menu.poll_shifts"),
        available_admin_booths_path,
        %w[shifts booths].include?(controller_name) && %w[available new].include?(action_name)
      ]
    end

    def signature_sheets_link
      [
        t("admin.menu.signature_sheets"),
        admin_signature_sheets_path,
        controller_name == "signature_sheets",
        class: "signature-sheets-link"
      ]
    end

    def messages_links
      section(t("admin.menu.messaging_users"), active: messages_menu_active?, class: "messages-link") do
        link_list(
          newsletters_link,
          admin_notifications_link,
          system_emails_link,
          emails_download_link,
          id: "messaging_users_menu"
        )
      end
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

    def site_customization_links
      section(t("admin.menu.title_site_customization"),
              active: customization?, class: "site-customization-link") do
        link_list(
          homepage_link,
          pages_link,
          banners_link,
          information_texts_link,
          documents_link,
          images_link,
          content_blocks_link
        )
      end
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

    def moderated_content_links
      section(t("admin.menu.title_moderated_content"),
              active: moderated_content?, class: "moderated-content-link") do
        link_list(
          (hidden_proposals_link if feature?(:proposals)),
          (hidden_debates_link if feature?(:debates)),
          (hidden_budget_investments_link if feature?(:budgets)),
          hidden_comments_link,
          hidden_proposal_notifications_link,
          hidden_users_link,
          activity_link
        )
      end
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

    def profiles_links
      section(t("admin.menu.title_profiles"), active: profiles?, class: "profiles-link") do
        link_list(
          administrators_link,
          organizations_link,
          officials_link,
          moderators_link,
          valuators_link,
          managers_link,
          (sdg_managers_link if feature?(:sdg)),
          users_link
        )
      end
    end

    def administrators_link
      [
        t("admin.menu.administrators"),
        admin_administrators_path,
        controller_name == "administrators",
        class: "administrators-link"
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

    def stats_link
      [
        t("admin.menu.stats"),
        admin_stats_path,
        controller_name == "stats",
        class: "stats-link"
      ]
    end

    def settings_links
      section(t("admin.menu.title_settings"), active: settings?, class: "settings-link") do
        link_list(
          settings_link,
          tenants_link,
          tags_link,
          (locales_link if I18n.available_locales.many?),
          geozones_link,
          local_census_records_link
        )
      end
    end

    def settings_link
      [
        t("admin.menu.settings"),
        admin_settings_path,
        controller_name == "settings"
      ]
    end

    def tenants_link
      if can?(:read, Tenant)
        [
          t("admin.menu.multitenancy"),
          admin_tenants_path,
          controller_name == "tenants",
          class: "tenants-link"
        ]
      end
    end

    def tags_link
      [
        t("admin.menu.proposals_topics"),
        admin_tags_path,
        controller_name == "tags"
      ]
    end

    def locales_link
      [
        t("admin.menu.locales"),
        admin_locales_path,
        controller_name == "locales"
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
        controller_name == "images" && controller.class.module_parent != Admin::Poll::Questions::Options
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

    def dashboard_links
      section(t("admin.menu.dashboard"), active: dashboard?, class: "dashboard-link") do
        link_list(
          dashboard_actions_link,
          administrator_tasks_link
        )
      end
    end

    def machine_learning_link
      [
        t("admin.menu.machine_learning"),
        admin_machine_learning_path,
        controller_name == "machine_learning",
        class: "ml-link"
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

    def section(title, **, &content)
      section_opener(title, **) + content.call
    end

    def section_opener(title, active:, **options)
      button_tag(title, { type: "button", disabled: "disabled", "aria-expanded": active }.merge(options))
    end
end
