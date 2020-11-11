goal = SDG::Goal.find(9)
if goal && SDG::Target.find_by(goal_id: goal.id).none?
  SDG::Target.create!(title_en: "9.1",
                      description_en: "9.1 Develop quality, reliable, sustainable and resilient infrastructure, including regional and transborder infrastructure, to support economic development and human well-being, with a focus on affordable and equitable access for all",
                      title_es: "9.1",
                      description_es: "9.1 Desarrollar infraestructuras fiables, sostenibles, resilientes y de calidad, incluidas infraestructuras regionales y transfronterizas, para apoyar el desarrollo económico y el bienestar humano, haciendo especial hincapié en el acceso asequible y equitativo para todos",
                      goal: goal)

  SDG::Target.create!(title_en: "9.2",
                      description_en: "9.2 Promote inclusive and sustainable industrialization and, by 2030, significantly raise industry’s share of employment and gross domestic product, in line with national circumstances, and double its share in least developed countries",
                      title_es: "9.2",
                      description_es: "9.2 Promover una industrialización inclusiva y sostenible y, de aquí a 2030, aumentar significativamente la contribución de la industria al empleo y al producto interno bruto, de acuerdo con las circunstancias nacionales, y duplicar esa contribución en los países menos adelantados",
                      goal: goal)

  SDG::Target.create!(title_en: "9.3",
                      description_en: "9.3 Increase the access of small-scale industrial and other enterprises, in particular in developing countries, to financial services, including affordable credit, and their integration into value chains and markets",
                      title_es: "9.3",
                      description_es: "9.3 Aumentar el acceso de las pequeñas industrias y otras empresas, particularmente en los países en desarrollo, a los servicios financieros, incluidos créditos asequibles, y su integración en las cadenas de valor y los mercados",
                      goal: goal)

  SDG::Target.create!(title_en: "9.4",
                      description_en: "9.4 By 2030, upgrade infrastructure and retrofit industries to make them sustainable, with increased resource-use efficiency and greater adoption of clean and environmentally sound technologies and industrial processes, with all countries taking action in accordance with their respective capabilities",
                      title_es: "9.4",
                      description_es: "9.4 De aquí a 2030, modernizar la infraestructura y reconvertir las industrias para que sean sostenibles, utilizando los recursos con mayor eficacia y promoviendo la adopción de tecnologías y procesos industriales limpios y ambientalmente racionales, y logrando que todos los países tomen medidas de acuerdo con sus capacidades respectivas",
                      goal: goal)

  SDG::Target.create!(title_en: "9.5",
                      description_en: "9.5 Enhance scientific research, upgrade the technological capabilities of industrial sectors in all countries, in particular developing countries, including, by 2030, encouraging innovation and substantially increasing the number of research and development workers per 1 million people and public and private research and development spending",
                      title_es: "9.5",
                      description_es: "9.5 Aumentar la investigación científica y mejorar la capacidad tecnológica de los sectores industriales de todos los países, en particular los países en desarrollo, entre otras cosas fomentando la innovación y aumentando considerablemente, de aquí a 2030, el número de personas que trabajan en investigación y desarrollo por millón de habitantes y los gastos de los sectores público y privado en investigación y desarrollo",
                      goal: goal)

  SDG::Target.create!(title_en: "9.A",
                      description_en: "9.A Facilitate sustainable and resilient infrastructure development in developing countries through enhanced financial, technological and technical support to African countries, least developed countries, landlocked developing countries and small island developing States 18",
                      title_es: "9.a",
                      description_es: "9.a Facilitar el desarrollo de infraestructuras sostenibles y resilientes en los países en desarrollo mediante un mayor apoyo financiero, tecnológico y técnico a los países africanos, los países menos adelantados, los países en desarrollo sin litoral y los pequeños Estados insulares en desarrollo",
                      goal: goal)

  SDG::Target.create!(title_en: "9.B",
                      description_en: "9.B Support domestic technology development, research and innovation in developing countries, including by ensuring a conducive policy environment for, inter alia, industrial diversification and value addition to commodities",
                      title_es: "9.b",
                      description_es: "9.b Apoyar el desarrollo de tecnologías, la investigación y la innovación nacionales en los países en desarrollo, incluso garantizando un entorno normativo propicio a la diversificación industrial y la adición de valor a los productos básicos, entre otras cosas",
                      goal: goal)

  SDG::Target.create!(title_en: "9.C",
                      description_en: "9.C Significantly increase access to information and communications technology and strive to provide universal and affordable access to the Internet in least developed countries by 2020",
                      title_es: "9.c",
                      description_es: "9.c Aumentar significativamente el acceso a la tecnología de la información y las comunicaciones y esforzarse por proporcionar acceso universal y asequible a Internet en los países menos adelantados de aquí a 2020",
                      goal: goal)
end
