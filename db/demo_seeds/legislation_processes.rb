section "Creating DEMO Collaborative Legislation Process 1" do
  process = Legislation::Process.create!(
    title: "Air Quality and Climate Change Plan",
    summary: "In the City Council we are designing a new Air Quality and Climate Change Plan. " \
             "Join the process to help us define the most important issues of the future plan. ",
    description: <<~DESCRIPTION,
      One of the main responsibilities of city councils is to look after the health of their
      citizens, implementing actions aimed at reducing risk situations and, among them,
      preventing climate change and monitoring and improving the quality of the air we
      breathe.\r\n\r\nThe reduction of air pollution and the fight against climate change must
      not be delayed, given that air pollution in cities is already the fourth cause of
      premature death in the world, according to a report published by the World Bank last
      September, and that cities are also important emitters of greenhouse gases.\r\n\r\nIn the
      City Council we are working so that next year we have an Air Quality and Climate Change
      Plan that responds to these needs. Right now we are defining thirty proposals in
      collaboration with neighbourhood and social organisations, technicians, administrations,
      academic institutions, social and trade associations and collectives, trade unions,
      business organisations and political groups. At the same time, we want our neighbours to
      be able to get to know them.\r\n\r\nNow is the time for you to tell us here how you think
      these measures would work in your street, in your neighbourhood, in your district.\r\n
    DESCRIPTION
    additional_info: "",
    start_date: 1.week.ago,
    end_date: 1.year.from_now,
    debate_start_date: 1.week.ago,
    debate_end_date: 10.months.from_now,
    debate_phase_enabled: true,
    published: true,
    created_at: 1.week.ago
  )

  document = demo_seed_document_attachment("legislation/processes/air-quality-regulation.pdf")
  process.documents.create!(title: "Air quality regulation", attachment: document, user_id: 1)

  document = demo_seed_document_attachment("legislation/processes/pollution-information-report.pdf")
  process.documents.create!(title: "Pollution information report", attachment: document, user_id: 1)

  question = process.questions.create!(title: "Do you think that restricting the access of " \
                                              "private vehicles to certain areas of your " \
                                              "district can improve pollution, noise levels " \
                                              "and generally improve the quality of public space?\r\n",
                                       author_id: 1,
                                       created_at: 1.week.ago)

  comment = question.comments.create!(body: "Absolutely! Pollution would be reduced by 40% of the city",
                                      user_id: 12,
                                      created_at: 6.days.ago)
  up_voters = users.sample(3)
  up_voters.each do |voter|
    comment.vote_by(voter: voter, vote: true)
  end
  comment.update!(updated_at: 6.days.ago)

  comment = question.comments.create!(body: "What is that figure based on?",
                                      ancestry: Comment.last.id,
                                      user_id: 11,
                                      created_at: 5.days.ago)
  up_voters = users.sample(1)
  up_voters.each do |voter|
    comment.vote_by(voter: voter, vote: true)
  end
  comment.update!(updated_at: 5.days.ago)

  comment = question.comments.create!(body: "For sure it would do it with the noise levels." \
                                            " And that is reason enough to do it.",
                                      user_id: 10,
                                      created_at: 4.days.ago)
  up_voters = users.sample(2)
  up_voters.each do |voter|
    comment.vote_by(voter: voter, vote: true)
  end
  comment.update!(updated_at: 3.days.ago)

  question.update!(updated_at: 3.days.ago)

  question = process.questions.create!(title: "Do you think that in order to improve pedestrian mobility" \
                                              " in the neighbourhoods of your district it would be" \
                                              " positive to limit the speed of vehicles to 30 km/h?\r\n",
                                       author_id: 1,
                                       created_at: 1.week.ago)

  comment = question.comments.create!(body: "Only in the residential area of the city",
                                      user_id: 3,
                                      created_at: 6.days.ago)
  up_voters = users.sample(2)
  up_voters.each do |voter|
    comment.vote_by(voter: voter, vote: true)
  end
  comment.update!(updated_at: 6.days.ago)

  comment = question.comments.create!(body: "Yes, this has proven to drastically" \
                                            " reduce accidents in cities.",
                                      user_id: 4,
                                      created_at: 5.days.ago)
  up_voters = users.sample(2)
  up_voters.each do |voter|
    comment.vote_by(voter: voter, vote: true)
  end
  comment.update!(updated_at: 5.days.ago)

  comment = question.comments.create!(body: "It would be enough 40 km/h",
                                      user_id: 6,
                                      created_at: 4.days.ago)
  up_voters = users.sample(1)
  up_voters.each do |voter|
    comment.vote_by(voter: voter, vote: true)
  end
  comment.update!(updated_at: 4.days.ago)

  comment = question.comments.create!(body: "I think it's a too low speed. It would also have " \
                                            "a big impact on our schedules.",
                                      user_id: 5,
                                      created_at: 3.days.ago)
  down_voters = users.sample(5)
  down_voters.each do |voter|
    comment.vote_by(voter: voter, vote: false)
  end
  comment.update!(updated_at: 3.days.ago)

  comment = question.comments.create!(body: "Our safety should be over our working times.",
                                      ancestry: Comment.last.id,
                                      user_id: 7,
                                      created_at: 2.days.ago)
  up_voters = users.sample(2)
  up_voters.each do |voter|
    comment.vote_by(voter: voter, vote: true)
  end
  comment.update!(updated_at: 2.days.ago)

  question.update!(updated_at: 2.days.ago)

  process.update!(updated_at: 4.days.ago)
