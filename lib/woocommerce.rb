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

all =  woocommerce.get("customers?per_page=100").parsed_response
puts all
all.each do |a|
  print a["billing"]["company"]
  print " "
  puts "025085515" ==  a["billing"]["company"]
end
