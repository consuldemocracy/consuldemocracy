goal = SDG::Goal.find(11)
if goal && SDG::Target.find_by(goal_id: goal.id).none?
  SDG::Target.create!(title_en: "11.1",
                      description_en: "11.1 By 2030, ensure access for all to adequate, safe and affordable housing and basic services and upgrade slums",
                      title_es: "11.1",
                      description_es: "11.1 De aquí a 2030, asegurar el acceso de todas las personas a viviendas y servicios básicos adecuados, seguros y asequibles y mejorar los barrios marginales",
                      goal: goal)

  SDG::Target.create!(title_en: "11.2",
                      description_en: "11.2 By 2030, provide access to safe, affordable, accessible and sustainable transport systems for all, improving road safety, notably by expanding public transport, with special attention to the needs of those in vulnerable situations, women, children, persons with disabilities and older persons",
                      title_es: "11.2",
                      description_es: "11.2 De aquí a 2030, proporcionar acceso a sistemas de transporte seguros, asequibles, accesibles y sostenibles para todos y mejorar la seguridad vial, en particular mediante la ampliación del transporte público, prestando especial atención a las necesidades de las personas en situación de vulnerabilidad, las mujeres, los niños, las personas con discapacidad y las personas de edad",
                      goal: goal)

  SDG::Target.create!(title_en: "11.3",
                      description_en: "11.3 By 2030, enhance inclusive and sustainable urbanization and capacity for participatory, integrated and sustainable human settlement planning and management in all countries",
                      title_es: "11.3",
                      description_es: "11.3 De aquí a 2030, aumentar la urbanización inclusiva y sostenible y la capacidad para la planificación y la gestión participativas, integradas y sostenibles de los asentamientos humanos en todos los países",
                      goal: goal)

  SDG::Target.create!(title_en: "11.4",
                      description_en: "11.4 Strengthen efforts to protect and safeguard the world’s cultural and natural heritage",
                      title_es: "11.4",
                      description_es: "11.4 Redoblar los esfuerzos para proteger y salvaguardar el patrimonio cultural y natural del mundo",
                      goal: goal)

  SDG::Target.create!(title_en: "11.5",
                      description_en: "11.5 By 2030, significantly reduce the number of deaths and the number of people affected and substantially decrease the direct economic losses relative to global gross domestic product caused by disasters, including water-related disasters, with a focus on protecting the poor and people in vulnerable situations",
                      title_es: "11.5",
                      description_es: "11.5 De aquí a 2030, reducir significativamente el número de muertes causadas por los desastres, incluidos los relacionados con el agua, y de personas afectadas por ellos, y reducir considerablemente las pérdidas económicas directas provocadas por los desastres en comparación con el producto interno bruto mundial, haciendo especial hincapié en la protección de los pobres y las personas en situaciones de vulnerabilidad",
                      goal: goal)

  SDG::Target.create!(title_en: "11.6",
                      description_en: "11.6 By 2030, reduce the adverse per capita environmental impact of cities, including by paying special attention to air quality and municipal and other waste management",
                      title_es: "11.6",
                      description_es: "11.6 De aquí a 2030, reducir el impacto ambiental negativo per capita de las ciudades, incluso prestando especial atención a la calidad del aire y la gestión de los desechos municipales y de otro tipo",
                      goal: goal)

  SDG::Target.create!(title_en: "11.7",
                      description_en: "11.7 By 2030, provide universal access to safe, inclusive and accessible, green and public spaces, in particular for women and children, older persons and persons with disabilities",
                      title_es: "11.7",
                      description_es: "11.7 De aquí a 2030, proporcionar acceso universal a zonas verdes y espacios públicos seguros, inclusivos y accesibles, en particular para las mujeres y los niños, las personas de edad y las personas con discapacidad",
                      goal: goal)

  SDG::Target.create!(title_en: "11.A",
                      description_en: "11.A Support positive economic, social and environmental links between urban, peri-urban and rural areas by strengthening national and regional development planning",
                      title_es: "11.a",
                      description_es: "11.a Apoyar los vínculos económicos, sociales y ambientales positivos entre las zonas urbanas, periurbanas y rurales fortaleciendo la planificación del desarrollo nacional y regional",
                      goal: goal)

  SDG::Target.create!(title_en: "11.B",
                      description_en: "11.B By 2020, substantially increase the number of cities and human settlements adopting and implementing integrated policies and plans towards inclusion, resource efficiency, mitigation and adaptation to climate change, resilience to disasters, and develop and implement, in line with the Sendai Framework for Disaster Risk Reduction 2015-2030, holistic disaster risk management at all levels",
                      title_es: "11.b",
                      description_es: "11.b De aquí a 2020, aumentar considerablemente el número de ciudades y asentamientos humanos que adoptan e implementan políticas y planes integrados para promover la inclusión, el uso eficiente de los recursos, la mitigación del cambio climático y la adaptación a él y la resiliencia ante los desastres, y desarrollar y poner en práctica, en consonancia con el Marco de Sendai para la Reducción del Riesgo de Desastres 2015-2030, la gestión integral de los riesgos de desastre a todos los niveles",
                      goal: goal)

  SDG::Target.create!(title_en: "11.C",
                      description_en: "11.C Support least developed countries, including through financial and technical assistance, in building sustainable and resilient buildings utilizing local materials",
                      title_es: "11.c",
                      description_es: "11.c Proporcionar apoyo a los países menos adelantados, incluso mediante asistencia financiera y técnica, para que puedan construir edificios sostenibles y resilientes utilizando materiales locales",
                      goal: goal)
end
