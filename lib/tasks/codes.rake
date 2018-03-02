namespace :codes do
  desc "Creates redeemable codes for direct verification"
  task :create, [:n] => :environment do |t, args|
    n = args.n.to_i
    bye(use_message_for_create) if n <= 0

    File.open("codes.txt", "w") do |f|

      n.times do
        begin
          token = RedeemableCode.generate_token
        end while RedeemableCode.where(token: token).exists?

        code = RedeemableCode.create(token: token)
        f.puts "#{token}"
      end

    end
    puts "Generados #{n} códigos, archivo codes.txt disponible"
  end


  private
    def use_message_for_create
      "* Use: rake codes:create[10]  (you have to specify a number of codes to generate)"
    end

    def bye(msg)
      puts msg
      exit(false)
    end
end
