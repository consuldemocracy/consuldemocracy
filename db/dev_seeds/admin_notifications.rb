section "Creating Admin Notifications & Templates" do
  AdminNotification.create!(
    title_en: 'Do you have a proposal?',
    title_es: 'Tienes una propuesta?',

    body_en: 'Remember you can create a proposal with your ideas and people will discuss & support it.',
    body_es: 'Recuerda que puedes crear propuestas y los ciudadanos las debatirán y apoyarán.',

    link: Setting['url'] + '/proposals',
    segment_recipient: 'administrators'
  ).deliver

  AdminNotification.create!(
    title_en: 'Help us translate consul',
    title_es: 'Ayúdanos a traducir CONSUL',

    body_en: 'If you are proficient in a language, please help us translate consul!.',
    body_es: 'Si dominas un idioma, ayúdanos a completar su traducción en CONSUL.',

    link: 'https://crwd.in/consul',
    segment_recipient: 'administrators'
  ).deliver

  AdminNotification.create!(
    title_en: 'You can now geolocate proposals & investments',
    title_es: 'Ahora puedes geolocalizar propuestas y proyectos de inversión',

    body_en: 'When you create a proposal or investment you now can specify a point on a map',
    body_es: 'Cuando crees una propuesta o proyecto de inversión podrás especificar su localización en el mapa',

    segment_recipient: 'administrators'
  ).deliver

  AdminNotification.create!(
    title_en: 'We are closing the Participatory Budget!!',
    title_es: 'Últimos días para crear proyectos de Presupuestos Participativos',

    body_en: 'Hurry up and create a last proposal before it ends next in few days!',
    body_es: 'Quedan pocos dias para que se cierre el plazo de presentación de proyectos de inversión para los presupuestos participativos!',

    segment_recipient: 'administrators',
    sent_at: nil
  )
end
