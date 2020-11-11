goal = SDG::Goal.find(3)
if goal && SDG::Target.find_by(goal_id: goal.id).none?
  SDG::Target.create!(title_en: "3.1",
                      description_en: "3.1 By 2030, reduce the global maternal mortality ratio to less than 70 per 100,000 live births.",
                      title_es: "3.1",
                      description_es: "3.1 Para 2030, reducir la tasa mundial de mortalidad materna a menos de 70 por cada 100.000 nacidos vivos",
                      goal: goal)

  SDG::Target.create!(title_en: "3.2",
                      description_en: "3.2 By 2030, end preventable deaths of newborns and children under 5 years of age, with all countries aiming to reduce neonatal mortality to at least as low as 12 per 1,000 live births and under-5 mortality to at least as low as 25 per 1,000 live births.",
                      title_es: "3.2",
                      description_es: "3.2 Para 2030, poner fin a las muertes evitables de recién nacidos y de niños menores de 5 años, logrando que todos los países intenten reducir la mortalidad neonatal al menos hasta 12 por cada 1.000 nacidos vivos, y la mortalidad de niños menores de 5 años al menos hasta 25 por cada 1.000 nacidos vivos",
                      goal: goal)

  SDG::Target.create!(title_en: "3.3",
                      description_en: "3.3 By 2030, end the epidemics of AIDS, tuberculosis, malaria and neglected tropical diseases and combat hepatitis, water-borne diseases and other communicable diseases.",
                      title_es: "3.3",
                      description_es: "3.3 Para 2030, poner fin a las epidemias del SIDA, la tuberculosis, la malaria y las enfermedades tropicales desatendidas y combatir la hepatitis, las enfermedades transmitidas por el agua y otras enfermedades transmisibles",
                      goal: goal)


  SDG::Target.create!(title_en: "3.4",
                      description_en: "3.4 By 2030, reduce by one third premature mortality from non-communicable diseases through prevention and treatment and promote mental health and well-being.",
                      title_es: "3.4",
                      description_es: "3.4 Para 2030, reducir en un tercio la mortalidad prematura por enfermedades no transmisibles mediante la prevención y el tratamiento y promover la salud mental y el bienestar",
                      goal: goal)

  SDG::Target.create!(title_en: "3.5",
                      description_en: "3.5 Strengthen the prevention and treatment of substance abuse, including narcotic drug abuse and harmful use of alcohol.",
                      title_es: "3.5",
                      description_es: "3.5 Fortalecer la prevención y el tratamiento del abuso de sustancias adictivas, incluido el uso indebido de estupefacientes y el consumo nocivo de alcohol",
                      goal: goal)

  SDG::Target.create!(title_en: "3.6",
                      description_en: "3.6 By 2020, halve the number of global deaths and injuries from road traffic accidents.",
                      title_es: "3.6",
                      description_es: "3.6 Para 2020, reducir a la mitad el número de muertes y lesiones causadas por accidentes de tráfico en el mundo",
                      goal: goal)

  SDG::Target.create!(title_en: "3.7",
                      description_en: "3.7 By 2030, ensure universal access to sexual and reproductive health-care services, including for family planning, information and education, and the integration of reproductive health into national strategies and programmes.",
                      title_es: "3.7",
                      description_es: "3.7 Para 2030, garantizar el acceso universal a los servicios de salud sexual y reproductiva, incluidos los de planificación de la familia, información y educación, y la integración de la salud reproductiva en las estrategias y los programas nacionales",
                      goal: goal)

  SDG::Target.create!(title_en: "3.8",
                      description_en: "3.8 Achieve universal health coverage, including financial risk protection, access to quality essential health-care services and access to safe, effective, quality and affordable essential medicines and vaccines for all.",
                      title_es: "3.8",
                      description_es: "3.8 Lograr la cobertura sanitaria universal, en particular la protección contra los riesgos financieros, el acceso a servicios de salud esenciales de calidad y el acceso a medicamentos y vacunas seguros, eficaces, asequibles y de calidad para todos",
                      goal: goal)

  SDG::Target.create!(title_en: "3.9",
                      description_en: "3.9 By 2030, substantially reduce the number of deaths and illnesses from hazardous chemicals and air, water and soil pollution and contamination.",
                      title_es: "3.9",
                      description_es: "3.9 Para 2030, reducir sustancialmente el número de muertes y enfermedades producidas por productos químicos peligrosos y la contaminación del aire, el agua y el suelo",
                      goal: goal)

  SDG::Target.create!(title_en: "3.A",
                      description_en: "3.A Strengthen the implementation of the World Health Organization Framework Convention on Tobacco Control in all countries, as appropriate.",
                      title_es: "3.a",
                      description_es: "3.a Fortalecer la aplicación del Convenio Marco de la Organización Mundial de la Salud para el Control del Tabaco en todos los países, según proceda",
                      goal: goal)

  SDG::Target.create!(title_en: "3.B",
                      description_en: "3.B Support the research and development of vaccines and medicines for the communicable and noncommunicable diseases that primarily affect developing countries, provide access to affordable essential medicines and vaccines, in accordance with the Doha Declaration on the TRIPS Agreement and Public Health, which affirms the right of developing countries to use to the full the provisions in the Agreement on Trade Related Aspects of Intellectual Property Rights regarding flexibilities to protect public health, and, in particular, provide access to medicines for all.",
                      title_es: "3.b",
                      description_es: "3.b Apoyar las actividades de investigación y desarrollo de vacunas y medicamentos para las enfermedades transmisibles y no transmisibles que afectan primordialmente a los países en desarrollo y facilitar el acceso a medicamentos y vacunas esenciales asequibles de conformidad con la Declaración de Doha relativa al Acuerdo sobre los ADPIC y la Salud Pública, en la que se afirma el derecho de los países en desarrollo a utilizar al máximo las disposiciones del Acuerdo sobre los Aspectos de los Derechos de Propiedad Intelectual Relacionados con el Comercio en lo relativo a la flexibilidad para proteger la salud pública y, en particular, proporcionar acceso a los medicamentos para todos",
                      goal: goal)

  SDG::Target.create!(title_en: "3.C",
                      description_en: "3.C Substantially increase health financing and the recruitment, development, training and retention of the health workforce in developing countries, especially in least developed countries and small island developing States.",
                      title_es: "3.c",
                      description_es: "3.c Aumentar sustancialmente la financiación de la salud y la contratación, el desarrollo, la capacitación y la retención del personal sanitario en los países en desarrollo, especialmente en los países menos adelantados y los pequeños Estados insulares en desarrollo",
                      goal: goal)

  SDG::Target.create!(title_en: "3.D",
                      description_en: "3.D Strengthen the capacity of all countries, in particular developing countries, for early warning, risk reduction and management of national and global health risks.",
                      title_es: "3.d",
                      description_es: "3.d Reforzar la capacidad de todos los países, en particular los países en desarrollo, en materia de alerta temprana, reducción de riesgos y gestión de los riesgos para la salud nacional y mundial",
                      goal: goal)
end
