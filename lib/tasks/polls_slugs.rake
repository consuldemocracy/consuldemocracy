namespace :temp do

desc "Create second citizen poll"
  task polls_slugs: :environment do

    (0..10).each do |i|
      poll = Poll.where(name: poll_attributes(i)[:name]).first
      poll.update_attributes(slug: poll_attributes(i)[:slug])

      if poll.save
        print "."
      else
        puts poll.errors.first
      end
    end
  end

  def poll_attributes(i)
    { name: "Remodelación de la #{main_square_names[i]}",
      slug: "#{main_square_slugs[i]}",
    }
  end

  def main_square_names
    ["Plaza de la Duquesa de Osuna (Barajas)",
     "Plaza de la Remonta (Tetuán)",
     "Plaza de la Vaguada (Fuencarral - El Pardo)",
     "Plaza Cívica de Lucero (Latina)",
     "Plaza de la Emperatriz (Carabanchel)",
     "Plaza del Puerto de Canfranc (Puente de Vallecas)",
     "Plaza del Encuentro (Moratalaz)",
     "Plaza de los Misterios (Ciudad Lineal)",
     "Plaza Cívica Mar de Cristal (Hortaleza)",
     "Plaza Mayor de Villaverde y Plaza de Ágata (Villaverde)",
     "Plaza Cívica de San Blas (San Blas - Canillejas)"]
  end

  def main_square_slugs
    ["rehabilitacion-plaza-duquesa-osuna",
     "rehabilitacion-plaza-remonta",
     "rehabilitacion-plaza-vaguada",
     "rehabilitacion-plaza-civica-lucero",
     "rehabilitacion-plaza-emperatriz",
     "rehabilitacion-plaza-puerto-canfranc",
     "rehabilitacion-plaza-encuentro",
     "rehabilitacion-plaza-misterios",
     "rehabilitacion-plaza-civica-mar-cristal",
     "rehabilitacion-plaza-mayor-villaverde",
     "rehabilitacion-plaza-civica-san-blas"]
  end
end
