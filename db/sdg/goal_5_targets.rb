goal = SDG::Goal.find(5)
if goal && SDG::Target.find_by(goal_id: goal.id).none?
  SDG::Target.create!(title_en: "5.1",
                      description_en: "5.1 End all forms of discrimination against all women and girls everywhere",
                      title_es: "5.1",
                      description_es: "5.1 Poner fin a todas las formas de discriminación contra todas las mujeres y las niñas en todo el mundo",
                      goal: goal)

  SDG::Target.create!(title_en: "5.2",
                      description_en: "5.2 Eliminate all forms of violence against all women and girls in the public and private spheres, including trafficking and sexual and other types of exploitation",
                      title_es: "5.2",
                      description_es: "5.2 Eliminar todas las formas de violencia contra todas las mujeres y las niñas en los ámbitos público y privado, incluidas la trata y la explotación sexual y otros tipos de explotación",
                      goal: goal)

  SDG::Target.create!(title_en: "5.3",
                      description_en: "5.3 Eliminate all harmful practices, such as child, early and forced marriage and female genital mutilation",
                      title_es: "5.3",
                      description_es: "5.3 Eliminar todas las prácticas nocivas, como el matrimonio infantil, precoz y forzado y la mutilación genital femenina",
                      goal: goal)

  SDG::Target.create!(title_en: "5.4",
                      description_en: "5.4 Recognize and value unpaid care and domestic work through the provision of public services, infrastructure and social protection policies and the promotion of shared responsibility within the household and the family as nationally appropriate",
                      title_es: "5.4",
                      description_es: "5.4 Reconocer y valorar los cuidados y el trabajo doméstico no remunerados mediante servicios públicos, infraestructuras y políticas de protección social, y promoviendo la responsabilidad compartida en el hogar y la familia, según proceda en cada país",
                      goal: goal)

  SDG::Target.create!(title_en: "5.5",
                      description_en: "5.5 Ensure women’s full and effective participation and equal opportunities for leadership at all levels of decisionmaking in political, economic and public life",
                      title_es: "5.5",
                      description_es: "5.5 Asegurar la participación plena y efectiva de las mujeres y la igualdad de oportunidades de liderazgo a todos los niveles decisorios en la vida política, económica y pública",
                      goal: goal)

  SDG::Target.create!(title_en: "5.6",
                      description_en: "5.6 Ensure universal access to sexual and reproductive health and reproductive rights as agreed in accordance with the Programme of Action of the International Conference on Population and Development and the Beijing Platform for Action and the outcome documents of their review conferences",
                      title_es: "5.6",
                      description_es: "5.6 Asegurar el acceso universal a la salud sexual y reproductiva y los derechos reproductivos según lo acordado de conformidad con el Programa de Acción de la Conferencia Internacional sobre la Población y el Desarrollo, la Plataforma de Acción de Beijing y los documentos finales de sus conferencias de examen",
                      goal: goal)

  SDG::Target.create!(title_en: "5.A",
                      description_en: "5.A Undertake reforms to give women equal rights to economic resources, as well as access to ownership and control over land and other forms of property, financial services, inheritance and natural resources, in accordance with national laws",
                      title_es: "5.a",
                      description_es: "5.a Emprender reformas que otorguen a las mujeres igualdad de derechos a los recursos económicos, así como acceso a la propiedad y al control de la tierra y otros tipos de bienes, los servicios financieros, la herencia y los recursos naturales, de conformidad con las leyes nacionales",
                      goal: goal)

  SDG::Target.create!(title_en: "5.B",
                      description_en: "5.B Enhance the use of enabling technology, in particular information and communications technology, to promote the empowerment of women",
                      title_es: "5.b",
                      description_es: "5.b Mejorar el uso de la tecnología instrumental, en particular la tecnología de la información y las comunicaciones, para promover el empoderamiento de las mujeres",
                      goal: goal)

  SDG::Target.create!(title_en: "5.C",
                      description_en: "5.C Adopt and strengthen sound policies and enforceable legislation for the promotion of gender equality and the empowerment of all women and girls at all levels",
                      title_es: "5.C",
                      description_es: "5.c Aprobar y fortalecer políticas acertadas y leyes aplicables para promover la igualdad de género y el empoderamiento de todas las mujeres y las niñas a todos los niveles",
                      goal: goal)
end
