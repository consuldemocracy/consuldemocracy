require 'mysql'

#my = Mysql.new(hostname, username, password, databasename)
con = Mysql.new('212.150.243.222', 'demonetm_consul', 'kolhaam2011', 'demonetm_db1')
rs = con.query('SELECT meta_value FROM `wp_woocommerce_order_items` oi left join wp_posts p on p.id = oi.order_id
 join wp_postmeta pm on p.ID = pm.post_id
where meta_key = "_billing_email"
and post_status = "wc-completed"
')
rs.each_hash { |h| puts h['meta_value']}
con.close
