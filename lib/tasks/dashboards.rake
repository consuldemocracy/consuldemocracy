namespace :dashboards do

  desc "Send to user notifications from new actions availability on dashboard"
  task send_notifications: :environment do
    Proposal.not_archived.each do |proposal|
      new_actions_ids = Dashboard::Action.detect_new_actions_since(Date.yesterday, proposal)

      if new_actions_ids.present?
        if proposal.published?
          Dashboard::Mailer.delay.new_actions_notification_rake_published(proposal,
                                                                    new_actions_ids)
        else
          Dashboard::Mailer.delay.new_actions_notification_rake_created(proposal,
                                                                  new_actions_ids)
        end
      end
    end
  end

  desc "Basic templates with Dashboard::Actions recommended"
  task create_basic_dashboard_actions_template: :environment do
    Dashboard::Action.create(title: "Kit de difusión",
                             description: "<p>Aquí tienes un manual para ayudarte a comunicar tu "\
                             "propuesta y que tengas el mayor éxito posible. Es fundamental que "\
                             "estés detrás de ella impulsándola. Este documento te ayudará a "\
                             "tener una estrategia en tu comunicación. Puedes descargártelo en "\
                             "pdf, como también leerlo online.</p>\r\n",
                             request_to_administrators: false,
                             day_offset: 1,
                             required_supports: 0,
                             order: 1,
                             active: true,
                             action_type: 1,
                             short_description: "Manual para diseñar tu estrategia de comunicación",
                             published_proposal: false)
    Dashboard::Action.create(title: "Habla primero con familiares y amigos",
                             description: "<p>Cuéntales tu propuesta, pídeles consejo y, una vez "\
                             "la hayas publicado, pídeles que la compartan en sus redes sociales. "\
                             "Ellos serán los primeros en apoyar tu campaña.</p>\r\n",
                             request_to_administrators: false,
                             day_offset: 0,
                             required_supports: 0,
                             order: 2,
                             active: true,
                             action_type: 0,
                             short_description: "Ellos serán tu primer y más importante apoyo",
                             published_proposal: false)
    Dashboard::Action.create(title: "Haz que tu campaña tenga la mejor imagen",
                             description: "<p>¡Añadir una fotografía o vídeo a tu propuesta "\
                             "consigue hasta 6 veces más apoyos que las propuestas que no la "\
                             "tienen! Es fundamental que escojas la mejor fotografía posible y, "\
                             "si las personas implicadas en la propuesta aparecen en ella, "\
                             "¡mucho mejor! Además, aquí te dejamos algunos consejos más técnicos "\
                             "para que apliques a la elección de la imagen de tu propuesta. "\
                             "Síguelos y verás el resultado:<br />\r\n- Fotos de animales y "\
                             "personas, siempre funcionan mejor.<br />\r\n- Las fotos grandes "\
                             "siempre quedan mejor, pero ¡ojo, la imagen no puede exceder 1Mb de "\
                             "peso máximo!<br />\r\n- Haz que tu foto sea apta para todos los "\
                             "públicos y no contenga contenido explícito.</p>\r\n",
                             request_to_administrators: false,
                             day_offset: 0,
                             required_supports: 0,
                             order: 0,
                             active: true,
                             action_type: 0,
                             short_description: "",
                             published_proposal: false)
    Dashboard::Action.create(title: "Elige un título corto, potente y llamativo",
                             description: "<p>Es importante ir al grano. Haz partícipes a todos "\
                             "de tu propuesta. Céntrate en la solución, en el beneficio o en "\
                             "aquello que se necesita resolver. Ubica tu propuesta ciudadana. "\
                             "Aquí te dejamos algunos ejemplos para que adaptes al título de tu "\
                             "propuesta:<br />\r\n- 'Queremos una Plaza de Olavide limpia y "\
                             "habitable'<br />\r\n- 'No al cierre del mercado de abastos de "\
                             "Leganés'<br />\r\n- 'No más basura en nuestro barrio de La Latina' "\
                             "<br />\r\n- 'Colocar más contenedores de vidrio en Argüelles' "\
                             "<br />\r\n- 'Arreglen la estación para bicicletas de Legazpi "\
                             "'</p>\r\n",
                             request_to_administrators: false,
                             day_offset: 0,
                             required_supports: 0,
                             order: 1,
                             active: true,
                             action_type: 0,
                             short_description: "Sé conciso y directo para que tu propuesta "\
                             "se entienda al instante",
                             published_proposal: false)
    Dashboard::Action.create(title: "Expresa siempre tu agradecimiento",
                             description: "<p>Tanto si te brindan su apoyo como si no, da las "\
                             "gracias siempre. Además de mostrar tu agradecimiento, servirá para "\
                             "crear una comunicación nueva que podría atraer a otras personas "\
                             "hasta tu propuesta y de este modo, conseguir nuevos apoyos.</p>\r\n",
                             request_to_administrators: false,
                             day_offset: 3,
                             required_supports: 0,
                             order: 5,
                             active: true,
                             action_type: 0,
                             short_description: "Es una buena manera de lograr apoyos en el futuro",
                             published_proposal: false)
    Dashboard::Action.create(title: "Cuéntaselo a tus amigos en persona",
                             description: "<p>Antes de publicar, haz un evento o plan con tu "\
                             "gente, amigos, familiares, compañeros de trabajo... Reúne a todo "\
                             "el mundo alrededor de unas cervecitas y una buena conversación, "\
                             "cuéntales tu propuesta e invítales a que la mejoren y participen de "\
                             "ella. Esta idea es fácilmente combinable con la creación de tus "\
                             "encuestas previas a la publicación de la propuesta. Puedes "\
                             "desarrollar las encuestas para estos encuentros y debatir las "\
                             "conclusiones; o bien que las respondan in situ, lo que "\
                             "prefieras.</p>\r\n",
                             request_to_administrators: false,
                             day_offset: 4,
                             required_supports: 0,
                             order: 6,
                             active: true,
                             action_type: 0,
                             short_description: "Crea un encuentro para compartir tu propuesta.",
                             published_proposal: false)
    Dashboard::Action.create(title: "Crea una encuesta personalizada",
                             description: "<p>Las encuestas sirven para resolver dudas, pedir "\
                             "opinión, mejorar tu propuesta y también para crear una comunidad "\
                             "en torno a la cual hacer crecer tu propuesta en apoyos, una vez la "\
                             "hayas afinado y mejorado y decidas hacerla pública para todos "\
                             "ellos.<br />\r\n<br />\r\nEsta idea es fácilmente combinable con "\
                             "la organización de un encuentro o evento en el que les cuentes a "\
                             "todos tus contactos, amigos y familiares cuál es tu propuesta y el "\
                             "por qué de la importancia de su apoyo para lograr tus "\
                             "objetivos.</p>\r\n",
                             request_to_administrators: false,
                             day_offset: 5,
                             required_supports: 0,
                             order: 7,
                             active: true,
                             action_type: 0,
                             short_description: "Pregunta lo que quieras sobre tu propuesta",
                             published_proposal: false)
    Dashboard::Action.create(title: "Suma en tu propósito a los negocios de tu barrio",
                             description: "<p>Quizá tu propuesta influya directamente en los "\
                             "negocios de tu barrio e incluso pueda ayudar a mejorar su situación "\
                             "y tú, seguro que conoces a esas personas que los dirigen o "\
                             "regentan, ¿verdad? Contacta con ellos y cuéntales todo para que "\
                             "te ayuden a lograr votos. ¡Ellos, como tú, también ganarán!</p>\r\n",
                             request_to_administrators: false,
                             day_offset: 7,
                             required_supports: 0,
                             order: 10,
                             active: true,
                             action_type: 0,
                             short_description: "¿Has pensado en hablar con los bares o "\
                             "comercios que más visitas?",
                             published_proposal: false)
    Dashboard::Action.create(title: "Incluye hashtags en tus publicaciones",
                             description: "<p>El hashtag es una herramienta indispensable para "\
                             "aumentar la participación y tus apoyos. Se utiliza principalmente "\
                             "en Twitter, pero Facebook, Instagram, Pinterest o Google+ también "\
                             "incorporan esta opción. Es muy recomendable que al publicar, "\
                             "siempre utilices los mismos hashtags en tus publicaciones para, "\
                             "sobre ellos, crear tu propio contenido. Haz una búsqueda o pide "\
                             "ayuda sobre cuáles utilizar y que tengan que ver con tu propuesta "\
                             "en concreto. Nosotros te dejamos aquí algunos ejemplos o ideas de "\
                             "hashtags que tienen que ver con diversos ámbitos sociales sobre los "\
                             "que podría ir tu propuesta. Pero lo ideal es que utilices otros más "\
                             "acordes a la temática de la tuya propia.<br /></p>\r\n",
                             request_to_administrators: false,
                             day_offset: 6,
                             required_supports: 0,
                             order: 9,
                             active: true,
                             action_type: 0,
                             short_description: "Utilizar hashtags te permitirá llegar a más gente",
                             published_proposal: false)
    Dashboard::Action.create(title: "Suma en tu propósito a ONGs o centros sociales de tu barrio",
                             description: "<p>Quizá tu propuesta influya directamente en la "\
                             "mejora de la calidad de vida de las personas que vivie en tu barrio "\
                             "o localidad, incluso aquellas con menos recursos y los colectivos "\
                             "más desfavorecidos o en riesgo de exclusión social. Contacta con "\
                             "las ONG's y Centros Sociales cercanos a ti y cuéntales tu "\
                             "propuesta para que te ayuden a lograr votos. ¡Estarán encantados "\
                             "de colaborar!</p>\r\n",
                             request_to_administrators: false,
                             day_offset: 7,
                             required_supports: 0,
                             order: 11,
                             active: true,
                             action_type: 0,
                             short_description: "Cuéntales tu propuesta a todos los que pueda "\
                             "interesarles",
                             published_proposal: false)
    Dashboard::Action.create(title: "¿Conoces a algún influencer?",
                             description: "<p>Un 'influencer' es una persona que cuenta con "\
                             "numerosos seguidores en redes sociales. Por ello, si en tu entorno "\
                             "cercano conoces a alguien que lo sea o que utilice activamente sus "\
                             "perfiles sociales y obtenga mucha o cierta repercusión en ellos, "\
                             "es una gran oportunidad para contarle acerca de tu propuesta y "\
                             "pedirle que te ayude a difundirla compartiéndola en sus redes "\
                             "sociales.</p>\r\n",
                             request_to_administrators: false,
                             day_offset: 8,
                             required_supports: 0,
                             order: 12,
                             active: true,
                             action_type: 0,
                             short_description: "Cuéntale tu propuesta y consigue que él y sus "\
                             "seguidores te apoyen",
                             published_proposal: false)
    Dashboard::Action.create(title: "Pide apoyos en persona",
                             description: "<p>Aunque tenemos medios a nuestro alcance capaces de "\
                             "llegar en un instante a cientos y miles de personas, nada funciona "\
                             "mejor que pedir el apoyo en persona. ¡Es 34 veces más eficaz que "\
                             "por email!</p>\r\n",
                             request_to_administrators: false,
                             day_offset: 1,
                             required_supports: 0,
                             order: 3,
                             active: true,
                             action_type: 0,
                             short_description: "¡Es 34 veces más eficaz que por email!",
                             published_proposal: false)
    Dashboard::Action.create(title: "Prepara tus mensajes en redes sociales",
                             description: "<p>Crea un pequeño calendario de publicaciones "\
                             "semanales en Facebook y/o Twitter (tres a la semana es suficiente "\
                             "durante los primeros meses). Utiliza imágenes en las que aparezcas "\
                             "tú mismo solicitando el apoyo o imágenes llamativas sobre el "\
                             "proyecto. Y sobre todo: utiliza un lenguaje sencillo, directo a "\
                             "la hora de pedir el apoyo y siempre con mensajes personalizados "\
                             "si vas a dirigirte a tus contactos de manera privada. Es "\
                             "importante que se sientan partícipes y no uno más en tu "\
                             "necesidad de conseguir apoyos.</p>\r\n",
                             request_to_administrators: false,
                             day_offset: 2,
                             required_supports: 0,
                             order: 4,
                             active: true,
                             action_type: 0,
                             short_description: "Es muy importante saber qué vas a decir y cómo",
                             published_proposal: false)
    Dashboard::Action.create(title: "Informa de tus planes antes de la publicación",
                             description: "<p>No es necesario que debas tener creada totalmente "\
                             "o publicada tu propuesta para comenzar a hablar de ella. De hecho, "\
                             "te recomendamos que hagas publicaciones en tus redes sociales y "\
                             "hables con tus amigos y familiares de ella antes de que vea la "\
                             "luz. Es lo que se llama una campaña 'teaser' y sirve para crear "\
                             "expectación sobre algo que va a llegar muy pronto.<br />\r\n "\
                             "<br />\r\nPara ello te recomendamos que incluyas mensajes de este "\
                             "tipo en tus publicaciones en redes sociales. De hecho, puedes "\
                             "copiar estos textos y utilizarlos si lo deseas:<br />\r\n- 'Muy "\
                             "pronto crearé mi propia propuesta ciudadana para mejorar nuestra "\
                             "ciudad de Madrid, y necesitaré vuestro apoyo más que nunca. Os "\
                             "seguiré informando desde aquí. Muchas gracias a todos'<br />\r\n- "\
                             "Este es un mensaje para todos aquellos a los que les importa "\
                             "su ciudad, su barrio y nuestro futuro. Quiero mejorar Madrid con "\
                             "una propuesta que muy pronto os haré llegar a todos para que "\
                             "juntos, logremos que se lleve a cabo. ¡Gracias a todos!</p>\r\n",
                             request_to_administrators: false,
                             day_offset: 6,
                             required_supports: 0,
                             order: 8,
                             active: true,
                             action_type: 0,
                             short_description: "Todos en redes sociales deben saber que "\
                             "pronto crearás tu propuesta.",
                             published_proposal: false)
    Dashboard::Action.create(title: "Comparte tu propuesta en comunidades de facebook",
                             description: "<p>Es fundamental que busques el apoyo que "\
                             "necesitas en todas partes. Las comunidades y grupos (privados "\
                             "o abiertos) de Facebook en Madrid, también son un buen lugar del "\
                             "que recabar nuevos apoyos y aliados en tu camino hacia la "\
                             "meta.<br />\r\n<br />\r\nPara ello, busca y selecciona bien "\
                             "aquellas comunidades y grupos ya creados en Facebook que son más "\
                             "afines a la naturaleza de tu propuesta. Por ejemplo si tu "\
                             "propuesta versa sobre 'mejorar un parque público', seguramente "\
                             "encuentres el apoyo que necesitas en ciclistas, grupos de "\
                             "running, colectivos y personas cercanas al parque, etc. "\
                             "Solicita unirte a ellos, y una vez estés dentro, publica allí tu "\
                             "propuesta informándoles de ella y pidiéndoles respetuosamente, "\
                             "su apoyo en la mejora de vuestra ciudad. Ten en cuenta siempre "\
                             "cómo enfocar tu mensaje para que sea lo más acorde al grupo en el "\
                             "que publicas y a también a sus intereses. Piensa que al final se "\
                             "trata de obtener apoyos de personas que no conoces, y ella, "\
                             "también debe entender cuál es el beneficio que obtiene por "\
                             "ayudarte. Y desde luego, en ningún caso, debe percibir tu "\
                             "petición como 'spam' o intrusiva, así que ten tacto al pedir "\
                             "tus apoyos.</p>\r\n",
                             request_to_administrators: false,
                             day_offset: 9,
                             required_supports: 0,
                             order: 13,
                             active: true,
                             action_type: 0,
                             short_description: "¿Sabes a cuántas personas podrías llegar "\
                             "con estos grupos?",
                             published_proposal: false)
    Dashboard::Action.create(title: "Analiza con detenimiento otras propuestas",
                             description: "<p>Parece una obviedad pero asegúrate de hacerlo. "\
                             "Antes de que tu propuesta vea la luz, fíjate en cómo lo han hecho "\
                             "otros ciudadanos y ciudadanas a la hora de crear la suya: "\
                             "fotografía, mensajes, título... Habrá algunas que te gusten más "\
                             "y menos, mejor o peor expuestas; tú debes analizarlas y quedarte "\
                             "con lo mejor de cada una para implantarlo a la tuya propia.<br /> "\
                             "\r\n<br />\r\nAquí te dejamos estos ejemplos de las más destacadas "\
                             "hasta el momento para que veas cómo lo han hecho. ¡Si ellos han "\
                             "conseguido los apoyos necesarios o están a punto, tú también puedes!",
                             request_to_administrators: false,
                             day_offset: 10,
                             required_supports: 0,
                             order: 14,
                             active: true,
                             action_type: 0,
                             short_description: "Antes de publicar tu propuesta, mira cómo "\
                             "lo han hecho otros",
                             published_proposal: false)
    Dashboard::Action.create(title: "Utiliza whatsapp para difundir ",
                             description: "<p>¡Tus amigos, familiares, tu entorno cercano te "\
                             "apoyarán para que tu propuesta se lleve a cabo. ¡No olvides copiar "\
                             "el enlace de tu propuesta e incluirlo en tu mensaje para que "\
                             "puedan ir directamente a apoyarte! Compártelo en todos tus grupos "\
                             ", pégalo a todos tus contactos de manera personal y "\
                             "¡obtendrás resultados más rápidamente!</p>\r\n",
                             request_to_administrators: false,
                             day_offset: 0,
                             required_supports: 0,
                             order: 17,
                             active: true,
                             action_type: 0,
                             short_description: "Whatsapp o su equivalente Telegram son grandes "\
                             "herramientas para conseguir apoyos instantáneos.",
                             published_proposal: true)
    Dashboard::Action.create(title: "Utiliza tus redes sociales",
                             description: "<p>En la fase de precampaña ya te invitamos a "\
                             "utilizar tus redes sociales, ¡son el mejor medio para llegar al "\
                             "máximo de personas! Además, también te hemos dado un KIT de "\
                             "imágenes para que puedas comunicar tu propuesta. Ahora además, "\
                             "te aconsejamos que, directamente, copies y pegues el enlace de tu "\
                             "propuesta en tus perfiles sociales para que la gente pueda "\
                             "acceder y apoyarte.</p>\r\n",
                             request_to_administrators: false,
                             day_offset: 0,
                             required_supports: 0,
                             order: 16,
                             active: true,
                             action_type: 0,
                             short_description: "Copia y pega el enlace de tu propuesta en "\
                             "tus perfiles sociales.",
                             published_proposal: true)
    Dashboard::Action.create(title: "Continúa pidiendo apoyo a nuevos embajadores de tu propuesta",
                             description: "<p>Tu propuesta para mejorar la ciudad puede mejorar "\
                             "también la vida de muchas personas incluidas aquellas que "\
                             "regentan bares, fruterías, peluquerías, o que ayudan a otros "\
                             "como ONG's, Centros Sociales, Asociaciones de Vecinos... Piensa a "\
                             "quién podría interesarle apoyar tu propuesta, cuéntale todo con "\
                             "detalle y ¡verás cómo logras muchos más apoyos de los que "\
                             "esperabas!</p>\r\n",
                             request_to_administrators: false,
                             day_offset: 1,
                             required_supports: 0,
                             order: 18,
                             active: true,
                             action_type: 0,
                             short_description: "Comercios, negocios locales, Centros Sociales, "\
                             "Colectivos...",
                             published_proposal: true)
    Dashboard::Action.create(title: "Pide que te dejen colocar carteles",
                             description: "<p>Seguro que te llevas genial con esos dueños de "\
                             "negocios, comercios, tiendas, centros sociales y cívicos, "\
                             "asociaciones... de tu barrio. ¡Pídeles que te permitan colocar en "\
                             "sus instalaciones y locales algún cartel informando de tu propuesta "\
                             "para que todo el que pase por allí pueda apoyarte y contárselo a "\
                             "otras personas!<br />\r\n<br />\r\nPara ello, puedes decírselo "\
                             "personalmente o recurrir a los nuevos recursos. Cuando logres los "\
                             "apoyos necesarios (si no los tienes ya), verás que a tu "\
                             "disposición hemos puesto un recurso 'Póster' para que puedas "\
                             "descargarlo e imprimirlo o imprimirlo directamente desde esta "\
                             "herramienta. Una vez lo tengas, pide permiso, y pégalo en "\
                             "distintos lugares para que todo el que pase por allí puedan saber "\
                             "de tu propuesta y entrar en la plataforma para apoyarte.</p>\r\n",
                             request_to_administrators: false,
                             day_offset: 1,
                             required_supports: 0,
                             order: 19,
                             active: true,
                             action_type: 0,
                             short_description: "¿Imaginas tu propuesta visible por todas partes?",
                             published_proposal: true)
    Dashboard::Action.create(title: "Aplica las acciones que tienes pendientes",
                             description: "<p>Es hora de llevar un paso más allá las acciones "\
                             "que te aconsejamos mientras tu propuesta estaba en borrador. Si no "\
                             "las conoces es el momento de que las repases con atención. El "\
                             "primer día de campaña es muy importante. Tu propuesta, por estar "\
                             "entre las nuevas publicadas, tiene más atención hoy ¡Aprovecha "\
                             "y difunde! </p>\r\n",
                             request_to_administrators: false,
                             day_offset: 0,
                             required_supports: 0,
                             order: 15,
                             active: true,
                             action_type: 0,
                             short_description: "Encontrarás todas las acciones en la página "\
                             "de \"Acciones recomendadas\" en tu Panel de Propuesta. Recuerda "\
                             "utilizarlas habitualmente para lograr nuevos apoyos.",
                             published_proposal: true)
    Dashboard::Action.create(title: "Pide a tu gente que comparta tu propuesta",
                             description: "<p>¡Cuanta más gente conozca tu propuesta mejor! No "\
                             "te cortes en pedir a tus amigos, familiares y contactos que "\
                             "compartan ellos también tu iniciativa en sus redes sociales. ¡La "\
                             "unión hace la fuerza!<br />\r\n<br />\r\nEn la fase de precampaña "\
                             "ya te invitamos a utilizar tus redes sociales, ¡son el mejor medio "\
                             "para llegar al máximo de personas! Además, también te hemos dado "\
                             "un KIT de imágenes para que puedas comunicar tu propuesta. Y si "\
                             "quieres, también puedes pasarles a ellos este KIT para que "\
                             "publiquen las imágenes y capten apoyos para ti a través de sus "\
                             "perfiles personales.<br />\r\n </p>\r\n",
                             request_to_administrators: false,
                             day_offset: 3,
                             required_supports: 0,
                             order: 21,
                             active: true,
                             action_type: 0,
                             short_description: "Pídeles que la muevan en sus redes sociales",
                             published_proposal: true)
    Dashboard::Action.create(title: "Tus vecinos son una gran comunidad para pedir apoyo",
                             description: "<p>El lugar en el que vives es el sitio idóneo para "\
                             "pedir apoyo ya que conoces a tus vecinos y de manera personal "\
                             "puedes pedirles que te ayuden, es sencillo y efectivo.<br />\r\n "\
                             "<br />\r\nPara ello, puedes decírselo personalmente, pegar un "\
                             "cartel en tu portal o convocar una reunión en tu casa para los "\
                             "interesados. Verás que dispones del recurso  'Cartel ' para que "\
                             "puedas descargarlo e imprimirlo. Si es necesario ayúdales para "\
                             "que se hagan un usuario en la plataforma Decide. Si has convocado "\
                             "una reunión, y vienen a  tu casa o llevas contigo un ordenador, "\
                             "tableta o móvil con Internet, les puede echar una mano para que se "\
                             "registren como nuevo usuario y te apoyen.</p>\r\n\r\n<p> </p>\r\n",
                             request_to_administrators: false,
                             day_offset: 4,
                             required_supports: 0,
                             order: 22,
                             active: true,
                             action_type: 0,
                             short_description: "Deja un cartel en tu portal o convoca una reunión",
                             published_proposal: true)
    Dashboard::Action.create(title: "Imprime tu propuesta y repártela",
                             description: "<p>Estás pidiéndoles su apoyo y es normal que ellos "\
                             "te pidan más información. Lo mejor es que no les reclames demasiado "\
                             "en primera instancia. Haz unas copias del resumen de tu propuesta, "\
                             "y entrégaselas a quien consideres oportuno. Las personas solemos "\
                             "interesarnos y apoyar aquello cuyo carácter parece serio y "\
                             "meditado. Por ello, te aconsejamos que redactes tu propuesta "\
                             "brevemente e imprimas varias copias para que todos aquellos que "\
                             "deseen saber más, puedan leer en sus casas y entender con "\
                             "tranquilidad, de qué trata realmente.</p>\r\n",
                             request_to_administrators: false,
                             day_offset: 2,
                             required_supports: 0,
                             order: 20,
                             active: true,
                             action_type: 0,
                             short_description: "La gente confía más cuando tiene información "\
                             "suficiente",
                             published_proposal: true)
    Dashboard::Action.create(title: "Crea tarjetas de visita adaptándolas para "\
                             "difundir tu propuesta",
                             description: "<p>¿Sabes cuánto cuesta hacer 500 tarjetas para "\
                             "presentar tu propuesta y captar nuevos apoyos de manera inmediata? "\
                             "Esta cantidad de tarjetas puede costar a partir de 7,25€. Busca "\
                             "la página web que más confianza te dé o imprimelas en una "\
                             "copistería, y pide a todo el mundo que te ayude a distribuirlas: "\
                             "amigos y familiares, vecinos, compañeros de trabajo, gente del "\
                             "barrio... ¡a quien tú quieras! No importa que no conozcas a la "\
                             "gente a la cual solicitas el apoyo para tu propuesta, ¡quien menos "\
                             "lo esperes te puede ayudar! Pero debes ponérselo fácil, por eso: "\
                             "añade el título y el identificador de tu propuesta en la tarjeta, "\
                             "el enlace a la web decide.madrid.es y tu nombre ¡y no te olvides de "\
                             "pedirles a todos/as que te apoyen, no sólo que visiten "\
                             "el link!</p>\r\n",
                             request_to_administrators: false,
                             day_offset: 5,
                             required_supports: 0,
                             order: 23,
                             active: true,
                             action_type: 0,
                             short_description: "Es una manera directa y diferente de llegar a "\
                             "más gente",
                             published_proposal: true)
    Dashboard::Action.create(title: "Pide que te apoyen en tu trabajo",
                             description: "<p>No dudes en hacerles saber de la creación de "\
                             "tu propuesta y de la necesidad de su apoyo por su parte para "\
                             "lograr hacerla realidad. En ellos y ellas, encontrarás una fuente "\
                             "de apoyo enorme que puede extenderse más allá si logras que hablen "\
                             "de la propuesta en sus entornos personales, por eso vale la pena "\
                             "hacer el esfuerzo durante un sólo día y no resultar demasiado "\
                             "insistente. <br />\r\n<br />\r\nPara ello, puedes contarles "\
                             "personalmente la motivación que te llevó a publicar la propuesta "\
                             "o explicarlo en grupo en los momentos de descanso. También pedir "\
                             "permiso a tu jefe/a para enviar un email a todos solicitando el "\
                             "apoyo. Puedes utilizar las tarjetas de visita o el cártel que ya "\
                             "conoces. Una vez lo tengas, pide permiso, y pégalo en distintos "\
                             "lugares como la entrada del baño, la zona de descanso... </p>\r\n",
                             request_to_administrators: false,
                             day_offset: 6,
                             required_supports: 0,
                             order: 24,
                             active: true,
                             action_type: 0,
                             short_description: "Apóyate en tus compañeros y compañeras de "\
                             "trabajo, ¡son cruciales!",
                             published_proposal: true)
    Dashboard::Action.create(title: "Manual Diez claves",
                             description: "<p>En estos momentos tu propuesta aún esta en modo "\
                             "borrador, es un momento perfecto para leerte este resumen que "\
                             "trata cómo publicar una propuesta ciudadana y empezar ya a reunir "\
                             "apoyos. Aunque ya habrás superado alguno de los pasos que repasa "\
                             "este artículo, como por ejemplo hacerte usuario/a, hay muchos "\
                             "otros que te pueden muy útiles, ya que incorporan recomendaciones. "\
                             "Es el caso de los consejos para conseguir una mejor redacción o "\
                             "con qué archivos podrías complementar la información que estás "\
                             "introduciendo en el formulario. ¡Échale un vistazo!</p>\r\n",
                             request_to_administrators: true,
                             day_offset: 0,
                             required_supports: 0,
                             order: 0,
                             active: true,
                             action_type: 1,
                             short_description: "Recomendaciones antes de publicar",
                             published_proposal: false)
    Dashboard::Action.create(title: "Mailing masivo",
                             description: "",
                             request_to_administrators: true,
                             day_offset: 0,
                             required_supports: 8000,
                             order: 7,
                             active: true,
                             action_type: 1,
                             short_description: "",
                             published_proposal: true)
    Dashboard::Action.create(title: "Píldora de vídeo",
                             description: "",
                             request_to_administrators: false,
                             day_offset: 0,
                             required_supports: 15000,
                             order: 8,
                             active: true,
                             action_type: 1,
                             short_description: "",
                             published_proposal: true)
    Dashboard::Action.create(title: "Imágenes para tus perfiles",
                             description: "<p>Algunos ejemplos para inspirarte o incluir en los "\
                             "perfiles que tengas activos en redes sociales. Se trata de cambiar "\
                             "temporalmente la imágen típica de tu usuario o el banner general "\
                             "en tu espacio de perfil, por otra que anuncie que tienes una "\
                             "propuesta en decide y que buscas apoyo. Puedes utilizar alguno de "\
                             "ellos,  crear tu mismo/a el slogan que mejor te vaya e ir "\
                             "cambiandolos regularmente. Es un espacio muy agradecido ya que "\
                             "cualquier persona que te conozca lo verá sin tener que hacer "\
                             "tanto esfuerzo por tu parte.</p>\r\n",
                             request_to_administrators: false,
                             day_offset: 1,
                             required_supports: 0,
                             order: 2,
                             active: true,
                             action_type: 1,
                             short_description: "Ejemplos para incluir en tus Redes Sociales",
                             published_proposal: true)
    Dashboard::Action.create(title: "Mención en RRSS del Ayuntamiento",
                             description: "",
                             request_to_administrators: true,
                             day_offset: 0,
                             required_supports: 1000,
                             order: 3,
                             active: true,
                             action_type: 1,
                             short_description: "Una difusión específica en las redes "\
                                                "del Ayuntamiento",
                             published_proposal: true)
    Dashboard::Action.create(title: "Decide Corner",
                             description: "",
                             request_to_administrators: true,
                             day_offset: 0,
                             required_supports: 1500,
                             order: 4,
                             active: true,
                             action_type: 1,
                             short_description: "",
                             published_proposal: true)
    Dashboard::Action.create(title: "1 día en portada",
                             description: "",
                             request_to_administrators: true,
                             day_offset: 0,
                             required_supports: 2500,
                             order: 5,
                             active: true,
                             action_type: 1,
                             short_description: "",
                             published_proposal: true)
    Dashboard::Action.create(title: "Anuncio en Facebook",
                             description: "",
                             request_to_administrators: true,
                             day_offset: 0,
                             required_supports: 5000,
                             order: 6,
                             active: true,
                             action_type: 1,
                             short_description: "",
                             published_proposal: true)
  end

end
