goal = SDG::Goal.find(1)
if goal && SDG::Target.find_by(goal_id: goal.id).none?
  SDG::Target.create!(title_en: "1.1",
                      description_en: "1.1 By 2030, eradicate extreme poverty for all people everywhere, currently measured as people living on less than $1.25 a day",
                      title_es: "1.1",
                      description_es: "1.1 Para 2030, erradicar la pobreza extrema para todas las personas en el mundo, actualmente medida por un ingreso por persona inferior a 1,25 dólares al día.",
                      goal: goal)

  SDG::Target.create!(title_en: "1.2",
                      description_en: "1.2 By 2030, reduce at least by half the proportion of men, women and children of all ages living in poverty in all its dimensions according to national definitions",
                      title_es: "1.2",
                      description_es: "1.2 Para 2030, reducir al menos a la mitad la proporción de hombres, mujeres y niños y niñas de todas las edades que viven en la pobreza en todas sus dimensiones con arreglo a las definiciones nacionales.",
                      goal: goal)

  SDG::Target.create!(title_en: "1.3",
                      description_en: "1.3 Implement nationally appropriate social protection systems and measures for all, including floors, and by 2030 achieve substantial coverage of the poor and the vulnerable",
                      title_es: "1.3",
                      description_es: "1.3 Poner en práctica a nivel nacional sistemas y medidas apropiadas de protección social para todos y, para 2030, lograr una amplia cobertura de los pobres y los más vulnerables.",
                      goal: goal)

  SDG::Target.create!(title_en: "1.4",
                      description_en: "1.4 By 2030, ensure that all men and women, in particular the poor and the vulnerable, have equal rights to economic resources, as well as access to basic services, ownership and control over land and other forms of property, inheritance, natural resources, appropriate new technology and financial services, including microfinance",
                      title_es: "1.4",
                      description_es: "1.4 Para 2030, garantizar que todos los hombres y mujeres, en particular los pobres y los más vulnerables, tengan los mismos derechos a los recursos económicos, así como acceso a los servicios básicos, la propiedad y el control de las tierras y otros bienes, la herencia, los recursos naturales, las nuevas tecnologías y los servicios económicos, incluida la microfinanciación.",
                      goal: goal)

  SDG::Target.create!(title_en: "1.5",
                      description_en: "1.5 By 2030, build the resilience of the poor and those in vulnerable situations and reduce their exposure and vulnerability to climate-related extreme events and other economic, social and environmental shocks and disasters",
                      title_es: "1.5",
                      description_es: "1.5 Para 2030, fomentar la resiliencia de los pobres y las personas que se encuentran en situaciones vulnerables y reducir su exposición y vulnerabilidad a los fenómenos extremos relacionados con el clima y a otros desastres económicos, sociales y ambientales.",
                      goal: goal)

  SDG::Target.create!(title_en: "1.A",
                      description_en: "1.A Ensure significant mobilization of resources from a variety of sources, including through enhanced development cooperation, in order to provide adequate and predictable means for developing countries, in particular least developed countries, to implement programmes and policies to end poverty in all its dimensions",
                      title_es: "1.a",
                      description_es: "1.a Garantizar una movilización importante de recursos procedentes de diversas fuentes, incluso mediante la mejora de la cooperación para el desarrollo, a fin de proporcionar medios suficientes y previsibles para los países en desarrollo, en particular los países menos adelantados, para poner en práctica programas y políticas encaminados a poner fin a la pobreza en todas sus dimensiones.",
                      goal: goal)

  SDG::Target.create!(title_en: "1.B",
                      description_en: "1.B Create sound policy frameworks at the national, regional and international levels, based on pro-poor and gender-sensitive development strategies, to support accelerated investment in poverty eradication actions",
                      title_es: "1.b",
                      description_es: "1.b Crear marcos normativos sólidos en el ámbito nacional, regional e internacional, sobre la base de estrategias de desarrollo en favor de los pobres que tengan en cuenta las cuestiones de género, a fin de apoyar la inversión acelerada en medidas para erradicar la pobreza.",
                      goal: goal)
end
