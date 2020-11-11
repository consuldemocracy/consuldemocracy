goal = SDG::Goal.find(4)
if goal && SDG::Target.find_by(goal_id: goal.id).none?
  SDG::Target.create!(title_en: "4.1",
                      description_en: "4.1 By 2030, ensure that all girls and boys complete free, equitable and quality primary and secondary education leading to relevant and Goal-4 effective learning outcomes",
                      title_es: "4.1",
                      description_es: "4.1 De aquí a 2030, asegurar que todas las niñas y todos los niños terminen la enseñanza primaria y secundaria, que ha de ser gratuita, equitativa y de calidad y producir resultados de aprendizaje pertinentes y efectivos",
                      goal: goal)


  SDG::Target.create!(title_en: "4.2",
                      description_en: "4.2 By 2030, ensure that all girls and boys have access to quality early childhood development, care and preprimary education so that they are ready for primary education",
                      title_es: "4.2",
                      description_es: "4.2 De aquí a 2030, asegurar que todas las niñas y todos los niños tengan acceso a servicios de atención y desarrollo en la primera infancia y educación preescolar de calidad, a fin de que estén preparados para la enseñanza primaria",
                      goal: goal)

  SDG::Target.create!(title_en: "4.3",
                      description_en: "4.3 By 2030, ensure equal access for all women and men to affordable and quality technical, vocational and tertiary education, including university",
                      title_es: "4.3",
                      description_es: "4.3 De aquí a 2030, asegurar el acceso igualitario de todos los hombres y las mujeres a una formación técnica, profesional y superior de calidad, incluida la enseñanza universitaria",
                      goal: goal)

  SDG::Target.create!(title_en: "4.4",
                      description_en: "4.4 By 2030, substantially increase the number of youth and adults who have relevant skills, including technical and vocational skills, for employment, decent jobs and entrepreneurship",
                      title_es: "4.4",
                      description_es: "4.4 De aquí a 2030, aumentar considerablemente el número de jóvenes y adultos que tienen las competencias necesarias, en particular técnicas y profesionales, para acceder al empleo, el trabajo decente y el emprendimiento",
                      goal: goal)

  SDG::Target.create!(title_en: "4.5",
                      description_en: "4.5 By 2030, eliminate gender disparities in education and ensure equal access to all levels of education and vocational training for the vulnerable, including persons with disabilities, indigenous peoples and children in vulnerable situations",
                      title_es: "4.5",
                      description_es: "4.5 De aquí a 2030, eliminar las disparidades de género en la educación y asegurar el acceso igualitario a todos los niveles de la enseñanza y la formación profesional para las personas vulnerables, incluidas las personas con discapacidad, los pueblos indígenas y los niños en situaciones de vulnerabilidad",
                      goal: goal)

  SDG::Target.create!(title_en: "4.6",
                      description_en: "4.6 By 2030, ensure that all youth and a substantial proportion of adults, both men and women, achieve literacy and numeracy",
                      title_es: "4.6",
                      description_es: "4.6 De aquí a 2030, asegurar que todos los jóvenes y una proporción considerable de los adultos, tanto hombres como mujeres, estén alfabetizados y tengan nociones elementales de aritmética",
                      goal: goal)

  SDG::Target.create!(title_en: "4.7",
                      description_en: "4.7 By 2030, ensure that all learners acquire the knowledge and skills needed to promote sustainable development, including, among others, through education for sustainable development and sustainable lifestyles, human rights, gender equality, promotion of a culture of peace and non-violence, global citizenship and appreciation of cultural diversity and of culture’s contribution to sustainable development",
                      title_es: "4.7",
                      description_es: "4.7 De aquí a 2030, asegurar que todos los alumnos adquieran los conocimientos teóricos y prácticos necesarios para promover el desarrollo sostenible, entre otras cosas mediante la educación para el desarrollo sostenible y los estilos de vida sostenibles, los derechos humanos, la igualdad de género, la promoción de una cultura de paz y no violencia, la ciudadanía mundial y la valoración de la diversidad cultural y la contribución de la cultura al desarrollo sostenible",
                      goal: goal)

  SDG::Target.create!(title_en: "4.A",
                      description_en: "4.A Build and upgrade education facilities that are child, disability and gender sensitive and provide safe, nonviolent, inclusive and effective learning environments for all",
                      title_es: "4.a",
                      description_es: "4.a Construir y adecuar instalaciones educativas que tengan en cuenta las necesidades de los niños y las personas con discapacidad y las diferencias de género, y que ofrezcan entornos de aprendizaje seguros, no violentos, inclusivos y eficaces para todos",
                      goal: goal)

  SDG::Target.create!(title_en: "4.B",
                      description_en: "4.B By 2020, substantially expand globally the number of scholarships available to developing countries, in particular least developed countries, small island developing States and African countries, for enrolment in higher education, including vocational training and information and communications technology, technical, engineering and scientific programmes, in developed countries and other developing countries",
                      title_es: "4.b",
                      description_es: "4.b De aquí a 2020, aumentar considerablemente a nivel mundial el número de becas disponibles para los países en desarrollo, en particular los países menos adelantados, los pequeños Estados insulares en desarrollo y los países africanos, a fin de que sus estudiantes puedan matricularse en programas de enseñanza superior, incluidos programas de formación profesional y programas técnicos, científicos, de ingeniería y de tecnología de la información y las comunicaciones, de países desarrollados y otros países en desarrollo",
                      goal: goal)

  SDG::Target.create!(title_en: "4.C",
                      description_en: "4.C By 2030, substantially increase the supply of qualified teachers, including through international cooperation for teacher training in developing countries, especially least developed countries and small island developing states",
                      title_es: "4.c",
                      description_es: "4.c De aquí a 2030, aumentar considerablemente la oferta de docentes calificados, incluso mediante la cooperación internacional para la formación de docentes en los países en desarrollo, especialmente los países menos adelantados y los pequeños Estados insulares en desarrollo",
                      goal: goal)
end
