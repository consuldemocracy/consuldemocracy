require "woocommerce_api"

woocommerce = WooCommerce::API.new(
  "http://www.kolhaam.org.il",
  "ck_1ef0696d317d1272b2d3fa3152f50155ad72ecb5",
  "cs_778561b003ad3bd565428e3ffea465de7a65136b",
  {
    wp_api: true,
    version: "wc/v1",
    verify_ssl: false 
  }
)

email = "yoav.lip@gmail.com"
#puts woocommerce.get("customers/28").parsed_response
puts woocommerce.get("customers?search=" + email).parsed_response
puts "all ----------"
all =  woocommerce.get("customers?per_page=100&orderby=id").parsed_response
puts all.length
puts all
all.each do |a|
  print a["billing"]["company"] 
  print " " + a["id"].to_s  + " " 
  print  a["email"] + " "
  puts "032843104" ==  a["billing"]["company"]
end
