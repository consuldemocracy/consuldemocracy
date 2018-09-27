section "Creating Admin Notifications & Templates" do
  AdminNotification.create!(
    title: I18n.t('seeds.admin_notification.internal_link.title'),
    body: I18n.t('seeds.admin_notification.internal_link.body'),
    link: Setting['url'] + I18n.t('seeds.admin_notification.internal_link.link'),
    segment_recipient: 'administrators'
  ).deliver

  AdminNotification.create!(
    title: I18n.t('seeds.admin_notification.external_link.title'),
    body: I18n.t('seeds.admin_notification.external_link.body'),
    link: I18n.t('seeds.admin_notification.external_link.link'),
    segment_recipient: 'administrators'
  ).deliver

  AdminNotification.create!(
    title: I18n.t('seeds.admin_notification.without_link.title'),
    body: I18n.t('seeds.admin_notification.without_link.body'),
    segment_recipient: 'administrators'
  ).deliver

  AdminNotification.create!(
    title: I18n.t('seeds.admin_notification.not_sent.title'),
    body: I18n.t('seeds.admin_notification.not_sent.body'),
    segment_recipient: 'administrators',
    sent_at: nil
  )
end
