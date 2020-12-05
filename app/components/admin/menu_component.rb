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

    def subnavigation_link(controller)
      [
        t("admin.menu.#{controller.tr("/", ".")}"),
        { controller: "/admin/#{controller}", action: :index },
        controller_name == controller.split("/").last
      ]
    end

    %w[
      newsletters admin_notifications system_emails emails_download
      hidden_proposals hidden_debates hidden_budget_investments hidden_comments hidden_proposal_notifications hidden_users activity
      banners
      administrators organizations officials moderators valuators managers users
      settings tags geozones
    ].each do |controller|
      define_method :"#{controller}_link" do
        subnavigation_link(controller)
      end
    end

    %w[information_texts documents content_blocks].each do |controller|
      define_method :"#{controller}_link" do
        subnavigation_link("site_customization/#{controller}")
      end
    end

    %w[administrator_tasks actions].each do |controller|
      define_method :"dashboard_#{controller}_link" do
        subnavigation_link("dashboard/#{controller}")
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

    def images_link
      [
        t("admin.menu.site_customization.images"),
        admin_site_customization_images_path,
        controller_name == "images" && controller.class.parent != Admin::Poll::Questions::Answers
      ]
    end

    def local_census_records_link
      [
        t("admin.menu.local_census_records"),
        admin_local_census_records_path,
        local_census_records?
      ]
    end
end
