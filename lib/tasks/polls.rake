namespace :polls do

  def create_2017_district_poll(geozone_name, attributes)
    poll = Poll.create!(
      name: geozone_name,
      starts_at: Date.new(2017, 2, 13),
      ends_at: Date.new(2017, 2, 19),
      geozone_restricted: true
    )
    poll.geozones << Geozone.where(name: geozone_name).first!
    Array.wrap(attributes).each do |attributes|
      Poll::Question.create!(
        { author_visible_name: "Junta de Distrito de #{geozone_name}",
          valid_answers: "",
          poll: poll,
          skip_length_checks: true,
          author: User.first
        }.merge(attributes)
      )
    end
  end

  desc "Imports the 2017 polls"
  task import_2017: :environment do

    poll_bu = Poll.create!(
      name: "Billete único para el transporte público",
      starts_at: Date.new(2017, 2, 13),
      ends_at: Date.new(2017, 2, 19),
      geozone_restricted: false
    )
    poll_bu.questions.create!(
      author: User.where(username: 'inwit').first || User.first,
      author_visible_name: "inwit",
      title: "Billete único para el transporte público",
      summary: "Es imprescindible que existan facilidades a la intermodalidad. Cambiar de medio de transporte público sin pagar más, en un periodo amplio (90 minutos al menos), es básico.",
      proposal: Proposal.where(id: 9).first || nil,
      valid_answers: "Sí,No",
      description: %{
<p>Esta propuesta bebe de los siguientes debates, que están entre los más valorados:</p>

<p><a href="https://decide.madrid.es/debates/74">https://decide.madrid.es/debates/74</a><p>
<p><a href="https://decide.madrid.es/debates/1772">https://decide.madrid.es/debates/1772</a><p>

<p>y otros.</p>
      }
    )

    poll_m100 = Poll.create!(
      name: "Madrid 100% Sostenible",
      starts_at: Date.new(2017, 2, 13),
      ends_at: Date.new(2017, 2, 19),
      geozone_restricted: false
    )
    poll_m100.questions.create!(
      author: User.where(username: 'Alianza por el Clima').first || User.first,
      author_visible_name: 'Alianza por el Clima',
      title: "Madrid 100% Sostenible",
      summary: "Queremos un Madrid que no amanezca con una boina de contaminación gris, que desafíe a las eléctricas, potencie las renovables y se asegure de que a ninguna familia le corten la luz este invierno.",
      proposal: Proposal.where(id: 199).first || nil,
      valid_answers: "Sí,No",
      description: %{
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

    poll_pe = Poll.create!(
      name: "Remodelación de Plaza España",
      starts_at: Date.new(2017, 2, 13),
      ends_at: Date.new(2017, 2, 19),
      geozone_restricted: false
    )
    poll_pe.questions.create!(
      author_visible_name: "Ayuntamiento de Madrid",
      skip_length_checks: true,
      author: User.first,
      title: "Votación final ciudadana del proyecto ganador",
      summary: "Proyecto X: Welcome mother Nature, good bye Mr Ford. Proyecto Y: Proyecto Y: UN PASEO POR LA CORNISA",
      valid_answers: "Proyecto X, Proyecto Y",
      description: %{
        <p>El pasado 14 de diciembre se convocó un grupo de trabajo multidisciplinar (asociaciones de vecinos, urbanistas, hoteleros, técnicos del Ayuntamiento, etc), que decidió las preguntas clave que habría que resolver para definir la nueva Plaza de España. Desde el 28 de enero esas preguntas han estado disponibles aquí para que cualquier madrileño las responda, y las respuestas mayoritarias se han convertido en las bases obligatorias del concurso internacional de remodelación de Plaza España.</p>
        <p>Todos los proyectos presentados han sido publicados en la web para ser debatidos y valorados. Un jurado ha elegido cinco de ellos, que serán desarrollados, y posteriormente dos finalistas. Finalmente será la gente de Madrid la que vote entre esos dos decidiendo el proyecto final a ejecutar.</p>
        <ul>
          <li><a href="https://decide.madrid.es/proceso/plaza-espana/proyectos/38">Proyecto X: Welcome mother Nature, good bye Mr Ford</a></li>
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
      summary: "¿Estás de acuerdo con mejorar el espacio peatonal de la Gran Vía mediante la ampliación de sus aceras?",
      valid_answers: "Sí,No"
    )
    poll_gv.questions.create!(
      author: User.first,
      author_visible_name: "Ayuntamiento de Madrid",
      skip_length_checks: true,
      title: "¿Consideras necesario mejorar las condiciones de las plazas traseras vinculadas a Gran Vía para que puedan ser utilizadas como espacio de descanso y/o de estancia?",
      summary: "¿Consideras necesario mejorar las condiciones de las plazas traseras vinculadas a Gran Vía para que puedan ser utilizadas como espacio de descanso y/o de estancia?",
      valid_answers: "Sí,No"
    )
    poll_gv.questions.create!(
      author: User.first,
      author_visible_name: "Ayuntamiento de Madrid",
      skip_length_checks: true,
      title: "¿Consideras que sería necesario incrementar el número de pasos peatonales de la Gran Vía para mejorar la comunicación peatonal?",
      summary: "¿Consideras que sería necesario incrementar el número de pasos peatonales de la Gran Vía para mejorar la comunicación peatonal?",
      valid_answers: "Sí,No"
    )
    poll_gv.questions.create!(
      author: User.first,
      author_visible_name: "Ayuntamiento de Madrid",
      skip_length_checks: true,
      title: "¿Estás de acuerdo en que el transporte público colectivo debe mantener su prioridad en la circulación rodada en la Gran Vía?",
      summary: "¿Estás de acuerdo en que el transporte público colectivo debe mantener su prioridad en la circulación rodada en la Gran Vía?",
      valid_answers: "Sí,No"
    )

    create_2017_district_poll('Barajas',
        title: "Prioriza el Plan Participativo de Actuación Territorial de Barajas",
        summary: %{Las 10 propuestas que tengan mayor número de apoyos serán asumidas por la Junta Municipal como propuestas de
                   máxima prioridad y se realizarán todas las acciones posibles desde la Junta para que se lleven a cabo},
        valid_answers: (1..64).to_a.join(','),
        description: %{
<p>Entre 2015 y 2016, la Junta Municipal de Barajas impulsó la realización de un Plan Participativo de Actuación Territorial en el que vecinas, vecinos y entidades sociales plantearon las propuestas que desean que lleve a cabo el actual equipo de gobierno. Dichas propuestas han sido asumidas por la Junta Municipal, incluso aunque en algunos casos no sean competencia del Ayuntamiento de Madrid. Respecto a estas últimas la Junta Municipal se compromete con la ciudadanía a dedicarles los esfuerzos necesarios para que puedan hacerse realidad. Emplazamos a las ciudadanas y ciudadanos de Barajas a que nos indiquen cuáles creen que son las más importantes entre todas ellas.</p>
<p>De la siguiente lista de propuestas, marque las que considere más importantes (máximo 10 propuestas).</p>
<ul>
<li>1. (CULTURA) Mejorar la oferta cultural, tanto en calidad como en variedad</li>
<li>2. (URBANISMO) Peatonalizar la Plaza Mayor de Barajas</li>
<li>3. (CULTURA) Crear equipamientos culturales en el barrio de Timón</li>
<li>4. (CULTURA) Crear un eje histórico-cultural de la Alameda de Osuna</li>
<li>5. (CULTURA) Recuperar la Casa del Pueblo de Barajas</li>
<li>6. (PARTICIPACIÓN) Proporcionar locales o espacios municipales a las asociaciones y colectivos del distrito</li>
<li>7. (URBANISMO) Recuperar la Plaza de Nuestra Señora de Loreto</li>
<li>8. (JUVENTUD) Crear una Casa de la Juventud o Centro Joven de Barajas</li>
<li>9. (JUVENTUD) Crear el Punto Joven Alameda: rocódromo y skatepark</li>
<li>10. (CULTURA) Reabrir el auditorio del Parque Juan Carlos I y dotarle de uso cultural</li>
<li>11. (DEPORTE) Ampliación del Centro Polideportivo Municipal de Barajas</li>
<li>12. (DEPORTE) Implantar un servicio de fisioterapia en el Centro Deportivo Municipal Barajas</li>
<li>13. (DEPORTE) Arreglar el acceso peatonal al Centro Deportivo Municipal Barajas</li>
<li>14. (DEPORTE) Creación de un centro de patinaje</li>
<li>15. (DEPORTE) Crear un servicio de alquiler de bicicletas en Barajas y fomentar su utilización</li>
<li>16. (DEPORTE) Mejorar el asfaltado del Parque Juan Carlos I</li>
<li>17. (DEPORTE) Reforma y adecuación integral de la Instalación Deportiva Municipal Básica del Barrio del Aeropuerto</li>
<li>18. (DEPORTE) Mejorar, por parte de la Junta Municipal, la difusión de los eventos deportivos de las asociaciones</li>
<li>19. (URBANISMO) Finalización de la Vía Verde de la Gasolina</li>
<li>20. (URBANISMO) Ampliación de la Vía Verde de la Gasolina</li>
<li>21. (MOVILIDAD) Construir un aparcamiento disuasorio en el Metro Barajas</li>
<li>22. (URBANISMO) Rehabilitación integral de las viviendas del Barrio del Aeropuerto</li>
<li>23. (URBANISMO) Rehabilitar el Bloque Ezequiel Peñalver y su entorno</li>
<li>24. (MEDIO AMBIENTE) Mejorar la limpieza del distrito</li>
<li>25. (MEDIO AMBIENTE) Crear bosques urbanos en el distrito</li>
<li>26. (EDUCACIÓN) Garantizar las plazas necesarias de Secundaria y Bachillerato para todos los alumnos de los centros públicos del distrito. Construcción de un nuevo instituto</li>
<li>27. (EDUCACIÓN) Construcción del pabellón deportivo en el CEIP Ciudad de Guadalajara</li>
<li>28. (EDUCACIÓN) Ampliación del comedor del CEIP Ciudad de Zaragoza</li>
<li>29. (EDUCACIÓN) Aumento de plazas y especialidades de FP en el IES Barajas</li>
<li>30. (EDUCACIÓN) Finalización del CEIP Margaret Thatcher</li>
<li>31. (EDUCACIÓN) Gestión pública de las Escuelas Infantiles y aumento de plazas</li>
<li>32. (EDUCACIÓN) Reimplantación del transporte escolar al Barrio del Aeropuerto</li>
<li>33. (EDUCACIÓN) Fortalecimiento del apoyo escolar a los niños con necesidades educativas especiales</li>
<li>34. (EDUCACIÓN) Incrementar las ayudas para libros de texto</li>
<li>35. (EDUCACIÓN) Mejorar el mantenimiento de los centros de enseñanza pública</li>
<li>36. (EDUCACIÓN) Implantar el proyecto “Camino seguro al colegio”</li>
<li>37. (COMERCIO) Crear una galería de alimentación en el Ensanche de Barajas</li>
<li>38. (COMERCIO) Conceder permiso anual para el Mercadillo Vecinal y el Artesanal</li>
<li>39. (EMPLEO) Impulsar la Oficina Municipal de Empleo de Barajas</li>
<li>40. (EMPLEO) Realizar inspecciones de trabajo en todos los comercios de Barajas</li>
<li>41. (EMPLEO) Crear de un Vivero de Empresas para emprendedores</li>
<li>42. (PARTICIPACIÓN) Prohibir la cesión de explotación en las casetas de las fiestas</li>
<li>43. (COMERCIO) Promover anualmente el comercio en Barajas</li>
<li>44. (COMERCIO) Difundir el comercio y la actividad empresarial del distrito en la página web de la Junta Municipal</li>
<li>45. (EQUIDAD) Realizar un estudio pormenorizado de la realidad de nuestros mayores</li>
<li>46. (EQUIDAD) Incrementar la inversión en Servicios Sociales</li>
<li>47. (EQUIDAD) Mejorar el acceso a las prestaciones de la Ley de Dependencia</li>
<li>48. (EQUIDAD) Crear un espacio de encuentro en el Bloque Ezequiel Peñalver</li>
<li>49. (EQUIDAD) Incrementar el personal de los Servicios Sociales</li>
<li>50. (EQUIDAD) Ofrecer consulta bucodental en los Centros de Mayores</li>
<li>51. (EQUIDAD) Realizar mejoras en el Centro de Mayores Acuario</li>
<li>52. (PARTICIPACIÓN) Desarrollar el capítulo de “Gobierno Abierto, Datos Abiertos”</li>
<li>53. (PARTICIPACIÓN) Reformar el reglamento de la Junta Municipal</li>
<li>54. (PARTICIPACIÓN) Presentar públicamente los presupuestos</li>
<li>55. (CULTURA) Recuperación de las fiestas populares de La Alameda de Osuna</li>
<li>56. (CULTURA) Creación del Cine Club Distrito Barajas</li>
<li>57. (MOVILIDAD) Implantar un autobús directo al Hospital Ramón y Cajal</li>
<li>58. (SALUD) Reabrir el servicio de urgencias</li>
<li>59. (SALUD) Implantar un dispensario sanitario en el Barrio del Aeropuerto</li>
<li>60. (SALUD) Construcción de un nuevo centro de salud</li>
<li>61. (SALUD) Mejorar la ubicación e infraestructura del centro de salud mental</li>
<li>62. (SALUD) Creación de un Centro Madrid Salud</li>
<li>63. (SALUD) Construcción de un centro de especialidades</li>
<li>64. (SALUD) Incremento del número de médicos, reposición de plazas y psicólogo/a para adultos en el centro de salud mental.</li>
</ul>
})

      create_2017_district_poll('San Blas-Canillejas',
        title: "Prioriza el Plan Participativo de Actuación Territorial de San Blas - Canillejas",
        summary: %{Las 10 propuestas que tengan mayor número de apoyos, serán asumidas por la Junta Municipal de
                   San Blas-Canillejas como propuestas de máxima prioridad y se realizarán todas las acciones posibles desde la Junta para que se lleven a cabo.},
        valid_answers: ( (1..12).map{|x|"ED#{x}"} +
                         (1..9).map{|x|"EQ#{x}"} +
                         (1..12).map{|x|"CU#{x}"} +
                         (1..5).map{|x|"EM#{x}"} +
                         (1..7).map{|x|"CO#{x}"} +
                         (1..9).map{|x|"DE#{x}"} +
                         (1..9).map{|x|"MA#{x}"} +
                         (1..9).map{|x|"UR#{x}"} +
                         (1..9).map{|x|"SA#{x}"} +
                         (1..8).map{|x|"MO#{x}"} ).join(','),
        description: %{
<p>Entre 2015 y 2016, la Junta Municipal de San Blas-Canillejas impulsó la realización de un Plan Participativo de Actuación Territorial en el que vecinas, vecinos y entidades sociales plantearon las propuestas que desean que lleve a cabo el actual equipo de gobierno. Dichas propuestas han sido asumidas por la Junta Municipal, incluso aunque en algunos casos no sean competencia del Ayuntamiento de Madrid. Respecto a estas últimas la Junta Municipal se compromete con la ciudadanía a dedicarles los esfuerzos necesarios para que puedan hacerse realidad. Emplazamos a las ciudadanas y ciudadanos de Barajas a que nos indiquen cuáles creen que son las más importantes entre todas ellas.</p>

<p>De las siguientes listas de propuestas, marque las que considere más importantes (máximo 10 propuestas).</p>

<p><strong>EDUCACIÓN</strong></p>
<ul>
<li>ED1. Construir IES en el Barrio de las Rejas</li>
<li>ED2. Construir nuevo colegio en las Rejas</li>
<li>ED3. Reformular cuotas, pliegos y ratios escuelas educación infantil</li>
<li>ED4. Construir 2ªFase IES Alfredo Kraus</li>
<li>ED5. Garantizar acceso Universidad a personas en riesgo de exclusión</li>
<li>ED6. Recuperar profesores apoyo, orientadores y profesores de servicios a la comunidad en colegios e institutos</li>
<li>ED7. Poner personal de limpieza en horario lectivo</li>
<li>ED8. Incrementar educadores sociales</li>
<li>ED9. Mejorar mantenimiento de los colegios públicos</li>
<li>ED10. Hacer gratuita la educación de 0 a 3 años</li>
<li>ED11. Revisar o suprimir la ley educativa (LOMCE</li>
<li>ED12. Eliminar asignatura de religión en horario lectivo</li>
</ul>

<p><strong>EQUIDAD</strong></p>
<ul>
<li>EQ1. Incrementar personal a los Servicios Sociales</li>
<li>EQ2. Dotar de presupuesto a las asociaciones que trabajan con personas en exclusión social</li>
<li>EQ3. Paquete de medidas para combatir la pobreza</li>
<li>EQ4. Mejorar la protección a las víctimas de violencia de género y a sus familias</li>
<li>EQ5. Fomentar el acogimiento familiar de menores tutelados</li>
<li>EQ6. Agilizar las valoraciones de dependencia y dotarla de mayores recursos</li>
<li>EQ7. Garantizar recursos básicos para cualquier persona</li>
<li>EQ8. No más desahucios por parte de los bancos</li>
<li>EQ9. Garantizar alquileres dignos</li>
</ul>

<p><strong>CULTURA</strong></p>
<ul>
<li>CU1. Garantizar la gestión municipal directa de los centros culturales</li>
<li>CU2. Facilitar el acceso de la ciudadanía a la gestión cultural</li>
<li>CU3. Mejorar la gestión y dotación de medios de los recursos culturales del distrito</li>
<li>CU4. Potenciar la iniciativa ciudadana en torno a la cultura</li>
<li>CU5. Facilitar espacios de gestión municipal a las entidades culturales del distrito</li>
<li>CU6. Facilitar la cesión de uso de los auditorios del distrito</li>
<li>CU7. Cesión de espacios cuturales en horario de tarde-noche</li>
<li>CU8. Promover el acceso de los jóvenes a la cultura</li>
<li>CU9. Mejorar la difusión de las actividades culturales entre los jóvenes</li>
<li>CU10. Mejorar la difusión de las actividades de los centros culturales entre la vecindad</li>
<li>CU11. Abrir la Finca Torre Arias a actividades culturales y sociales</li>
<li>CU12. Garantizar la accesibilidad a las instalaciones culturales</li>
</ul>

<p><strong>EMPLEO</strong></p>
<ul>
<li>EM1. Instaurar una Oficina de la Agencia Municipal para el Empleo en el Distrito</li>
<li>EM2. Creación de un Observatorio Distrital sobre Empleo, Formación y Actividad Comercial y Productiva</li>
<li>EM3. Impulsar Planes y Acciones de Formación Profesional para el Empleo en el Distrito</li>
<li>EM4. Impulsar el autoempleo, el cooperativismo y la economía social, a nivel municipal y distrital</li>
<li>EM5. Remunicipalización de servicios públicos, incremento de los recursos humanos para la gestión municipal, y concursos de plazas vacantes</li>
</ul>

<p><strong>COMERCIO</strong></p>
<ul>
<li>CO1. Moratoria indefinida a la implantación de más Grandes Superficies y Centros Comerciales en el Distrito</li>
<li>CO2. Rediseño de los ejes comerciales y espacios sociales del distrito</li>
<li>CO3. Creación de plazas de aparcamiento y gestión eficaz de zonas de carga y descarga</li>
<li>CO4. Plan Especial de Limpieza y Mantenimiento en los Ejes Comerciales del Distrito</li>
<li>CO5. Apoyo e impulso a las Actividades Comerciales en periodos especiales</li>
<li>CO6. Simplificar los procedimientos administrativos y reducir las limitaciones existentes para la actividad comercial</li>
<li>CO7. Mejorar la seguridad de las zonas comerciales y controlar la venta ilegal</li>
</ul>

<p><strong>DEPORTE</strong></p>
<ul>
<li>DE1. Remodelación del Polideportivo de San Blas</li>
<li>DE2. Remodelación y rehabilitación de las pistas elementales</li>
<li>DE3. Revertir la gestión indirecta de las instalaciones deportivas</li>
<li>DE4. Plan de hierba artificial para fútbol</li>
<li>DE5. Valorar la necesidad de nuevas instalaciones polideportivas</li>
<li>DE6. Mejora del carril bici</li>
<li>DE7. Nueva piscina cubierta</li>
<li>DE8. Garantizar la accesibilidad de las instalaciones deportivas</li>
<li>DE9. Mejora de los elementos para la práctica del ejercicio en los parques</li>
</ul>

<p><strong>MEDIO AMBIENTE</strong></p>
<ul>
<li>MA1. Construcción de nuevos parques infantiles y la mejora de los ya existentes</li>
<li>MA2. Regeneración y Gestión sostenible del patrimonio ambiental de la Quinta de Torre Arias y del Distrito, en general, con modelos participativos</li>
<li>MA3. Alternativas a la problemática planteada por la convivencia de animales de compañía (perros</li>
<li>MA4. Declaración de la Quinta de Torre Arias como Bien de Interés Cultural</li>
<li>MA5. Residuos Cero: un plan, para que en lugar de crearlos, sean reutilizables y reciclables</li>
<li>MA6. Eliminación del concepto de perreras de toda la Comunidad, en el sentido de último reducto a donde llegan los animales antes de su muerte</li>
<li>MA7. Creación de una nueva ley de gestión de residuos sostenible para la ciudadanía</li>
<li>MA8. Ley estatal contra el maltrato animal</li>
<li>MA9. Derogación de la nueva y actual Ley de Montes</li>
</ul>

<p><strong>URBANISMO</strong></p>
<ul>
<li>UR1. Plan de dignificación de Ciudad Pegaso</li>
<li>UR2. Supresión de las barreras arquitéctonicas del distrito</li>
<li>UR3. Intervención para la dignificación en el espacio conocido como Plaza Cívica</li>
<li>UR4. Intervención en los locales vacios del IVIMA</li>
<li>UR5. Impulsar el cumplimiento de un estricto plan de seguridad de la zona de explotación minera de sepiolita</li>
<li>UR6. Intervención urgente en edificios abandonados del IVIMA</li>
<li>UR7. Apertura de la estación de O’Donell</li>
<li>UR8. Traslado del Cuartel de San Cristóbal, y desarrollo en sus terrenos de un programa alternativo de equipamientos para el Distrito.</li>
<li>UR9. Resolución de los problemas de acceso al distrito de San Blas a la M-40</li>
</ul>

<p><strong>SALUD</strong></p>
<ul>
<li>SA1. Fomentar la participación ciudadana y la democracia en temas de salud, a través de los Consejos de salud del distrito</li>
<li>SA2. Dotación económica y facilitación de trámites burocráticos para las organizaciones dedicadas a temas de salud en el distrito</li>
<li>SA3. Apoyo a Madrid Salud San Blas y al Programa contra la desigualdades sociales</li>
<li>SA4. Incrementar los servicios de ayuda a domicilio</li>
<li>SA5. Instar desde el Ayuntamiento la derogación del Plan de Medidas de Garantía de la Sostenibilidad del Sistema Sanitario Público de la Comunidad de Madrid.</li>
<li>SA6. Desarrollar convenios para la creación de unidades de corta estancia</li>
<li>SA7. Incremento del personal cualificado en los Centros de Salud</li>
<li>SA8. Es imprescindible luchar por tener una Sanidad Pública Universal.</li>
<li>SA9. Aumentar el número claustro en la Universidad para cubrir las necesidades de personal sanitario cualificado </li>
</ul>

<p><strong>MOVILIDAD</strong></p>
<ul>
<li>MO1. Instalar vados peatonales (rebajes adaptados</li>
<li>MO2. Permitir el acceso de las bicicletas a las dependencias municipales del distrito</li>
<li>MO3. Dotar de ascensores o de escaleras mecánicas en las estaciones de metro del distrito</li>
<li>MO4. Rediseño integral de la red de la EMT, en especial en los barrios periféricos (Rejas, Las Mercedes, etc.</li>
<li>MO5. Limitación a 30 km/h en todas las calles del distrito de un solo carril</li>
<li>MO6. Promoción y fomento de la implantación en los centros educativos del Programa Municipal STARS (“Con bici y a pie al Cole”)</li>
<li>MO7. Reducir el tiempo de la fase semafórica de paso de vehículo (ganar tiempo peatones</li>
<li>MO8. Redistribución del espacio público atendiendo a la prioridad del ciudadano que camina, el que va en bici y en transporte público por encima del coche privado.</li>
</ul>

})
      create_2017_district_poll('Hortaleza', [
        {
          title: "¿Cambiamos el nombre del distrito de Hortaleza a Hortaleza-Canillas?",
          summary: %{La respuesta que cuente con mayor número de apoyos será la que la Concejala-Presidenta llevará al Pleno del Ayuntamiento para su votación.},
          valid_answers: "Sí,No",
          description: %{
<p>Es en los siglos XII y XIII cuando aparecen los nombres de Hortaleza y Canillas, asentamientos que nacieron al noreste de la Villa de Madrid, como consecuencia de la repoblación castellana llevada a cabo para asentar el territorio conquistado a las tropas musulmanas.<p>
<p>Hasta el siglo XX Hortaleza y Canillas contaron con Ayuntamientos propios e independientes. Es en 1950 cuando el antiguo municipio de Canillas fue absorbido por Madrid, dentro del proyecto denominado Gran Madrid. Un día después sucedió lo mismo con Hortaleza.</p>
<p>Al contrario que el resto de municipios absorbidos a la capital, como Hortaleza, Vallecas, los Carabancheles, Vicálvaro o Villaverde, Canillas continua desaparecido del mapa administrativo de la capital.</p>
}
        }, {
          title: "¿Debe retomar el actual Parque de Felipe VI a su nombre original Parque Forestal de Valdebebas?",
          summary: %{La respuesta que cuente con mayor número de apoyos será la que la Concejala-Presidenta llevará al Pleno del Ayuntamiento para su votación.},
          valid_answers: "Sí,No",
          description: ""
        }
      ])

      create_2017_district_poll('Retiro', [
        {
          title: "¿Cómo quieres que se llame el Centro Cultural situado en el Mercado de Ibiza, c/ Ibiza 8?",
          summary: "¿Cómo quieres que se llame el Centro Cultural situado en el Mercado de Ibiza, c/ Ibiza 8?",
          valid_answers: "Amparo Barayón,Ángeles García-Madrid,El Buen Mercado de Retiro,Carmen Martín Gaite,Concha García Campoy,Duquesa de Santoña,Fernando Rivero Ramírez,Francisco Bernis Madrazo,José Hierro,Marcos Ana,María Asquerino,Mercado de Ibiza,Pepita Embil Echániz,Ramón J. Sénder,Santiago Ramón y Cajal,Las Sin Sombrero,Zenobia Camprubí"
        }, {
          title: "¿Cómo quieres que se llame el Centro Cultural situado en c/ Luis Peidró 2?",
          summary: "¿Cómo quieres que se llame el Centro Cultural situado en c/ Luis Peidró 2?",
          valid_answers: "Ángeles García-Madrid,Las Californias,Zenobia Camprubí"
        }, {
          title: "¿Cómo quieres que se llame el Centro Sociocultural situado en la Junta Municipal de Retiro, Avda. Ciudad de Barcelona 164?",
          summary: "¿Cómo quieres que se llame el Centro Sociocultural situado en la Junta Municipal de Retiro, Avda. Ciudad de Barcelona 164?",
          valid_answers: "Ángeles García-Madrid,Clara Campoamor Rodríguez,Concha García Campoy,Concha Méndez Cuesta,José Hierro,Marcos Ana,María Asquerino,María Casares,Memorial 11M,Las Sin Sombrero"
        }
      ])

      create_2017_district_poll('Salamanca', [
        {
          title: "¿Considera que la Junta Municipal del Distrito de Salamanca debe llevar a cabo las acciones necesarias para incrementar la protección de edificios históricos e instar para que se protejan los que actualmente no figuran en el catálogo de bienes protegidos?",
          summary: "La respuesta que cuente con mayor número de votos será la que se lleve a cabo",
          description: %{<p>El Distrito de Salamanca cuenta con un número importante de edificios con alto valor histórico y patrimonial. En la actualidad, algunos de ellos figuran en el catálogo de bienes protegidos del Ayuntamiento de Madrid, que establece su grado de protección. Sin embargo, existen inmuebles que actualmente están fuera de este listado o cuyo nivel de protección es demasiado bajo. Es por esto que, desde la Junta Municipal del Distrito de Salamanca, se consulta a la población si considera que esta línea de preservación de los elementos que conforman la historia de la ciudad de Madrid debería incluirse en las líneas y prioridades de trabajo de esta administración</p>},
          valid_answers: "Sí,No"
        }
      ])

      create_2017_district_poll('Vicálvaro', [
        {
          title: "¿Cómo quieres que se llame el Espacio de Igualdad del Distrito de Vicálvaro?",
          summary: "El nombre que cuente con mayor número de apoyos será la que se utilizará para designar al Espacio de Igualdad del Distrito de Vicálvaro.",
          valid_answers: "María Pacheco,Federica Montseny,Gloria Fuertes,Frida Kahlo",
          description: %{
<p>Información adicional sobre las personas cuyos nombres se proponen para de
Espacio de Igualdad del Distrito de Vicálvaro:</p>

<p><strong>María Pacheco</strong></p>

<p>(<a href="https://es.wikipedia.org/wiki/Granada_(Espa%C3%B1a)">Granada</a>,
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
en febrero de <a href="https://es.wikipedia.org/wiki/1522">1522</a>.</p>

<p><strong>Federica Montseny Mañé</p>

<p>(<a href="https://es.wikipedia.org/wiki/Madrid">Madrid</a>,
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
  Occidental</a>.</p>
<p>Publicó casi cincuenta novelas cortas con trasfondo romántico-social
dirigidas concretamente a las mujeres de la clase proletaria, así
como escritos políticos, éticos, biográficos y autobiográficos.</p>

<p><strong>Gloria Fuertes García</strong></p>

<p>(<a href="https://es.wikipedia.org/wiki/Madrid">Madrid</a>,
<a href="https://es.wikipedia.org/wiki/28_de_julio">28
de julio</a>
de <a href="https://es.wikipedia.org/wiki/1917">1917</a>
- <a href="https://es.wikipedia.org/wiki/Ib%C3%ADdem">ibídem</a>,
<a href="https://es.wikipedia.org/wiki/27_de_noviembre">27
de noviembre</a>
de <a href="https://es.wikipedia.org/wiki/1998">1998</a>)
fue una poeta <a href="https://es.wikipedia.org/wiki/Espa%C3%B1a">española</a>
y autora de <a href="https://es.wikipedia.org/wiki/Literatura_infantil_y_juvenil">literatura
infantil y juvenil</a></p>

<p><strong>Magdalena Carmen Frida Kahlo Calderón</strong></p>

<p>(<a href="https://es.wikipedia.org/wiki/Coyoac%C3%A1n">Coyoacán</a>,
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
  Trotski</a>.</p>

<p>Su obra pictórica gira temáticamente en torno a su biografía y a
su propio sufrimiento. Fue autora de unas 200 obras, principalmente
autorretratos, en los que proyectó sus dificultades por sobrevivir.
La obra de Kahlo está influenciada por su esposo, el reconocido
pintor <a href="https://es.wikipedia.org/wiki/Diego_Rivera">Diego
Rivera</a>,
con el que compartió su gusto por el arte popular mexicano de raíces
indígenas, inspirando a otros pintores y pintoras mexicanos del
periodo postrevolucionario</p>
}

        }
      ])


  end
end
