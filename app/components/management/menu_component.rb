class Management::MenuComponent < ApplicationComponent
  use_helpers :managed_user, :link_list

  private

    def user_links
      link_to(t("management.menu.users"), "#", class: "users-link") +
        link_list(
          select_user_link,
          (reset_password_email_link if managed_user.email),
          reset_password_manually_link,
          create_proposal_link,
          support_proposals_link,
          (create_budget_investment_link if Setting["process.budgets"]),
          (support_budget_investments_link  if Setting["process.budgets"]),
          class: "is-active"
        )
    end

    def select_user_link
      [
        t("management.menu.select_user"),
        management_document_verifications_path,
        users?
      ]
    end

    def reset_password_email_link
      [
        t("management.account.menu.reset_password_email"),
        edit_password_email_management_account_path,
        edit_password_email?
      ]
    end

    def reset_password_manually_link
      [
        t("management.account.menu.reset_password_manually"),
        edit_password_manually_management_account_path,
        edit_password_manually?
      ]
    end

    def create_proposal_link
      [
        t("management.menu.create_proposal"),
        new_management_proposal_path,
        create_proposal?
      ]
    end

    def support_proposals_link
      [
        t("management.menu.support_proposals"),
        management_proposals_path,
        support_proposal?
      ]
    end

    def create_budget_investment_link
      [
        t("management.menu.create_budget_investment"),
        create_investments_management_budgets_path,
        create_investments?
      ]
    end

    def support_budget_investments_link
      [
        t("management.menu.support_budget_investments"),
        support_investments_management_budgets_path,
        support_investments?
      ]
    end

    def users?
      ["users", "email_verifications", "document_verifications"].include?(controller_name)
    end

    def edit_password_email?
      controller_name == "account" && action_name == "edit_password_email"
    end

    def edit_password_manually?
      controller_name == "account" && action_name == "edit_password_manually"
    end

    def create_proposal?
      controller_name == "proposals" && action_name == "new"
    end

    def support_proposal?
      controller_name == "proposals" && action_name == "index"
    end

    def print_proposals?
      controller_name == "proposals" && action_name == "print"
    end

    def create_investments?
      (controller_name == "budget_investments" && action_name == "new") ||
        (controller_name == "budgets" && action_name == "create_investments")
    end

    def support_investments?
      (controller_name == "budget_investments" && action_name == "index") ||
        (controller_name == "budgets" && action_name == "support_investments")
    end

    def print_investments?
      (controller_name == "budget_investments" && action_name == "print") ||
        (controller_name == "budgets" && action_name == "print_investments")
    end

    def user_invites?
      controller_name == "user_invites"
    end
end
