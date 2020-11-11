goal = SDG::Goal.find(13)
if goal && SDG::Target.find_by(goal_id: goal.id).none?
  SDG::Target.create!(title_en: "13.1",
                      description_en: "13.1 Strengthen resilience and adaptive capacity to climate-related hazards and natural disasters in all countries",
                      title_es: "13.1",
                      description_es: "13.1 Fortalecer la resiliencia y la capacidad de adaptación a los riesgos relacionados con el clima y los desastres naturales en todos los países",
                      goal: goal)

  SDG::Target.create!(title_en: "13.2",
                      description_en: "13.2 Integrate climate change measures into national policies, strategies and planning",
                      title_es: "13.2",
                      description_es: "13.2 Incorporar medidas relativas al cambio climático en las políticas, estrategias y planes nacionales",
                      goal: goal)

  SDG::Target.create!(title_en: "13.3",
                      description_en: "13.3 Improve education, awareness-raising and human and institutional capacity on climate change mitigation, adaptation, impact reduction and early warning",
                      title_es: "13.3",
                      description_es: "13.3 Mejorar la educación, la sensibilización y la capacidad humana e institucional respecto de la mitigación del cambio climático, la adaptación a él, la reducción de sus efectos y la alerta temprana",
                      goal: goal)

  SDG::Target.create!(title_en: "13.A",
                      description_en: "13.A Implement the commitment undertaken by developed-country parties to the United Nations Framework Convention on Climate Change to a goal of mobilizing jointly $100 billion annually by 2020 from all sources to address the needs of developing countries in the context of meaningful mitigation actions and transparency on implementation and fully operationalize the Green Climate Fund through its capitalization as soon as possible",
                      title_es: "13.a",
                      description_es: "13.a Cumplir el compromiso de los países desarrollados que son partes en la Convención Marco de las Naciones Unidas sobre el Cambio Climático de lograr para el año 2020 el objetivo de movilizar conjuntamente 100.000 millones de dólares anuales procedentes de todas las fuentes a fin de atender las necesidades de los países en desarrollo respecto de la adopción de medidas concretas de mitigación y la transparencia de su aplicación, y poner en pleno funcionamiento el Fondo Verde para el Clima capitalizándolo lo antes posible",
                      goal: goal)

  SDG::Target.create!(title_en: "13.B",
                      description_en: "13.B Promote mechanisms for raising capacity for effective climate change-related planning and management in least developed countries and small island developing States, including focusing on women, youth and local and marginalized communities",
                      title_es: "13.b",
                      description_es: "13.b Promover mecanismos para aumentar la capacidad para la planificación y gestión eficaces en relación con el cambio climático en los países menos adelantados y los pequeños Estados insulares en desarrollo, haciendo particular hincapié en las mujeres, los jóvenes y las comunidades locales y marginadas",
                      goal: goal)
end
