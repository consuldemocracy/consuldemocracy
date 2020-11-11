goal = SDG::Goal.find(2)
if goal && SDG::Target.find_by(goal_id: goal.id).none?
  SDG::Target.create!(title_en: "2.1",
                      description_en: "2.1 By 2030, end hunger and ensure access by all people, in particular the poor and people in vulnerable situations, including infants, to safe, nutritious and sufficient food all year round.",
                      title_es: "2.1",
                      description_es: "2.1 Para 2030, poner fin al hambre y asegurar el acceso de todas las personas, en particular los pobres y las personas en situaciones vulnerables, incluidos los lactantes, a una alimentación sana, nutritiva y suficiente durante todo el año",
                      goal: goal)

  SDG::Target.create!(title_en: "2.2",
                      description_en: "2.2 By 2030, end all forms of malnutrition, including achieving, by 2025, the internationally agreed targets on stunting and wasting in children under 5 years of age, and address the nutritional needs of adolescent girls, pregnant and lactating women and older persons.",
                      title_es: "2.1",
                      description_es: "2.2 Para 2030, poner fin a todas las formas de malnutrición, incluso logrando, a más tardar en 2025, las metas convenidas internacionalmente sobre el retraso del crecimiento y la emaciación de los niños menores de 5 años, y abordar las necesidades de nutrición de las adolescentes, las mujeres embarazadas y lactantes y las personas de edad",
                      goal: goal)

  SDG::Target.create!(title_en: "2.3",
                      description_en: "2.3 By 2030, double the agricultural productivity and incomes of small-scale food producers, in particular women, indigenous peoples, family farmers, pastoralists and fishers, including through secure and equal access to land, other productive resources and inputs, knowledge, financial services, markets and opportunities for value addition and non-farm employment.",
                      title_es: "2.3",
                      description_es: "2.3 Para 2030, duplicar la productividad agrícola y los ingresos de los productores de alimentos en pequeña escala, en particular las mujeres, los pueblos indígenas, los agricultores familiares, los pastores y los pescadores, entre otras cosas mediante un acceso seguro y equitativo a las tierras, a otros recursos de producción e insumos, conocimientos, servicios financieros, mercados y oportunidades para la generación de valor añadido y empleos no agrícolas",
                      goal: goal)

  SDG::Target.create!(title_en: "2.4",
                      description_en: "2.4 By 2030, ensure sustainable food production systems and implement resilient agricultural practices that increase productivity and production, that help maintain ecosystems, that strengthen capacity for adaptation to climate change, extreme weather, drought, flooding and other disasters and that progressively improve land and soil quality.",
                      title_es: "2.4",
                      description_es: "2.4 Para 2030, asegurar la sostenibilidad de los sistemas de producción de alimentos y aplicar prácticas agrícolas resilientes que aumenten la productividad y la producción, contribuyan al mantenimiento de los ecosistemas, fortalezcan la capacidad de adaptación al cambio climático, los fenómenos meteorológicos extremos, las sequías, las inundaciones y otros desastres, y mejoren progresivamente la calidad del suelo y la tierra",
                      goal: goal)

  SDG::Target.create!(title_en: "2.5",
                      description_en: "2.5 By 2020, maintain the genetic diversity of seeds, cultivated plants and farmed and domesticated animals and their related wild species, including through soundly managed and diversified seed and plant banks at the national, regional and international levels, and promote access to and fair and equitable sharing of benefits arising from the utilization of genetic resources and associated traditional knowledge, as internationally agreed.",
                      title_es: "2.5",
                      description_es: "2.5 Para 2020, mantener la diversidad genética de las semillas, las plantas cultivadas y los animales de granja y domesticados y sus especies silvestres conexas, entre otras cosas mediante una buena gestión y diversificación de los bancos de semillas y plantas a nivel nacional, regional e internacional, y promover el acceso a los beneficios que se deriven de la utilización de los recursos genéticos y los conocimientos tradicionales y su distribución justa y equitativa, como se ha convenido internacionalmente",
                      goal: goal)

  SDG::Target.create!(title_en: "2.A",
                      description_en: "2.A Increase investment, including through enhanced international cooperation, in rural infrastructure, agricultural research and extension services, technology development and plant and livestock gene banks in order to enhance agricultural productive capacity in developing countries, in particular least developed countries.",
                      title_es: "2.a",
                      description_es: "2.a Aumentar las inversiones, incluso mediante una mayor cooperación internacional, en la infraestructura rural, la investigación agrícola y los servicios de extensión, el desarrollo tecnológico y los bancos de genes de plantas y ganado a fin de mejorar la capacidad de producción agrícola en los países en desarrollo, en particular en los países menos adelantados",
                      goal: goal)

  SDG::Target.create!(title_en: "2.B",
                      description_en: "2.B Correct and prevent trade restrictions and distortions in world agricultural markets, including through the parallel elimination of all forms of agricultural export subsidies and all export measures with equivalent effect, in accordance with the mandate of the Doha Development Round.",
                      title_es: "2.b",
                      description_es: "2.b Corregir y prevenir las restricciones y distorsiones comerciales en los mercados agropecuarios mundiales, entre otras cosas mediante la eliminación paralela de todas las formas de subvenciones a las exportaciones agrícolas y todas las medidas de exportación con efectos equivalentes, de conformidad con el mandato de la Ronda de Doha para el Desarrollo",
                      goal: goal)

  SDG::Target.create!(title_en: "2.C",
                      description_en: "2.C Adopt measures to ensure the proper functioning of food commodity markets and their derivatives and facilitate timely access to market information, including on food reserves, in order to help limit extreme food price volatility.",
                      title_es: "2.c",
                      description_es: "2.c Adoptar medidas para asegurar el buen funcionamiento de los mercados de productos básicos alimentarios y sus derivados y facilitar el acceso oportuno a información sobre los mercados, en particular sobre las reservas de alimentos, a fin de ayudar a limitar la extrema volatilidad de los precios de los alimentos",
                      goal: goal)
end
