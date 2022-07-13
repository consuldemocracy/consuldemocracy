section "Creating DEMO Proposals" do

  author = User.find(3)
  proposal = Proposal.create!(title: "Strategic plan for a 100% green city",
                              summary: "We want a city that does not dawn with a cloud of grey pollution, that bets on sustainability, promotes renewables and ensures that no family is cut off the light this winter.",
                              description: "<p>How do we want to do it?

Asking the City Council to commit to sign the manifesto \"SUSTAINABLE CITY\" and to implement it -- We demand compliance with the following 14 points:</p>

<ul>
	<li>Develop awareness campaigns, training and promotion of energy culture in all areas of the city.</li>
	<li>To contract municipal electricity with a 100% renewable guarantee of origin.</li>
	<li>Establish a transversal work team for the preparation, execution and monitoring of strategic plans.</li>
	<li>Facilitate the obtaining on a regular basis of the energy and economic data necessary for its management.</li>
	<li>Design and implement energy efficiency actions in municipal facilities prioritizing changes in habits to eliminate wasteful consumption. The savings achieved by changing habits will be invested, in part or in full, in new energy efficiency measures.</li>
	<li>Implement energy efficiency programmes in educational centres, such as the 50/50 project -- consisting of returning 50% of the savings to the school and reverting the other half to new savings, efficiency and renewable measures in the same centre.</li>
	<li>Apply measures to combat energy poverty: processing of the social bond, etc.</li>
	<li>Design and execute all new constructions or municipal works with criteria of almost zero energy consumption.</li>
	<li>Implement sustainable mobility actions: promotion of public transport, use of sustainable vehicles, pedestrianisation of streets, etc.</li>
	<li>Design a plan to gradually replace the entire fleet of vehicles dedicated to public transport and municipal vehicles with electric vehicles.</li>
	<li>Establish fiscal measures to promote energy efficiency and renewable energies.</li>
	<li>Revise municipal by-laws to favour self-sufficient energy systems based on renewable energies.</li>
	<li>Generate a sustainable urban model by stopping speculative processes.</li>
	<li>Make a sustainable management of Urban Solid Waste.</li>
</ul>",
                              tag_list: "sustainable,green,environment",
                              video_url: "https://www.youtube.com/watch?v=IFjD3NMv6Kw",
                              author_id: author.id,
                              responsible_name: author.username,
                              terms_of_service: "1",
                              created_at: 1.day.ago,
                              published_at: 1.month.ago)
  image = Rack::Test::UploadedFile.new(Rails.root.join("db", "demo_seeds", "images", "proposals", "strategic-plan-for-a-100-green-city.jpg"))
  add_image(image, proposal)

  supporters = users.sample(5)
  supporters.each do |supporter|
    proposal.vote_by(voter: supporter, vote: true)
  end

  comment = proposal.comments.create!(body: "I love this proposal. I'm going to contribute by telling my friends about it.",
                                      user_id: 12,
                                      created_at: 3.hours.ago)
  up_voters = users.sample(5)
  up_voters.each do |voter|
    comment.vote_by(voter: voter, vote: true)
  end
  comment.update(updated_at: 2.hours.ago)

  comment = proposal.comments.create!(body: "It is a very necessary proposal. It is only necessary to look at the latest IPCC panel reports to see the dramatic situation the planet is going through.",
                                      user_id: 11,
                                      created_at: 2.hours.ago)
  up_voters = users.sample(4)
  up_voters.each do |voter|
    comment.vote_by(voter: voter, vote: true)
  end
  comment.update(updated_at: 1.hour.ago)

  comment = proposal.comments.create!(body: "What are the last global numbers on the issue?",
                                      user_id: 10,
                                      created_at: 1.hour.ago)
  up_voters = users.sample(3)
  up_voters.each do |voter|
    comment.vote_by(voter: voter, vote: true)
  end
  comment.update(updated_at: 1.minute.ago)

  comment = proposal.comments.create!(body: "Great including \"Establish a transversal work team for the preparation, execution and monitoring of strategic plans.\" But it should be defined how this team decide its members",
                                      user_id: 9,
                                      created_at: 1.minute.ago)
  voters = users.sample(3)
  up_voters = voters.first(1)
  up_voters.each do |voter|
    comment.vote_by(voter: voter, vote: true)
  end
  down_voters = voters.last(2)
  down_voters.each do |voter|
    comment.vote_by(voter: voter, vote: false)
  end
  comment.update(updated_at: 1.second.ago)

  proposal.update(updated_at: 1.second.ago)

  author = User.find(6)
  proposal = Proposal.create!(title: "The right to play: for a more child-friendly city",
                              summary: "We want to improve public spaces for children to play. We propose clean, creative parks, play again in squares and streets (as before) and create a network of public toy libraries.",
                              description: "<p>\"Children need time and space to play. Play is not a luxury, it is a necessity\" Kay Redfield.</p>

<p>Play is fundamental to children's health, development and well-being. Play is a right under the UN Convention on the Rights of the Child (art. 31), yet it is one of the most neglected and forgotten. Today, children play half as long as their parents did at their age, with consequences for their physical and mental health. Therefore, we propose these concrete measures to guarantee the right to play in Madrid.</p>

<p>PLAY OUTDOOR: in parks, squares, streets and courtyards Ensure playgrounds are well maintained, clean and have shaded areas. Design new parks and renovate existing ones using materials from nature to promote creativity and free play and ensure that they are inclusive, accessible, sustainable, safe and intergenerational. Reclaim squares as intergenerational meeting spaces, playgrounds and recreation areas within the city. To recover the streets as play spaces, adapting European good practices such as proposing the closing of one street per neighbourhood to traffic for community use and for children, temporarily or permanently as requested by the neighbourhood. Create safe school paths for all schools. Progressively renovate schoolyards so that they are creative, inclusive spaces, with an element of nature, co-designed with children and key actors.</p>

<p>PLAY INDOORS: Create a network of municipal toy libraries as a refuge to continue playing when weather conditions make it difficult to play outdoors. Create and/or set up indoor and air-conditioned play areas in sports centres, cultural centres and other underused buildings, in all neighbourhoods of Madrid, for children of all ages, gender, accessible, inclusive and safe. Create a pilot project: Covered Municipal Free Play Space. Ensure a space dedicated to upbringing per neighbourhood with sufficient capacity to meet the needs of babies, boys and girls from 0 to 3.</p>

<p>THE RIGHT TO PLAY FOR ALL: Incorporate 1 m2/inhabitant for play in the sustainable urban planning of the municipality to create, recover or expand play areas in the city. Provide the main cultural and leisure centres in each district with accessible, inclusive, sustainable and safe play areas for girls and boys. Decentralize leisure and cultural activities in all neighbourhoods/districts and ensure their free and/or accessibility.</p>

<p>Allow healthy play by applying air quality measures in children's play areas. Include children in the design and evaluation of new public play spaces.</p>",
                              tag_list: "human rights,children,Social Rights",
                              video_url: "https://www.youtube.com/watch?v=5tjRPWPhIfA",
                              author_id: author.id,
                              responsible_name: author.username,
                              terms_of_service: "1",
                              created_at: 1.week.ago,
                              published_at: 1.week.ago)
  image = Rack::Test::UploadedFile.new(Rails.root.join("db", "demo_seeds", "images", "proposals", "the-right-to-play-for-a-more-child-friendly-city.jpg"))
  add_image(image, proposal)

  supporters = users.sample(4)
  supporters.each do |supporter|
    proposal.vote_by(voter: supporter, vote: true)
  end

  comment = proposal.comments.create!(body: "A beautiful proposal!",
                                      user_id: 11,
                                      created_at: 5.days.ago)
  up_voters = users.sample(6)
  up_voters.each do |voter|
    comment.vote_by(voter: voter, vote: true)
  end
  comment.update(updated_at: 3.days.ago)

  comment = proposal.comments.create!(body: "It's a human right. No doubt about it. And cities are the perfect governments to develop them.",
                                      user_id: 10,
                                      created_at: 1.day.ago)
  up_voters = users.sample(4)
  up_voters.each do |voter|
    comment.vote_by(voter: voter, vote: true)
  end
  comment.update(updated_at: 3.hours.ago)

  comment = proposal.comments.create!(body: "Participatory budgeting could also be used to improve childrens facilities",
                                      user_id: 9,
                                      created_at: 1.hour.ago)
  voters = users.sample(3)
  up_voters = voters.first(2)
  up_voters.each do |voter|
    comment.vote_by(voter: voter, vote: true)
  end
  down_voters = voters.last(1)
  down_voters.each do |voter|
    comment.vote_by(voter: voter, vote: false)
  end
  comment.update(updated_at: 3.minutes.ago)

  proposal.update(updated_at: 3.minutes.ago)

  author = User.find(4)
  proposal = Proposal.create!(title: "Change the city's public transport ticket for easier transfers",
                              summary: "It is essential that there are facilities for intermodality. Changing public transport without paying more, in a long period (90 minutes at least), is basic.",
                              description: "<p>We propose the existence of an intermodal ticket, that is to say, with which, once purchased, one could travel by any public transport. This is important because people use the transport network in a mixed way using different means of transport in a single journey. This, in turn, would result in very significant savings in the city's expenses. And also a very positive impact on pollution in the city as it would greatly increase the use of public transport to the detriment of private transport.</p>

<p>The ticket would be valid for a limited time, we propose 90 minutes. </p>",
                              tag_list: "transport,bus,Environment",
                              video_url: "https://www.youtube.com/watch?v=tCIHe8DD0tw",
                              author_id: author.id,
                              responsible_name: author.username,
                              terms_of_service: "1",
                              created_at: 1.month.ago,
                              published_at: 1.month.ago)
  image = Rack::Test::UploadedFile.new(Rails.root.join("db", "demo_seeds", "images", "proposals", "change-the-city-s-public-transport-ticket-for-easier-transfers.jpg"))
  add_image(image, proposal)

  supporters = users.sample(3)
  supporters.each do |supporter|
    proposal.vote_by(voter: supporter, vote: true)
  end

  comment = proposal.comments.create!(body: "I propose it be 3 hours better, like in other big cities.",
                                      user_id: 10,
                                      created_at: 3.weeks.ago)
  voters = users.sample(3)
  up_voters = voters.first(2)
  up_voters.each do |voter|
    comment.vote_by(voter: voter, vote: true)
  end
  down_voters = voters.last(1)
  down_voters.each do |voter|
    comment.vote_by(voter: voter, vote: false)
  end
  comment.update(updated_at: 2.weeks.ago)

  comment = proposal.comments.create!(body: "In Tokyo it is 4 hours. That would be even better.",
                                      ancestry: Comment.last.id,
                                      user_id: 9,
                                      created_at: 2.weeks.ago)
  voters = users.sample(4)
  up_voters = voters.first(2)
  up_voters.each do |voter|
    comment.vote_by(voter: voter, vote: true)
  end
  down_voters = voters.last(2)
  down_voters.each do |voter|
    comment.vote_by(voter: voter, vote: false)
  end
  comment.update(updated_at: 1.week.ago)

  proposal.update(updated_at: 1.week.ago)

  author = User.find(7)
  proposal = Proposal.create!(title: "Create a real network of safe cycle lanes in the city",
                              summary: "Whether segregated from motorised traffic or taking advantage of the roadway, it is essential to create a safe bicycle network if it is to occupy an important place as a means of transport.",
                              description: "<p>Whether segregated from motorised traffic or taking advantage of the roadway, it is essential to create a safe network for bicycles if it is to occupy an important place as an efficient means of transport. Thinking that these lanes should be able to be used by children, adults and also the elderly, they must guarantee safety and allow them to circulate without the pressure of being surrounded by cars or motorcycles, as not everyone has a state of form that allows them to go at a considerable speed, or simply want to go at a leisurely pace.</p>

<p>One cannot walk quietly on the road because, let us be realistic, we hinder traffic and we are a scourge to car drivers. It is not a question of harming the car or the pedestrian, so I think that the best solution is not to get in the way of different lanes. Motorised traffic would also benefit because the number of motorised vehicles would be reduced. The best working example is Amsterdam. </p>
",
                              tag_list: "cycling,cars,pollution",
                              author_id: author.id,
                              responsible_name: author.username,
                              terms_of_service: "1",
                              created_at: 6.months.ago,
                              published_at: 6.months.ago)

  supporters = users.sample(2)
  supporters.each do |supporter|
    proposal.vote_by(voter: supporter, vote: true)
  end

  comment = proposal.comments.create!(body: "What type of bike lane is really the safest? On the road or as a lane next to cars?",
                                      user_id: 8,
                                      created_at: 5.months.ago)
  up_voters = users.sample(5)
  up_voters.each do |voter|
    comment.vote_by(voter: voter, vote: true)
  end
  comment.update(updated_at: 3.months.ago)

  comment = proposal.comments.create!(body: "On the road for sure. Much more protected.",
                                      ancestry: Comment.last.id,
                                      user_id: 7,
                                      created_at: 3.months.ago)
  up_voters = users.sample(3)
  up_voters.each do |voter|
    comment.vote_by(voter: voter, vote: true)
  end
  comment.update(updated_at: 1.month.ago)

  comment = proposal.comments.create!(body: "What about buses and taxis?",
                                      user_id: 6,
                                      created_at: 1.month.ago)
  voters = users.sample(3)
  up_voters = voters.first(2)
  up_voters.each do |voter|
    comment.vote_by(voter: voter, vote: true)
  end
  down_voters = voters.last(1)
  down_voters.each do |voter|
    comment.vote_by(voter: voter, vote: false)
  end
  comment.update(updated_at: 1.week.ago)

  proposal.update(updated_at: 1.week.ago)

  author = User.find(8)
  proposal = Proposal.create!(title: "Prevent supermarkets from wasting food",
                              summary: "Supermarkets over 400 meters should donate perishable food to food banks, animal feed organizations or the manufacture of agricultural fertilizers.",
                              description: "<p>The last UN meeting proposed a law to considerably reduce supermarkets' waste of food.

The law prevents supermarkets over 400 meters from throwing away perishable food, which will have to be donated to organizations in charge of things like food banks, animal feed or for the manufacture of agricultural fertilizers, thus considerably reducing the waste of food and carbon dioxide emissions.

We must avoid wasting food that can be perfectly fit for human consumption, or that can be recycled in some way.

Every day 21,000 tons of food are wasted in the country, 1,000 of which are caused by the commercial distribution sector.</p>",
                              tag_list: "human rights,food,environment",
                              video_url: "https://www.youtube.com/watch?v=fRovHP4eXyM",
                              author_id: author.id,
                              responsible_name: author.username,
                              terms_of_service: "1",
                              created_at: (1.year - 1.day).ago,
                              published_at: (1.year - 1.day).ago)

  supporters = users.sample(1)
  supporters.each do |supporter|
    proposal.vote_by(voter: supporter, vote: true)
  end

  comment = proposal.comments.create!(body: "Should we involve charities in this proposal?",
                                      user_id: 11,
                                      created_at: 11.months.ago)
  up_voters = users.sample(4)
  up_voters.each do |voter|
    comment.vote_by(voter: voter, vote: true)
  end
  comment.update(updated_at: 9.months.ago)

  comment = proposal.comments.create!(body: "Perhaps consideration should be given to extending this proposal beyond supermarkets.",
                                      user_id: 10,
                                      created_at: 9.months.ago)
  voters = users.sample(5)
  up_voters = voters.first(2)
  up_voters.each do |voter|
    comment.vote_by(voter: voter, vote: true)
  end
  down_voters = voters.last(3)
  down_voters.each do |voter|
    comment.vote_by(voter: voter, vote: false)
  end
  comment.update(updated_at: 3.months.ago)

  comment = proposal.comments.create!(body: "To what other establishments could it be extended?",
                                      ancestry: Comment.last.id,
                                      user_id: 9,
                                      created_at: 3.months.ago)
  up_voters = users.sample(3)
  up_voters.each do |voter|
    comment.vote_by(voter: voter, vote: true)
  end
  comment.update(updated_at: 1.month.ago)

  proposal.update(updated_at: 1.month.ago)
end
