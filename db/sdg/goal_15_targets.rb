goal = SDG::Goal.find(15)
if goal && SDG::Target.find_by(goal_id: goal.id).none?
  SDG::Target.create!(title_en: "15.1",
                      description_en: "15.1 By 2020, ensure the conservation, restoration and sustainable use of terrestrial and inland freshwater ecosystems and their services, in particular forests, wetlands, mountains and drylands, in line with obligations under international agreements",
                      title_es: "15.1",
                      description_es: "15.1 Para 2020, velar por la conservación, el restablecimiento y el uso sostenible de los ecosistemas terrestres y los ecosistemas interiores de agua dulce y los servicios que proporcionan, en particular los bosques, los humedales, las montañas y las zonas áridas, en consonancia con las obligaciones contraídas en virtud de acuerdos internacionales",
                      goal: goal)

  SDG::Target.create!(title_en: "15.2",
                      description_en: "15.2 By 2020, promote the implementation of sustainable management of all types of forests, halt deforestation, restore degraded forests and substantially increase afforestation and reforestation globally",
                      title_es: "15.2",
                      description_es: "15.2 Para 2020, promover la gestión sostenible de todos los tipos de bosques, poner fin a la deforestación, recuperar los bosques degradados e incrementar la forestación y la reforestación a nivel mundial",
                      goal: goal)

  SDG::Target.create!(title_en: "15.3",
                      description_en: "15.3 By 2030, combat desertification, restore degraded land and soil, including land affected by desertification, drought and floods, and strive to achieve a land degradation-neutral world",
                      title_es: "15.3",
                      description_es: "15.3 Para 2030, luchar contra la desertificación, rehabilitar las tierras y los suelos degradados, incluidas las tierras afectadas por la desertificación, la sequía y las inundaciones, y procurar lograr un mundo con una degradación neutra del suelo",
                      goal: goal)

  SDG::Target.create!(title_en: "15.4",
                      description_en: "15.4 By 2030, ensure the conservation of mountain ecosystems, including their biodiversity, in order to enhance their capacity to provide benefits that are essential for sustainable development",
                      title_es: "15.4",
                      description_es: "15.4 Para 2030, velar por la conservación de los ecosistemas montañosos, incluida su diversidad biológica, a fin de mejorar su capacidad de proporcionar beneficios esenciales para el desarrollo sostenible",
                      goal: goal)

  SDG::Target.create!(title_en: "15.5",
                      description_en: "15.5 Take urgent and significant action to reduce the degradation of natural habitats, halt the loss of biodiversity and, by 2020, protect and prevent the extinction of threatened species",
                      title_es: "15.5",
                      description_es: "15.5 Adoptar medidas urgentes y significativas para reducir la degradación de los hábitats naturales, detener la pérdida de la diversidad biológica y, para 2020, proteger las especies amenazadas y evitar su extinción",
                      goal: goal)

  SDG::Target.create!(title_en: "15.6",
                      description_en: "15.6 Promote fair and equitable sharing of the benefits arising from the utilization of genetic resources and promote appropriate access to such resources, as internationally agreed",
                      title_es: "15.6",
                      description_es: "15.6 Promover la participación justa y equitativa en los beneficios que se deriven de la utilización de los recursos genéticos y promover el acceso adecuado a esos recursos, como se ha convenido internacionalmente",
                      goal: goal)

  SDG::Target.create!(title_en: "15.7",
                      description_en: "15.7 Take urgent action to end poaching and trafficking of protected species of flora and fauna and address both demand and supply of illegal wildlife products",
                      title_es: "15.7",
                      description_es: "15.7 Adoptar medidas urgentes para poner fin a la caza furtiva y el tráfico de especies protegidas de flora y fauna y abordar la demanda y la oferta ilegales de productos silvestres",
                      goal: goal)

  SDG::Target.create!(title_en: "15.8",
                      description_en: "15.8 By 2020, introduce measures to prevent the introduction and significantly reduce the impact of invasive alien species on land and water ecosystems and control or eradicate the priority species",
                      title_es: "15.8",
                      description_es: "15.8 Para 2020, adoptar medidas para prevenir la introducción de especies exóticas invasoras y reducir de forma significativa sus efectos en los ecosistemas terrestres y acuáticos y controlar o erradicar las especies prioritarias",
                      goal: goal)

  SDG::Target.create!(title_en: "15.9",
                      description_en: "15.9 By 2020, integrate ecosystem and biodiversity values into national and local planning, development processes, poverty reduction strategies and accounts",
                      title_es: "15.9",
                      description_es: "15.9 Para 2020, integrar los valores de los ecosistemas y la diversidad biológica en la planificación nacional y local, los procesos de desarrollo, las estrategias de reducción de la pobreza y la contabilidad",
                      goal: goal)

  SDG::Target.create!(title_en: "15.A",
                      description_en: "15.A Mobilize and significantly increase financial resources from all sources to conserve and sustainably use biodiversity and ecosystems",
                      title_es: "15.a",
                      description_es: "15.a Movilizar y aumentar de manera significativa los recursos financieros procedentes de todas las fuentes para conservar y utilizar de forma sostenible la diversidad biológica y los ecosistemas",
                      goal: goal)

  SDG::Target.create!(title_en: "15.B",
                      description_en: "15.B Mobilize significant resources from all sources and at all levels to finance sustainable forest management and provide adequate incentives to developing countries to advance such management, including for conservation and reforestation",
                      title_es: "15.b",
                      description_es: "15.b Movilizar un volumen apreciable de recursos procedentes de todas las fuentes y a todos los niveles para financiar la gestión forestal sostenible y proporcionar incentivos adecuados a los países en desarrollo para que promuevan dicha gestión, en particular con miras a la conservación y la reforestación",
                      goal: goal)

  SDG::Target.create!(title_en: "15.C",
                      description_en: "15.C Enhance global support for efforts to combat poaching and trafficking of protected species, including by increasing the capacity of local communities to pursue sustainable livelihood opportunities",
                      title_es: "15.c",
                      description_es: "15.c Aumentar el apoyo mundial a la lucha contra la caza furtiva y el tráfico de especies protegidas, en particular aumentando la capacidad de las comunidades locales para promover oportunidades de subsistencia sostenibles",
                      goal: goal)
end
