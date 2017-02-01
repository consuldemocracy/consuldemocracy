require 'fileutils'

namespace :polls do

  def create_2017_district_poll(geozone_name, questions_attributes)
    questions = Array.wrap(questions_attributes)
    poll = Poll.create!(
      name: questions.size == 1 ? questions[0][:title] : geozone_name,
      starts_at: Date.new(2017, 2, 13),
      ends_at: Date.new(2017, 2, 19),
      geozone_restricted: true
    )
    poll.geozones << Geozone.where(name: geozone_name).first!
    questions.each do |question_attributes|
      Poll::Question.create!(
        { author_visible_name: "Junta de Distrito de #{geozone_name}",
          valid_answers: "",
          poll: poll,
          skip_length_checks: true,
          author: User.first
        }.merge(question_attributes)
      )
    end
  end

  POLL_SPECS_2017 = [ {
        nvotes_poll_id: 100,
        name: 'Billete único, Madrid 100% Sostenible, Plaza de España',
        layout: 'simultaneous-questions'
      }, {
        nvotes_poll_id: 200,
        name: 'Gran Vía',
        layout: 'simultaneous-questions'
      }, {
        nvotes_poll_id: 300,
        name: '¿Cómo quieres que se llame el Espacio de Igualdad del Distrito de Vicálvaro?',
        layout: 'simultaneous-questions'
      }, {
        nvotes_poll_id: 400,
        name: '¿Considera que la Junta Municipal del Distrito de Salamanca debe llevar a cabo las acciones necesarias para incrementar la protección de edificios históricos e instar para que se protejan los que actualmente no figuran en el catálogo de bienes protegidos?',
        layout: 'simultaneous-questions'
      }, {
        nvotes_poll_id: 500,
        name: 'Hortaleza',
        layout: 'simultaneous-questions'
      }, {
        nvotes_poll_id: 600,
        name: 'Prioriza el Plan Participativo de Actuación Territorial de Barajas',
        layout: 'accordion'
      }, {
        nvotes_poll_id: 700,
        name: 'Prioriza el Plan Participativo de Actuación Territorial de San Blas - Canillejas',
        layout: 'accordion'
      }, {
        nvotes_poll_id: 800,
        name: 'Retiro',
        layout: 'simultaneous-questions'
      }
    ]

  BARAJAS_2017_SHORT_DESCRIPTION = %{
<p>Entre 2015 y 2016, la Junta Municipal de Barajas impulsó la realización de un Plan Participativo de Actuación Territorial en el que vecinas, vecinos y entidades sociales plantearon las propuestas que desean que lleve a cabo el actual equipo de gobierno. Dichas propuestas han sido asumidas por la Junta Municipal, incluso aunque en algunos casos no sean competencia del Ayuntamiento de Madrid. Respecto a estas últimas la Junta Municipal se compromete con la ciudadanía a dedicarles los esfuerzos necesarios para que puedan hacerse realidad. Emplazamos a las ciudadanas y ciudadanos de Barajas a que nos indiquen cuáles creen que son las más importantes entre todas ellas.</p>

<p><strong>Las 10 propuestas que tengan mayor número de apoyos serán asumidas por la Junta Municipal como propuestas de máxima prioridad y se realizarán todas las acciones posibles desde la Junta para que se lleven a cabo.</strong></p>

<p>De la siguiente lista de propuestas, marque las que considere más importantes (máximo 10 propuestas).</p>
  }

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


  SAN_BLAS_2017_SHORT_DESCRIPTION = %{
<p>Entre 2015 y 2016, la Junta Municipal de San Blas-Canillejas impulsó la realización de un Plan Participativo de Actuación Territorial en el que vecinas, vecinos y entidades sociales plantearon las propuestas que desean que lleve a cabo el actual equipo de gobierno. Dichas propuestas han sido asumidas por la Junta Municipal, incluso aunque en algunos casos no sean competencia del Ayuntamiento de Madrid. Respecto a estas últimas la Junta Municipal se compromete con la ciudadanía a dedicarles los esfuerzos necesarios para que puedan hacerse realidad. Emplazamos a las ciudadanas y ciudadanos de Barajas a que nos indiquen cuáles creen que son las más importantes entre todas ellas.</p>

<p><strong>Las 10 propuestas que tengan mayor número de apoyos, serán asumidas por la Junta Municipal de San Blas-Canillejas como propuestas de máxima prioridad y se realizarán todas las acciones posibles desde la Junta para que se lleven a cabo.</strong></p>

<p>De las siguientes listas de propuestas, marque las que considere más importantes (máximo 10 propuestas).</p>
  }

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
      name: "Billete único, Madrid 100% Sostenible, Plaza de España",
      starts_at: Date.new(2017, 2, 13),
      ends_at: Date.new(2017, 2, 19),
      geozone_restricted: false
    )
    poll_main.questions.create!(
      author: User.where(username: 'inwit').first || User.first,
      author_visible_name: "inwit",
      title: "¿Estás de acuerdo con la propuesta “Billete único para el transporte público”?",
      proposal: Proposal.where(id: 9).first || nil,
      valid_answers: "Sí,No",
      description: %{
<blockquote><p>Es imprescindible que existan facilidades a la intermodalidad. Cambiar de medio de transporte público sin pagar más, en un periodo amplio (90 minutos al menos), es básico.</p></blockquote>
<p>Esta propuesta bebe de los siguientes debates, que están entre los más valorados:</p>

<p><a href="https://decide.madrid.es/debates/74">https://decide.madrid.es/debates/74</a><p>
<p><a href="https://decide.madrid.es/debates/1772">https://decide.madrid.es/debates/1772</a><p>

<p>y otros.</p>
      }
    )
    poll_main.questions.create!(
      author: User.where(username: 'Alianza por el Clima').first || User.first,
      author_visible_name: 'Alianza por el Clima',
      title: "¿Estás de acuerdo con la propuesta “Madrid 100% Sostenible”?",
      proposal: Proposal.where(id: 199).first || nil,
      valid_answers: "Sí,No",
      description: %{
<blockquote><p>Queremos un Madrid que no amanezca con una boina de contaminación gris, que desafíe a las eléctricas, potencie las renovables y se asegure de que a ninguna familia le corten la luz este invierno.</p></blockquote>

<p>¿Cómo?</p>

<p>Pidiéndole al Ayuntamiento de Madrid que se comprometa a<strong> firmar el manifiesto "MADRID CIUDAD SOSTENIBLE"</strong></u><strong> y a ponerlo en marcha -- </strong>Exigimos el cumplimiento de los 14 puntos siguientes:</p>

<ol>
<li>Desarrollar campañas de sensibilización, formación y <strong>fomento de la cultura energética </strong>en todos los ámbitos de la ciudad.</li>
<li>Contratar la <strong>energía eléctrica municipal con garantía de origen 100% renovable.</strong>
</li>
<li>Establecer un equipo de trabajo transversal para la <strong>elaboración, ejecución y seguimiento de los planes estratégicos.</strong>
</li>
<li>Facilitar la obtención de forma regular de los <strong>datos energéticos y económicos</strong> necesarios para su gestión.</li>
<li>
<strong>Diseñar e implantar acciones de eficiencia energética en las instalaciones municipales</strong> priorizando cambios de hábitos para eliminar los derroches en el consumo. Los ahorros conseguidos por el cambio de hábitos se invertirán, en parte o en su totalidad, en nuevas medidas de eficiencia energética.</li>
<li>
<strong>Implantar programas de eficiencia energética en los centros educativos</strong>, como el proyecto 50/50 -- consistente en devolver el 50% de los ahorros a la escuela y revertir la otra mitad en nuevas medidas de ahorro, eficiencia y renovables en el mismo centro.</li>
<li>
<strong>Aplicar medidas de lucha contra la pobreza energética</strong>: tramitación del bono social, etc.</li>
<li>Diseñar y ejecutar todas las <strong>construcciones u obras municipales nuevas con criterios de consumo de energía casi nulo.</strong>
</li>
<li>
<strong>Implementar acciones de movilidad sostenible</strong>: fomento de transporte público, uso de vehículos sostenibles, peatonalización de las calles,etc.</li>
<li>Diseñar un plan para sustituir paulatinamente por <strong>vehículos eléctricos</strong> todo el parque móvil dedicado al  transporte público y los vehículos municipales.</li>
<li>Establecer <strong>medidas fiscales de fomento de la eficiencia energética </strong>y las energías renovables.</li>
<li>Revisar las ordenanzas municipales para <strong>favorecer los sistemas de auto-abastecimiento energético </strong>a partir de energías renovables.</li>
<li>Generar <strong>un modelo urbanístico sostenible mediante la paralización de los procesos especulativos.</strong>
</li>
<li>
<strong>Hacer una gestión sostenible de los Residuos Sólidos Urbanos</strong>.</li>
</ol>

<p>*Propuesta impulsada por Alianza por el Clima -- plataforma formada por más de 400 organizaciones que luchan contra el cambio climático global alrededor de la Cumbre de París, que se celebrará el 30 de Noviembre de este año.</p>
        <p>
      }
    )

    poll_main.questions.create!(
      author_visible_name: "Ayuntamiento de Madrid",
      skip_length_checks: true,
      author: User.first,
      title: "De los dos proyectos finalistas para reformar la Plaza de España ¿cuál prefieres que se lleve a cabo?",
      valid_answers: "Proyecto X, Proyecto Y",
      description: %{
        <p>El pasado 14 de diciembre se convocó un grupo de trabajo multidisciplinar (asociaciones de vecinos, urbanistas, hoteleros, técnicos del Ayuntamiento, etc), que decidió las preguntas clave que habría que resolver para definir la nueva Plaza de España. Desde el 28 de enero esas preguntas han estado disponibles aquí para que cualquier madrileño las responda, y las respuestas mayoritarias se han convertido en las bases obligatorias del concurso internacional de remodelación de Plaza España.</p>
        <p>Todos los proyectos presentados han sido publicados en la web para ser debatidos y valorados. Un jurado ha elegido cinco de ellos, que serán desarrollados, y posteriormente dos finalistas. Finalmente será la gente de Madrid la que vote entre esos dos decidiendo el proyecto final a ejecutar.</p>
        <ul>
          <li><a href="https://decide.madrid.es/proceso/plaza-espana/proyectos/38">Proyecto X: Welcome mother Nature</a></li>
          <li><a href="https://decide.madrid.es/proceso/plaza-espana/proyectos/22">Proyecto Y: UN PASEO POR LA CORNISA</a></li>
        </ul>
      }
    )

    poll_gv = Poll.create!(
      name: "Gran Vía",
      starts_at: Date.new(2017, 2, 13),
      ends_at: Date.new(2017, 2, 19),
      geozone_restricted: false
    )
    poll_gv.questions.create!(
      author: User.first,
      author_visible_name: "Ayuntamiento de Madrid",
      skip_length_checks: true,
      title: "¿Estás de acuerdo con mejorar el espacio peatonal de la Gran Vía mediante la ampliación de sus aceras?",
      valid_answers: "Sí,No"
    )
    poll_gv.questions.create!(
      author: User.first,
      author_visible_name: "Ayuntamiento de Madrid",
      skip_length_checks: true,
      title: "¿Consideras necesario mejorar las condiciones de las plazas traseras vinculadas a Gran Vía para que puedan ser utilizadas como espacio de descanso y/o de estancia?",
      valid_answers: "Sí,No"
    )
    poll_gv.questions.create!(
      author: User.first,
      author_visible_name: "Ayuntamiento de Madrid",
      skip_length_checks: true,
      title: "¿Consideras que sería necesario incrementar el número de pasos peatonales de la Gran Vía para mejorar la comunicación peatonal?",
      valid_answers: "Sí,No"
    )
    poll_gv.questions.create!(
      author: User.first,
      author_visible_name: "Ayuntamiento de Madrid",
      skip_length_checks: true,
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
        description: %{
<p>Es en los siglos XII y XIII cuando aparecen los nombres de Hortaleza y Canillas, asentamientos que nacieron al noreste de la Villa de Madrid, como consecuencia de la repoblación castellana llevada a cabo para asentar el territorio conquistado a las tropas musulmanas.<p>
<p>Hasta el siglo XX Hortaleza y Canillas contaron con Ayuntamientos propios e independientes. Es en 1950 cuando el antiguo municipio de Canillas fue absorbido por Madrid, dentro del proyecto denominado Gran Madrid. Un día después sucedió lo mismo con Hortaleza.</p>
<p>Al contrario que el resto de municipios absorbidos a la capital, como Hortaleza, Vallecas, los Carabancheles, Vicálvaro o Villaverde, Canillas continua desaparecido del mapa administrativo de la capital.</p>
<p><strong>La respuesta que cuente con mayor número de apoyos será la que la Concejala-Presidenta llevará al Pleno del Ayuntamiento para su votación.</strong></p>
}
      }, {
        title: "¿Debe retomar el actual Parque de Felipe VI a su nombre original Parque Forestal de Valdebebas?",
        valid_answers: "Sí,No",
        description: "<p><strong>La respuesta que cuente con mayor número de apoyos será la que la Concejala-Presidenta llevará al Pleno del Ayuntamiento para su votación.</strong></p>"
      }
    ])

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
    ])

    create_2017_district_poll('Salamanca', [
      {
        title: "¿Considera que la Junta Municipal del Distrito de Salamanca debe llevar a cabo las acciones necesarias para incrementar la protección de edificios históricos e instar para que se protejan los que actualmente no figuran en el catálogo de bienes protegidos?",
        description: %{
          <p>El Distrito de Salamanca cuenta con un número importante de edificios con alto valor histórico y patrimonial. En la actualidad, algunos de ellos figuran en el catálogo de bienes protegidos del Ayuntamiento de Madrid, que establece su grado de protección. Sin embargo, existen inmuebles que actualmente están fuera de este listado o cuyo nivel de protección es demasiado bajo. Es por esto que, desde la Junta Municipal del Distrito de Salamanca, se consulta a la población si considera que esta línea de preservación de los elementos que conforman la historia de la ciudad de Madrid debería incluirse en las líneas y prioridades de trabajo de esta administración</p>
          <p><strong>La respuesta que cuente con mayor número de votos será la que se lleve a cabo.</strong></p>
        },
        valid_answers: "Sí,No"
      }
    ])

    create_2017_district_poll('Vicálvaro', [
      {
        title: "¿Cómo quieres que se llame el Espacio de Igualdad del Distrito de Vicálvaro?",
        valid_answers: "María Pacheco,Federica Montseny,Gloria Fuertes,Frida Kahlo",
        description: %{
<p>Durante el último trimestre de 2016 se realizó un proceso participativo presencial apoyado en redes en el que se solicitaban sugerencias para la preselección de nombres para el Espacio de Igualdad de Vicálvaro y enero de 2017 se ha contado además con la participación de las entidades de mujeres. Como resultado de estas consultas se ha llegado a las cuatro propuestas siguientes, dos de ellas surgidos del proceso inicial de selección y otras dos aportadas por las entidades.</p>

<p><strong>El nombre que cuente con mayor número de apoyos será la que se utilizará para designar al Espacio de Igualdad del Distrito de Vicálvaro.</strong></p>

<p>Información adicional sobre las personas cuyos nombres se proponen para de Espacio de Igualdad del Distrito de Vicálvaro:</p>

<ul>

<li><strong>María Pacheco</strong> (<a href="https://es.wikipedia.org/wiki/Granada_(Espa%C3%B1a)">Granada</a>,
<a href="https://es.wikipedia.org/wiki/1497">1497</a>
- <a href="https://es.wikipedia.org/wiki/Oporto">Oporto</a>,
<a href="https://es.wikipedia.org/wiki/Portugal">Portugal</a>,
<a href="https://es.wikipedia.org/wiki/1531">1531</a>),
de nombre completo María Pacheco y Mendoza. Noble <a href="https://es.wikipedia.org/wiki/Castilla">castellana</a>.
Fue esposa del general comunero <a href="https://es.wikipedia.org/wiki/Juan_de_Padilla">Juan
de Padilla</a>;
tras la muerte de su marido asumió desde <a href="https://es.wikipedia.org/wiki/Toledo">Toledo</a>
el mando de la sublevación de las <a href="https://es.wikipedia.org/wiki/Comunidades_de_Castilla">Comunidades
de Castilla</a>
hasta que capituló ante el rey <a href="https://es.wikipedia.org/wiki/Carlos_I_de_Espa%C3%B1a">Carlos
I de España y V del Sacro Imperio Romano Germánico</a>
en febrero de <a href="https://es.wikipedia.org/wiki/1522">1522</a>.</li>

<li><strong>Federica Montseny Mañé</p> (<a href="https://es.wikipedia.org/wiki/Madrid">Madrid</a>,
<a href="https://es.wikipedia.org/wiki/Espa%C3%B1a">España</a>;
<a href="https://es.wikipedia.org/wiki/12_de_febrero">12
de febrero</a>
de <a href="https://es.wikipedia.org/wiki/1905">1905</a>
<a href="https://es.wikipedia.org/wiki/Toulouse">Toulouse</a>,
<a href="https://es.wikipedia.org/wiki/Francia">Francia</a>;
<a href="https://es.wikipedia.org/wiki/14_de_enero">14
de enero</a>
de <a href="https://es.wikipedia.org/wiki/1994">1994</a>)
fue una <a href="https://es.wikipedia.org/wiki/Pol%C3%ADtico">política</a>
y <a href="https://es.wikipedia.org/wiki/Sindicalista">sindicalista</a>
<a href="https://es.wikipedia.org/wiki/Anarquista">anarquista</a>
<a href="https://es.wikipedia.org/wiki/Espa%C3%B1a">española</a>,
ministra durante la <a href="https://es.wikipedia.org/wiki/II_Rep%C3%BAblica_espa%C3%B1ola">II
República española</a>,
siendo la primera mujer en ocupar un cargo ministerial en <a href="https://es.wikipedia.org/wiki/Espa%C3%B1a">España</a>
y una de las primeras en <a href="https://es.wikipedia.org/wiki/Europa_Occidental">Europa
Occidental</a>.Publicó casi cincuenta novelas cortas con trasfondo romántico-social
dirigidas concretamente a las mujeres de la clase proletaria, así
como escritos políticos, éticos, biográficos y autobiográficos.</li>

<li><strong>Gloria Fuertes García</strong> (<a href="https://es.wikipedia.org/wiki/Madrid">Madrid</a>,
<a href="https://es.wikipedia.org/wiki/28_de_julio">28
de julio</a>
de <a href="https://es.wikipedia.org/wiki/1917">1917</a>
- <a href="https://es.wikipedia.org/wiki/Ib%C3%ADdem">ibídem</a>,
<a href="https://es.wikipedia.org/wiki/27_de_noviembre">27
de noviembre</a>
de <a href="https://es.wikipedia.org/wiki/1998">1998</a>)
fue una poeta <a href="https://es.wikipedia.org/wiki/Espa%C3%B1a">española</a>
y autora de <a href="https://es.wikipedia.org/wiki/Literatura_infantil_y_juvenil">literatura
infantil y juvenil</a></li>

<li><strong>Magdalena Carmen Frida Kahlo Calderón</strong> (<a href="https://es.wikipedia.org/wiki/Coyoac%C3%A1n">Coyoacán</a>,
<a href="https://es.wikipedia.org/wiki/6_de_julio">6
de julio</a>
de <a href="https://es.wikipedia.org/wiki/1907">1907</a>-
<a href="https://es.wikipedia.org/wiki/Ib%C3%ADdem">Ib.</a>,
<a href="https://es.wikipedia.org/wiki/13_de_julio">13
de julio</a>
de <a href="https://es.wikipedia.org/wiki/1954">1954</a>)
fue una <a href="https://es.wikipedia.org/wiki/Pintura">pintora</a>
y <a href="https://es.wikipedia.org/wiki/Poes%C3%ADa">poetisa</a>
<a href="https://es.wikipedia.org/wiki/Mexicana">mexicana</a>.
Casada con el célebre muralista mexicano <a href="https://es.wikipedia.org/wiki/Diego_Rivera">Diego
Rivera</a>,
su vida estuvo marcada por el infortunio de contraer <a href="https://es.wikipedia.org/wiki/Poliomielitis">poliomielitis</a>
y después por un grave accidente en su juventud que la mantuvo
postrada en cama durante largos periodos, llegando a someterse hasta
a 32 operaciones quirúrgicas. Llevó una vida poco convencional, fue
<a href="https://es.wikipedia.org/wiki/Bisexual">bisexual</a> y
entre sus amantes se encontraba <a href="https://es.wikipedia.org/wiki/Le%C3%B3n_Trotski">León
Trotski</a>. Su obra pictórica gira temáticamente en torno a su biografía y a
su propio sufrimiento. Fue autora de unas 200 obras, principalmente
autorretratos, en los que proyectó sus dificultades por sobrevivir.
La obra de Kahlo está influenciada por su esposo, el reconocido
pintor <a href="https://es.wikipedia.org/wiki/Diego_Rivera">Diego
Rivera</a>, con el que compartió su gusto por el arte popular mexicano de raíces
indígenas, inspirando a otros pintores y pintoras mexicanos del
periodo postrevolucionario</li>

</ul>

}

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
          f.puts "Description\t#{description.try(:gsub, "\n", '')}"
          f.puts "Number of winners\t#{spec[:layout] == 'accordion' ? 10 : 1}"
          f.puts "Minimum choices\t0"
          f.puts "Maximum choices\t#{spec[:layout] == 'accordion' ? 10 : 1}"
          f.puts "Randomize options order\tFALSE"
          f.puts "@Options"
          options.each_with_index do |option, index|
            name = option[:name]
            name = "#{index+1}. #{name}" if spec[:layout] == 'accordion'
            f.puts "#{index+1}\t#{name}\t#{option[:description]}\t#{option[:category]}"
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
    puts "All polls updated"
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
      Poll.all.destroy_all
    end
  end
end
