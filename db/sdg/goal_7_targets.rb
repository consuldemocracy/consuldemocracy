goal = SDG::Goal.find(7)
if goal && SDG::Target.find_by(goal_id: goal.id).none?
  SDG::Target.create!(title_en: "7.1",
                      description_en: "7.1 By 2030, ensure universal access to affordable, reliable and modern energy services",
                      title_es: "7.1",
                      description_es: "7.1 De aquí a 2030, garantizar el acceso universal a servicios energéticos asequibles, fiables y modernos",
                      goal: goal)

  SDG::Target.create!(title_en: "7.2",
                      description_en: "7.2 By 2030, increase substantially the share of renewable energy in the global energy mix",
                      title_es: "7.2",
                      description_es: "7.2 De aquí a 2030, aumentar considerablemente la proporción de energía renovable en el conjunto de fuentes energéticas",
                      goal: goal)

  SDG::Target.create!(title_en: "7.3",
                      description_en: "7.3 By 2030, double the global rate of improvement in energy efficiency",
                      title_es: "7.3",
                      description_es: "7.3 De aquí a 2030, duplicar la tasa mundial de mejora de la eficiencia energética",
                      goal: goal)

  SDG::Target.create!(title_en: "7.A",
                      description_en: "7.A By 2030, enhance international cooperation to facilitate access to clean energy research and technology, including renewable energy, energy efficiency and advanced and cleaner fossil-fuel technology, and promote investment in energy infrastructure and clean energy technology",
                      title_es: "7.a",
                      description_es: "7.a De aquí a 2030, aumentar la cooperación internacional para facilitar el acceso a la investigación y la tecnología relativas a la energía limpia, incluidas las fuentes renovables, la eficiencia energética y las tecnologías avanzadas y menos contaminantes de combustibles fósiles, y promover la inversión en infraestructura energética y tecnologías limpias",
                      goal: goal)

  SDG::Target.create!(title_en: "7.B",
                      description_en: "7.B By 2030, expand infrastructure and upgrade technology for supplying modern and sustainable energy services for all in developing countries, in particular least developed countries, small island developing States, and land-locked developing countries, in accordance with their respective programmes of support",
                      title_es: "7.b",
                      description_es: "7.b De aquí a 2030, ampliar la infraestructura y mejorar la tecnología para prestar servicios energéticos modernos y sostenibles para todos en los países en desarrollo, en particular los países menos adelantados, los pequeños Estados insulares en desarrollo y los países en desarrollo sin litoral, en consonancia con sus respectivos programas de apoyo",
                      goal: goal)
end
