require_dependency "poll/answer"
require_dependency "poll/question/answer"

section "Creating DEMO polls" do
  poll = Poll.create!(name: "Refurbishment of the North Square",
                      slug: "refurbishment-of-the-north-square",
                      summary: "Decided now what the Town Hall is going to do with this square.\r\nThis is one of the 10 squares that have been selected for a possible remodeling to improve its use for the population. There has been a participatory process that ends now in this final phase of voting. It decides with respect to the squares if they should be remodeled or not, and for those that mostly decide to remodel which will be the projects to carry out.",
                      description: "More information\r\nThe North Square aims to become a hub of attraction for the district and for the population that may come from other parts of the city, as it has optimal regional accessibility in public transport.\r\nIt comes from an order of the Plan of 1985, with the aim of consolidating a built residential front to the new park and accommodate uses to serve as a connection between the old and the new.\r\nThe plot is intended for sports use and green area, but currently has a large vacant area that requires rethinking under a new perspective to take advantage of position and generate a pole of attraction towards the district, is intended to create a new square as a venue for cultural events and social meetings that is one of the most obvious deficiencies in the districts of the periphery.",
                      starts_at: 1.week.ago,
                      ends_at:   1.week.from_now,
                      author_id: 1,
                      geozone_restricted: false,
                      created_at: 1.month.ago)

  Image.create!(
    imageable: poll,
    title: poll.name,
    attachment: Rack::Test::UploadedFile.new(Rails.root.join("db", "demo_seeds", "images", "widgets", "decide-which-should-be-the-new-square.jpg")),
    user: User.first
  )

  question = poll.questions.create!(title: "Do you consider it necessary to remodel the square?",
                                    author_id: 1,
                                    created_at: 1.month.ago,
                                    updated_at: 1.month.ago)

  answer = question.question_answers.create!(title: "Yes", description: "", given_order: 1)
  users.first(6).each do |user|
    Poll::Answer.create!(question_id: question.id,
                         author: user,
                         answer: answer.title)
    Poll::Voter.create!(document_type: user.document_type,
                        document_number: user.document_number,
                        user: user,
                        poll: poll,
                        origin: "web",
                        token: SecureRandom.hex(32))
  end

  answer = question.question_answers.create!(title: "No", description: "", given_order: 2)
  users.last(4).each do |user|
    Poll::Answer.create!(question_id: question.id,
                         author: user,
                         answer: answer.title)
    Poll::Voter.create!(document_type: user.document_type,
                        document_number: user.document_number,
                        user: user,
                        poll: poll,
                        origin: "web",
                        token: SecureRandom.hex(32))
  end

  question = poll.questions.create!(title: "Which of the two finalist projects do you prefer to be carried out?",
                                    author_id: 1,
                                    created_at: 1.month.ago,
                                    updated_at: 1.month.ago)

  answer = question.question_answers.create!(title: "Light of the City",
                                             description: "<p>'Light of the City' responds to the will of the citizens to create a centrality in the district, through a new public space: the civic square. The proposal must respond to very different situations from the most technical point of view: topography, roads, accessibility...even the most social. For this reason, 'Light of the City' is understood as an integrator, an element in which to converge. Urban integrator: the new square is the point of connection of the great green extension of the park with the most consolidated and dense part of the district. In addition to the opportunity to continue an important point of public transport connection. Social integrator: the identity of a neighborhood is nourished by the neighborhood association and the sense of belonging to a place. The social diversity present in the district needs a place like the new civic square to integrate all the neighbors, so that they recognize it and appropriate it in a natural and open way. The mixture will exponentially enrich the quality of the public space. Integrator of uses: due to the great dimension of the square, it is necessary a simple strategy that is able to give answer to the different uses required by the neighbors. For this reason, program bands are used that will allow easy understanding of the space for all users and is, in the same way, another gesture towards the integration of different situations in the same place.</p>\r\n",
                                             given_order: 1)
  document = Rack::Test::UploadedFile.new(Rails.root.join("db", "demo_seeds", "documents", "polls", "light-of-the-city.pdf"))
  answer.documents.create!(title: "Project report", attachment: document, user_id: 1)
  answer.videos.create!(title: answer.title, url: "https://www.youtube.com/watch?v=48SqdGXukbg")
  users.first(6).each do |user|
    Poll::Answer.create!(question_id: question.id,
                         author: user,
                         answer: answer.title)
  end

  3.times do |number|
    answer.images.create!(
      title: answer.title,
      attachment: Rack::Test::UploadedFile.new(Rails.root.join("db", "demo_seeds", "images", "polls", "light-of-the-city-#{number + 1}.jpg")),
      user: User.first
    )
  end

  answer = question.question_answers.create!(title: "Square with History",
                                             description: "<p>The identification of an urban image in an area must be worked on, reading pre-existences and placing new elements that endow it with character. Citizens must identify these urban elements as their own in the civic square. The project tries to bring together the needs of a population and its relationship with the city. A social reference of appropriation of public space. An attempt is made to set up a meeting place and enjoy the district's own activities, increasing urban quality, especially the network of bordering spaces. The bases are raised to achieve over time a new area of centrality through the realization of a 'square equipped' that one of the most important milestones of use of the district. This is where the importance of degenerating activity in the square lies, taking advantage of the efficient value of the itineraries that run through it and activating it through the introduction of equipment needs in the neighbourhood. Facilities are established to make up the square. This enclosure is configured by means of the introduction of program in the square: Market, sport and therapeutic Swimming pools, polyvalent Rooms, Symphonic Room and classrooms of music and dance. The proposal tries to solve the problems of connection of the square and to give continuity to the accessible pedestrian itineraries necessary to be able to cover the square in all its fullness. This is achieved by modifying the natural height of the terrain taking as a premise that the accessible natural pass is the fastest route. Consideration will be given to aspects that consider the conservation of energy and natural resources, the reuse of those resources, the management of the life cycle of the materials and components used and considerations relating to the quality of the building.</p>\r\n",
                                           given_order: 2)
  document = Rack::Test::UploadedFile.new(Rails.root.join("db", "demo_seeds", "documents", "polls", "square-with-history.pdf"))
  answer.documents.create!(title: "Project report", attachment: document, user_id: 1)

  3.times do |number|
    answer.images.create!(
      title: answer.title,
      attachment: Rack::Test::UploadedFile.new(Rails.root.join("db", "demo_seeds", "images", "polls", "square-with-history-#{number + 1}.jpg")),
      user: User.first
    )
  end

  users.last(4).each do |user|
    Poll::Answer.create!(question_id: question.id,
                         author: user,
                         answer: answer.title)
  end

  comment = poll.comments.create!(body: "I love the large green area of the second proposal. I think that this should be particularly taken into account.",
                                  user_id: 3,
                                  created_at: 6.days.ago)
  up_voters = users.sample(4)
  up_voters.each do |voter|
    comment.vote_by(voter: voter, vote: true)
  end
  comment.update(updated_at: 6.days.ago)

  comment = poll.comments.create!(body: "Yes, but it is much more expensive.",
                                  ancestry: Comment.last.id,
                                  user_id: 4,
                                  created_at: 5.days.ago)
  up_voters = users.sample(3)
  up_voters.each do |voter|
    comment.vote_by(voter: voter, vote: true)
  end
  comment.update(updated_at: 5.days.ago)

  comment = poll.comments.create!(body: "The second proposals is connecting with the near square. That will produce a larger public space. Great.",
                                  user_id: 5,
                                  created_at: 4.days.ago)
  voters = users.sample(4)
  up_voters = voters.first(2)
  up_voters.each do |voter|
    comment.vote_by(voter: voter, vote: true)
  end
  down_voters = voters.last(2)
  down_voters.each do |voter|
    comment.vote_by(voter: voter, vote: false)
  end
  comment.update(updated_at: 4.days.ago)

  comment = poll.comments.create!(body: "The first one would be faster to build.",
                                  user_id: 6,
                                  created_at: 3.days.ago)
  voters = users.sample(7)
  up_voters = voters.first(4)
  up_voters.each do |voter|
    comment.vote_by(voter: voter, vote: true)
  end
  down_voters = voters.last(3)
  down_voters.each do |voter|
    comment.vote_by(voter: voter, vote: false)
  end
  comment.update(updated_at: 3.days.ago)

  poll.update(updated_at: 3.days.ago)
end
