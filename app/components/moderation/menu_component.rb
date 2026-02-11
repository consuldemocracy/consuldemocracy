class Moderation::MenuComponent < ApplicationComponent
  use_helpers :link_list

  def links
    [
      moderation_root_link,
      (proposals_link if feature?(:proposals)),
      (proposal_notifications_link if feature?(:proposals)),
      (debates_link if feature?(:debates)),
      (budget_investments_link if feature?(:budgets)),
      (legislation_proposals_link if feature?(:legislation)),
      comments_link,
      users_link
    ]
  end

  private

    def moderation_root_link
      [t("moderation.dashboard.index.title"), moderation_root_path]
    end

    def proposals_link
      [
        t("moderation.menu.proposals"),
        moderation_proposals_path,
        controller_name == "proposals" && !legislation?,
        class: "proposals-link"
      ]
    end

    def proposal_notifications_link
      [
        t("moderation.menu.proposal_notifications"),
        moderation_proposal_notifications_path,
        controller_name == "proposal_notifications",
        class: "proposal-notifications-link"
      ]
    end

    def debates_link
      [
        t("moderation.menu.flagged_debates"),
        moderation_debates_path,
        controller_name == "debates",
        class: "debates-link"
      ]
    end

    def budget_investments_link
      [
        t("moderation.menu.flagged_investments"),
        moderation_budget_investments_path,
        controller_name == "investments",
        class: "investments-link"
      ]
    end

    def comments_link
      [
        t("moderation.menu.flagged_comments"),
        moderation_comments_path,
        controller_name == "comments",
        class: "comments-link"
      ]
    end

    def users_link
      [
        t("moderation.menu.users"),
        moderation_users_path,
        controller_name == "users",
        class: "users-link"
      ]
    end

    def legislation_proposals_link
      [
        t("sdg_management.menu.legislation_proposals"),
        moderation_legislation_proposals_path,
        legislation?,
        class: "legislation-link"
      ]
    end

    def legislation?
      controller_path.split("/").include?("legislation")
    end
end
