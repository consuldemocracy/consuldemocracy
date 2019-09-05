section "Creating DEMO homepage widgets" do

  card = Widget::Card.create!(link_url: "/budgets",
                              header: true,
                              created_at: 1.week.ago,
                              updated_at: 1.week.ago,
                              columns: 4,
                              label: "",
                              title: "Vote the participatory budgeting!",
                              description: "You have 100 million euros to imagine a new city",
                              link_text: "Vote")

  card.image = Image.create!(imageable: card,
                             title: card.title,
                             attachment: File.new(Rails.root.join("db", "demo_seeds", "images", "widgets", "homepage-card.jpg")),
                             user_id: 1)

  card = Widget::Card.create!(link_url: "/legislation/processes/2/draft_versions/1",
                              header: false,
                              created_at: 1.week.ago,
                              updated_at: 1.week.ago,
                              columns: 4,
                              label: "",
                              title: "Comment the Animal protection ordinance",
                              description: "Give your opinion about the new Regulatory Ordinance of the tenancy and protection of the animals.",
                              link_text: "Comment the text")

  card.image = Image.create!(imageable: card,
                             title: card.title,
                             attachment: File.new(Rails.root.join("db", "demo_seeds", "images", "widgets", "comment-the-animal-protection-ordinance.jpg")),
                             user_id: 1)

  card = Widget::Card.create!(link_url: "/polls/refurbishment-of-the-north-square",
                              header: false,
                              created_at: 1.week.ago,
                              updated_at: 1.week.ago,
                              columns: 4,
                              label: "",
                              title: "Decide which should be the new square",
                              description: "This is one of the 10 squares that have been selected for a possible remodeling to improve its use for the population.",
                              link_text: "Decide the new square")

  card.image = Image.create!(imageable: card,
                             title: card.title,
                             attachment: File.new(Rails.root.join("db", "demo_seeds", "images", "widgets", "decide-which-should-be-the-new-square.jpg")),
                             user_id: 1)

  Widget::Feed.create!(kind: "proposals",
                       limit: 2,
                       created_at: 1.week.ago,
                       updated_at: 1.week.ago)
  Widget::Feed.create!(kind: "debates",
                       limit: 3,
                       created_at: 1.week.ago,
                       updated_at: 1.week.ago)
  Widget::Feed.create!(kind: "processes",
                       limit: 1,
                       created_at: 1.week.ago,
                       updated_at: 1.week.ago)
end
