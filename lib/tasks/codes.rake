namespace :codes do
  desc "Creates redeemable codes for direct verification"
  task :create, [:n] => :environment do |t, args|
    n = args.n.to_i
    bye(use_message_for_create) if n <= 0

    bye(no_geozone_message) unless geozone = Geozone.find_by(name: "Centro")

    File.open("codes.txt", "w") do |f|
      f.puts("Distrito, Token")

      n.times do
        begin
          token = RedeemableCode.generate_token
        end while RedeemableCode.where(token: token, geozone_id: geozone.id).exists?

        code = RedeemableCode.create(geozone_id: geozone.id, token: token)
        f.puts "#{geozone.name}, #{token}"
      end

    end
    puts "Generados #{n} códigos, archivo codes.txt disponible"
  end


  private
    def use_message_for_create
      "* Use: rake codes:create[10]  (you have to specify a number of codes to generate)"
    end

    def no_geozone_message
      "* Could not find Geozone to apply"
    end

    def bye(msg)
      puts msg
      exit(false)
    end
end
