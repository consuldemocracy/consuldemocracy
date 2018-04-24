require 'custom/post_db_import'

namespace :custom do

  desc "Finalise l'import de la BDD originelle"
  task :finalize_db_import => :environment do |t, args|
    p "==== finalize_db_import started: #{Time.now} ===="
    begin
      PostDbImport.call!
      p "==== finalize_db_import ended: #{Time.now} ===="
    rescue Exception => e
      error = "Error: #{e}"
      p error
    end
  end

end
