Setting["feature.areas"] = 'f'

areas = [
  {
    name: {
      val: "IDEES PER A MILLORAR L’URBANISME",
      es: "IDEAS PARA MEJORAR EL URBANISMO"
    },
    subareas: [
      {
        val: "Idees per a tindre un mobiliari millor a la ciutat",
        es: "Ideas para tener un mobiliario mejor en la ciudad",
      },
      {
        val: "Idees per millorar les zones verdes",
        es: "Ideas para mejorar las zonas verdes"
      },
      {
        val:
        es:
      }
                 "Idees per a fer més accessible la ciutat",
      {
        val:
        es:
      }
      {
        val:
        es:
      }

    ]

  }



                 "Idees per a fer més accessible la ciutat",
                 "Propostes de millora en temes d’il·luminació i/o contaminació lumínica",
                 "Tens alguna proposta que responga a un problema diferent en aquest tema?"] }




              "IDEES PER A MILLORAR LA MOBILITAT i EL TRÀNSIT" =>
                ["Idees per a millorar en l’aparcament públic de la ciutat",
                 "Idees per millorar el sistema de zona blava",
                 "Idees per millorar la complicada situació de circulació a la ciutat tant per a vehicles a motor, bicicletes i vianants",
                 "Idees per reduir la velocitat i el excés de trànsit",
                 "Idees que milloren la temporalització dels semàfors",
                 "Tens alguna proposta que responga a un problema diferent en aquest tema?"],
              "IDEES PER A MILLORAR EN L’EDUCACIÓ FORMAL" =>
                ["Millores en les instal·lacions educatives",
                 "Idees per articular un sistema públic de guarderies infantils a la ciutat"],
              "IDEES PER A TINDRE UNA CIUTAT MÉS NETA I SALUDABLE" =>
                ["Mesures per a millorar la neteja viària",
                 "Idees que milloren els problemes de convivència amb les mascotes a la ciutat",
                 "Mesures per a la reducció de la contaminació",
                 "Tens alguna proposta que responga a un problema diferent en aquest tema?"],
              "IDEES PER A MILLORAR LES INSTAL·LACIONS I ELS SERVEIS MUNICIPALS" =>
                ["Idees per a millorar l’oferta de centres específics per a persones majors, centres juvenils o infància",
                 "Idees per a millorar els equipaments esportius"],
              "IDEES PER A MILLORAR LA SEGURETAT CIUTADANA" =>
                ["Idees per a millorar la sensació de seguretat ciutadana, sobretot a la perifèria"],
              "IDEES PER RECOLZAR A LES ASSOCIACIONS I INCENTIVAR L’ACTIVITAT SOCIOCULTURAL" =>
                ["Idees que milloren la situació de les associacions culturals, de dones, esportives, de persones majors i totes en general, a la ciutat",
                 "Idees que milloren el sistema de subvencions municipal a les associacions."],
              "IDEES PER A MILLORAR EL DESENVOLUPAMENT ECONÒMIC I EL FOMENT DE L’OCUPACIÓ" =>
                ["Idees que milloren la situació del xicotet comerç",
                 "Idees per a augmentar la varietat de comerços a la ciutat",
                 "Idees per a millorar l’oferta de treball a la ciutat",
                 "Idees per a incentivar la innovació i els nous projectes empresarials a la ciutat"],
              "IDEES PER A MILLORAR LA SITUACIÓ DE LES PERSONES AMB NECESSITATS ESPECÍFIQUES" =>
                ["Com milloraries els sistema d’ajuda a aquest col·lectiu?",
                 "Idees per a millorar les condicions de les residències de la tercera edat.",
                 "Idees per a millorar en els serveis social municipals"]
            }]
areas_es = {
                "Ideas para hacer más accesible la ciudad",
                "Propuestas de mejora en temas de iluminación y/o contaminación lumínica",
                "¿Tienes alguna propuesta que responda a un problema diferente en este tema?"],
              "IDEAS PARA MEJORAR LA MOVILIDAD y EL TRÁFICO" =>
                ["Ideas para mejorar en el aparcamiento público de la ciudad",
                 "Ideas para mejorar el sistema de zona azul",
                 "Ideas para mejorar la complicada situación de circulación a la ciudad tanto para vehículos a motor, bicicletas y peatones",
                 "Ideas para reducir la velocidad y el exceso de tráfico",
                 "Ideas que mejoran la temporalización de los semáforos",
                 "¿Tienes alguna propuesta que responda a un problema diferente en este tema?"],
              "IDEAS PARA MEJORAR EN LA EDUCACIÓN FORMAL" =>
                ["Mejoras en las instalaciones educativas",
                 "Ideas para articular un sistema público de guarderías infantiles a la ciudad"],
              "IDEAS PARA TENER UNA CIUDAD MÁS NETA Y SALUDABLE" =>
                ["Medidas para mejorar la limpieza viaria",
                 "Ideas que mejoran los problemas de convivencia con las mascotas a la ciudad",
                 "Medidas para la reducción de la contaminación",
                 "¿Tienes alguna propuesta que responda a un problema diferente en este tema?"],
              "IDEAS PARA MEJORAR LAS INSTALACIONES Y LOS SERVICIOS MUNICIPALES" =>
                ["Ideas para mejorar la oferta de centros específicos para personas mayores, centros juveniles o infancia",
                 "Ideas para mejorar las equipaciones deportivas"],
              "IDEAS PARA MEJORAR LA SEGURIDAD CIUDADANA" =>
                ["Ideas para mejorar la sensación de seguridad ciudadana, sobre todo a la periferia"],
              "IDEAS PARA APOYAR A LAS ASOCIACIONES E INCENTIVAR La ACTIVIDAD SOCIOCULTURAL" =>
                ["Ideas que mejoren la situación de las asociaciones culturales, de mujeres, deportivas, de personas mayores y todas en general, a la ciudad",
                 "Ideas que mejoren el sistema de subvenciones municipal a las asociaciones."],
              "IDEAS PARA MEJORAR EL DESARROLLO ECONÓMICO Y EL FOMENTO DE LA OCUPACIÓN" =>
                ["Ideas que mejoren la situación del pequeño comercio",
                 "Ideas para aumentar la variedad de comercios a la ciudad",
                 "Ideas para mejorar la oferta de trabajo a la ciudad",
                 "Ideas para incentivar la innovación y los nuevos proyectos empresariales en la ciudad"],
              "IDEAS PARA MEJORAR LA SITUACIÓN DE LAS PERSONAS CON NECESIDADES ESPECÍFICAS" =>
                ["¿Como mejorarías los sistema de ayuda a este colectivo?",
                 "Ideas para mejorar las condiciones de las residencias de la tercera edad.",
                 "Ideas para mejorar en los servicios social municipales"]
            }




I18n.default_locale = :es
areas_es.each do |area, sub_areas|
  new_area = Area.find_or_create_by(name: area)
  new_area_translation = Area::Translation.find_or_create_by(name: area, area_id: new_area.id, locale: es)
  areas_es[area].each do |sub_area_name|
    sub_area = SubArea.find_or_create_by(name: sub_area_name, area_id: new_area.id)
    new_area_translation = SubArea::Translation.find_or_create_by(name: area, sub_area_id: sub_area.id, locale: es)
  end
end
areas_val.each do |area, sub_areas|
  area = Area.find(name: area)
  new_area_translation = Area::Translation.find_or_create_by(name: area)
  areas_val[area].each do |sub_area_name|
    sub_area = SubArea.find_or_create_by(name: sub_area_name, area_id: new_area.id)
    new_area_translation = SubArea::Translation.find_or_create_by(name: area)
  end
end
