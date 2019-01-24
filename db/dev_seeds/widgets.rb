section "Creating header and cards for the homepage" do

  def create_image_attachment(type)
    {
      cached_attachment: Rails.root.join("db/dev_seeds/images/#{type}_background.jpg"),
      title: "#{type}_background.jpg",
      user: User.first
    }
  end

  Widget::Card.create!(
    title_en: 'CONSUL',
    title_es: 'CONSUL',

    description_en: 'Free software for citizen participation.',
    description_es: 'Software libre para la participación ciudadana.',

    link_text_en: 'More information',
    link_text_es: 'Más información',

    label_en: 'Welcome to',
    label_es: 'Bienvenido a',

    link_url: 'http://consulproject.org/',
    header: true,
    image_attributes: create_image_attachment('header')
  )

  Widget::Card.create!(
    title_en: 'How do debates work?',
    title_es: '¿Cómo funcionan los debates?',

    description_en: 'Anyone can open threads on any subject, creating separate spaces where people can discuss the proposed topic. Debates are valued by everybody, to highlight the most important issues.',
    description_es: 'Cualquiera puede iniciar un debate sobre cualquier tema, creando un espacio separado donde compartir puntos de vista con otras personas. Los debates son valorados por todos para destacar los temas más importantes.',

    link_text_en: 'More about debates',
    link_text_es: 'Más sobre debates',

    label_en: 'Debates',
    label_es: 'Debates',

    link_url: 'https://youtu.be/zU_0UN4VajY',
    header: false,
    image_attributes: create_image_attachment('debate')
  )

  Widget::Card.create!(
    title_en: 'How do citizen proposals work?',
    title_es: '¿Cómo funcionan las propuestas ciudadanas?',

    description_en: "A space for everyone to create a citizens' proposal and seek supports. Proposals which reach to enough supports will be voted and so, together we can decide the issues that matter to us.",
    description_es: 'Un espacio para que el ciudadano cree una propuesta y busque apoyo. Las propuestas que obtengan el apoyo necesario serán votadas. Así juntos podemos decidir sobre los temas que nos importan.',

    link_text_en: 'More about proposals',
    link_text_es: 'Más sobre propuestas',

    label_en: 'Citizen proposals',
    label_es: 'Propuestas ciudadanas',

    link_url: 'https://youtu.be/ZHqBpT4uCoM',
    header: false,
    image_attributes: create_image_attachment('proposal')
  )

  Widget::Card.create!(
    title_en: 'How do participatory budgets work?',
    title_es: '¿Cómo funcionan los propuestos participativos?',

    description_en: " Participatory budgets allow citizens to propose and decide directly how to spend part of the budget, with monitoring and rigorous evaluation of proposals by the institution. Maximum effectiveness and control with satisfaction for everyone.",
    description_es: "Los presupuestos participativos permiten que los ciudadanos propongan y decidan directamente cómo gastar parte del presupuesto, con la supervisión y valoración de la institución. Máxima eficacia y control para la satisfacción de todos",

    link_text_en: 'More about Participatory budgets',
    link_text_es: 'Más sobre presupuestos participativos',

    label_en: 'Participatory budgets',
    label_es: 'Presupuestos participativos',

    link_url: 'https://youtu.be/igQ8KGZdk9c',
    header: false,
    image_attributes: create_image_attachment('budget')
  )
end
