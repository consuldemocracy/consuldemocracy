section "Creating header and cards for the homepage" do

  def create_image_attachment(type)
    {
      cached_attachment: Rails.root.join("db/dev_seeds/images/#{type}_background.jpg"),
      title: "#{type}_background.jpg",
      user: User.first
    }
  end

  Widget::Card.create!(
    title: 'CONSUL',
    description: 'Free software for citizen participation.',
    link_text: 'More information',
    link_url: 'help_path',
    label: 'Welcome to',
    header: TRUE,
    image_attributes: create_image_attachment('header')
  )

  Widget::Card.create!(
    title: 'How do debates work?',
    description: 'Anyone can open threads on any subject, creating separate spaces where people can discuss the proposed topic. Debates are valued by everybody, to highlight the most important issues.',
    link_text: 'More about debates',
    link_url: 'https://youtu.be/zU_0UN4VajY',
    label: 'Debates',
    header: FALSE,
    image_attributes: create_image_attachment('debate')
  )

  Widget::Card.create!(
    title: 'How do citizen proposals work?',
    description: "A space for everyone to create a citizens' proposal and seek supports. Proposals which reach to enough supports will be voted and so, together we can decide the issues that matter to us.",
    link_text: 'More about proposals',
    link_url: 'https://youtu.be/ZHqBpT4uCoM',
    label: 'Citizen proposals',
    header: FALSE,
    image_attributes: create_image_attachment('proposal')
  )

  Widget::Card.create!(
    title: 'How do participatory budgets work?',
    description: " Participatory budgets allow citizens to propose and decide directly how to spend part of the budget, with monitoring and rigorous evaluation of proposals by the institution. Maximum effectiveness and control with satisfaction for everyone.",
    link_text: 'More about Participatory budgets',
    link_url: 'https://youtu.be/igQ8KGZdk9c',
    label: 'Participatory budgets',
    header: FALSE,
    image_attributes: create_image_attachment('budget')
  )
end
