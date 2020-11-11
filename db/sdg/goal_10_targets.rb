goal = goal
if goal && SDG::Target.find_by(goal_id: goal.id).none?
  SDG::Target.create!(title_en: "10.1",
                      description_en: "10.1 By 2030, progressively achieve and sustain income growth of the bottom 40 per cent of the population at a rate higher than the national average",
                      title_es: "10.1",
                      description_es: "10.1 De aquí a 2030, lograr progresivamente y mantener el crecimiento de los ingresos del 40% más pobre de la población a una tasa superior a la media nacional",
                      goal: goal)

  SDG::Target.create!(title_en: "10.2",
                      description_en: "10.2 By 2030, empower and promote the social, economic and political inclusion of all, irrespective of age, sex, disability, race, ethnicity, origin, religion or economic or other status",
                      title_es: "10.2",
                      description_es: "10.2 De aquí a 2030, potenciar y promover la inclusión social, económica y política de todas las personas, independientemente de su edad, sexo, discapacidad, raza, etnia, origen, religión o situación económica u otra condición",
                      goal: goal)

  SDG::Target.create!(title_en: "10.3",
                      description_en: "10.3 Ensure equal opportunity and reduce inequalities of outcome, including by eliminating discriminatory laws, policies and practices and promoting appropriate legislation, policies and action in this regard",
                      title_es: "10.3",
                      description_es: "10.3 Garantizar la igualdad de oportunidades y reducir la desigualdad de resultados, incluso eliminando las leyes, políticas y prácticas discriminatorias y promoviendo legislaciones, políticas y medidas adecuadas a ese respecto",
                      goal: goal)

  SDG::Target.create!(title_en: "10.4",
                      description_en: "10.4 Adopt policies, especially fiscal, wage and social protection policies, and progressively achieve greater equality",
                      title_es: "10.4",
                      description_es: "10.4 Adoptar políticas, especialmente fiscales, salariales y de protección social, y lograr progresivamente una mayor igualdad",
                      goal: goal)

  SDG::Target.create!(title_en: "10.5",
                      description_en: "10.5 Improve the regulation and monitoring of global financial markets and institutions and strengthen the implementation of such regulations",
                      title_es: "10.5",
                      description_es: "10.5 Mejorar la reglamentación y vigilancia de las instituciones y los mercados financieros mundiales y fortalecer la aplicación de esos reglamentos",
                      goal: goal)

  SDG::Target.create!(title_en: "10.6",
                      description_en: "10.6 Ensure enhanced representation and voice for developing countries in decision-making in global international economic and financial institutions in order to deliver more effective, credible, accountable and legitimate institutions",
                      title_es: "10.6",
                      description_es: "10.6 Asegurar una mayor representación e intervención de los países en desarrollo en las decisiones adoptadas por las instituciones económicas y financieras internacionales para aumentar la eficacia, fiabilidad, rendición de cuentas y legitimidad de esas instituciones",
                      goal: goal)

  SDG::Target.create!(title_en: "10.7",
                      description_en: "10.7 Facilitate orderly, safe, regular and responsible migration and mobility of people, including through the implementation of planned and well-managed migration policies",
                      title_es: "10.7",
                      description_es: "10.7 Facilitar la migración y la movilidad ordenadas, seguras, regulares y responsables de las personas, incluso mediante la aplicación de políticas migratorias planificadas y bien gestionadas",
                      goal: goal)

  SDG::Target.create!(title_en: "10.A",
                      description_en: "10.A Implement the principle of special and differential treatment for developing countries, in particular least developed countries, in accordance with World Trade Organization agreements",
                      title_es: "10.a",
                      description_es: "10.a Aplicar el principio del trato especial y diferenciado para los países en desarrollo, en particular los países menos adelantados, de conformidad con los acuerdos de la Organización Mundial del Comercio",
                      goal: goal)

  SDG::Target.create!(title_en: "10.B",
                      description_en: "10.B Encourage official development assistance and financial flows, including foreign direct investment, to States where the need is greatest, in particular least developed countries, African countries, small island developing States and landlocked developing countries, in accordance with their national plans and programmes",
                      title_es: "10.b",
                      description_es: "10.b Fomentar la asistencia oficial para el desarrollo y las corrientes financieras, incluida la inversión extranjera directa, para los Estados con mayores necesidades, en particular los países menos adelantados, los países africanos, los pequeños Estados insulares en desarrollo y los países en desarrollo sin litoral, en consonancia con sus planes y programas nacionales",
                      goal: goal)

  SDG::Target.create!(title_en: "10.C",
                      description_en: "10.C By 2030, reduce to less than 3 per cent the transaction costs of migrant remittances and eliminate remittance corridors with costs higher than 5 per cent",
                      title_es: "10.c",
                      description_es: "10.c De aquí a 2030, reducir a menos del 3% los costos de transacción de las remesas de los migrantes y eliminar los corredores de remesas con un costo superior al 5%",
                      goal: goal)
end
