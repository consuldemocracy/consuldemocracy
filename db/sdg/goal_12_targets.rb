goal = SDG::Goal.find(12)
if goal && SDG::Target.find_by(goal_id: goal.id).none?
  SDG::Target.create!(title_en: "12.1",
                      description_en: "12.1 Implement the 10-year framework of programmes on sustainable consumption and production, all countries taking action, with developed countries taking the lead, taking into account the development and capabilities of developing countries",
                      title_es: "12.1",
                      description_es: "12.1 Aplicar el Marco Decenal de Programas sobre Modalidades de Consumo y Producción Sostenibles, con la participación de todos los países y bajo el liderazgo de los países desarrollados, teniendo en cuenta el grado de desarrollo y las capacidades de los países en desarrollo",
                      goal: goal)

  SDG::Target.create!(title_en: "12.2",
                      description_en: "12.2 By 2030, achieve the sustainable management and efficient use of natural resources",
                      title_es: "12.2",
                      description_es: "12.2 De aquí a 2030, lograr la gestión sostenible y el uso eficiente de los recursos naturales",
                      goal: goal)

  SDG::Target.create!(title_en: "12.3",
                      description_en: "12.3 By 2030, halve per capita global food waste at the retail and consumer levels and reduce food losses along production and supply chains, including post-harvest losses",
                      title_es: "12.3",
                      description_es: "12.3 De aquí a 2030, reducir a la mitad el desperdicio de alimentos per capita mundial en la venta al por menor y a nivel de los consumidores y reducir las pérdidas de alimentos en las cadenas de producción y suministro, incluidas las pérdidas posteriores a la cosecha",
                      goal: goal)

  SDG::Target.create!(title_en: "12.4",
                      description_en: "12.4 By 2020, achieve the environmentally sound management of chemicals and all wastes throughout their life cycle, in accordance with agreed international frameworks, and significantly reduce their release to air, water and soil in order to minimize their adverse impacts on human health and the environment",
                      title_es: "12.4",
                      description_es: "12.4 De aquí a 2020, lograr la gestión ecológicamente racional de los productos químicos y de todos los desechos a lo largo de su ciclo de vida, de conformidad con los marcos internacionales convenidos, y reducir significativamente su liberación a la atmósfera, el agua y el suelo a fin de minimizar sus efectos adversos en la salud humana y el medio ambiente",
                      goal: goal)

  SDG::Target.create!(title_en: "12.5",
                      description_en: "12.5 By 2030, substantially reduce waste generation through prevention, reduction, recycling and reuse",
                      title_es: "12.5",
                      description_es: "12.5 De aquí a 2030, reducir considerablemente la generación de desechos mediante actividades de prevención, reducción, reciclado y reutilización",
                      goal: goal)

  SDG::Target.create!(title_en: "12.6",
                      description_en: "12.6 Encourage companies, especially large and transnational companies, to adopt sustainable practices and to integrate sustainability information into their reporting cycle",
                      title_es: "12.6",
                      description_es: "12.6 Alentar a las empresas, en especial las grandes empresas y las empresas transnacionales, a que adopten prácticas sostenibles e incorporen información sobre la sostenibilidad en su ciclo de presentación de informes",
                      goal: goal)

  SDG::Target.create!(title_en: "12.7",
                      description_en: "12.7 Promote public procurement practices that are sustainable, in accordance with national policies and priorities",
                      title_es: "12.7",
                      description_es: "12.7 Promover prácticas de adquisición pública que sean sostenibles, de conformidad con las políticas y prioridades nacionales",
                      goal: goal)

  SDG::Target.create!(title_en: "12.8",
                      description_en: "12.8 By 2030, ensure that people everywhere have the relevant information and awareness for sustainable development and lifestyles in harmony with nature",
                      title_es: "12.8",
                      description_es: "12.8 De aquí a 2030, asegurar que las personas de todo el mundo tengan la información y los conocimientos pertinentes para el desarrollo sostenible y los estilos de vida en armonía con la naturaleza",
                      goal: goal)

  SDG::Target.create!(title_en: "12.A",
                      description_en: "12.A Support developing countries to strengthen their scientific and technological capacity to move towards more sustainable patterns of consumption and production",
                      title_es: "12.a",
                      description_es: "12.a Ayudar a los países en desarrollo a fortalecer su capacidad científica y tecnológica para avanzar hacia modalidades de consumo y producción más sostenibles",
                      goal: goal)

  SDG::Target.create!(title_en: "12.B",
                      description_en: "12.B Develop and implement tools to monitor sustainable development impacts for sustainable tourism that creates jobs and promotes local culture and products",
                      title_es: "12.b",
                      description_es: "12.b Elaborar y aplicar instrumentos para vigilar los efectos en el desarrollo sostenible, a fin de lograr un turismo sostenible que cree puestos de trabajo y promueva la cultura y los productos locales",
                      goal: goal)

  SDG::Target.create!(title_en: "12.C",
                      description_en: "12.C Rationalize inefficient fossil-fuel subsidies that encourage wasteful consumption by removing market distortions, in accordance with national circumstances, including by restructuring taxation and phasing out those harmful subsidies, where they exist, to reflect their environmental impacts, taking fully into account the specific needs and conditions of developing countries and minimizing the possible adverse impacts on their development in a manner that protects the poor and the affected communities",
                      title_es: "12.c",
                      description_es: "12.c Racionalizar los subsidios ineficientes a los combustibles fósiles que fomentan el consumo antieconómico eliminando las distorsiones del mercado, de acuerdo con las circunstancias nacionales, incluso mediante la reestructuración de los sistemas tributarios y la eliminación gradual de los subsidios perjudiciales, cuando existan, para reflejar su impacto ambiental, teniendo plenamente en cuenta las necesidades y condiciones específicas de los países en desarrollo y minimizando los posibles efectos adversos en su desarrollo, de manera que se proteja a los pobres y a las comunidades afectadas",
                      goal: goal)
end