end

section "Creating DEMO Collaborative Legislation Process 2" do
  process = Legislation::Process.create!(
    title: "Ordinance regulating the holding and protection of animals.",
    summary: "Review with us the new proposal of Regulatory Ordinance contributing with your comments.\r\n",
    description: "This debate space is opened to know your opinion about the alternative " \
                 "solutions that are proposed in the modification of the Regulatory Ordinance " \
                 "of the tenancy and protection of the animals, having as main objective the " \
                 "need to achieve the maximum level of protection and welfare of the animals.",
    additional_info: <<~INFO,
      The main purposes in which the modification of the Ordinance regulating the possession and
      protection of animals is framed are the following:\r\n\r\n1. To prevent wild animals from
      being subjected to unnatural and unnecessary suffering and exploitation by prohibiting the
      installation of circuses that use wild animals in their shows and their classification as
      a serious infraction with its corresponding sanction, in accordance with the Universal
      Declaration of Animal Rights, and with the legislation on this matter established in most
      countries of the European Union,\r\n\r\n2. The creation of a forum as a space for
      collaboration between the City Council and non-profit, academic, administrative and animal
      protection entities, whose objective is to work in a coordinated manner for the
      protection, health and welfare of animals in the City.
    INFO
    start_date: 10.days.ago,
    end_date: 1.year.from_now,
    draft_publication_date: 10.days.ago,
    allegations_start_date: 10.days.ago,
    allegations_end_date: 9.months.from_now,
    allegations_phase_enabled: true,
    draft_publication_enabled: true,
    published: true,
    created_at: 10.days.ago
  )

  body = File.read(Rails.root.join("db", "demo_seeds", "documents", "legislation", "processes",
                                   "draft.html"))
  draft = process.draft_versions.create!(title: "Proposal for a new Ordinance regulating the " \
                                                "holding and protection of animals.",
                                         body: body,
                                         created_at: 10.days.ago,
                                         updated_at: 10.days.ago,
                                         status: "published")

  annotation = draft.annotations.create!(
    quote: "lucrative purposes, sports and recreation",
    ranges: [{
      "start" => "/p[3]",
      "startOffset" => 155,
      "end" => "/p[3]",
      "endOffset" => 197
    }],
    text: "It is important to separate the reference to recreation in order to have a special " \
          "impact on this part of the protection.",
    author_id: 3,
    range_start: "/p[3]",
    range_start_offset: 155,
    range_end: "/p[3]",
    range_end_offset: 197,
    context: <<~CONTEXT,
      The purpose of this Ordinance is to establish those requirements that may be demanded in
      the municipality, for the keeping of pets, and also those used for <span
      class=annotator>lucrative purposes, sports and recreation</span>, in order to achieve, on
      the one hand, the proper conditions of health and safety for the environment and, on the
      other, adequate protection of animals.
    CONTEXT
    created_at: 9.days.ago,
    updated_at: 9.days.ago
  )

  comment = Comment.last
  up_voters = users.sample(4)
  up_voters.each do |voter|
    comment.vote_by(voter: voter, vote: true)
  end
  comment.update!(updated_at: 9.days.ago)

  annotation.comments.create!(body: "I agree. That should be included in article 4.",
                              user_id: 9,
                              created_at: 8.days.ago,
                              updated_at: 8.days.ago)

  annotation.comments.create!(body: "That was already commented in the previous spectacle ordinance",
                              user_id: 9,
                              created_at: 8.days.ago,
                              updated_at: 8.days.ago)
