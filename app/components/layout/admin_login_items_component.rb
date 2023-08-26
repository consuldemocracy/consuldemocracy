class Layout::AdminLoginItemsComponent < ApplicationComponent
  attr_reader :user
  delegate :link_list, :show_admin_menu?, to: :helpers

  def initialize(user)
    @user = user
  end

  def render?
    show_admin_menu?(user)
  end

  private

    def admin_links
      [
        (admin_link if user.administrator?),
        (moderation_link if user.administrator? || user.moderator?),
        (valuation_link if feature?(:budgets) && (user.administrator? || user.valuator?)),
        (management_link if user.administrator? || user.manager?),
        (officing_link if user.poll_officer?),
        (sdg_management_link if feature?(:sdg) && (user.administrator? || user.sdg_manager?))
      ]
    end

    def admin_link
      [t("layouts.header.administration"), admin_root_path]
    end

    def moderation_link
      [t("layouts.header.moderation"), moderation_root_path]
    end

    def valuation_link
      [t("layouts.header.valuation"), valuation_root_path]
    end

    def management_link
      [t("layouts.header.management"), management_sign_in_path]
    end

    def officing_link
      [t("layouts.header.officing"), officing_root_path]
    end

    def sdg_management_link
      [t("sdg_management.header.title"), sdg_management_root_path]
    end
end
