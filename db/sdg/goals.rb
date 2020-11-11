if SDG::Goal.count == 0
  SDG::Goal.create!(code: 1,
                    title_en: "No poverty",
                    description_en: "End poverty in all its forms everywhere.",
                    title_es: "Fin de la pobreza",
                    description_es: "Poner fin a la pobreza en todas sus formas en todo el mundo.")

  SDG::Goal.create!(code: 2,
                    title_en: "Zero Hunger",
                    description_en: "Zero Hunger.",
                    title_es: "Hambre Cero",
                    description_es: "Poner fin al hambre.")

  SDG::Goal.create!(code: 3,
                    title_en: "Good Health and Well-Being",
                    description_en: "Ensure healthy lives and promote well-being for all at all ages.",
                    title_es: "Salud y Bienestar",
                    description_es: "Garantizar una vida sana y promover el bienestar para todos en todas las edades.")

  SDG::Goal.create!(code: 4,
                    title_en: "Quality Education",
                    description_en: "Quality Education",
                    title_es: "Educación de Calidad",
                    description_es: "Garantizar una educación inclusiva, equitativa y de calidad y promover oportunidades de aprendizaje durante toda la vida para todos.")

  SDG::Goal.create!(code: 5,
                    title_en: "Gender Equality",
                    description_en: "Achieve gender equality and empower all women and girls.",
                    title_es: "Igualdad de Género",
                    description_es: "Lograr la igualdad entre los géneros y empoderar a todas las mujeres y las niñas.")

  SDG::Goal.create!(code: 6,
                    title_en: "Clean Water and Sanitation",
                    description_en: "Ensure access to water and sanitation for all.",
                    title_es: "Agua Limpia y Saneamiento",
                    description_es: "Garantizar la disponibilidad de agua y su gestión sostenible y el saneamiento para todos.")

  SDG::Goal.create!(code: 7,
                    title_en: "Affordable and Clean Energy",
                    description_en: "Ensure access to affordable, reliable, sustainable and modern energy.",
                    title_es: "Energía Sostenible y No Contaminante",
                    description_es: "Garantizar el acceso a una energía asequible, segura, sostenible y moderna.")

  SDG::Goal.create!(code: 8,
                    title_en: "Decent Work and Economic Growth",
                    description_en: "Promote inclusive and sustainable economic growth, employment and decent work for all.",
                    title_es: "Trabajo Decente y Crecimiento Económico",
                    description_es: "Promover el crecimiento económico inclusivo y sostenible, el empleo y el trabajo decente para todos.")

  SDG::Goal.create!(code: 9,
                    title_en: "Industry, Innovation and Infrastructure",
                    description_en: "Build resilient infrastructure, promote sustainable industrialization and foster innovation.",
                    title_es: "Industria, Innovación e Infraestructuras",
                    description_es: "Construir infraestructuras resilientes, promover la industrialización sostenible y fomentar la innovación.")

  SDG::Goal.create!(code: 10,
                    title_en: "Reduced Inequalities",
                    description_en: "Reduce inequality within and among countries.",
                    title_es: "Reducción de las Desigualdades",
                    description_es: "Reducir la desigualdad en y entre los países.")

  SDG::Goal.create!(code: 11,
                    title_en: "Sustainable Cities and Communities",
                    description_en: "Make cities inclusive, safe, resilient and sustainable.",
                    title_es: "Ciudades y Comunidades Sostenibles",
                    description_es: "Lograr que las ciudades sean más inclusivas, seguras, resilientes y sostenibles.")

  SDG::Goal.create!(code: 12,
                    title_en: "Responsible Consumption and Production ",
                    description_en: "Ensure sustainable consumption and production patterns.",
                    title_es: "Producción y Consumo Responsables",
                    description_es: "Garantizar modalidades de consumo y producción sostenibles.")

  SDG::Goal.create!(code: 13,
                    title_en: "Climate Action",
                    description_en: "Take urgent action to combat climate change and its impacts.",
                    title_es: "Acción Por el Clima",
                    description_es: "Adoptar medidas urgentes para combatir el cambio climático y sus efectos.")

  SDG::Goal.create!(code: 14,
                    title_en: "Life Below Water",
                    description_en: "Conserve and sustainably use the oceans, seas and marine resources.",
                    title_es: "Vida Submarina",
                    description_es: "Conservar y utilizar sosteniblemente los océanos, los mares y los recursos marinos.")

  SDG::Goal.create!(code: 15,
                    title_en: "Life on Land",
                    description_en: "Sustainably manage forests, combat desertification, halt and reverse land degradation, halt biodiversity loss.",
                    title_es: "Vida de Ecosistemas Terrestres",
                    description_es: "Gestionar sosteniblemente los bosques, luchar contra la desertificación, detener e invertir la degradación de las tierras, detener la pérdida de biodiversidad.")

  SDG::Goal.create!(code: 16,
                    title_en: "Peace, Justice and Strong Institution",
                    description_en: "Promote just, peaceful and inclusive societies.",
                    title_es: "Paz, Justicia e Instituciones Sólidas",
                    description_es: "Promover sociedades justas, pacíficas e inclusivas.")

  SDG::Goal.create!(code: 17,
                    title_en: "Partnerships For the Goals",
                    description_en: "Revitalize the global partnership for Sustainable Development.",
                    title_es: "Alianzas para Lograr los Objetivos",
                    description_es: "Revitalizar la Alianza Mundial para el Desarrollo Sostenible.")
end
