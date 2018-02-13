namespace :direct_messages do

  desc "Send direct messages from medialab to specific users"
  task medialab: :environment do
    invalid = []
    valid = []
    no_email = []

    usernames.each do |username|
      user = User.where(username: username).first
      if user.present? && user.email_on_direct_message?
        message = DirectMessage.new(direct_message_attributes(user))
        if message.save
          Mailer.direct_message_for_receiver(message).deliver
          print "."
          valid << user.id
        else
          puts "invalid #{user.id}"
          invalid << user.id
        end
      else
        puts "no email on direct message"
        no_email << username
      end
    end

    puts "invalid: #{invalid.count}"
    puts "valid: #{valid.count}"
    puts "no_email: #{no_email.count}"
    puts no_email
  end

  def direct_message_attributes(user)
    { title:    title,
      body:     body,
      sender:   sender,
      receiver: user }
  end

  def sender
    User.where(email: "comunidades.decide@medialab-prado.es").first
  end

  def title
    "Hola"
  end

  def body
    "Tú y otros 300 autores habéis escrito una propuesta sobre infancia en Decide Madrid y, juntas, suman los apoyos necesarios para llegar a votación; un paso fundamental para poder hacerse realidad en Madrid.
     Por ello, MediaLab-Prado te quiere invitar el sábado 3 de marzo (de 10h a 14h30) a un evento en el que diseñar colectivamente una propuesta que sitúe Madrid como ciudad europea amigable para la infancia. Durante la jornada, se expondrán experiencias de ciudades internacionales que han priorizado el derecho a jugar, se harán dinámicas para despertar la creatividad y se trabajará en equipo para aprovechar la inteligencia colectiva.
     ¡Esperamos contar contigo! Si tienes peques, habrá ludoteca.
     Si te interesa, aquí el formulario  de inscripción: http://bit.ly/Formulario-3Marzo, déjanos tu contacto y te enviaremos más información sobre el evento.  Si tienes cualquier pregunta puedes escribirnos a comunidades.decide@medialab-prado.es o por WhatsApp:  631 013 092."
  end

  def usernames
    ["Alvar-o",
     "AmandaH",
     "AmayaBarajas",
     "Ana de la Fuente",
     "Ana Sánchez",
     "AnaGambin",
     "ANARU",
     "Andrés Fernández",
     "angel Cuesta Perez",
     "ángela",
     "angelbujalance@yahoo.es",
     "Anitarr",
     "AOTIN",
     "Apsss2000",
     "Araisa",
     "Araitz Bilbao",
     "aupalaura",
     "Av10",
     "batan",
     "Beameno",
     "Bearubio",
     "BeatrizCd",
     "BEGOÑA DEL AMO MARTIN",
     "Belen MO",
     "belenibanezgo",
     "belenmadsiempre",
     "berlin979",
     "Bethesda",
     "Bfguerrero",
     "Bhagwant Morgar",
     "BLANCA",
     "boo40",
     "BORJA GONZALEZ",
     "Cáncer ",
     "Carmen Peragón Roa",
     "carmenlr",
     "CarolaHF",
     "Celia Ramos",
     "Celina",
     "CIUDADAN@",
     "CiudadanaIrene",
     "Civita",
     "CLARENS",
     "Concepcion",
     "cpb3",
     "CrisS",
     "Cristina Os",
     "CristinaRueda",
     "ctina85",
     "Cuestaabajo",
     "daniela-2",
     "David Diez Marcos",
     "David Eduardo Garcia Alonso",
     "David Vargas",
     "Eduardoa1",
     "edwin",
     "elantiguo",
     "Elenahm",
     "ELGON",
     "Elmo",
     "Elsa Muñoz",
     "ememad",
     "EmmaMB",
     "Encarna VM",
     "EQUITY",
     "ersone",
     "Esmeralda Ls",
     "ESPACIO VERDE",
     "Espe Rueda",
     "Esther G",
     "JuanNadie",
     "f.boga",
     "fanta",
     "Fatima C",
     "Felipe Alfaro Solana",
     "fernad39",
     "Fernando Ornes",
     "Fernando Sánchez Delgado",
     "Fhcchi",
     "Fjmmem",
     "Font",
     "Gis Godoy",
     "Golf4",
     "Henerya",
     "Hermine I",
     "Hernán Caamaño",
     "hoser",
     "Hourcade",
     "Hugo P.",
     "Humberto Mediavilla Bouza",
     "Ignacio Asensio",
     "IKBE ",
     "ioi",
     "ipakoyo",
     "Irene Alcázar ",
     "Isabel de Juan",
     "Isabel Núñez",
     "Isabel_Olano",
     "Isabelg",
     "ITrojaola",
     "ivilo",
     "Izaskun Marco",
     "JAMA",
     "Jarsolo",
     "Javier Merinero",
     "Javier Rojas",
     "Javier1970",
     "Javsalvador",
     "Jesus ",
     "jesvelasco",
     "jj",
     "jorcan",
     "Jorge San Pedro",
     "José Alberto Pérez Cueto",
     "Jose Manuel Jimeno Corral",
     "JoseAGM",
     "Josefina",
     "Jpserna",
     "jralvarez",
     "Juan Antonio del Barrio Díaz",
     "JuanJo Ordóñez",
     "JuanNadie",
     "Julia Dávila ",
     "Julia Varona",
     "KATHERINE MENDOZA",
     "Laalgo80",
     "LadyH",
     "Laly Zambrano",
     "Latino",
     "Laura de la Fuente",
     "lauracañas",
     "Lauralechonalvarez",
     "Lesttat",
     "Lexmadrid",
     "Lkar",
     "Lobo Solitario",
     "Lrn32",
     "Lucas Jagger",
     "Lucía Díaz Valero",
     "Lucía Frere",
     "LucyW",
     "Lunakiller",
     "Luvara",
     "M. José Sánchez",
     "Ma Blvr",
     "macarenapormadrid",
     "Madridaje",
     "MAIDA",
     "Maitena",
     "Mamá Feliz",
     "marck",
     "marcosvnaranjo",
     "Margarita Pérez jimenez",
     "Marguetin",
     "María Aguirre Arroyo",
     "Maria Angeles Mena",
     "MARIA DOLORES",
     "María jesus",
     "Maria Mota",
     "María Sil",
     "MariaMadrid",
     "MariaMaestro",
     "Maricruz",
     "marimadrid77",
     "Marjorie2102",
     "Marta Toral",
     "Martah",
     "martanavarrobenedito",
     "MCarmen",
     "MCSDV",
     "mdefrutos",
     "Megumi",
     "Mercedes D C",
     "meryshelly",
     "Mgo ",
     "Mía wallace",
     "Migleve",
     "miriamtierra",
     "Momo San",
     "Monica lleo",
     "Monimoni",
     "Moon",
     "mrfer",
     "Mrp",
     "n1cirro",
     "Nagore",
     "NFA",
     "Noemí de Vicente",
     "None",
     "norelis",
     "nouk27",
     "Nuria 1703",
     "nyebes",
     "omgmarin",
     "OscarChamberi",
     "PabloAuz",
     "Paloma Gámez",
     "participativosforochamberi",
     "Patricia1978",
     "Patucoss",
     "Patxi Aguirrezabal ",
     "paula pz",
     "Pedro Gallego Heredero",
     "Pepa Macarro",
     "picosgi",
     "Pigomezsa",
     "Pikha",
     "Pilar-Rayder",
     "Pilili1980",
     "plob",
     "pms",
     "poppyboy",
     "Puchis",
     "Quirche",
     "Rafael Arroyo",
     "rafael898",
     "Raquelpez",
     "RaquelRM",
     "Raqueltg",
     "RATONCIN VALLEKAS",
     "raudo",
     "Raul Cuevas Mesa",
     "Roberto_Ordás",
     "Rocio Luque",
     "Rodrigo Mira",
     "rositarodr",
     "Ruidos Plaza Comendadoras",
     "runinops",
     "Ruth Diaz Palacios",
     "Sallylanga",
     "Sánchez",
     "Sébastien Morice",
     "Seda Petrova",
     "sentidocomún",
     "sergius",
     "SILVIA DIAZ",
     "SilviaVH",
     "smr76",
     "SNF",
     "SUMADRID",
     "SusanaRF",
     "Tamara85",
     "Tato Caro",
     "Teresa Hdez",
     "Teresagm",
     "Terete74",
     "Tesi",
     "thernandezca",
     "Thorgal",
     "Tikitaka",
     "TilesÖz",
     "Tormal",
     "TwintiTarantino",
     "Urre",
     "vallekas",
     "Vane2p0",
     "Veronica Gonzalez Gonzalez",
     "Violeta RA",
     "Virginia Pilar",
     "Willy",
     "Xulio",
     "xylus",
     "yolcarrillo"]
  end

end

