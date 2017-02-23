module Polls2017ResultsStatsHelper

  def total_votes_for_answer(question, answer)
    ::Poll::PartialResult.where(question_id: question.id).where(answer: answer).sum(:amount)
  end

  def total_votes_for_poll(poll)
    ::Poll::FinalRecount.where(booth_assignment_id: poll.booth_assignment_ids).sum(:count)
  end

  def poll_stats(poll)
    total = Poll::Voter.where(poll_id: poll.id).count
    web = Poll::Voter.web.where(poll_id: poll.id).count
    booth = Poll::Voter.booth.where(poll_id: poll.id).count
    letter = Poll::Voter.letter.where(poll_id: poll.id).count

    white_web = 0
    white_booth = Poll::WhiteResult.all.sum(:amount)
    white_letter = 0

    null_web = 0
    null_booth = Poll::NullResult.all.sum(:amount)
    null_letter = 0

    poll_stats = {
      poll: poll,

      total_votes: total,

      web_votes: web,
      booth_votes: booth,
      letter_votes: letter,
      total_valid_votes: web + booth + letter,

      white_web_votes: white_web,
      white_booth_votes: white_booth,
      white_letter_votes: white_letter,
      total_white_votes: white_web + white_booth + white_letter,

      null_web_votes: null_web,
      null_booth_votes: null_booth,
      null_letter_votes: null_letter,
      total_null_votes: null_web + null_booth + null_letter,

      total_web: web + white_web + null_web,
      total_booth: booth + white_booth + null_booth,
      total_letter: letter + white_letter + null_letter,

      total_total: web + booth + letter + white_web + white_booth + white_letter + null_web + null_booth + null_letter
    }
  end

  def barajas_questions_valid_answers_mappings(answer)
    @barajas_questions_valid_answers_mapping ||= {
      "1" => "(NO ES COMPETENCIA MUNICIPAL) Garantizar las plazas necesarias de Secundaria y Bachillerato para todos los alumnos de los centros públicos del distrito. Construcción de un nuevo instituto",
      "2" => "(NO ES COMPETENCIA MUNICIPAL) Construcción del pabellón deportivo en el CEIP Ciudad de Guadalajara",
      "3" => "(NO ES COMPETENCIA MUNICIPAL) Ampliación del comedor del CEIP Ciudad de Zaragoza",
      "4" => "(NO ES COMPETENCIA MUNICIPAL) Aumento de plazas y especialidades de FP en el IES Barajas",
      "5" => "(NO ES COMPETENCIA MUNICIPAL) Finalización del CEIP Margaret Thatcher",
      "6" => "Gestión pública de las Escuelas Infantiles y aumento de plazas",
      "7" => "Reimplantación del transporte escolar al Barrio del Aeropuerto",
      "8" => "Fortalecimiento del apoyo escolar a los niños con necesidades educativas especiales",
      "9" => "Incrementar las ayudas para libros de texto",
      "10" => "Mejorar el mantenimiento de los centros de enseñanza pública",
      "11" => "Implantar el proyecto “Camino seguro al colegio”",
      "12" => "Realizar un estudio pormenorizado de la realidad de nuestros mayores",
      "13" => "Incrementar la inversión en Servicios Sociales",
      "14" => "Mejorar el acceso a las prestaciones de la Ley de Dependencia",
      "15" => "Crear un espacio de encuentro en el Bloque Ezequiel Peñalver",
      "16" => "Incrementar el personal de los Servicios Sociales",
      "17" => "Ofrecer consulta bucodental en los Centros de Mayores",
      "18" => "Realizar mejoras en el Centro de Mayores Acuario",
      "19" => "Mejorar la oferta cultural, tanto en calidad como en variedad",
      "20" => "Crear equipamientos culturales en el barrio de Timón",
      "21" => "Crear un eje histórico-cultural de la Alameda de Osuna",
      "22" => "(NO ES COMPETENCIA MUNICIPAL) Recuperar la Casa del Pueblo de Barajas",
      "23" => "Reabrir el auditorio del Parque Juan Carlos I y dotarle de uso cultural",
      "24" => "Recuperación de las fiestas populares de La Alameda de Osuna",
      "25" => "Creación del Cine Club Distrito Barajas",
      "26" => "Impulsar la Oficina Municipal de Empleo de Barajas",
      "27" => "(NO ES COMPETENCIA MUNICIPAL) Realizar inspecciones de trabajo en todos los comercios de Barajas",
      "28" => "Crear de un Vivero de Empresas para emprendedores",
      "29" => "Crear una galería de alimentación en el Ensanche de Barajas",
      "30" => "Conceder permiso anual para el Mercadillo Vecinal y el Artesanal",
      "31" => "Promover anualmente el comercio en Barajas",
      "32" => "Difundir el comercio y la actividad empresarial del distrito en la página web de la Junta Municipal",
      "33" => "Ampliación del Centro Polideportivo Municipal de Barajas",
      "34" => "Implantar un servicio de fisioterapia en el Centro Deportivo Municipal Barajas",
      "35" => "Arreglar el acceso peatonal al Centro Deportivo Municipal Barajas",
      "36" => "Creación de un centro de patinaje",
      "37" => "Crear un servicio de alquiler de bicicletas en Barajas y fomentar su utilización",
      "38" => "Mejorar el asfaltado del Parque Juan Carlos I",
      "39" => "Reforma y adecuación integral de la Instalación Deportiva Municipal Básica del Barrio del Aeropuerto",
      "40" => "Mejorar, por parte de la Junta Municipal, la difusión de los eventos deportivos de las asociaciones",
      "41" => "Mejorar la limpieza del distrito",
      "42" => "Crear bosques urbanos en el distrito",
      "43" => "Recuperar la Plaza de Nuestra Señora de Loreto",
      "44" => "Peatonalizar la Plaza Mayor de Barajas",
      "45" => "Finalización de la Vía Verde de la Gasolina",
      "46" => "Ampliación de la Vía Verde de la Gasolina",
      "47" => "Rehabilitación integral de las viviendas del Barrio del Aeropuerto",
      "48" => "Rehabilitar el Bloque Ezequiel Peñalver y su entorno",
      "49" => "(NO ES COMPETENCIA MUNICIPAL) Reabrir el servicio de urgencias",
      "50" => "(NO ES COMPETENCIA MUNICIPAL) Implantar un dispensario sanitario en el Barrio del Aeropuerto",
      "51" => "(NO ES COMPETENCIA MUNICIPAL) Construcción de un nuevo centro de salud",
      "52" => "(NO ES COMPETENCIA MUNICIPAL) Mejorar la ubicación e infraestructura del centro de salud mental",
      "53" => "Creación de un Centro Madrid Salud",
      "54" => "(NO ES COMPETENCIA MUNICIPAL) Construcción de un centro de especialidades",
      "55" => "(NO ES COMPETENCIA MUNICIPAL) Incremento del número de médicos, reposición de plazas y psicólogo/a para adultos en el centro de salud mental.",
      "56" => "Construir un aparcamiento disuasorio en el Metro Barajas",
      "57" => "Implantar un autobús directo al Hospital Ramón y Cajal",
      "58" => "Proporcionar locales o espacios municipales a las asociaciones y colectivos del distrito",
      "59" => "Prohibir la cesión de explotación en las casetas de las fiestas",
      "60" => "Desarrollar el capítulo de “Gobierno Abierto, Datos Abiertos”",
      "61" => "Reformar el reglamento de la Junta Municipal",
      "62" => "Presentar públicamente los presupuestos",
      "63" => "Crear una Casa de la Juventud o Centro Joven de Barajas",
      "64" => "Crear el Punto Joven Alameda: rocódromo y skatepark"
    }
    @barajas_questions_valid_answers_mapping[answer]
  end

  def san_blas_questions_valid_answers_mappings(answer)
    @san_blas_questions_valid_answers_mapping ||= {
      "1" => "(NO ES COMPETENCIA MUNICIPAL) Construir IES en el Barrio de las Rejas",
      "2" => "(NO ES COMPETENCIA MUNICIPAL) Construir nuevo colegio en las Rejas ",
      "3" => "Reformular cuotas, pliegos y ratios escuelas educación infantil",
      "4" => "(NO ES COMPETENCIA MUNICIPAL) Construir 2ªFase IES Alfredo Kraus",
      "5" => "(NO ES COMPETENCIA MUNICIPAL) Garantizar acceso Universidad a personas en riesgo de exclusión ",
      "6" => "(NO ES COMPETENCIA MUNICIPAL) Recuperar profesores apoyo, orientadores y profesores de servicios a la comunidad en colegios e institutos",
      "7" => "Poner personal de limpieza en horario lectivo",
      "8" => "Incrementar educadores sociales",
      "9" => "Mejorar mantenimiento de los colegios públicos",

      "10" => "Hacer gratuita la educación de 0 a 3 años",
      "11" => "(NO ES COMPETENCIA MUNICIPAL) Revisar o suprimir la ley educativa (LOMCE) ",
      "12" => "(NO ES COMPETENCIA MUNICIPAL) Eliminar asignatura de religión en horario lectivo",
      "13" => "Incrementar personal a los Servicios Sociales",
      "14" => "Dotar de presupuesto a las asociaciones que trabajan con personas en exclusión social ",
      "15" => "Paquete de medidas para combatir la pobreza",
      "16" => "Mejorar la protección a las víctimas de violencia de género y a sus familias",
      "17" => "Fomentar el acogimiento familiar de menores tutelados",
      "18" => "(NO ES COMPETENCIA MUNICIPAL) Agilizar las valoraciones de dependencia y dotarla de mayores recursos",
      "19" => "Garantizar recursos básicos para cualquier persona",
      "20" => "(NO ES COMPETENCIA MUNICIPAL) No más desahucios por parte de los bancos",
      "21" => "Garantizar alquileres dignos",
      "22" => "Garantizar la gestión municipal directa de los centros culturales",
      "23" => "Facilitar el acceso de la ciudadanía a la gestión cultural",
      "24" => "Mejorar la gestión y dotación de medios de los recursos culturales del distrito",
      "25" => "Potenciar la iniciativa ciudadana en torno a la cultura",
      "26" => "Facilitar espacios de gestión municipal a las entidades culturales del distrito",
      "27" => "Facilitar la cesión de uso de los auditorios del distrito",
      "28" => "Cesión de espacios cuturales en horario de tarde-noche",
      "29" => "Promover el acceso de los jóvenes a la cultura",
      "30" => "Mejorar la difusión de las actividades culturales entre los jóvenes",
      "31" => "Mejorar la difusión de las actividades de los centros culturales entre la vecindad ",
      "32" => "Abrir la Finca Torre Arias a actividades culturales y sociales",
      "33" => "Garantizar la accesibilidad a las instalaciones culturales",
      "34" => "Instaurar una Oficina de la Agencia Municipal para el Empleo en el Distrito",
      "35" => "Creación de un Observatorio Distrital sobre Empleo, Formación y Actividad Comercial y Productiva",
      "36" => "Impulsar Planes y Acciones de Formación Profesional para el Empleo en el Distrito",
      "37" => "Impulsar el autoempleo, el cooperativismo y la economía social, a nivel municipal y distrital",
      "38" => "Remunicipalización de servicios públicos, incremento de los recursos humanos para la gestión municipal, y concursos de plazas vacantes",
      "39" => "(NO ES COMPETENCIA MUNICIPAL) Moratoria indefinida a la implantación de más Grandes Superficies y Centros Comerciales en el Distrito",
      "40" => "Rediseño de los ejes comerciales y espacios sociales del distrito",
      "41" => "Creación de plazas de aparcamiento y gestión eficaz de zonas de carga y descarga",
      "42" => "Plan Especial de Limpieza y Mantenimiento en los Ejes Comerciales del Distrito",
      "43" => "Apoyo e impulso a las Actividades Comerciales en periodos especiales",
      "44" => "Simplificar los procedimientos administrativos y reducir las limitaciones existentes para la actividad comercial",
      "45" => "Mejorar la seguridad de las zonas comerciales y controlar la venta ilegal",
      "46" => "Remodelación del Polideportivo de San Blas",
      "47" => "Remodelación y rehabilitación de las pistas elementales",
      "48" => "Revertir la gestión indirecta de las instalaciones deportivas",
      "49" => "Plan de hierba artificial para fútbol",
      "50" => "Valorar la necesidad de nuevas instalaciones polideportivas",
      "51" => "Mejora del carril bici",
      "52" => "Nueva piscina cubierta",
      "53" => "Garantizar la accesibilidad de las instalaciones deportivas",
      "54" => "Mejora de los elementos para la práctica del ejercicio en los parques",
      "55" => "Construcción de nuevos parques infantiles y la mejora de los ya existentes",
      "56" => "Regeneración y Gestión sostenible del patrimonio ambiental de la Quinta de Torre Arias y del Distrito, en general, con modelos participativos",
      "57" => "Alternativas a la problemática planteada por la convivencia de animales de compañía (perros) y sus dueños, con el resto de vecinos en la vía pública",
      "58" => "Declaración de la Quinta de Torre Arias como Bien de Interés Cultural",
      "59" => "Residuos Cero: un plan, para que en lugar de crearlos, sean reutilizables y reciclables",
      "60" => "(NO ES COMPETENCIA MUNICIPAL) Eliminación del concepto de perreras de toda la Comunidad, en el sentido de último reducto a donde llegan los animales antes de su muerte",
      "61" => "(NO ES COMPETENCIA MUNICIPAL) Creación de una nueva ley de gestión de residuos sostenible para la ciudadanía",
      "62" => "(NO ES COMPETENCIA MUNICIPAL) Ley estatal contra el maltrato animal",
      "63" => "(NO ES COMPETENCIA MUNICIPAL) Derogación de la nueva y actual Ley de Montes",
      "64" => "Plan de dignificación de Ciudad Pegaso",
      "65" => "Supresión de las barreras arquitéctonicas del distrito",
      "66" => "Intervención para la dignificación en el espacio conocido como Plaza Cívica",
      "67" => "(NO ES COMPETENCIA MUNICIPAL) Intervención en los locales vacios del IVIMA",
      "68" => "Impulsar el cumplimiento de un estricto plan de seguridad de la zona de explotación minera de sepiolita",
      "69" => "(NO ES COMPETENCIA MUNICIPAL) Intervención urgente en edificios abandonados del IVIMA",
      "70" => "(NO ES COMPETENCIA MUNICIPAL) Apertura de la estación de O’Donell",
      "71" => "(NO ES COMPETENCIA MUNICIPAL) Traslado del Cuartel de San Cristóbal, y desarrollo en sus terrenos de un programa alternativo de equipamientos para el Distrito.",
      "72" => "(NO ES COMPETENCIA MUNICIPAL) Resolución de los problemas de acceso al distrito de San Blas a la M-40",
      "73" => "Fomentar la participación ciudadana y la democracia en temas de salud, a través de los Consejos de salud del distrito",
      "74" => "Dotación económica y facilitación de trámites burocráticos para las organizaciones dedicadas a temas de salud en el distrito",
      "75" => "Apoyo a Madrid Salud San Blas y al Programa contra la desigualdades sociales",
      "76" => "Incrementar los servicios de ayuda a domicilio",
      "77" => " Instar desde el Ayuntamiento la derogación del Plan de Medidas de Garantía de la Sostenibilidad del Sistema Sanitario Público de la Comunidad de Madrid.",
      "78" => "Desarrollar convenios para la creación de unidades de corta estancia",
      "79" => "(NO ES COMPETENCIA MUNICIPAL) Incremento del personal cualificado en los Centros de Salud",
      "80" => "(NO ES COMPETENCIA MUNICIPAL) Es imprescindible luchar por tener una Sanidad Pública Universal.",
      "81" => "(NO ES COMPETENCIA MUNICIPAL) Aumentar el número claustro en la Universidad para cubrir las necesidades de personal sanitario cualificado ",
      "82" => "Instalar  vados peatonales (rebajes adaptados) en todos los bordillos de cruces de aceras de todo el distrito.",
      "83" => "Permitir el acceso de las bicicletas a las dependencias municipales del distrito",
      "84" => "(NO ES COMPETENCIA MUNICIPAL) Dotar de ascensores o de escaleras mecánicas en las estaciones de metro del distrito",
      "85" => "Rediseño integral de la red de la EMT, en especial en los barrios periféricos (Rejas, Las Mercedes, etc.)",
      "86" => "Limitación a 30 km/h en todas las calles del distrito de un solo carril",
      "87" => "Promoción y fomento de la implantación en los centros educativos del Programa Municipal STARS (“Con bici y a pie al Cole”)",
      "88" => "Reducir el tiempo de la fase semafórica de paso de vehículo (ganar tiempo peatones) en distintos puntos del distrito",
      "89" => "Redistribución del espacio público atendiendo a la prioridad del ciudadano que camina, el que va en bici y en transporte público por encima del coche privado."
    }
    @san_blas_questions_valid_answers_mapping[answer]
  end
end
