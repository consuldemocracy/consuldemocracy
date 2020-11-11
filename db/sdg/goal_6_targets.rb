goal = SDG::Goal.find(6)
if goal && SDG::Target.find_by(goal_id: goal.id).none?
  SDG::Target.create!(title_en: "6.1",
                      description_en: "6.1 By 2030, achieve universal and equitable access to safe and affordable drinking water for all",
                      title_es: "6.1",
                      description_es: "6.1 De aquí a 2030, lograr el acceso universal y equitativo al agua potable a un precio asequible para todos",
                      goal: goal)

  SDG::Target.create!(title_en: "6.2",
                      description_en: "6.2 By 2030, achieve access to adequate and equitable sanitation and hygiene for all and end open defecation, paying special attention to the needs of women and girls and those in vulnerable situations",
                      title_es: "6.2",
                      description_es: "6.2 De aquí a 2030, lograr el acceso a servicios de saneamiento e higiene adecuados y equitativos para todos y poner fin a la defecación al aire libre, prestando especial atención a las necesidades de las mujeres y las niñas y las personas en situaciones de vulnerabilidad",
                      goal: goal)

  SDG::Target.create!(title_en: "6.3",
                      description_en: "6.3 By 2030, improve water quality by reducing pollution, eliminating dumping and minimizing release of hazardous chemicals and materials, halving the proportion of untreated wastewater and substantially increasing recycling and safe reuse globally",
                      title_es: "6.3",
                      description_es: "6.3 De aquí a 2030, mejorar la calidad del agua reduciendo la contaminación, eliminando el vertimiento y minimizando la emisión de productos químicos y materiales peligrosos, reduciendo a la mitad el porcentaje de aguas residuales sin tratar y aumentando considerablemente el reciclado y la reutilización sin riesgos a nivel mundial",
                      goal: goal)

  SDG::Target.create!(title_en: "6.4",
                      description_en: "6.4 By 2030, substantially increase water-use efficiency across all sectors and ensure sustainable withdrawals and supply of freshwater to address water scarcity and substantially reduce the number of people suffering from water scarcity",
                      title_es: "6.4",
                      description_es: "6.4 De aquí a 2030, aumentar considerablemente el uso eficiente de los recursos hídricos en todos los sectores y asegurar la sostenibilidad de la extracción y el abastecimiento de agua dulce para hacer frente a la escasez de agua y reducir considerablemente el número de personas que sufren falta de agua",
                      goal: goal)

  SDG::Target.create!(title_en: "6.5",
                      description_en: "6.5 By 2030, implement integrated water resources management at all levels, including through transboundary cooperation as appropriate",
                      title_es: "6.5",
                      description_es: "6.5 De aquí a 2030, implementar la gestión integrada de los recursos hídricos a todos los niveles, incluso mediante la cooperación transfronteriza, según proceda",
                      goal: goal)

  SDG::Target.create!(title_en: "6.6",
                      description_en: "6.6 By 2020, protect and restore water-related ecosystems, including mountains, forests, wetlands, rivers, aquifers and lakes",
                      title_es: "6.6",
                      description_es: "6.6 De aquí a 2020, proteger y restablecer los ecosistemas relacionados con el agua, incluidos los bosques, las montañas, los humedales, los ríos, los acuíferos y los lagos",
                      goal: goal)

  SDG::Target.create!(title_en: "6.A",
                      description_en: "6.A By 2030, expand international cooperation and capacity-building support to developing countries in water- and sanitation-related activities and programmes, including water harvesting, desalination, water efficiency, wastewater treatment, recycling and reuse technologies",
                      title_en: "6.a",
                      description_es: "6.a De aquí a 2030, ampliar la cooperación internacional y el apoyo prestado a los países en desarrollo para la creación de capacidad en actividades y programas relativos al agua y el saneamiento, como los de captación de agua, desalinización, uso eficiente de los recursos hídricos, tratamiento de aguas residuales, reciclado y tecnologías de reutilización",
                      goal: goal)

  SDG::Target.create!(title_en: "6.B",
                      description_en: "6.B Support and strengthen the participation of local communities in improving water and sanitation management",
                      title_es: "6.b",
                      description_es: "6.b Apoyar y fortalecer la participación de las comunidades locales en la mejora de la gestión del agua y el saneamiento",
                      goal: goal)
end
