section "Creating Admin Notifications & Templates" do
  AdminNotification.create!(
    random_locales_attributes(
      **%i[title body].index_with do |attribute|
        -> { I18n.t("seeds.admin_notifications.proposal.#{attribute}") }
      end
    ).merge(
      link: Rails.application.routes.url_helpers.proposals_url(Tenant.current_url_options),
      segment_recipient: "administrators"
    )
  ).deliver

  AdminNotification.create!(
    random_locales_attributes(
      **%i[title body].index_with do |attribute|
        -> { I18n.t("seeds.admin_notifications.help.#{attribute}") }
      end
    ).merge(link: "https://crwd.in/consul", segment_recipient: "administrators")
  ).deliver

  AdminNotification.create!(
    random_locales_attributes(
      **%i[title body].index_with do |attribute|
        -> { I18n.t("seeds.admin_notifications.map.#{attribute}") }
      end
    ).merge(segment_recipient: "administrators")
  ).deliver

  AdminNotification.create!(
    random_locales_attributes(
      **%i[title body].index_with do |attribute|
        -> { I18n.t("seeds.admin_notifications.budget.#{attribute}") }
      end
    ).merge(segment_recipient: "administrators", sent_at: nil)
  )
end