end

section "Creating DEMO Collaborative Legislation Process 3" do
  process = Legislation::Process.create!(
    title: "Human Rights Plan for the City",
    summary: "The City Council wants to reinforce its commitment to Human Rights with the " \
             "elaboration of a Plan that will be the instrument for the development of its " \
             "public policies with a transversal approach that affects all municipal action.\r\n",
    description: "The present Human Rights Plan aims to answer a question: How can the City " \
                 "Council improve its performance to continue contributing to make the reality " \
                 "of human rights in your city?\r\n\r\nSubmit your proposals and value those " \
                 "of others and experts from the city council. The most supported proposals " \
                 "will be included in the plan.",
    additional_info: <<~INFO,
      The City Council has long been contributing on a daily basis to the defence and promotion
      of human rights, through all its structures, services, policies and programmes, and is
      currently one of the cross-cutting axes of the Government's Action Plan. The aim of this
      Human Rights Plan is to consolidate, reinforce and expand this municipal work, with its
      many strengths and good practices, to ensure that the City Council continues to fulfil its
      obligations to respect, protect and fulfil the human rights of all people living in the
      city.\r\n\r\nTo this end, the main objective of this Plan is, as stated in the
      Government's Plan of Action, to mainstream a human rights-based, gender-based and
      gender-sensitive approach.\r\n\r\nintersectionality in municipal policies. This is an
      innovative conceptual framework developed by the United Nations that places the rights of
      women and men at the centre of the process.\r\n\r\nand gender equity as the foundation,
      objective and instrument of public policies. Above all, it seeks to strengthen municipal
      action in the face of the main human rights shortcomings, inequality and poverty that
      exist in the city and that especially affect women and the most discriminated groups:
      lesbians, gays, transsexuals, transgender people, bisexuals and intersex people; people
      belonging to religious or ethnic minorities (gypsy people, afro-descendants, nationalized
      population, etc.); people with disabilities; and people with
      disabilities.\r\n\r\ndisability/functional diversity; older people, young people; people
      with addictions; migrant and refugee populations; children and adolescents; homeless
      people; families most affected by the economic crisis or austerity
      policies.\r\n\r\nInternational and European human rights law.\r\n\r\nThe main normative
      source from which this Plan is inspired is international human rights law, and
      specifically, the 1948 Universal Declaration of Human Rights (UDHR) and the main treaties
      signed and ratified by the national government.\r\n\r\nTogether with international norms,
      this Plan is inspired and nourished, secondly, by the set of standards developed by
      international and European mechanisms that extensively include the main obligations of
      States in the area of human rights, including environmental rights, as well as the right
      to development, peace and international solidarity.7 It also includes the commitments
      acquired in the the scope of the objectives of sustainable development (hereinafter
      referred to as ODS) and of the so-called Agenda 2030.\r\n
    INFO
    start_date: 12.days.ago,
    end_date: 6.months.from_now,
    published: true,
    proposals_phase_start_date: 12.days.ago,
    proposals_phase_end_date: 4.months.from_now,
    proposals_phase_enabled: true,
    created_at: 12.days.ago
  )

  author = users.sample
  proposal = process.proposals.create!(
    title: "Prevention and mitigation of climate change and pollution",
    summary: "To guarantee adaptation and resilience to climate change, achieving the reduction " \
             "of greenhouse gases, the commitment of 100% renewable by 2050 and the reduction of 1.5º.",
    description: <<~DESCRIPTION,
      <p>Guarantee adaptation and resilience to climate change, achieving a reduction in
      greenhouse gases, a 100% renewable commitment by 2050 and a reduction of 1.5º. Actions
      such as: Municipal action plan for adaptation and mitigation of Climate Change
      (Madrid-Natura Programme, FREVUE Programme and others), as a coherent public policy
      coordinated with other existing plans (Air Quality Plan, Mobility Plan and Renewable
      Energy Plan); better monitoring of episodes of atmospheric pollution and extreme
      temperatures (cold and heat), as a basis for launching emergency plans; measures to
      ensure the conservation and expansion of the city's green heritage (planting of trees,
      plant cover, vertical gardens, urban orchards, etc.); Framework Plan for the prevention
      and sustainable management of waste in the municipality of Madrid 2017-2022 (with
      awareness-raising campaigns, improvement of collection services, implementation of nearby
      clean points, promotion of the collection of organic fraction, etc.).); environmental
      education and awareness programmes to achieve civic co-responsibility in the areas of
      mobility, energy saving and waste management.</p>\r\n
    DESCRIPTION
    tag_list: "Sustainable urban development,Health",
    author_id: author.id,
    responsible_name: author.username,
    terms_of_service: "1",
    created_at: 11.days.ago
  )

  supporters = users.sample(2)
  supporters.each do |supporter|
    proposal.vote_by(voter: supporter, vote: true)
  end

  proposal.update!(updated_at: 10.days.ago)

  author = users.sample
  proposal = process.proposals.create!(
    title: "Plan for the reception and care of asylum-seekers and refugees",
    summary: "Adoption of a Reception and Care Plan for Asylum Seekers and Refugees\r\n",
    description: <<~DESCRIPTION,
      <p>Within the framework of the Safe Haven Cities initiative, the adoption of a Plan for
      the reception and care of asylum seekers and refugees so that they can find a new city in
      Madrid in which to live with dignity. This means, among other things: guaranteeing them
      comprehensive social care (including coverage of basic needs, psychological care, support
      for schooling, children's education, employment, housing, etc.) throughout the asylum
      process and afterwards if necessary; advice and accompaniment throughout their asylum
      process; specific measures to ensure refugee women and minors their right to a life free
      of violence and discrimination.</p>\r\n
    DESCRIPTION
    tag_list: "housing,Health",
    author_id: author.id,
    responsible_name: author.username,
    terms_of_service: "1",
    created_at: 10.days.ago
  )

  supporters = users.sample(2)
  supporters.each do |supporter|
    proposal.vote_by(voter: supporter, vote: true)
  end

  proposal.update!(updated_at: 10.days.ago)

  author = users.sample
  proposal = process.proposals.create!(
    title: "Access to education for all children living in Madrid",
    summary: "Promote, within the framework of their competencies, children's effective access to " \
             "the right to education without discrimination.\r\n",
    description: <<~DESCRIPTION,
      <p>To promote, within the framework of its competencies, effective access for all children
      living in Madrid to the right to education without discrimination. Lines of action such
      as: free access to quality primary education without discrimination, including coverage
      from 0 to 3 years and with support measures for sectors and families that are more
      discriminated against or have fewer resources; monitoring the quality of outsourced
      educational services so that specialised psycho-pedagogical criteria take precedence over
      economic criteria; together with other administrations, programmes for the prevention of
      social exclusion and the prevention and control of school absenteeism that ensure the
      inclusion and continuity of training and the non-drop-out of children and young people,
      especially of certain groups (at-risk adolescents, Romany population, migrant and refugee
      population, unaccompanied minors, young pregnant women or mothers, etc.).); progressive
      investment plan in the facilities of municipally-owned schools to guarantee their quality
      and accessibility, especially for people with functional diversity; specific measures for
      non-discriminatory access to municipal plans or programmes for educational support,
      leisure and free time, sports, extracurricular and extracurricular activities, especially
      for people belonging to more discriminated groups and people with functional
      diversity.</p>\r\n
    DESCRIPTION
    tag_list: "Education",
    author_id: author.id,
    responsible_name: author.username,
    terms_of_service: "1",
    created_at: 9.days.ago
  )

  supporters = users.sample(3)
  supporters.each do |supporter|
    proposal.vote_by(voter: supporter, vote: true)
  end

  proposal.update!(updated_at: 9.days.ago)

  author = users.sample
  proposal = process.proposals.create!(
    title: "Effective right of access to energy without discrimination",
    summary: "Contributing to the realization of the right to access to energy for the most " \
             "vulnerable people\r\n",
    description: <<~DESCRIPTION,
      <p>To continue to contribute, with renewed vigour, together with other administrations and
      actors, to the realisation of the right to access to energy (electricity, gas and other
      energy sources) for the most socially vulnerable within the framework of an ecologically
      sustainable city. It implies, among other lines of action: improvement of the
      identification of situations of energy poverty and detection of people at risk of energy
      poverty, through Social Services with the support of the associative fabric involved;
      modification of the Economic Aid Ordinance in order to improve its management and control,
      coordination with supplier companies and the accessibility of the population without
      discrimination (with measures such as light cheques paid directly to energy supplier
      companies); encouraging energy companies to guarantee energy coverage on the basis of
      social criteria through the signing of agreements (reductions or exemptions from payment
      of bills, no cuts in supplies, elimination of the costs of reconnecting people living in
      poverty); information campaigns on energy efficiency and on billing for groups at risk of
      energy poverty; increasing the energy efficiency of the homes of people who have been
      awarded social housing or those living in energy poverty, avoiding their impact on health,
      including energy self-production.</p>\r\n
    DESCRIPTION
    tag_list: "Sustainable urban development,housing,Health",
    author_id: author.id,
    responsible_name: author.username,
    terms_of_service: "1",
    created_at: 8.days.ago
  )

  supporters = users.sample(4)
  supporters.each do |supporter|
    proposal.vote_by(voter: supporter, vote: true)
  end

  proposal.update!(updated_at: 8.days.ago)

  author = users.sample
  proposal = process.proposals.create!(
    title: "Measures to protect people suffering from xenophobia and racism",
    summary: "Measures to protect people suffering from racism, intolerance, xenophobia, Islamophobia.\r\n",
    description: <<~DESCRIPTION,
      <p>Take appropriate measures to protect people suffering from racism, intolerance,
      xenophobia, Islamophobia, against all forms of discrimination in political, social, labour
      and cultural spheres, as well as to eliminate conditions that cause or reproduce racial
      discrimination. With actions such as: A transversal and participative diagnosis on the
      scope, causes and evolution of racial and ethnic discrimination (direct and indirect)
      existing in Madrid, its districts and neighbourhoods, with special attention to situations
      of islamophobia, xenophobia, anti-gypsyism, discrimination against afro-descendants,
      nationalized people, migrants and refugees, and multiple discriminations (women, girls and
      boys, LGBTI, people with functional diversity, sick people, elderly people); Plan for
      Coexistence, Interculturality and the Fight against Racism (which includes better
      accessibility to municipal services and programmes; the fight against racial
      discrimination in employment, trade, housing, education, health, culture, sports; the
      management of intercultural coexistence); Strategy for "Promotion of equality and
      non-discrimination of the Roma population" of the Government Action Plan; channels for
      participation in municipal policies that affect them by entities and persons belonging to
      groups that are more susceptible to racial discrimination.</p>\r\n
    DESCRIPTION
    tag_list: "Education,Health",
    author_id: author.id,
    responsible_name: author.username,
    terms_of_service: "1",
    created_at: 1.week.ago
  )

  supporters = users.sample(5)
  supporters.each do |supporter|
    proposal.vote_by(voter: supporter, vote: true)
  end

  proposal.update!(updated_at: 1.week.ago)

  author = users.sample
  proposal = process.proposals.create!(
    title: "Full realization of the right to adequate and adequate food.",
    summary: "To achieve progressively the full realization of the fundamental right to " \
             "adequate and adequate food.\r\n",
    description: <<~DESCRIPTION,
      <p>To take steps with a view to achieving progressively the full realization of the
      fundamental right of everyone to adequate and appropriate food. It implies actions such
      as study on the food emergency situation and accessibility of the population to the right
      to adequate, appropriate (with healthy hygienic conditions) and sustainable food,
      especially for children, the elderly, the functionally diverse, the homeless, the most
      disadvantaged families and the most discriminated groups, taking into account differences
      between neighbourhoods and districts; Plan to put an end to hunger and malnutrition in
      Madrid, reinforcing the funds destined to cover temporary and social emergency aid, with
      the "Madrid te alimenta" programme, speeding up the deadlines for achieving the minimum
      insertion income, being measures that reinforce people's economic autonomy and respect for
      their beliefs; promoting compliance with the Milan Pact, promoting sustainable, inclusive
      and safe food systems, and guaranteeing the most sustainable management of natural food
      resources; improving health and food quality control, ensuring that private sector and
      civil society activities (such as municipal markets) are in line with adequate food;
      awareness-raising for healthy, responsible and sustainable food (with campaigns in the
      field of education, health centres, senior citizens), including information on proximity
      and ecological trade; food assistance for disasters or humanitarian emergencies within
      municipal policies of solidarity and cooperation, including assistance to refugees and
      displaced persons in other countries.</p>\r\n
    DESCRIPTION
    tag_list: "Food and quality water",
    author_id: author.id,
    responsible_name: author.username,
    selected: true,
    terms_of_service: "1",
    created_at: 6.days.ago
  )

  supporters = users.sample(6)
  supporters.each do |supporter|
    proposal.vote_by(voter: supporter, vote: true)
  end

  proposal.update!(updated_at: 6.days.ago)
