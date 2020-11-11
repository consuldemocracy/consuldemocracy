goal = SDG::Goal.find(8)
if goal && SDG::Target.find_by(goal_id: goal.id).none?
  SDG::Target.create!(title_en: "8.1",
                      description_en: "Sustain per capita economic growth in accordance with national circumstances and, in particular, at least 7 per cent gross domestic product growth per annum in the least developed countries",
                      title_es: "8.1",
                      description_es: "8.1 Mantener el crecimiento económico per capita de conformidad con las circunstancias nacionales y, en particular, un crecimiento del producto interno bruto de al menos el 7% anual en los países menos adelantados",
                      goal: goal)

  SDG::Target.create!(title_en: "8.2",
                      description_en: "Achieve higher levels of economic productivity through diversification, technological upgrading and innovation, including through a focus on high-value added and labour-intensive sectors",
                      title_es: "8.2",
                      description_es: "8.2 Lograr niveles más elevados de productividad económica mediante la diversificación, la modernización tecnológica y la innovación, entre otras cosas centrándose en los sectores con gran valor añadido y un uso intensivo de la mano de obra",
                      goal: goal)

  SDG::Target.create!(title_en: "8.3",
                      description_en: "Promote development-oriented policies that support productive activities, decent job creation, entrepreneurship, creativity and innovation, and encourage the formalization and growth of micro-, small- and medium-sized enterprises, including through access to financial services",
                      title_es: "8.3",
                      description_es: "8.3 Promover políticas orientadas al desarrollo que apoyen las actividades productivas, la creación de puestos de trabajo decentes, el emprendimiento, la creatividad y la innovación, y fomentar la formalización y el crecimiento de las microempresas y las pequeñas y medianas empresas, incluso mediante el acceso a servicios financieros",
                      goal: goal)

  SDG::Target.create!(title_en: "8.4",
                      description_en: "Improve progressively, through 2030, global resource efficiency in consumption and production and endeavour to decouple economic growth from environmental degradation, in accordance with the 10-year framework of programmes on sustainable consumption and production, with developed countries taking the lead",
                      title_es: "8.4",
                      description_es: "8.4 Mejorar progresivamente, de aquí a 2030, la producción y el consumo eficientes de los recursos mundiales y procurar desvincular el crecimiento económico de la degradación del medio ambiente, conforme al Marco Decenal de Programas sobre modalidades de Consumo y Producción Sostenibles, empezando por los países desarrollados",
                      goal: goal)

  SDG::Target.create!(title_en: "8.5",
                      description_en: "By 2030, achieve full and productive employment and decent work for all women and men, including for young people and persons with disabilities, and equal pay for work of equal value",
                      title_es: "8.5",
                      description_es: "8.5 De aquí a 2030, lograr el empleo pleno y productivo y el trabajo decente para todas las mujeres y los hombres, incluidos los jóvenes y las personas con discapacidad, así como la igualdad de remuneración por trabajo de igual valor",
                      goal: goal)

  SDG::Target.create!(title_en: "8.6",
                      description_en: "By 2020, substantially reduce the proportion of youth not in employment, education or training",
                      title_es: "8.6",
                      description_es: "8.6 De aquí a 2020, reducir considerablemente la proporción de jóvenes que no están empleados y no cursan estudios ni reciben capacitación",
                      goal: goal)

  SDG::Target.create!(title_en: "8.7",
                      description_en: "Take immediate and effective measures to eradicate forced labour, end modern slavery and human trafficking and secure the prohibition and elimination of the worst forms of child labour, including recruitment and use of child soldiers, and by 2025 end child labour in all its forms",
                      title_es: "8.7",
                      description_es: "8.7 Adoptar medidas inmediatas y eficaces para erradicar el trabajo forzoso, poner fin a las formas contemporáneas de esclavitud y la trata de personas y asegurar la prohibición y eliminación de las peores formas de trabajo infantil, incluidos el reclutamiento y la utilización de niños soldados, y, de aquí a 2025, poner fin al trabajo infantil en todas sus formas",
                      goal: goal)

  SDG::Target.create!(title_en: "8.8",
                      description_en: "Protect labour rights and promote safe and secure working environments for all workers, including migrant workers, in particular women migrants, and those in precarious employment",
                      title_es: "8.8",
                      description_es: "8.8 Proteger los derechos laborales y promover un entorno de trabajo seguro y sin riesgos para todos los trabajadores, incluidos los trabajadores migrantes, en particular las mujeres migrantes y las personas con empleos precarios",
                      goal: goal)

  SDG::Target.create!(title_en: "8.9",
                      description_en: "By 2030, devise and implement policies to promote sustainable tourism that creates jobs and promotes local culture and products",
                      title_es: "8.9",
                      description_es: "8.9 De aquí a 2030, elaborar y poner en práctica políticas encaminadas a promover un turismo sostenible que cree puestos de trabajo y promueva la cultura y los productos locales",
                      goal: goal)

  SDG::Target.create!(title_en: "8.10",
                      description_en: "Strengthen the capacity of domestic financial institutions to encourage and expand access to banking, insurance and financial services for all",
                      title_es: "8.10",
                      description_es: "8.10 Fortalecer la capacidad de las instituciones financieras nacionales para fomentar y ampliar el acceso a los servicios bancarios, financieros y de seguros para todos",
                      goal: goal)

  SDG::Target.create!(title_en: "8.A",
                      description_en: "Increase Aid for Trade support for developing countries, in particular least developed countries, including through the Enhanced Integrated Framework for Trade-Related Technical Assistance to Least Developed Countries",
                      title_es: "8.a",
                      description_es: "8.a Aumentar el apoyo a la iniciativa de ayuda para el comercio en los países en desarrollo, en particular los países menos adelantados, incluso mediante el Marco Integrado Mejorado para la Asistencia Técnica a los Países Menos Adelantados en Materia de Comercio",
                      goal: goal)

  SDG::Target.create!(title_en: "8.B",
                      description_en: "By 2020, develop and operationalize a global strategy for youth employment and implement the Global Jobs Pact of the International Labour Organization",
                      title_es: "8.b",
                      description_es: "8.b De aquí a 2020, desarrollar y poner en marcha una estrategia mundial para el empleo de los jóvenes y aplicar el Pacto Mundial para el Empleo de la Organización Internacional del Trabajo",
                      goal: goal)
end
