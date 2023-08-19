class Layout::AdminHeaderComponent < ApplicationComponent
  attr_reader :user
  delegate :namespace, :namespaced_root_path, :show_admin_menu?, to: :helpers

  def initialize(user)
    @user = user
  end

  private

    def namespaced_header_title
      if namespace == "moderation/budgets"
        t("moderation.header.title")
      elsif namespace == "management"
        t("management.dashboard.index.title")
      else
        t("#{namespace}.header.title")
      end
    end

    def namespace_path
      if namespace == "officing"
        "#"
      else
        namespaced_root_path
      end
    end

    def show_account_menu?
      show_admin_menu?(user) || namespace != "management"
    end
end