end

section "Creating DEMO Collaborative Legislation Process 4" do
  process = Legislation::Process.create!(
    title: "Strategic Mobility Plan 2025-2035",
    summary: "The Strategic Mobility Plan 2025-2035 will be written together with our citizens.\r\n",
    description: "The Strategic Mobility Plan 2025-2035 will be written" \
                 " together with our citizens. You can participate in the" \
                 " drafting of the Plan during three consecutive phases:\r\n" \
                 "1. Join the discussion about what are the most important" \
                 " mobility themes for the city\r\n" \
                 "2. Submit proposals or ideas for Mobility projects or regulations in the city\r\n" \
                 "3. Comment on the first and second draft of the Strategic Mobility Plan 2025-2035\r\n",
    homepage: <<~HOMEPAGE,
      <p>Participation in the city has a few rules and guidelines. These are:</p>
       <ol>
       <li>What happens with my input? Your input will be used to write up the Strategic
       Mobility Plan 2025-2035, as long as the suggestions, proposals and comments are feasible
       and fit within the wider Mobility Framework of the city. Participants will receive structural
       feedback before and after each phase of the process.</li>
       <li>What is the Strategic Mobility Plan about? The Strategic Mobility Plan 2025-2035 will
       define the priorities and policy choices of the city for the next ten years. It will define
       sustainability variables and projects, determine which modes of transport and which
       districts of the city get prioritized, and it will set a timeline for completion of projects</li>
       <li>Are there any rules for participation? Yes, we carefully enforce certain rules
       for participation.
          <ul>
            <li>Collaboration. It is important to look at other people's contribution. We will look at
            everything but will eventually accept proposals with the most support and/or votes.
            </li>
            <li>Be concise. We value short and concise contributions, which will positively affect the
            chances of proposals being integrated in the Strategic Mobility Plan 2025-2035.
            </li>
            <li>No discrimination. Offensive languages will not be tolerated and comments.</li>
          </ul>
        </li>
       </ol>
    HOMEPAGE
    additional_info: "",
    start_date: 4.days.ago,
    end_date: 6.months.from_now,
    published: true,
    homepage_enabled: true,
    debate_start_date: 1.week.ago,
    debate_end_date: 10.months.from_now,
    debate_phase_enabled: true,
    proposals_phase_start_date: 12.days.ago,
    proposals_phase_end_date: 4.months.from_now,
    proposals_phase_enabled: true,
    draft_publication_date: 10.days.ago,
    draft_publication_enabled: true,
    allegations_start_date: 10.days.ago,
    allegations_end_date: 9.months.from_now,
    allegations_phase_enabled: true,
    created_at: 12.days.ago
  )

  document = demo_seed_document_attachment("legislation/processes/eurocities-policy-statement-2024.pdf")
  process.documents.create!(title: "A better mobility starts in cities", attachment: document, user_id: 1)

  author = users.sample
  proposal = process.proposals.create!(
    title: "Shared electric cars in Northern districts",
    summary: "I propose the installation of an electric car sharing station within our neighborhood. " \
             "With the growing demand for sustainable transportation and the increasing number of " \
             "residents prioritizing enviro",
    description: <<~DESCRIPTION,
      <p>I propose the installation of an electric car sharing station within our neighborhood. With the
      growing demand for sustainable transportation and the increasing number of residents prioritizing
      environmentally conscious choices, a car sharing station would offer an affordable, practical, and
      eco-friendly alternative to car ownership. It would significantly reduce traffic congestion, lower
      carbon emissions, and support the city's climate goals, while also providing residents—especially
      those without personal vehicles—convenient access to reliable transportation for errands,
      appointments, and daily commutes.</p><p>I recommend the station be located in a central, accessible
      area near public transit lines and residential buildings, ensuring it serves the broadest possible
      portion of the community. This initiative aligns with broader trends in urban mobility and
      sustainability, and I believe our neighborhood can be a model for future development. I encourage
      the municipality to collaborate with electric car sharing providers and explore potential grants or
      incentives to support this project. I, along with many fellow residents, would be eager to support
      and utilize such a service.</p>\r\n
    DESCRIPTION
    tag_list: "Sustainability car district",
    author_id: author.id,
    responsible_name: author.username,
    terms_of_service: "1",
    created_at: 11.days.ago
  )
  supporters = users.sample(5)
  supporters.each do |supporter|
    proposal.vote_by(voter: supporter, vote: true)
  end
  comment = proposal.comments.create!(body: "Thanks to all for supporting my proposal!",
                                      user_id: author.id, created_at: 6.days.ago)
  up_voters = users.sample(1)
  up_voters.each do |voter|
    comment.vote_by(voter: voter, vote: true)
  end
  comment.update!(updated_at: 1.day.ago)

  proposal.update!(updated_at: 1.week.ago)

  question = process.questions.create!(
    title: "What do you think are the most important challenges of mobility in our city?\r\n",
    author_id: 1,
    created_at: 1.week.ago
  )
  question.question_options.create!(
    value: "Transport hubs and timelines and not well connected"
  )
  question.question_options.create!(
    value: "Limited capacity of public transport"
  )
  question.question_options.create!(
    value: "High congestion of mobility networks during busy hours"
  )
  question.question_options.create!(
    value: "Limited accessibility of private mobility for low-income groups"
  )
  question.question_options.create!(
    value: "Underperformance on sustainability goals"
  )
  comment = question.comments.create!(
    body: "Buses and train stations are too far apart in the East district!",
    user_id: 12,
    created_at: 6.days.ago
  )
  up_voters = users.sample(2)
  up_voters.each do |voter|
    comment.vote_by(voter: voter, vote: true)
  end
  comment.update!(updated_at: 6.days.ago)
  comment = question.comments.create!(
    body: "The city needs high ambitions when it comes to climate policies",
    user_id: 8,
    created_at: 6.days.ago
  )
  up_voters = users.sample(1)
  up_voters.each do |voter|
    comment.vote_by(voter: voter, vote: true)
  end
  comment.update!(updated_at: 6.days.ago)

  question = process.questions.create!(
    title: "Which modes of transport should have priority in the city?\r\n",
    author_id: 1,
    created_at: 1.week.ago
  )
  question.question_options.create!(value: "Car")
  question.question_options.create!(value: "Tram and bus")
  question.question_options.create!(value: "Metro and train")
  question.question_options.create!(value: "Bicycle")
  question.question_options.create!(value: "Pedestrian")
  question.question_options.create!(value: "Scooter")
  comment = question.comments.create!(
    body: "Tram is the oldest and most original form of " \
          "transport in this city, that's why we should invest in it",
    user_id: 3,
    created_at: 6.days.ago
  )
  up_voters = users.sample(1)
  up_voters.each do |voter|
    comment.vote_by(voter: voter, vote: true)
  end
  comment.update!(updated_at: 6.days.ago)

  comment = question.comments.create!(
    body: "We need more metro stations to facilitate fast mobility " \
          " across the city's districts including outskirts!",
    user_id: 4,
    created_at: 6.days.ago
  )
  up_voters = users.sample(1)
  up_voters.each do |voter|
    comment.vote_by(voter: voter, vote: true)
  end

  down_voters = users.sample(1)
  down_voters.each do |voter|
    comment.vote_by(voter: voter, vote: false)
  end
  comment.update!(updated_at: 3.days.ago)

  question = process.questions.create!(
    title: "Which of the current projects of the city do you see as promising?\r\n",
    author_id: 1,
    created_at: 1.week.ago
  )
  question.question_options.create!(
    value: "15-Minute City Plan"
  )
  question.question_options.create!(
    value: "Development of all-in-1 public transport mobile application"
  )
  question.question_options.create!(
    value: "Redevelopment of central station into modern and central transport hub"
  )
  question.question_options.create!(
    value: "Bike Only Streets Plan"
  )
  question.question_options.create!(
    value: "District-based mobility"
  )

  comment = question.comments.create!(
    body: "Bike Only Streets is already a working concept" \
          " in cities like Valencia, Spain, and Montreal, Canada",
    user_id: 5,
    created_at: 6.days.ago
  )
  up_voters = users.sample(2)
  up_voters.each do |voter|
    comment.vote_by(voter: voter, vote: true)
  end

  comment = question.comments.create!(
    body: "Districts should become mobility centers in themselves " \
          "because local communities will benefit the most from that",
    user_id: 7,
    created_at: 6.days.ago
  )
  up_voters = users.sample(1)
  up_voters.each do |voter|
    comment.vote_by(voter: voter, vote: true)
  end
  comment.update!(updated_at: 3.days.ago)

  body = File.read(Rails.root.join("db", "demo_seeds", "documents", "legislation", "processes",
                                   "draft-mobility.html"))
  draft = process.draft_versions.create!(title: "Draft of the Strategic Mobility Plan 2025-2035",
                                         body: body,
                                         created_at: 10.days.ago,
                                         updated_at: 10.days.ago,
                                         status: "published")

  draft.annotations.create!(
    quote: "STRATEGIC MOBILITY PLAN 2025-2035",
    ranges: [{
      "start" => "/p[1]",
      "startOffset" => 0,
      "end" => "/p[1]",
      "endOffset" => 36
    }],
    text: "Maybe we can give it a better sounding name, like Mobility and " \
          "Transport for All, Sustainable and Efficient. How about that?",
    author_id: 3,
    range_start: "/p[1]",
    range_start_offset: 0,
    range_end: "/p[1]",
    range_end_offset: 36,
    context: "<span class=annotator>STRATEGIC MOBILITY PLAN 2025-2035</span>",
    created_at: 9.days.ago,
    updated_at: 9.days.ago
  )
  comment = Comment.last
  up_voters = users.sample(1)
  up_voters.each do |voter|
    comment.vote_by(voter: voter, vote: true)
  end

  draft.annotations.create!(
    quote: "In five years, zero-emission mobility",
    ranges: [{
      "start" => "/p[3]",
      "startOffset" => 0,
      "end" => "/p[3]",
      "endOffset" => 40
    }],
    text: "I think this is a very good ambition but I think the texts " \
          "lacks sufficient proposals to make this a reality",
    author_id: 3,
    range_start: "/p[3]",
    range_start_offset: 0,
    range_end: "/p[3]",
    range_end_offset: 40,
    context: "<span class=annotator>In five years, zero-emission mobility</span>",
    created_at: 9.days.ago,
    updated_at: 9.days.ago
  )
  draft.annotations.create!(
    quote: "Eurocities manifesto",
    ranges: [{
      "start" => "/p[5]",
      "startOffset" => 21,
      "end" => "/p[5]",
      "endOffset" => 41
    }],
    text: "If you read the manifesto, there is more inspiration, also about transitioning car " \
          "mobility into zero-cost emission sectors and concrete policy proposals on how to " \
          "accomplish that.",
    author_id: 3,
    range_start: "/p[5]",
    range_start_offset: 20,
    range_end: "/p[5]",
    range_end_offset: 41,
    context: "<span class=annotator>Eurocities manifesto</span>",
    created_at: 9.days.ago,
    updated_at: 9.days.ago
  )
  draft.annotations.create!(
    quote: "climate, road safety, air quality, noise",
    ranges: [{
      "start" => "/p[2]",
      "startOffset" => 340,
      "end" => "/p[2]",
      "endOffset" => 380
    }],
    text: "I think we should add accessibility in terms of costs to these goals",
    author_id: 3,
    range_start: "/p[2]",
    range_start_offset: 340,
    range_end: "/p[2]",
    range_end_offset: 380,
    context: "The task of the next EU policymakers will revolve around keeping the EU on track to meet " \
             "its targets for 2030 and beyond in terms of " \
             "<span class=annotator>climate, road safety, air quality," \
             " noise</span> and other Green Deal objectives.",
    created_at: 9.days.ago,
    updated_at: 9.days.ago
  )
  draft.annotations.create!(
    quote: "enhanced city involvement in decision-making.",
    ranges: [{
      "start" => "/p[3]",
      "startOffset" => 657,
      "end" => "/p[3]",
      "endOffset" => 704
    }],
    text: "Very much agree with this. People have the best ideas!",
    author_id: 3,
    range_start: "/p[3]",
    range_start_offset: 657,
    range_end: "/p[3]",
    range_end_offset: 704,
    context: "<span class=annotator>enhanced city involvement in decision-making.</span>",
    created_at: 9.days.ago,
    updated_at: 9.days.ago
  )

  milestone = process.milestones.create!(
    publication_date: 10.days.ago,
    description: "Draft of the Strategic Mobility Plan 2025-2035 published",
    title: "Draft of the Strategic Mobility Plan 2025-2035 published",
  )
  image = Rack::Test::UploadedFile.new(Rails.root.join("db", "demo_seeds", "images", "legislation",
                                                       "processes", "opening.jpg"))
  milestone.image = Image.create!({
    imageable: milestone,
    title: milestone.title,
    attachment: image,
    user: User.first
  })
  milestone.save!

  milestone = process.milestones.create!(
    publication_date: 1.day.ago,
    description: "1000 active citizens in the first phase of the participation process!",
    title: "1000 active citizens in the first phase of the participation process!",
  )
  image = Rack::Test::UploadedFile.new(Rails.root.join("db", "demo_seeds", "images", "legislation",
                                                       "processes", "first-phase.jpg"))
  milestone.image = Image.create!({
    imageable: milestone,
    title: milestone.title,
    attachment: image,
    user: User.first
  })
  milestone.save!
end
