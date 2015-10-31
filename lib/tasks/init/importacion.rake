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

def tag_code (tag)
  programa = YAML.load_file('config/locales/programa.es.yml')
  programa = programa["es"]["programa"]
  programa.each do |clave, valor|
    tag = clave if valor == tag
  end
  tag
end

namespace :init do
  desc "[init] Cargar datos de medidas"
  task :importacion => :environment do
    #progress = RakeProgressbar.new(%x(cat lib/tasks/init/* | wc -l).to_i + 1)
    Medida.delete_all
    xlsx= Roo::Spreadsheet.open("lib/tasks/init/Programa.xlsx")
    sheet=xlsx.sheet(0)
    headers={ID: "ID", titulo: "Titulo de la medida", descripcion: "Literal", memoria:"Mem. Jur.", bloque: "Bloque", epigrafe: "Epígrafe", subepigrafe: "Subepígrafe", oficial: "oficial"}
    sheet.each do |r|
        #puts r.inspect
        #puts "#{r[1]} #{r[2]}"
      if r[0].to_i > 0 && !r[1].nil?
puts "ID: #{r[0].to_i} \t tag_list: #{tag_code(r[3])}, #{tag_code(r[4])}"
        Medida.new do |t|
          t.id =r[0].to_i
          t.title =r[1]
          t.description="#{r[2]}\n#{r[3]}"
          t.author_id = 2
          t.tag_list =[ tag_code(r[3]), tag_code(r[4]) ]
          #puts "#{t.id}" #{t.title} #{t.description} #{t.author_id} #{t.tag_list} "
        end .save!(:validate => false)
      end
    end
  end
end



