$("#<%= dom_id(@medida) %> .js-flag-actions").html('<%= j render("medidas/flag_actions", medida: @medida) %>');
