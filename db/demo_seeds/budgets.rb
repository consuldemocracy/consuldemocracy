section "Creating DEMO Participatory Budgets" do

  current_year = Date.current.year

  budget = Budget.create!(name: "Participatory budgeting #{current_year}",
                         slug: "participatory-budgeting-#{current_year}",
                         currency_symbol: "€",
                         phase: "balloting",
                         published: true)

  group = budget.groups.create!(name: "City projects", slug: "city-projects")

  heading = group.headings.create!(name: "City", price: 60000000, population: 3000000)

  heading.investments.create!(title: " Chargers for electric vehicles.",
                              description: "<p>The city must have more charging zones to encourage the purchase of electric vehicles. For a cleaner and greener city.</p>
",
                              feasibility: "feasible",
                              valuation_finished: true,
                              tag_list: "Sustainability,Environment,Mobility,Health",
                              price: 24000000,
                              selected: true,
                              author: users.sample,
                              terms_of_service: "1")

  heading.investments.create!(title: "Canine Parks in each district",
                              description: "<p>Areas of a minimum area of 500 square meters, with a wire fence of 2 meters high (minimum) where dogs can be loose, run and play at any time of day. With complements such as litter bins (for excrement and other waste), fountains, benches and shade (trees, \"tejadillo\", etc). Without prejudice to the schedule that can go loose dogs in the parks (ie, that this is still kept in the park or garden that this canine area) and can also enjoy it considered potentially dangerous. In each district where there is no canine zone or if this exists and needs improvements, make them (broken fence, missing accessories, etc.). With periodical maintenance of the town hall (emptying of litter bins, care of the vegetation, various arrangements, etc).</p>\r\n",
                              feasibility: "feasible",
                              valuation_finished: false,
                              tag_list: "Sustainability,Sports,environment",
                              price: 20000000,
                              selected: false,
                              author: users.sample,
                              terms_of_service: "1")

  image = Rack::Test::UploadedFile.new(Rails.root.join("db", "demo_seeds", "images", "investments", "canine-parks-in-each-district.jpg"))
  add_image(image, Budget::Investment.last)

  heading.investments.create!(title: "Financial aid to guarantee basic food supply",
                              description: "<p>Social emergency financial aid is not just welfare benefits. They form part of the benefits implemented by the social protection system to overcome situations of social difficulty. In accordance with the provisions of Law 11/2003 on Social Services, these economic benefits, together with the techniques and materials, will be the actions carried out to achieve, re-establish or improve their welfare.</p>\r\n\r\n<p>Based on data from the National Statistics Institute's Living Conditions Survey, it is estimated that 1% of the inhabitants of the municipality of \"cannot afford a meal of meat, chicken or fish at least every two days\", some 32,000 people. If we take into account that less than 14,000 people receive the Minimum Income of Insertion, we see that the population that cannot afford a basic diet is more than double that which receives economic aid from the Autonomous Community. This shows that the Community's aid does not reach all the people who need it either.</p>\r\n\r\n<p>In recent years, night-time queues of people waiting to pick up waste from supermarkets have become commonplace in working-class neighbourhoods. New neighbourhood food collection and distribution networks have also emerged, a clear symptom of the inadequacy of public policies and the overflow of traditional NGOs.</p>\r\n\r\n<p>We consider that Participatory Budgets can be an opportunity to reach objectives of coverage of needs not reached until now, and to offer a definitive support to people and families that do not reach their autonomy and well-being because the existing aids are not sufficient.</p>\r\n\r\n<p>Our proposal consists of fully allocating the 30 million euros of the Participatory Budgets to an economic aid programme to eradicate food poverty in the city. This would mean contributing 0.6% of the City Council Budget to satisfy a basic need of 1% of the population, the most vulnerable.</p>\r\n\r\n<p>We invite you to massively support this proposal to eradicate this social stigma and as a way of demonstrating to Public Administrations that what citizens demand in the first place is that basic human rights be guaranteed. </p>\r\n",
                              feasibility: "feasible",
                              valuation_finished: true,
                              tag_list: "Social Rights,Safety and Emergencies,Health",
                              price: 25000000,
                              selected: true,
                              author: users.sample,
                              terms_of_service: "1")

  heading.investments.create!(title: "Creation of day centres for people with Alzheimer's disease",
                              description: "<p>The population is increasing in age and not all older people have places to go with specific help. Especially municipal day centres for Alzheimer's where professionals could help stimulate them to be less sad and alone at home.</p>\r\n",
                              feasibility: "feasible",
                              valuation_finished: true,
                              tag_list: "Social Rights,Health",
                              price: 20000000,
                              selected: true,
                              author: users.sample,
                              terms_of_service: "1")

  heading.investments.create!(title: "Green roofs and solar panels",
                              description: "<p>Create a network of green roofs with vegetation to help improve air quality and reduce temperature in the city.</p>\r\n\r\n<p>On roofs that are not suitable for the use of vegetation, install solar panels that meet the energy needs of city lighting and public buildings.</p>\r\n",
                              feasibility: "feasible",
                              valuation_finished: true,
                              tag_list: "environment",
                              price: 500000,
                              selected: true,
                              author: users.sample,
                              terms_of_service: "1")

  group = budget.groups.create!(name: "Districts projects", slug: "districts-projects")

  heading = group.headings.create!(name: "North district", slug: "north-district", price: 10000000, population: 1000000)

  heading.investments.create!(title: "The boulevard of art",
                              description: "<p>The general objective of the project is to be able to generate a work space where artists and artisans can earn a living while promoting expression through art, whether through workshops, shows, exhibitions, craft booths, mimes, dance, painting, poetry ...</p>\r\n\r\n<p>The boulevard would have 14 permanent booths which would be rented by the Board (monthly, weekly, fortnightly...) for different events (handicrafts, books, gastronomy of other towns and countries, flowers...).</p>\r\n\r\n<p>The booths could have energy in a sustainable way, in addition these booths could take advertising of the shops of the neighborhood to save expenses as much as possible.</p>\r\n\r\n<p>The project contemplates a Mural of Expression where, monthly, graffiti painters or whoever wants to express themselves. Each month would be bleached with the complicity of the neighborhood. These samples of street art could be the object of some report by workshops so that this ephemeral art could be captured in an annual exhibition.</p>\r\n\r\n<p>It also contemplates a stage for neighborhood groups (charangas, orchestras, monologues, magicians, puppets, dance, theater ...), so as to create a meeting space between artists, artisans and neighborhood.</p>\r\n\r\n<p>COMMENTS:</p>\r\n\r\n<p>We present this project with the illusion of being able to carry out together with the neighbourhood collectives, a space where art overflows in every corner of the boulevard and thus recover a space that has been damaged in recent years.</p>\r\n\r\n<p>Not only would it give work to artisans, but it would also dynamise the area and rescue it from the state of deterioration in which it finds itself.</p>\r\n\r\n<p>The support of the Town Planning and Employment Committee is requested because it touches areas of them.</p>\r\n",
                              feasibility: "feasible",
                              valuation_finished: true,
                              tag_list: "Culture",
                              price: 3700000,
                              selected: true,
                              author: users.sample,
                              terms_of_service: "1")

  image = Rack::Test::UploadedFile.new(Rails.root.join("db", "demo_seeds", "images", "investments", "the-boulevard-of-art.jpg"))
  add_image(image, Budget::Investment.last)

  heading.investments.create!(title: "Shade trees in squares",
                              description: "<p>Plant shade trees in squares that are now mere stone deserts or lack them, so that they can be used by neighbors as small oases in the city and contribute to clean the environment and lower high temperatures in summer. To provide them with sufficient land and irrigation so that they can live and develop (and not remain like sad skewers). Choose species that work well in this environment.</p>\r\n",
                              feasibility: "feasible",
                              valuation_finished: true,
                              tag_list: "Sustainability,Environment",
                              price: 4000000,
                              selected: true,
                              author: users.sample,
                              terms_of_service: "1")

  heading.investments.create!(title: "Sustainable social economy project",
                              description: "<p>It is proposed the creation of a market where neighbors can exchange objects (barter), would not be a selling market, nor with the existence of donations, nor would there be any profit, only exchange of objects without the presence of money. And in order to do so, it is requested that part of the public space in the Children's Park be adapted with the urban furniture necessary to make this market where barter can be carried out between the neighbours.</p>\r\n\r\n<p>The necessary urban furniture would be tables, benches and a closed space to store materials that will be used in the barter market.</p>\r\n\r\n<p>This proposal is created due to the lack of public spaces destined to the neighborhood meeting, to improve the social economy of the neighborhoods and to continue with the work that the collectives and the neighbors of the district of Chamartín had been doing in the barter market that was carried out in the park of Gloria Fuertes.</p>\r\n\r\n<p>The estimated value of investment in this proposal would be around € 5000.</p>\r\n",
                              feasibility: "feasible",
                              valuation_finished: true,
                              tag_list: "Sustainability,Economy",
                              price: 4600000,
                              selected: true,
                              author: users.sample,
                              terms_of_service: "1")

  heading.investments.create!(title: "Comprehensive reform of roads, sidewalks and tunnels",
                              description: "<p>Integral reform of roads and sidewalks, and Repair, painting and asphalt of tunnels </p>\r\n",
                              feasibility: "feasible",
                              valuation_finished: true,
                              tag_list: "urbanism,Mobility",
                              price: 4700000,
                              selected: true,
                              author: users.sample,
                              terms_of_service: "1")


  heading = group.headings.create!(name: "West district", slug: "west-district", price: 10000000, population: 1000000)

  heading.investments.create!(title: "Public playroom",
                              description: "<p>A public playroom is needed for children and babies in the District so that they can play days of rain, cold, or very hot. Currently, the only options are private, scarce and expensive. In addition, there are almost no public (or private) spaces appropriate for babies in their first year of life to develop their motor skills.</p>\r\n\r\n<p>It is proposed to create a comfortable, warm, inclusive and accessible space, where we can spend time with our children and share with other families. A public space could be set up to become a playroom with a wide access timetable. In its interior and exterior zones, children will be able to socialize, play and participate in activities, babies will be able to move freely in a safe place; and their mothers and fathers will have zones to exchange experiences, form themselves, organize workshops, weave networks and propose cultural activities for girls and boys.</p>\r\n",
                              feasibility: "feasible",
                              valuation_finished: true,
                              tag_list: "Social Rights,Culture",
                              price: 3800000,
                              selected: true,
                              author: users.sample,
                              terms_of_service: "1")

  heading.investments.create!(title: "Cinematheque for the district",
                              description: "<p>La Nave is the result of the rehabilitation of a part of the old and abandoned barracks, which was saved from real estate speculation thanks to the struggle of the neighbors of the neighborhood to maintain it for equipping the neighborhood.</p>\r\n\r\n<p>It is a cultural macrospace that has two theater rooms, several multipurpose rooms, common areas and warehouses. The previous government left it in absolute disuse and even today, the programming that is carried out is far below the occupation that can accommodate this large space.</p>\r\n\r\n<p>Our proposal consists in the creation of a cinema library, an audiovisual room for alternative, independent and non-fiction cinema programming that would be located in a room on the lower floor of the Nave Teatro.</p>\r\n\r\n<p>It is a project that does not require a great investment but that would give cultural life to a neighbourhood that, like almost all of them, has lost all its cinemas, as well as offering all the people of Madrid the possibility of enriching our social and cultural life.</p>\r\n\r\n<p>Thank you for supporting our proposal.</p>\r\n",
                              feasibility: "feasible",
                              valuation_finished: true,
                              tag_list: "Districts,Culture",
                              price: 4000000,
                              selected: true,
                              author: users.sample,
                              terms_of_service: "1")

  image = Rack::Test::UploadedFile.new(Rails.root.join("db", "demo_seeds", "images", "investments", "cinematheque-for-the-district.jpg"))
  add_image(image, Budget::Investment.last)

  heading.investments.create!(title: "Pedestrianization of streets with narrow and impracticable sidewalks",
                              description: "<p>The object of this proposal is to pedestrianize those streets of the district whose narrow sidewalks are in practice impracticable. In particular, the proposal refers to streets with sidewalks of 1m or less in width.</p>\r\n\r\n<p>Among other problems, neighbors and pedestrians are forced to share the roadway with vehicles and sidewalks are inaccessible to people with disabilities. Coexistence is sometimes made even more difficult by the fact that these streets (often separated from the main roads) are used for loading and unloading illegally and outside the areas set aside for this purpose.</p>\r\n",
                              feasibility: "feasible",
                              valuation_finished: true,
                              tag_list: "urbanism,environment,Health",
                              price: 5000000,
                              selected: true,
                              author: users.sample,
                              terms_of_service: "1")

  heading = group.headings.create!(name: "East district", slug: "east-district", price: 10000000, population: 500000)

  heading.investments.create!(title: "Remodelling of the central square",
                              description: "<p>The residents of the square want a reform of the square that makes it greener more colorful and more of all neighbors eradicating bad habits there. we also want the square to be more sustainable even placing triangular sails that provide shade in summer and water mist to cool the area. we also want more trees and cultural alternatives such as theater and puppets some solidarity market and even the possibility of giving a concert with unidirectional speakers. We are open to any suggestion or idea from any of the neighbors of the district.</p>\r\n",
                              feasibility: "feasible",
                              valuation_finished: true,
                              tag_list: "Culture,Sports,urbanism",
                              price: 4000000,
                              selected: true,
                              author: users.sample,
                              terms_of_service: "1")

  heading.investments.create!(title: "Change all lighting to leds",
                              description: "<p>Continue to change the lighting of the city, not only the low streetlights that have been changed recently, but also the higher streetlights, all the lighting of tunnels and roads and the lighting of public buildings, thus promoting greater savings that impact on energy expenditure (this money can be used for other initiatives) and simultaneously promoting a reduction in pollution that such energy savings entails. Part of the money can also be used to carry out a campaign to encourage the same change in private homes, providing incentives such as discounts on the purchase of such lighting systems.</p>\r\n\r\n<p>At the same time, we could think of models of street lamps with solar panels in the same style as parking meters or some traffic signs, so that the savings would be greater or the energy generated could be sold to the electricity grid.</p>\r\n\r\n<p>It is necessary to think about saving expenses as well as it has been carried out, in this way greater budgetary items can be destined for things that are worthwhile to the citizens. </p>\r\n",
                              feasibility: "feasible",
                              valuation_finished: true,
                              tag_list: "environment,Health",
                              price: 4000000,
                              selected: true,
                              author: users.sample,
                              terms_of_service: "1")

  image = Rack::Test::UploadedFile.new(Rails.root.join("db", "demo_seeds", "images", "investments", "change-all-lighting-to-leds.jpg"))
  add_image(image, Budget::Investment.last)

  heading.investments.create!(title: "Musical equipment for the District's public schools",
                              description: "<p>The proposal is aimed at equipping several public schools in the District with instruments and other equipment related to musical teaching and practice, with the aim of holding music classes organised outside school hours, as well as rehearsals by the Orquesta-Escuela del Barrio for children and adults, within the framework of the project being carried out by the Association made up of different citizen groups (musical and educational associations).</p>\r\n",
                              feasibility: "feasible",
                              valuation_finished: true,
                              tag_list: "Culture",
                              price: 4100000,
                              selected: true,
                              author: users.sample,
                              terms_of_service: "1")

  heading = group.headings.create!(name: "South district", slug: "south-district", price: 10000000, population: 500000)

  heading.investments.create!(title: "Enlarge library",
                              description: "<p>Dámaso Alonso's library is small and would need to be enlarged in order to enlarge the collection of books. </p>\r\n",
                              feasibility: "feasible",
                              valuation_finished: true,
                              tag_list: "Culture",
                              price: 3800000,
                              selected: true,
                              author: users.sample,
                              terms_of_service: "1")

  heading.investments.create!(title: "Reading rooms: accessibility and wi-fi",
                              description: "<p>The reading rooms are one of the few spaces, next to the libraries, where the youth of the district can study quietly and properly prepare their exams.</p>\r\n\r\n<p>Recently some of them have been rehabilitated, but they need improvements both to allow access to their services to everyone and to facilitate the consultation of information and knowledge so necessary while a person studies. Therefore, we propose that in the four reading rooms:</p>\r\n\r\n<p>To install elements that allow accessibility to people with reduced mobility, except in Cebreros due to the strong technical difficulties of carrying it out. Free wi-fi network coverage is available. We also propose the installation of accessibility elements for people with reduced mobility at the western entrance to the Cultural Centre. </p>\r\n",
                              feasibility: "feasible",
                              valuation_finished: true,
                              tag_list: "Districts,Culture",
                              price: 4500000,
                              selected: true,
                              author: users.sample,
                              terms_of_service: "1")

  heading.investments.create!(title: "District International Blues Festival",
                              description: "<p>We believe that the city deserves an international Blues festival as it is held in other cities. The musical offer is wide and, especially in the months of spring to autumn, there are a lot of live music activities. However, Blues is in a position of inferiority to other musical styles, as it has enjoyed little institutional support for its promotion. That is why we are making this proposal, a Festival that will be free and will feature leading figures of national and international Blues.</p>\r\n\r\n<p></p>\r\n\r\n<p>Last year we had the opportunity to organize a Blues festival with musicians, which was developed with great success. This fact, together with the flourishing associative and cultural activity of the District in the last years, encourages us to propose this International Festival taking advantage of the existing municipal spaces.</p>\r\n\r\n<p></p>\r\n\r\n<p>Its realization could serve as a means to create in the district a cultural circuit with a stable cultural program, as it provides for the exploitation of synergies with other associations, seeking their participation and collaboration. The event will also have economic advantages for the District and for the city, as this type of event attracts fans, with the consequent increase in activity, especially in the services sector.</p>\r\n\r\n<p></p>\r\n\r\n<p>The Festival will include musical and children's activities, a conference, a documentary screening, a master class and an exhibition, with the aim of presenting a broad programme aimed at all audiences.</p>\r\n\r\n<p></p>\r\n\r\n<p>Calendar: SpringFriday 24 and Saturday 25 May + Friday 31 May, Saturday 1 and Sunday 2 June</p>\r\n",
                              feasibility: "feasible",
                              valuation_finished: true,
                              tag_list: "Culture",
                              price: 4000000,
                              selected: true,
                              author: users.sample,
                              terms_of_service: "1")

  image = Rack::Test::UploadedFile.new(Rails.root.join("db", "demo_seeds", "images", "investments", "district-international-blues-festival.jpg"))
  add_image(image, Budget::Investment.last)

  heading.investments.create!(title: "Outdoor Dancefloors",
                              description: "<p>Installation/construction of two dance floors (wooden floor) in the district</p>\r\n\r\n<p>Technical aspects: </p>\r\n\r\n<p>- Surface area of land to be built per track: 100 square meters</p>\r\n\r\n<p>- Floor material: wooden platform resistant to exteriors (sliding materials to facilitate the dance and the care of the knees of lxs bailarinxs).</p>\r\n\r\n<p>- Lighting point installation (Electrotechnics: Power supply, electricity): to be able to plug loudspeakers or other utensils.</p>\r\n\r\n<p>Possible location within the park itself: The best site, for lighting, sonority (minimize possible impact to the rest of neighbors), shadows and location, would be in the area that now occupies the playground (more used, unfortunately, as a dog park) which would move this to another area of the park. (it is not essential and would be evaluated by the technicians of the council with a view to minimizing expenses and improving the idea).</p>\r\n\r\n<p>The dance floor would in no case involve eliminating any of the existing trees, which means respecting them and/or integrating them into the design.</p>\r\n\r\n<p>Justification of the location, ideas and positive aspects to take into account that support the investment:</p>\r\n\r\n<p>- Dynamisation of public spaces with music and dance for all citizens.</p>\r\n\r\n<p>- Intergenerational activities.</p>\r\n\r\n<p>- New ways of living and building the public space, promoting neighborhood coexistence.</p>\r\n\r\n<p>- Dancing as an alternative to healthy, social leisure, which helps to improve both physical and psychological fitness.</p>\r\n",
                              feasibility: "feasible",
                              valuation_finished: true,
                              tag_list: "urbanism,Culture,Music",
                              price: 4700000,
                              selected: true,
                              author: users.sample,
                              terms_of_service: "1")

  budget.investments.each do |investment|
    MapLocation.create(latitude: Setting["map.latitude"].to_f + rand(-1..1)/100.to_f,
                       longitude: Setting["map.longitude"].to_f + rand(-7..7)/100.to_f,
                       zoom: Setting["map.zoom"],
                       investment_id: investment.id)
  end

end
