class Management::MenuComponent < ApplicationComponent
  use_helpers :managed_user, :link_list

  private

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
