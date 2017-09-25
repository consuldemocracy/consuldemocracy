require 'fileutils'

namespace :polls do

  def create_2017_district_poll(geozone_name, questions_attributes, poll_name=nil)
    questions = Array.wrap(questions_attributes)
    poll = Poll.create!(
      name: questions.size == 1 ? questions[0][:title] : (poll_name || geozone_name),
      starts_at: Date.today,
      ends_at: Date.new(2017, 2, 19),
      geozone_restricted: true
    )
    poll.geozones << Geozone.where(name: geozone_name).first!
    questions.each do |question_attributes|
      Poll::Question.create!(
        { author_visible_name: "Junta de Distrito de #{geozone_name}",
          valid_answers: "",
          poll: poll,
          author: User.first
        }.merge(question_attributes)
      )
    end
  end

  POLL_SPECS_2017 = [ {
        nvotes_poll_id: 1005,
        name: 'Madrid 100% Sostenible, Billete único para el transporte público y Plaza de España',
        layout: 'simultaneous-questions'
      }, {
        nvotes_poll_id: 2005,
        name: 'Gran Vía',
        layout: 'simultaneous-questions'
      }, {
        nvotes_poll_id: 3005,
        name: '¿Cómo quieres que se llame el Espacio de Igualdad del Distrito de Vicálvaro?',
        layout: 'simultaneous-questions'
      }, {
        nvotes_poll_id: 4005,
        name: '¿Considera que la Junta Municipal del Distrito de Salamanca debe llevar a cabo las acciones necesarias para incrementar la protección de edificios históricos e instar para que se protejan los que actualmente no figuran en el catálogo de bienes protegidos?',
        layout: 'simultaneous-questions'
      }, {
        nvotes_poll_id: 5005,
        name: 'Nombre de distrito y Parque Felipe VI en Hortaleza',
        layout: 'simultaneous-questions'
      }, {
        nvotes_poll_id: 6005,
        name: 'Prioriza el Plan Participativo de Actuación Territorial de Barajas',
        layout: 'accordion'
      }, {
        nvotes_poll_id: 7005,
        name: 'Prioriza el Plan Participativo de Actuación Territorial de San Blas - Canillejas',
        layout: 'accordion'
      }, {
        nvotes_poll_id: 8005,
        name: 'Nombres de centros culturales en Retiro',
        layout: 'simultaneous-questions'
      }
    ]

  BARAJAS_2017_SHORT_DESCRIPTION = ""

  BARAJAS_2017_OPTIONS = [
    { category: "EDUCACIÓN",
      name: "(NO ES COMPETENCIA MUNICIPAL) Garantizar las plazas necesarias de Secundaria y Bachillerato para todos los alumnos de los centros públicos del distrito. Construcción de un nuevo instituto",
      description: "Es necesario garantizar que todos los alumnos de colegios públicos del distrito puedan cursar secundaria y bachillerato en un centro público del distrito, adoptando medidas urgentes a corto plazo, y también a medio y largo plazo, que solucionen de forma definitiva la dramática situación actual de falta de plazas."},
    { category: "EDUCACIÓN",
      name: "(NO ES COMPETENCIA MUNICIPAL) Construcción del pabellón deportivo en el CEIP Ciudad de Guadalajara",
      description: "El Centro dispone de un pequeño gimnasio habilitado para su uso por 35 personas en un primer piso, claramente insuficiente para cubrir las necesidades de los 500 alumnos de Infantil y Primaria que cursan estudios en este centro. Las clases de gimnasia se realizan a la intemperie, así como las actividades sociales (asambleas, juegos, fiestas y reuniones diversas), debiendo ser suspendidas cada vez que llueve. La Dirección del Centro y la AMPA llevan 15 años reclamando la construcción de un pabellón deportivo."},
    { category: "EDUCACIÓN",
      name: "(NO ES COMPETENCIA MUNICIPAL) Ampliación del comedor del CEIP Ciudad de Zaragoza",
      description: "Es necesario ampliar el comedor del CEIP Ciudad de Zaragoza, ya que su capacidad es insuficiente ante el incremento de usuarios del mismo en los últimos años."},
    { category: "EDUCACIÓN",
      name: "(NO ES COMPETENCIA MUNICIPAL) Aumento de plazas y especialidades de FP en el IES Barajas",
      description: "Para todos los cursos en el IES Barajas hay más demanda de plazas de las que al final se son ofertadas. Afecta de forma muy directa a alumnos que han terminado recientemente la ESO dentro del distrito o en la zona de influencia del IES Barajas y optan por continuar sus estudios en una FP de Grado Medio en alguna de las especialidades ofrecidas por el centro. También ha empezado a suceder en las especialidades de FP de Grado Superior y en FP Básica. Por otro lado, la oferta actual de especialidades del IES Barajas gira en torno a Joyería, Automoción, Mecánica, Electromecánica, Aviónica y TIC. La mayoría son especialidades demandadas y desarrolladas a nivel laboral fundamentalmente por población masculina. Se hace necesario ampliar la oferta con especialidades que sean demandadas también por mujeres, con el fin de darles igualdad de oportunidades de cursar especialidades de FP de su interés y con salidas profesionales."},
    { category: "EDUCACIÓN",
      name: "(NO ES COMPETENCIA MUNICIPAL) Finalización del CEIP Margaret Thatcher",
      description: "Es necesario finalizar las obras del CEIP Margaret Thatcher."},
    { category: "EDUCACIÓN",
      name: "Gestión pública de las Escuelas Infantiles y aumento de plazas",
      description: "Volver a la gestión directa, evitando que empresas ajenas a la educación infantil se lucren aplicando un criterio económico sobre el pedagógico, con el consiguiente deterioro en los objetivos que ello supone."},
    { category: "EDUCACIÓN",
      name: "Reimplantación del transporte escolar al Barrio del Aeropuerto",
      description: "Hace años había un transporte escolar para el traslado de alumnos del Barrio del Aeropuerto hasta los CEIP ubicados en la Alameda de Osuna. Actualmente, ese servicio de transporte ha dejado de prestarse, por lo que los alumnos del Barrio del Aeropuerto se ven obligados a desplazarse por otros medios, con los inconvenientes que ello acarrea."},
    { category: "EDUCACIÓN",
      name: "Fortalecimiento del apoyo escolar a los niños con necesidades educativas especiales",
      description: "Generar mayor cantidad de espacios de apoyo escolar a los niños con necesidades educativas especiales. "},
    { category: "EDUCACIÓN",
      name: "Incrementar las ayudas para libros de texto",
      description: "Es necesario aumentar las ayudas para la compra de libros de texto en la Comunidad de Madrid."},
    { category: "EDUCACIÓN",
      name: "Mejorar el mantenimiento de los centros de enseñanza pública",
      description: "El servicio de mantenimiento de los centros de enseñanza pública del distrito deja mucho que desear. Los centros estaban abandonados por la Junta Municipal y las peticiones realizadas por las direcciones de los centros eran mal atendidas, en tiempo y en forma. Desde hace unos años, las AMPAs de los centros se han visto en la obligación de involucrarse en las demandas de servicios de mantenimiento, reforzando las acciones que las direcciones, como es su obligación, han mantenido. Se han realizado en los últimos cuatro años algunas de los temas acumulados durante años de abandono, pero los tiempos y las formas siguen siendo claramente insatisfactorias, y la calidad de los trabajos realizados deja, en general, mucho que desear."},
    { category: "EDUCACIÓN",
      name: "Implantar el proyecto “Camino seguro al colegio”",
      description: "Generar una red de personas que se conviertan en acompañantes de los niños en su camino al cole."},
    { category: "EQUIDAD",
      name: "Realizar un estudio pormenorizado de la realidad de nuestros mayores",
      description: "Pedimos realizar un estudio en profundidad de la realidad de nuestros mayores (a modo de informe o libro blanco), contando con nuestros mayores, con distintos especialistas (médicos, psicólogos, Servicios Sociales etc.) y también con jóvenes que puedan percibir qué nuevos tiempos están naciendo."},
    { category: "EQUIDAD",
      name: "Incrementar la inversión en Servicios Sociales",
      description: "Consideramos de gran importancia mayor número de agentes sociales (trabajadoras sociales, educadoras sociales de calle y Animadoras socioculturales dentro del entorno, considerando estas figuras como profesionales que desarrollan una intervención socioeducativa con las personas en sus contextos con el objeto de que logren un desarrollo personal y social pleno, y participen, de modo responsable, en los diferentes ámbitos sociales y comunitarios."},
    { category: "EQUIDAD",
      name: "Mejorar el acceso a las prestaciones de la Ley de Dependencia",
      description: "La aplicación del derecho recogido en la Ley 39/2006, de 14 de diciembre, de Promoción de la Autonomía Personal y Atención a las Personas en Situación de Dependencia, no está llegando a todas las personas con la rapidez que requiere. Los recortes también se han visto reflejados en las prestaciones para las personas dependientes, a pesar de ser un derecho reconocido en dicha Ley. En el distrito de Barajas no estamos a salvo de esta incidencia."},
    { category: "EQUIDAD",
      name: "Crear un espacio de encuentro en el Bloque Ezequiel Peñalver",
      description: "Instar al estamento competente a dotar al Bloque Ezequiel Peñalver de un espacio para encuentro vecinal."},
    { category: "EQUIDAD",
      name: "Incrementar el personal de los Servicios Sociales",
      description: "Consideramos que las necesidades básicas de la ciudadanía son una responsabilidad pública. Por tanto, proponemos una mayor dotación en los Servicios Sociales del distrito, con más trabajadoras sociales para que puedan tramitar las ayudas y atender mejor a las personas. También, que se eliminen las trabas burocráticas que existen para acceder a las distintas prestaciones."},
    { category: "EQUIDAD",
      name: "Ofrecer consulta bucodental en los Centros de Mayores",
      description: "Considerando el alto porcentaje de mayores en el distrito, vemos imprescindible el poder contar con consulta de salud bucodental en los Centros de Mayores."},
    { category: "EQUIDAD",
      name: "Realizar mejoras en el Centro de Mayores Acuario",
      description: "Son necesarias mejoras en el Centro de Mayores Acuario, considerando las quejas recibidas de sus usuarios por el insuficiente o nulo mantenimiento que tiene el centro."},
    { category: "CULTURA",
      name: "Mejorar la oferta cultural, tanto en calidad como en variedad",
      description: "El objetivo es mejorar la calidad de la formación que se da en los centros culturales, de tal forma que no estén en desventaja con los centros privados y sean accesibles a todos los segmentos de la población."},
    { category: "CULTURA",
      name: "Crear equipamientos culturales en el barrio de Timón",
      description: "Construcción de un centro cultural y una biblioteca en el barrio de Timón - Ensanche de Barajas."},
    { category: "CULTURA",
      name: "Crear un eje histórico-cultural de la Alameda de Osuna",
      description: "Redacción de un plan director para la regeneración urbana del área trasera del Jardín Histórico de “El Capricho” y su vinculación con la zona verde del Castillo de la Alameda de Osuna que posibilite la creación de nuevos espacios públicos, la potenciación del patrimonio y la creación de equipamientos culturales."},
    { category: "CULTURA",
      name: "(NO ES COMPETENCIA MUNICIPAL) Recuperar la Casa del Pueblo de Barajas",
      description: "Recuperar la Casa del Pueblo (Calle del Duque, 29) para la creación de un Centro de Documentación Histórica de Barajas."},
    { category: "CULTURA",
      name: "Reabrir el auditorio del Parque Juan Carlos I y dotarle de uso cultural",
      description: "Reabrir el auditorio del Parque Juan Carlos I y dotarle de uso cultural."},
    { category: "CULTURA",
      name: "Recuperación de las fiestas populares de La Alameda de Osuna",
      description: "La Alameda de Osuna tuvo antiguamente, en años posteriores a su creación, unas fiestas de barrio que desaparecieron por la baja participación vecinal y el desinterés de las autoridades."},
    { category: "CULTURA",
      name: "Creación del Cine Club Distrito Barajas",
      description: "Creación de un cine club del distrito de Barajas."},
    { category: "EMPLEO",
      name: "Impulsar la Oficina Municipal de Empleo de Barajas",
      description: "Promocionar la Oficina Municipal de Empleo (Avda. Cantabria) y crear una bolsa de trabajo."},
    { category: "EMPLEO",
      name: "(NO ES COMPETENCIA MUNICIPAL) Realizar inspecciones de trabajo en todos los comercios de Barajas",
      description: "RESUMEN: Inspecciones de trabajo en los locales de pocos trabajadores (no grandes o medianas superficies)."},
    { category: "EMPLEO",
      name: "Crear de un Vivero de Empresas para emprendedores",
      description: "Creación de un Vivero de Empresas para los emprendedores. Oficinas con un bajo alquiler para que la gente emprendedora pueda iniciar sus proyectos con costes bajos."},
    { category: "COMERCIO",
      name: "Crear una galería de alimentación en el Ensanche de Barajas",
      description: "Pedimos para el Ensanche de Barajas una Galería de Alimentación, vendría muy bien tanto para fomentar el consumo de proximidad en el barrio así como para fomentar el “espíritu” de barrio ya que al ser zonas de reciente construcción esta falta de servicios promueve un “desapego” a la vida de barrio y el uso excesivo del coche. Con esto conseguiríamos promover el tejido social del barrio y reducir las emisiones contaminantes."},
    { category: "COMERCIO",
      name: "Conceder permiso anual para el Mercadillo Vecinal y el Artesanal",
      description: "Pedir un Permiso anual para la celebración del Mercadillo Vecinal de la plaza de Nuestra Señora de Loreto y del Mercadillo de Artesanía en la Plaza de Barajas (excepto en agosto)."},
    { category: "COMERCIO",
      name: "Promover anualmente el comercio en Barajas",
      description: "Realizar un Plan Anual de Fomento y Apoyo del Comercio Local en Barajas."},
    { category: "COMERCIO",
      name: "Difundir el comercio y la actividad empresarial del distrito en la página web de la Junta Municipal",
      description: "Que en la página web de la Junta Municipal de Barajas se cree directorio de comercios y empresas del distrito."},
    { category: "DEPORTE",
      name: "Ampliación del Centro Polideportivo Municipal de Barajas",
      description: "Una vez realizada la Junta de Compensación de los terrenos situados desde el Centro Deportivo Municipal Barajas hasta el aparcamiento de larga estancia del aeropuerto y estando aprobada la cesión de los terrenos colindantes, 6.148 m2 (ver anexo), solicitamos que sean integrados en el polideportivo para ampliar las instalaciones con cuatro pistas de pádel con grada y cubiertas. "},
    { category: "DEPORTE",
      name: "Implantar un servicio de fisioterapia en el Centro Deportivo Municipal Barajas",
      description: "Poner en marcha un servicio de fisioterapia, con dotación de personal suficiente, en el Centro Deportivo Municipal Barajas."},
    { category: "DEPORTE",
      name: "Arreglar el acceso peatonal al Centro Deportivo Municipal Barajas",
      description: "Adecuar la acera y la zona ajardinada en la Avda. de Logroño, frente a la entrada peatonal del Centro Deportivo Municipal Barajas."},
    { category: "DEPORTE",
      name: "Creación de un centro de patinaje",
      description: "Desde hace algo más de 8 años, la Asociación Madridpatina lleva solicitando un espacio donde poder desarrollar actividades relacionadas con el patinaje. Un deporte que tiene una gran demanda en el distrito y que actualmente se cubre gracias al acuerdo que tiene la Asociación Madridpatina con el Parque Juan Carlos I para impartir clases en el parking del auditorio."},
    { category: "DEPORTE",
      name: "Crear un servicio de alquiler de bicicletas en Barajas y fomentar su utilización",
      description: "Pedimos la creación de un sistema de alquiler de bicicletas para todas las personas que viven en el distrito de Barajas, así como el fomento del uso de la bicicleta para nuestros barrios."},
    { category: "DEPORTE",
      name: "Mejorar el asfaltado del Parque Juan Carlos I",
      description: "El Parque Juan Carlos I es usado desde hace muchos años tanto por peatones como por bicicletas, así como por patinadores. Se propone el estudio para mejorar la calidad del suelo en su totalidad o solo en un lateral (tipo carril bici) del Paseo de las Estaciones, que tiene un total de 3,14 km. en forma de círculo."},
    { category: "DEPORTE",
      name: "Reforma y adecuación integral de la Instalación Deportiva Municipal Básica del Barrio del Aeropuerto",
      description: "Reforma y acondicionamiento integral de la Instalación Deportiva Municipal Básica del Barrio del Aeropuerto, dotándola de todas las áreas y espacios necesarios para la práctica, el aprendizaje y la competición de varios deportes, cumpliendo con toda la legislación vigente y que pueda ser usada, tanto por escuelas deportivas, como para el ocio y disfrute todos los vecinos."},
    { category: "DEPORTE",
      name: "Mejorar, por parte de la Junta Municipal, la difusión de los eventos deportivos de las asociaciones",
      description: "Mejorar, por parte de la Junta Municipal, la difusión de los eventos deportivos de las asociaciones."},
    { category: "MEDIO AMBIENTE",
      name: "Mejorar la limpieza del distrito",
      description: "Es imprescindible acabar con la suciedad en todos los barrios del distrito y llevar a cabo una limpieza constante."},
    { category: "MEDIO AMBIENTE",
      name: "Crear bosques urbanos en el distrito",
      description: "La propuesta consiste en que el Ayuntamiento de Madrid ponga los menos impedimentos burocráticos posibles, promueva, fomente y ayude al desarrollo de bosques urbanos naturales en las diferentes zonas del distrito, que se llevarían a cabo por los propios vecinos voluntarios de forma desinteresada. Para ello se pide que se les permita plantar árboles y arbustos y que los cuiden, con el fin de desarrollar bosques urbanos naturales, dejando que la naturaleza actúe y recupere parte del espacio perdido."},
    { category: "URBANISMO",
      name: "Recuperar la Plaza de Nuestra Señora de Loreto",
      description: "Recuperación de la Plaza de Nuestra Señora de Loreto como espacio para el pequeño comercio y potenciación de la misma como un nuevo referente para el distrito."},
    { category: "URBANISMO",
      name: "Peatonalizar la Plaza Mayor de Barajas",
      description: "Realizar un plan integral para la peatonalización de la Plaza Mayor y de parte de los viales del casco histórico de Barajas, a partir de la creación de la vía de circunvalación de este último."},
    { category: "URBANISMO",
      name: "Finalización de la Vía Verde de la Gasolina",
      description: "El Ayuntamiento considero finalizadas las obras de la Vía Verde de la Gasolina en 2008, pero quedan pendientes actuaciones."},
    { category: "URBANISMO",
      name: "Ampliación de la Vía Verde de la Gasolina",
      description: "Ampliación de la Vía Verde de la Gasolina en todo el antiguo recorrido del Tren de la Gasolina."},
    { category: "URBANISMO",
      name: "Rehabilitación integral de las viviendas del Barrio del Aeropuerto",
      description: "El Barrio del Aeropuerto es una de las zonas más desfavorecidas de todo el distrito, por lo que necesita ya una rehabilitación integral."},
    { category: "URBANISMO",
      name: "Rehabilitar el Bloque Ezequiel Peñalver y su entorno",
      description: "El Bloque Ezequiel Peñalver se encuentra en un estado lamentable, por lo que urge su rehabilitación y la urbanización de su entorno."},
    { category: "SALUD",
      name: "(NO ES COMPETENCIA MUNICIPAL) Reabrir el servicio de urgencias",
      description: "Solicitamos la reapertura inmediata del servicio de urgencias 24 horas y todos los días de la semana, servicio que quedó limitado a los fines de semana desde hace varios años. Dicha reapertura debe ir acompañada de servicio de radiología y especialistas en pediatría."},
    { category: "SALUD",
      name: "(NO ES COMPETENCIA MUNICIPAL) Implantar un dispensario sanitario en el Barrio del Aeropuerto",
      description: "Solicitamos que se dote al Barrio del Aeropuerto con un dispensario sanitario que preste servicio de medicina, al menos dos días a la semana, y servicio de enfermería, al menos una vez a la semana."},
    { category: "SALUD",
      name: "(NO ES COMPETENCIA MUNICIPAL) Construcción de un nuevo centro de salud",
      description: "Se solicita la construcción de un nuevo centro de salud en el distrito de Barajas."},
    { category: "SALUD",
      name: "(NO ES COMPETENCIA MUNICIPAL) Mejorar la ubicación e infraestructura del centro de salud mental",
      description: "Se solicita que se mejore la ubicación e infraestructura de centro de salud mental, dado que el actual se encuentra en un primer piso sin ascensor y un local adyacente para atender a los pacientes con movilidad restringida. Por ello, es necesario buscar un emplazamiento adecuado en el distrito de Barajas, con un centro amplio y accesible."},
    { category: "SALUD",
      name: "Creación de un Centro Madrid Salud",
      description: "Solicitamos la creación de un Centro Madrid Salud con el objetivo de impulsar las actividades de promoción y prevención de la salud en nuestro distrito. Actualmente se está desarrollando desde el Centro Madrid Salud Hortaleza. Desde esta comisión creemos que el tener un centro cercano, mejoraría la accesibilidad a los distintos programas que realizan e instamos a que vuelvan a realizarse los controles ginecológicos para prevención del cáncer ginecológico, que anteriormente realizaban."},
    { category: "SALUD",
      name: "(NO ES COMPETENCIA MUNICIPAL) Construcción de un centro de especialidades",
      description: "Solicitamos la construcción de un Centro de especialidades en el distrito de Barajas."},
    { category: "SALUD",
      name: "(NO ES COMPETENCIA MUNICIPAL) Incremento del número de médicos, reposición de plazas y psicólogo/a para adultos en el centro de salud mental.",
      description: "Solicitamos el aumento del número de médicos en el centro de salud de Barajas, así como cubrir las bajas de los médicos por enfermedad o en período vacacional de los centros sanitarios. También, la dotación de un psicólogo/a más para adultos en el centro de salud mental." },
    { category: "MOVILIDAD",
      name: "Construir un aparcamiento disuasorio en el Metro Barajas",
      description: "Dado el gran número de vehículos privados que cruzan el distrito, sería necesaria la construcción de un aparcamiento disuasorio en el Metro de Barajas, que también podría servir de intercambiador de transporte público."},
    { category: "MOVILIDAD",
      name: "Implantar un autobús directo al Hospital Ramón y Cajal",
      description: "Solicitamos una línea de autobús que conecte de forma directa el distrito con el Hospital Universitario Ramón y Cajal. El objetivo que se persigue es que los vecinos de los diferentes barrios del distrito, tengan un transporte directo con el hospital de referencia, de forma que se mejore el servicio que se presta en la actualidad, reduciendo considerablemente la duración del trayecto."},
    { category: "PARTICIPACIÓN",
      name: "Proporcionar locales o espacios municipales a las asociaciones y colectivos del distrito",
      description: "Utilización de espacios municipales que sea posible adaptar para las asociaciones y colectivos del distrito."},
    { category: "PARTICIPACIÓN",
      name: "Prohibir la cesión de explotación en las casetas de las fiestas",
      description: "La adjudicación de las casetas en las fiestas del distrito (Nuestra Señora de la Soledad) deben ser adjudicadas con la condición de que la asociación o partido político no la de en cesión de explotación a una empresa privada, con el fin de lucrarse."},
    { category: "PARTICIPACIÓN",
      name: "Desarrollar el capítulo de “Gobierno Abierto, Datos Abiertos”",
      description: "Ante la deficiencia informativa de la página web del distrito, proponemos que se empiece a trabajar en el capítulo de GOBIERNO ABIERTO, DATOS ABIERTOS."},
    { category: "PARTICIPACIÓN",
      name: "Reformar el reglamento de la Junta Municipal",
      description: "Para hacer más eficientes los plenos."},
    { category: "PARTICIPACIÓN",
      name: "Presentar públicamente los presupuestos",
      description: "Solicitamos que se haga una presentación pública de los presupuestos definitivos de cada año."},
    { category: "JUVENTUD",
      name: "Crear una Casa de la Juventud o Centro Joven de Barajas",
      description: "Crear una Casa o Centro Joven en el distrito, un espacio multiusos donde los jóvenes puedan realizar diferentes actividades y en donde participen asociaciones juveniles. Posibilidad de que sea en la Casa de Oficios/Escuela Municipal de Música tras la creación de una nueva dotación en la Huerta Valenciana."},
    { category: "JUVENTUD",
      name: "Crear el Punto Joven Alameda: rocódromo y skatepark",
      description: "Esta propuesta de Punto Joven pretende crear un espacio de ocio saludable y un punto de encuentro para jóvenes y gente de todas las edades, que contaría con un rocódromo y un skatepark, integrado en la zona verde del Metro de El Capricho y rehabilitando una zona actualmente degradada."}
  ]


  SAN_BLAS_2017_SHORT_DESCRIPTION = ""

  SAN_BLAS_2017_OPTIONS = [
    { category: "EDUCACIÓN",
      name: "(NO ES COMPETENCIA MUNICIPAL) Construir IES en el Barrio de las Rejas" },
    { category: "EDUCACIÓN",
      name: "(NO ES COMPETENCIA MUNICIPAL) Construir nuevo colegio en las Rejas " },
    { category: "EDUCACIÓN",
      name: "Reformular cuotas, pliegos y ratios escuelas educación infantil" },
    { category: "EDUCACIÓN",
      name: "(NO ES COMPETENCIA MUNICIPAL) Construir 2ªFase IES Alfredo Kraus" },
    { category: "EDUCACIÓN",
      name: "(NO ES COMPETENCIA MUNICIPAL) Garantizar acceso Universidad a personas en riesgo de exclusión " },
    { category: "EDUCACIÓN",
      name: "(NO ES COMPETENCIA MUNICIPAL) Recuperar profesores apoyo, orientadores y profesores de servicios a la comunidad en colegios e institutos" },
    { category: "EDUCACIÓN",
      name: "Poner personal de limpieza en horario lectivo" },
    { category: "EDUCACIÓN",
      name: "Incrementar educadores sociales" },
    { category: "EDUCACIÓN",
      name: "Mejorar mantenimiento de los colegios públicos" },
    { category: "EDUCACIÓN",
      name: "Hacer gratuita la educación de 0 a 3 años" },
    { category: "EDUCACIÓN",
      name: "(NO ES COMPETENCIA MUNICIPAL) Revisar o suprimir la ley educativa (LOMCE) " },
    { category: "EDUCACIÓN",
      name: "(NO ES COMPETENCIA MUNICIPAL) Eliminar asignatura de religión en horario lectivo" },
    { category: "EQUIDAD",
      name: "Incrementar personal a los Servicios Sociales" },
    { category: "EQUIDAD",
      name: "Dotar de presupuesto a las asociaciones que trabajan con personas en exclusión social " },
    { category: "EQUIDAD",
      name: "Paquete de medidas para combatir la pobreza" },
    { category: "EQUIDAD",
      name: "Mejorar la protección a las víctimas de violencia de género y a sus familias" },
    { category: "EQUIDAD",
      name: "Fomentar el acogimiento familiar de menores tutelados" },
    { category: "EQUIDAD",
      name: "(NO ES COMPETENCIA MUNICIPAL) Agilizar las valoraciones de dependencia y dotarla de mayores recursos" },
    { category: "EQUIDAD",
      name: "Garantizar recursos básicos para cualquier persona" },
    { category: "EQUIDAD",
      name: "(NO ES COMPETENCIA MUNICIPAL) No más desahucios por parte de los bancos" },
    { category: "EQUIDAD",
      name: "Garantizar alquileres dignos" },
    { category: "CULTURA",
      name: "Garantizar la gestión municipal directa de los centros culturales" },
    { category: "CULTURA",
      name: "Facilitar el acceso de la ciudadanía a la gestión cultural" },
    { category: "CULTURA",
      name: "Mejorar la gestión y dotación de medios de los recursos culturales del distrito" },
    { category: "CULTURA",
      name: "Potenciar la iniciativa ciudadana en torno a la cultura" },
    { category: "CULTURA",
      name: "Facilitar espacios de gestión municipal a las entidades culturales del distrito" },
    { category: "CULTURA",
      name: "Facilitar la cesión de uso de los auditorios del distrito" },
    { category: "CULTURA",
      name: "Cesión de espacios cuturales en horario de tarde-noche" },
    { category: "CULTURA",
      name: "Promover el acceso de los jóvenes a la cultura" },
    { category: "CULTURA",
      name: "Mejorar la difusión de las actividades culturales entre los jóvenes" },
    { category: "CULTURA",
      name: "Mejorar la difusión de las actividades de los centros culturales entre la vecindad " },
    { category: "CULTURA",
      name: "Abrir la Finca Torre Arias a actividades culturales y sociales" },
    { category: "CULTURA",
      name: "Garantizar la accesibilidad a las instalaciones culturales" },
    { category: "EMPLEO",
      name: "Instaurar una Oficina de la Agencia Municipal para el Empleo en el Distrito" },
    { category: "EMPLEO",
      name: "Creación de un Observatorio Distrital sobre Empleo, Formación y Actividad Comercial y Productiva" },
    { category: "EMPLEO",
      name: "Impulsar Planes y Acciones de Formación Profesional para el Empleo en el Distrito" },
    { category: "EMPLEO",
      name: "Impulsar el autoempleo, el cooperativismo y la economía social, a nivel municipal y distrital" },
    { category: "EMPLEO",
      name: "Remunicipalización de servicios públicos, incremento de los recursos humanos para la gestión municipal, y concursos de plazas vacantes" },
    { category: "COMERCIO",
      name: "(NO ES COMPETENCIA MUNICIPAL) Moratoria indefinida a la implantación de más Grandes Superficies y Centros Comerciales en el Distrito" },
    { category: "COMERCIO",
      name: "Rediseño de los ejes comerciales y espacios sociales del distrito" },
    { category: "COMERCIO",
      name: "Creación de plazas de aparcamiento y gestión eficaz de zonas de carga y descarga" },
    { category: "COMERCIO",
      name: "Plan Especial de Limpieza y Mantenimiento en los Ejes Comerciales del Distrito" },
    { category: "COMERCIO",
      name: "Apoyo e impulso a las Actividades Comerciales en periodos especiales" },
    { category: "COMERCIO",
      name: "Simplificar los procedimientos administrativos y reducir las limitaciones existentes para la actividad comercial" },
    { category: "COMERCIO",
      name: "Mejorar la seguridad de las zonas comerciales y controlar la venta ilegal" },
    { category: "DEPORTE",
      name: "Remodelación del Polideportivo de San Blas" },
    { category: "DEPORTE",
      name: "Remodelación y rehabilitación de las pistas elementales" },
    { category: "DEPORTE",
      name: "Revertir la gestión indirecta de las instalaciones deportivas" },
    { category: "DEPORTE",
      name: "Plan de hierba artificial para fútbol" },
    { category: "DEPORTE",
      name: "Valorar la necesidad de nuevas instalaciones polideportivas" },
    { category: "DEPORTE",
      name: "Mejora del carril bici" },
    { category: "DEPORTE",
      name: "Nueva piscina cubierta" },
    { category: "DEPORTE",
      name: "Garantizar la accesibilidad de las instalaciones deportivas" },
    { category: "DEPORTE",
      name: "Mejora de los elementos para la práctica del ejercicio en los parques" },
    { category: "MEDIO AMBIENTE",
      name: "Construcción de nuevos parques infantiles y la mejora de los ya existentes" },
    { category: "MEDIO AMBIENTE",
      name: "Regeneración y Gestión sostenible del patrimonio ambiental de la Quinta de Torre Arias y del Distrito, en general, con modelos participativos" },
    { category: "MEDIO AMBIENTE",
      name: "Alternativas a la problemática planteada por la convivencia de animales de compañía (perros) y sus dueños, con el resto de vecinos en la vía pública" },
    { category: "MEDIO AMBIENTE",
      name: "Declaración de la Quinta de Torre Arias como Bien de Interés Cultural" },
    { category: "MEDIO AMBIENTE",
      name: "Residuos Cero: un plan, para que en lugar de crearlos, sean reutilizables y reciclables" },
    { category: "MEDIO AMBIENTE",
      name: "(NO ES COMPETENCIA MUNICIPAL) Eliminación del concepto de perreras de toda la Comunidad, en el sentido de último reducto a donde llegan los animales antes de su muerte" },
    { category: "MEDIO AMBIENTE",
      name: "(NO ES COMPETENCIA MUNICIPAL) Creación de una nueva ley de gestión de residuos sostenible para la ciudadanía" },
    { category: "MEDIO AMBIENTE",
      name: "(NO ES COMPETENCIA MUNICIPAL) Ley estatal contra el maltrato animal" },
    { category: "MEDIO AMBIENTE",
      name: "(NO ES COMPETENCIA MUNICIPAL) Derogación de la nueva y actual Ley de Montes" },
    { category: "URBANISMO",
      name: "Plan de dignificación de Ciudad Pegaso" },
    { category: "URBANISMO",
      name: "Supresión de las barreras arquitéctonicas del distrito" },
    { category: "URBANISMO",
      name: "Intervención para la dignificación en el espacio conocido como Plaza Cívica" },
    { category: "URBANISMO",
      name: "(NO ES COMPETENCIA MUNICIPAL) Intervención en los locales vacios del IVIMA" },
    { category: "URBANISMO",
      name: "Impulsar el cumplimiento de un estricto plan de seguridad de la zona de explotación minera de sepiolita" },
    { category: "URBANISMO",
      name: "(NO ES COMPETENCIA MUNICIPAL) Intervención urgente en edificios abandonados del IVIMA" },
    { category: "URBANISMO",
      name: "(NO ES COMPETENCIA MUNICIPAL) Apertura de la estación de O’Donell" },
    { category: "URBANISMO",
      name: "(NO ES COMPETENCIA MUNICIPAL) Traslado del Cuartel de San Cristóbal, y desarrollo en sus terrenos de un programa alternativo de equipamientos para el Distrito." },
    { category: "URBANISMO",
      name: "(NO ES COMPETENCIA MUNICIPAL) Resolución de los problemas de acceso al distrito de San Blas a la M-40" },
    { category: "SALUD",
      name: "Fomentar la participación ciudadana y la democracia en temas de salud, a través de los Consejos de salud del distrito" },
    { category: "SALUD",
      name: "Dotación económica y facilitación de trámites burocráticos para las organizaciones dedicadas a temas de salud en el distrito" },
    { category: "SALUD",
      name: "Apoyo a Madrid Salud San Blas y al Programa contra la desigualdades sociales" },
    { category: "SALUD",
      name: "Incrementar los servicios de ayuda a domicilio" },
    { category: "SALUD",
      name: " Instar desde el Ayuntamiento la derogación del Plan de Medidas de Garantía de la Sostenibilidad del Sistema Sanitario Público de la Comunidad de Madrid." },
    { category: "SALUD",
      name: "Desarrollar convenios para la creación de unidades de corta estancia" },
    { category: "SALUD",
      name: "(NO ES COMPETENCIA MUNICIPAL) Incremento del personal cualificado en los Centros de Salud" },
    { category: "SALUD",
      name: "(NO ES COMPETENCIA MUNICIPAL) Es imprescindible luchar por tener una Sanidad Pública Universal." },
    { category: "SALUD",
      name: "(NO ES COMPETENCIA MUNICIPAL) Aumentar el número claustro en la Universidad para cubrir las necesidades de personal sanitario cualificado " },
    { category: "MOVILIDAD",
      name: "Instalar  vados peatonales (rebajes adaptados) en todos los bordillos de cruces de aceras de todo el distrito." },
    { category: "MOVILIDAD",
      name: "Permitir el acceso de las bicicletas a las dependencias municipales del distrito" },
    { category: "MOVILIDAD",
      name: "(NO ES COMPETENCIA MUNICIPAL) Dotar de ascensores o de escaleras mecánicas en las estaciones de metro del distrito" },
    { category: "MOVILIDAD",
      name: "Rediseño integral de la red de la EMT, en especial en los barrios periféricos (Rejas, Las Mercedes, etc.)" },
    { category: "MOVILIDAD",
      name: "Limitación a 30 km/h en todas las calles del distrito de un solo carril" },
    { category: "MOVILIDAD",
      name: "Promoción y fomento de la implantación en los centros educativos del Programa Municipal STARS (“Con bici y a pie al Cole”)" },
    { category: "MOVILIDAD",
      name: "Reducir el tiempo de la fase semafórica de paso de vehículo (ganar tiempo peatones) en distintos puntos del distrito" },
    { category: "MOVILIDAD",
      name: "Redistribución del espacio público atendiendo a la prioridad del ciudadano que camina, el que va en bici y en transporte público por encima del coche privado." }
  ]

  desc "Imports the 2017 polls"
  task import_2017: :environment do

    poll_main = Poll.create!(
      name: "Madrid 100% Sostenible, Billete único para el transporte público y Plaza de España",
      starts_at: Date.today,
      ends_at: Date.new(2017, 2, 19),
      geozone_restricted: false
    )
    poll_main.questions.create!(
      author: User.where(username: 'inwit').first || User.first,
      author_visible_name: "inwit",
      title: "¿Estás de acuerdo con la propuesta “Billete único para el transporte público”?",
      proposal: Proposal.where(id: 9).first || nil,
      valid_answers: "Sí,No",
      description: ""
    )
    poll_main.questions.create!(
      author: User.where(username: 'Alianza por el Clima').first || User.first,
      author_visible_name: 'Alianza por el Clima',
      title: "¿Estás de acuerdo con la propuesta “Madrid 100% Sostenible”?",
      proposal: Proposal.where(id: 199).first || nil,
      valid_answers: "Sí,No",
      description: ""
    )

    poll_main.questions.create!(
      author_visible_name: "Ayuntamiento de Madrid",
      author: User.first,
      title: "De los dos proyectos finalistas para reformar la Plaza de España ¿cuál prefieres que se lleve a cabo?",
      valid_answers: "Proyecto X, Proyecto Y",
      description: ""
    )

    poll_gv = Poll.create!(
      name: "Gran Vía",
      starts_at: Date.today,
      ends_at: Date.new(2017, 2, 19),
      geozone_restricted: false
    )
    poll_gv.questions.create!(
      author: User.first,
      author_visible_name: "Ayuntamiento de Madrid",
      title: "¿Estás de acuerdo con mejorar el espacio peatonal de la Gran Vía mediante la ampliación de sus aceras?",
      valid_answers: "Sí,No"
    )
    poll_gv.questions.create!(
      author: User.first,
      author_visible_name: "Ayuntamiento de Madrid",
      title: "¿Consideras necesario mejorar las condiciones de las plazas traseras vinculadas a Gran Vía para que puedan ser utilizadas como espacio de descanso y/o de estancia?",
      valid_answers: "Sí,No"
    )
    poll_gv.questions.create!(
      author: User.first,
      author_visible_name: "Ayuntamiento de Madrid",
      title: "¿Consideras que sería necesario incrementar el número de pasos peatonales de la Gran Vía para mejorar la comunicación peatonal?",
      valid_answers: "Sí,No"
    )
    poll_gv.questions.create!(
      author: User.first,
      author_visible_name: "Ayuntamiento de Madrid",
      title: "¿Estás de acuerdo en que el transporte público colectivo debe mantener su prioridad en la circulación rodada en la Gran Vía?",
      valid_answers: "Sí,No"
    )

    create_2017_district_poll('Barajas',
      title: "Prioriza el Plan Participativo de Actuación Territorial de Barajas",
      valid_answers: (1..BARAJAS_2017_OPTIONS.size).to_a.join(','),
      description: BARAJAS_2017_SHORT_DESCRIPTION +
                   BARAJAS_2017_OPTIONS.each_with_index.map{|o,i| "<h4>#{i+1}. #{o[:category]} - #{o[:name]}</h4><p>#{o[:description]}</p>"}.join("\n")
    )

    create_2017_district_poll('San Blas-Canillejas',
      title: "Prioriza el Plan Participativo de Actuación Territorial de San Blas - Canillejas",
      valid_answers: (1..SAN_BLAS_2017_OPTIONS.size).to_a.join(','),
      description: SAN_BLAS_2017_SHORT_DESCRIPTION +
                   SAN_BLAS_2017_OPTIONS.each_with_index.map{|o,i| "<p>#{i+1}. #{o[:category]} - #{o[:name]}</p>"}.join("\n")
    )

    create_2017_district_poll('Hortaleza', [
      {
        title: "¿Cambiamos el nombre del distrito de Hortaleza a Hortaleza-Canillas?",
        valid_answers: "Sí,No",
        description: ""
      }, {
        title: "¿Debe retomar el actual Parque de Felipe VI a su nombre original Parque Forestal de Valdebebas?",
        valid_answers: "Sí,No",
        description: ""
      }
    ], "Nombre de distrito y Parque Felipe VI en Hortaleza")

    create_2017_district_poll('Retiro', [
      {
        title: "¿Cómo quieres que se llame el Centro Cultural situado en el Mercado de Ibiza, c/ Ibiza 8?",
        valid_answers: "Amparo Barayón,Ángeles García-Madrid,El Buen Mercado de Retiro,Carmen Martín Gaite,Concha García Campoy,Duquesa de Santoña,Fernando Rivero Ramírez,Francisco Bernis Madrazo,José Hierro,Marcos Ana,María Asquerino,Mercado de Ibiza,Pepita Embil Echániz,Ramón J. Sénder,Santiago Ramón y Cajal,Las Sin Sombrero,Zenobia Camprubí"
      }, {
        title: "¿Cómo quieres que se llame el Centro Cultural situado en c/ Luis Peidró 2?",
        valid_answers: "Ángeles García-Madrid,Las Californias,Zenobia Camprubí"
      }, {
        title: "¿Cómo quieres que se llame el Centro Sociocultural situado en la Junta Municipal de Retiro, Avda. Ciudad de Barcelona 164?",
        valid_answers: "Ángeles García-Madrid,Clara Campoamor Rodríguez,Concha García Campoy,Concha Méndez Cuesta,José Hierro,Marcos Ana,María Asquerino,María Casares,Memorial 11M,Las Sin Sombrero"
      }
    ], "Nombres de centros culturales en Retiro")

    create_2017_district_poll('Salamanca', [
      {
        title: "¿Considera que la Junta Municipal del Distrito de Salamanca debe llevar a cabo las acciones necesarias para incrementar la protección de edificios históricos e instar para que se protejan los que actualmente no figuran en el catálogo de bienes protegidos?",
        description: "",
        valid_answers: "Sí,No"
      }
    ])

    create_2017_district_poll('Vicálvaro', [
      {
        title: "¿Cómo quieres que se llame el Espacio de Igualdad del Distrito de Vicálvaro?",
        valid_answers: "María Pacheco,Federica Montseny,Gloria Fuertes,Frida Kahlo",
        description: ""
      }
    ])
  end

  desc "Generates a tsv file for Nvotes. Requires polls to be imported first"
  task generate_2017_nvotes_tsv: :environment do
    output_folder = Rails.root.join('tmp', 'nvotes_tsv_2017')
    FileUtils.rm_rf output_folder
    FileUtils.mkdir output_folder

    POLL_SPECS_2017.each do |spec|
      File.open output_folder.join("#{spec[:nvotes_poll_id]}.tsv"), "w" do |f|
        poll = Poll.where(name: spec[:name]).first!
        f.puts "#Election"
        f.puts "Title\t#{poll.name}"
        f.puts "Id\t#{spec[:nvotes_poll_id]}"
        f.puts "Layout\tsimple"
        f.puts "Share Text\tCompartir en Twitter"
        f.puts ""
        poll.questions.sort_for_list.each do |question|
          description = question.description
          options = question.valid_answers.map{|a| {name: a}}
          if spec[:layout] == 'accordion'
            if spec[:name] =~ /Barajas/
              description = BARAJAS_2017_SHORT_DESCRIPTION
              options = BARAJAS_2017_OPTIONS
            else
              description = SAN_BLAS_2017_SHORT_DESCRIPTION
              options = SAN_BLAS_2017_OPTIONS
            end
          end

          f.puts ""
          f.puts "#Question"
          f.puts "Title\t#{question.title}"
          f.puts "Voting System\tplurality-at-large"
          f.puts "Layout\t#{spec[:layout]}"
          f.puts "Description\t"
          f.puts "Number of winners\t#{spec[:layout] == 'accordion' ? 10 : 1}"
          f.puts "Minimum choices\t0"
          f.puts "Maximum choices\t#{spec[:layout] == 'accordion' ? 10 : 1}"
          f.puts "Randomize options order\tFALSE"
          f.puts "extra: group\t#{question.id}"
          f.puts ""
          f.puts "@Options"
          f.puts "Id\tText"
          options.each_with_index do |option, index|
            name = option[:name]
            name = "#{index+1}. #{name}" if spec[:layout] == 'accordion'
            f.puts "#{index}\t#{name}\t#{option[:description]}\t#{option[:category]}"
          end
        end
      end
    end
    puts "Files have been written in #{output_folder}"
  end

  desc "Adds a valid nvotes_election_id to all generated polls (requires the polls to be imported first)"
  task add_2017_nvotes_poll_id: :environment do
    POLL_SPECS_2017.each do |spec|
      poll = Poll.where(name: spec[:name]).first!
      poll.update!(nvotes_poll_id: spec[:nvotes_poll_id])
    end
  end

  desc "Prints all voter hashes"
  task voter_hashes: :environment do
    puts Poll::Nvote.pluck(:voter_hash)
  end

  desc "Temporarily adds a valid nvotes_election_id to all polls"
  task add_tmp_nvotes_poll_id: :environment do
    Poll.all.each do |poll|
      poll.update(nvotes_poll_id: "128")
    end
  end

  namespace :danger do
    desc "Destroys all polls"
    task destroy_all: :environment do
      Poll::PartialResult.all.destroy_all
      Poll::Question.all.each {|q| q.really_destroy!}
      Poll::Voter.all.destroy_all
      Poll::Nvote.all.each {|n| n.really_destroy!}
      Poll.all.destroy_all
    end
  end

  desc "Runs all necessary tasks to setup polls"
  task setup: :environment do
    Rake::Task["polls:danger:destroy_all"].execute
    Rake::Task["polls:import_2017"].execute
    Rake::Task["polls:add_2017_nvotes_poll_id"].execute
  end

  desc "Migrates data from FinalRecount to TotalResult"
  task migrate_final_recount_total_result: :environment do
    Poll::FinalRecount.all.each do |final_recount|
      author = User.where(email: 'adevapl@madrid.es').first
      total_result = Poll::TotalResult.new
      total_result.booth_assignment = final_recount.booth_assignment
      total_result.officer_assignment = final_recount.officer_assignment
      total_result.amount = final_recount.count
      total_result.amount_log = final_recount.count_log
      total_result.officer_assignment_id_log = final_recount.officer_assignment_id_log
      total_result.date = final_recount.date
      total_result.origin = final_recount.origin
      total_result.author = author
      total_result.author_id_log = ":#{author.id}"
      puts "Error creating TotalResult with ##{final_recount.id} FinalRecount params, #{total_result.errors}" unless total_result.save
    end
  end
end
