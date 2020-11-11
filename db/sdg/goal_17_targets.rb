goal = SDG::Goal.find(17)
if goal && SDG::Target.find_by(goal_id: goal.id).none?
  SDG::Target.create!(title_en: "17.1",
                      description_en: "17.1 Strengthen domestic resource mobilization, including through international support to developing countries, to improve domestic capacity for tax and other revenue collection",
                      title_es: "17.1",
                      description_es: "17.1 Fortalecer la movilización de recursos internos, incluso mediante la prestación de apoyo internacional a los países en desarrollo, con el fin de mejorar la capacidad nacional para recaudar ingresos fiscales y de otra índole",
                      goal: goal)

  SDG::Target.create!(title_en: "17.2",
                      description_en: "17.2 Developed countries to implement fully their official development assistance commitments, including the commitment by many developed countries to achieve the target of 0.7 per cent of ODA/GNI to developing countries and 0.15 to 0.20 per cent of ODA/GNI to least developed countries ODA providers are encouraged to consider setting a target to provide at least 0.20 per cent of ODA/GNI to least developed countries",
                      title_es: "17.2",
                      description_es: "17.2 Velar por que los países desarrollados cumplan plenamente sus compromisos en relación con la asistencia oficial para el desarrollo, incluido el compromiso de numerosos países desarrollados de alcanzar el objetivo de destinar el 0,7% del ingreso nacional bruto a la asistencia oficial para el desarrollo de los países en desarrollo y entre el 0,15% y el 0,20% del ingreso nacional bruto a la asistencia oficial para el desarrollo de los países menos adelantados; se alienta a los proveedores de asistencia oficial para el desarrollo a que consideren la posibilidad de fijar una meta para destinar al menos el 0,20% del ingreso nacional bruto a la asistencia oficial para el desarrollo de los países menos adelantados",
                      goal: goal)

  SDG::Target.create!(title_en: "17.3",
                      description_en: "17.3 Mobilize additional financial resources for developing countries from multiple sources",
                      title_es: "17.3",
                      description_es: "17.3 Movilizar recursos financieros adicionales de múltiples fuentes para los países en desarrollo",
                      goal: goal)

  SDG::Target.create!(title_en: "17.4",
                      description_en: "17.4 Assist developing countries in attaining long-term debt sustainability through coordinated policies aimed at fostering debt financing, debt relief and debt restructuring, as appropriate, and address the external debt of highly indebted poor countries to reduce debt distress",
                      title_es: "17.4",
                      description_es: "17.4 Ayudar a los países en desarrollo a lograr la sostenibilidad de la deuda a largo plazo con políticas coordinadas orientadas a fomentar la financiación, el alivio y la reestructuración de la deuda, según proceda, y hacer frente a la deuda externa de los países pobres muy endeudados a fin de reducir el endeudamiento excesivo",
                      goal: goal)

  SDG::Target.create!(title_en: "17.5",
                      description_en: "17.5 Adopt and implement investment promotion regimes for least developed countries",
                      title_es: "17.5",
                      description_es: "17.5 Adoptar y aplicar sistemas de promoción de las inversiones en favor de los países menos adelantados",
                      goal: goal)

  SDG::Target.create!(title_en: "17.6",
                      description_en: "17.6 Enhance North-South, South-South and triangular regional and international cooperation on and access to science, technology and innovation and enhance knowledge sharing on mutually agreed terms, including through improved coordination among existing mechanisms, in particular at the United Nations level, and through a global technology facilitation mechanism",
                      title_es: "17.6",
                      description_es: "17.6 Mejorar la cooperación regional e internacional Norte-Sur, Sur-Sur y triangular en materia de ciencia, tecnología e innovación y el acceso a estas, y aumentar el intercambio de conocimientos en condiciones mutuamente convenidas, incluso mejorando la coordinación entre los mecanismos existentes, en particular a nivel de las Naciones Unidas, y mediante un mecanismo mundial de facilitación de la tecnología",
                      goal: goal)

  SDG::Target.create!(title_en: "17.7",
                      description_en: "17.7 Promote the development, transfer, dissemination and diffusion of environmentally sound technologies to developing countries on favourable terms, including on concessional and preferential terms, as mutually agreed",
                      title_es: "17.7",
                      description_es: "17.7 Promover el desarrollo de tecnologías ecológicamente racionales y su transferencia, divulgación y difusión a los países en desarrollo en condiciones favorables, incluso en condiciones concesionarias y preferenciales, según lo convenido de mutuo acuerdo",
                      goal: goal)

  SDG::Target.create!(title_en: "17.8",
                      description_en: "17.8 Fully operationalize the technology bank and science, technology and innovation capacity-building mechanism for least developed countries by 2017 and enhance the use of enabling technology, in particular information and communications technology",
                      title_es: "17.8",
                      description_es: "17.8 Poner en pleno funcionamiento, a más tardar en 2017, el banco de tecnología y el mecanismo de apoyo a la creación de capacidad en materia de ciencia, tecnología e innovación para los países menos adelantados y aumentar la utilización de tecnologías instrumentales, en particular la tecnología de la información y las comunicaciones",
                      goal: goal)

  SDG::Target.create!(title_en: "17.9",
                      description_en: "17.9 Enhance international support for implementing effective and targeted capacity-building in developing countries to support national plans to implement all the sustainable development goals, including through North-South, South-South and triangular cooperation",
                      title_es: "17.9",
                      description_es: "17.9 Aumentar el apoyo internacional para realizar actividades de creación de capacidad eficaces y específicas en los países en desarrollo a fin de respaldar los planes nacionales de implementación de todos los Objetivos de Desarrollo Sostenible, incluso mediante la cooperación Norte-Sur, Sur-Sur y triangular",
                      goal: goal)

  SDG::Target.create!(title_en: "17.10",
                      description_en: "17.10 Promote a universal, rules-based, open, non-discriminatory and equitable multilateral trading system under the World Trade Organization, including through the conclusion of negotiations under its Doha Development Agenda",
                      title_es: "17.10",
                      description_es: "17.10 Promover un sistema de comercio multilateral universal, basado en normas, abierto, no discriminatorio y equitativo en el marco de la Organización Mundial del Comercio, incluso mediante la conclusión de las negociaciones en el marco del Programa de Doha para el Desarrollo",
                      goal: goal)

  SDG::Target.create!(title_en: "17.11",
                      description_en: "17.11 Significantly increase the exports of developing countries, in particular with a view to doubling the least developed countries’ share of global exports by 2020",
                      title_es: "17.11",
                      description_es: "17.11 Aumentar significativamente las exportaciones de los países en desarrollo, en particular con miras a duplicar la participación de los países menos adelantados en las exportaciones mundiales de aquí a 2020",
                      goal: goal)

  SDG::Target.create!(title_en: "17.12",
                      description_en: "17.12 Realize timely implementation of duty-free and quota-free market access on a lasting basis for all least developed countries, consistent with World Trade Organization decisions, including by ensuring that preferential rules of origin applicable to imports from least developed countries are transparent and simple, and contribute to facilitating market access",
                      title_es: "17.12",
                      description_es: "17.12 Lograr la consecución oportuna del acceso a los mercados libre de derechos y contingentes de manera duradera para todos los países menos adelantados, conforme a las decisiones de la Organización Mundial del Comercio, incluso velando por que las normas de origen preferenciales aplicables a las importaciones de los países menos adelantados sean transparentes y sencillas y contribuyan a facilitar el acceso a los mercados",
                      goal: goal)

  SDG::Target.create!(title_en: "17.13",
                      description_en: "17.13 Enhance global macroeconomic stability, including through policy coordination and policy coherence",
                      title_es: "17.13",
                      description_es: "17.13 Aumentar la estabilidad macroeconómica mundial, incluso mediante la coordinación y coherencia de las políticas",
                      goal: goal)

  SDG::Target.create!(title_en: "17.14",
                      description_en: "17.14 Enhance policy coherence for sustainable development",
                      title_es: "17.14",
                      description_es: "17.14 Mejorar la coherencia de las políticas para el desarrollo sostenible",
                      goal: goal)

  SDG::Target.create!(title_en: "17.15",
                      description_en: "17.15 Respect each country’s policy space and leadership to establish and implement policies for poverty eradication and sustainable development",
                      title_es: "17.15",
                      description_es: "17.15 Respetar el margen normativo y el liderazgo de cada país para establecer y aplicar políticas de erradicación de la pobreza y desarrollo sostenible",
                      goal: goal)

  SDG::Target.create!(title_en: "17.16",
                      description_en: "17.16 Enhance the global partnership for sustainable development, complemented by multi-stakeholder partnerships that mobilize and share knowledge, expertise, technology and financial resources, to support the achievement of the sustainable development goals in all countries, in particular developing countries",
                      title_es: "17.16",
                      description_es: "17.16 Mejorar la Alianza Mundial para el Desarrollo Sostenible, complementada por alianzas entre múltiples interesados que movilicen e intercambien conocimientos, especialización, tecnología y recursos financieros, a fin de apoyar el logro de los Objetivos de Desarrollo Sostenible en todos los países, particularmente los países en desarrollo",
                      goal: goal)

  SDG::Target.create!(title_en: "17.17",
                      description_en: "17.17 Encourage and promote effective public, public-private and civil society partnerships, building on the experience and resourcing strategies of partnerships",
                      title_es: "17.17",
                      description_es: "17.17 Fomentar y promover la constitución de alianzas eficaces en las esferas pública, público-privada y de la sociedad civil, aprovechando la experiencia y las estrategias de obtención de recursos de las alianzas",
                      goal: goal)

  SDG::Target.create!(title_en: "17.18",
                      description_en: "17.18 By 2020, enhance capacity-building support to developing countries, including for least developed countries and small island developing States, to increase significantly the availability of high-quality, timely and reliable data disaggregated by income, gender, age, race, ethnicity, migratory status, disability, geographic location and other characteristics relevant in national contexts",
                      title_es: "17.18",
                      description_es: "17.18 De aquí a 2020, mejorar el apoyo a la creación de capacidad prestado a los países en desarrollo, incluidos los países menos adelantados y los pequeños Estados insulares en desarrollo, para aumentar significativamente la disponibilidad de datos oportunos, fiables y de gran calidad desglosados por ingresos, sexo, edad, raza, origen étnico, estatus migratorio, discapacidad, ubicación geográfica y otras características pertinentes en los contextos nacionales",
                      goal: goal)

  SDG::Target.create!(title_en: "17.19",
                      description_en: "17.19 By 2030, build on existing initiatives to develop measurements of progress on sustainable development that complement gross domestic product, and support statistical capacity-building in developing countries",
                      title_es: "17.19",
                      description_es: "17.19 De aquí a 2030, aprovechar las iniciativas existentes para elaborar indicadores que permitan medir los progresos en materia de desarrollo sostenible y complementen el producto interno bruto, y apoyar la creación de capacidad estadística en los países en desarrollo",
                      goal: goal)
end
