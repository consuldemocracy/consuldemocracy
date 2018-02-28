section "Creating Admin Notifications & Templates" do
  AdminNotification.create!(
    title: 'New usage Terms & Conditions!',
    segment_recipient: 'administrators',
    body: 'We have improved our usage terms & conditions! please check them out to be up to date.',
    link: 'http://localhost:3000/condiciones-de-uso'
  ).deliver

  AdminNotification.create!(
    title: 'Help us translate consul 🤓',
    segment_recipient: 'administrators',
    body: 'If you are proficient in a language, please help us translate consul!.',
    link: 'https://crwd.in/consul'
  ).deliver

  AdminNotification.create!(
    title: 'You can now geolocate proposals & investments',
    segment_recipient: 'administrators',
    body: 'When you create a proposal or investment you now can specify a point on a map 🗺'
  ).deliver

  AdminNotification.create!(
    title: 'We just opened a new Participatory Budget!',
    segment_recipient: 'administrators',
    link: 'https://www.decide.madrid.es/presupuestos2018/1',
    body: 'Start creating proposals for budget investments!'
  ).deliver

  AdminNotification.create!(
    title: 'We are closing the 2018 Participatory Budget!!',
    segment_recipient: 'administrators',
    link: 'https://www.decide.madrid.es/presupuestos2018/1',
    body: 'Hurry up and create a last proposal before it ends next in two days!',
    sent_at: nil
  )
end
