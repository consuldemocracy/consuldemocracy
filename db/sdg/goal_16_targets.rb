goal = SDG::Goal.find(16)
if goal && SDG::Target.find_by(goal_id: goal.id).none?
  SDG::Target.create!(title_en: "16.1",
                      description_en: "16.1 Significantly reduce all forms of violence and related death rates everywhere",
                      title_es: "16.1",
                      description_es: "16.1 Reducir significativamente todas las formas de violencia y las correspondientes tasas de mortalidad en todo el mundo",
                      goal: goal)

  SDG::Target.create!(title_en: "16.2",
                      description_en: "16.2 End abuse, exploitation, trafficking and all forms of violence against and torture of children",
                      title_es: "16.2",
                      description_es: "16.2 Poner fin al maltrato, la explotación, la trata y todas las formas de violencia y tortura contra los niños",
                      goal: goal)

  SDG::Target.create!(title_en: "16.3",
                      description_en: "16.3 Promote the rule of law at the national and international levels and ensure equal access to justice for all",
                      title_es: "16.3",
                      description_es: "16.3 Promover el estado de derecho en los planos nacional e internacional y garantizar la igualdad de acceso a la justicia para todos",
                      goal: goal)

  SDG::Target.create!(title_en: "16.4",
                      description_en: "16.4 By 2030, significantly reduce illicit financial and arms flows, strengthen the recovery and return of stolen assets and combat all forms of organized crime",
                      title_es: "16.4",
                      description_es: "16.4 De aquí a 2030, reducir significativamente las corrientes financieras y de armas ilícitas, fortalecer la recuperación y devolución de los activos robados y luchar contra todas las formas de delincuencia organizada",
                      goal: goal)

  SDG::Target.create!(title_en: "16.5",
                      description_en: "16.5 Substantially reduce corruption and bribery in all their forms",
                      title_es: "16.5",
                      description_es: "16.5 Reducir considerablemente la corrupción y el soborno en todas sus formas",
                      goal: goal)

  SDG::Target.create!(title_en: "16.6",
                      description_en: "16.6 Develop effective, accountable and transparent institutions at all levels",
                      title_es: "16.6",
                      description_es: "16.6 Crear a todos los niveles instituciones eficaces y transparentes que rindan cuentas",
                      goal: goal)

  SDG::Target.create!(title_en: "16.7",
                      description_en: "16.7 Ensure responsive, inclusive, participatory and representative decision-making at all levels",
                      title_es: "16.7",
                      description_es: "16.7 Garantizar la adopción en todos los niveles de decisiones inclusivas, participativas y representativas que respondan a las necesidades",
                      goal: goal)

  SDG::Target.create!(title_en: "16.8",
                      description_en: "16.8 Broaden and strengthen the participation of developing countries in the institutions of global governance",
                      title_es: "16.8",
                      description_es: "16.8 Ampliar y fortalecer la participación de los países en desarrollo en las instituciones de gobernanza mundial",
                      goal: goal)

  SDG::Target.create!(title_en: "16.9",
                      description_en: "16.9 By 2030, provide legal identity for all, including birth registration",
                      title_es: "16.9",
                      description_es: "16.9 De aquí a 2030, proporcionar acceso a una identidad jurídica para todos, en particular mediante el registro de nacimientos",
                      goal: goal)

  SDG::Target.create!(title_en: "16.10",
                      description_en: "16.10 Ensure public access to information and protect fundamental freedoms, in accordance with national legislation and international agreements",
                      title_es: "16.10",
                      description_es: "16.10 Garantizar el acceso público a la información y proteger las libertades fundamentales, de conformidad con las leyes nacionales y los acuerdos internacionales",
                      goal: goal)

  SDG::Target.create!(title_en: "16.A",
                      description_en: "16.A Strengthen relevant national institutions, including through international cooperation, for building capacity at all levels, in particular in developing countries, to prevent violence and combat terrorism and crime",
                      title_es: "16.a",
                      description_es: "16.a Fortalecer las instituciones nacionales pertinentes, incluso mediante la cooperación internacional, para crear a todos los niveles, particularmente en los países en desarrollo, la capacidad de prevenir la violencia y combatir el terrorismo y la delincuencia",
                      goal: goal)

  SDG::Target.create!(title_en: "16.B",
                      description_en: "16.B Promote and enforce non-discriminatory laws and policies for sustainable development",
                      title_es: "16.b",
                      description_es: "16.b Promover y aplicar leyes y políticas no discriminatorias en favor del desarrollo sostenible",
                      goal: goal)
end
