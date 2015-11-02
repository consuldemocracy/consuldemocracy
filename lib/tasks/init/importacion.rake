require 'roo'
require 'yaml'

class String
  def to_slug
    #strip the string
    ret = I18n.transliterate self.strip.downcase
    #blow away apostrophes
    ret.gsub! /['`]/,""
    ret.gsub! "/","-"
    #replace all non alphanumeric, underscore or periods with underscore
    ret.gsub! /\s*[^A-Za-z0-9\.\-]\s*/, ''
    #convert double underscores to single
    ret.gsub! /_+/,"_"
    #strip off leading/trailing underscore
    ret.gsub! /\A[_\.]+|[_\.]+\z/,""
    ret.downcase
  end
end

def tag_code (tag, programa)
  programa = programa["es"]["programa"]
  programa.each do |clave, valor|
    tag = clave if valor == tag
  end
  tag
end

namespace :init do
  desc "[init] Cargar datos de medidas"
  task :importacion => :environment do
    Medida.delete_all
    xlsx = Roo::Spreadsheet.open("lib/tasks/init/Programa.xlsx")
    sheet = xlsx.sheet(0)
    headers = { ID: "ID", titulo: "Titulo de la medida", descripcion: "Literal", bloque: "Bloque", epigrafe: "Epígrafe", oficial: "oficial" }
    programa = YAML.load_file('config/locales/programa.es.yml')
    sheet.each do |r|
      if r[0].to_i > 0 && !r[1].nil?
        Medida.new do |t|
          t.id = r[0].to_i
          t.title = r[1]
          t.description = r[2].gsub("\n","<br>\n")
          t.author_id = 2
          t.tag_list = [ tag_code(r[3], programa), tag_code(r[4], programa) ]
        end .save!(:validate => false)
        puts "ID: #{r[0].to_i} \t\t tag_list: '#{tag_code(r[3], programa)}', '#{tag_code(r[4], programa)}'"
      end
    end
  end
end

