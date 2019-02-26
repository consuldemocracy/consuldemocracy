section "Creating district Forums" do
  forums = ["Fuencarral - El Pardo", "Moncloa - Aravaca", "Tetuán", "Chamberí", "Centro", "Latina",
            "Carabanchel", "Arganzuela", "Usera", "Villaverde", "Chamartín", "Salamanca", "Retiro",
            "Puente de Vallecas", "Villa de Vallecas", "Hortaleza", "Barajas", "Ciudad Lineal",
            "Moratalaz", "San Blas - Canillejas", "Vicálvaro"]
  forums.each_with_index do |forum, i|
    user = create_user("user_for_forum#{i + 1}@example.es")
    Forum.create(name: forum, user: user)
  end
end
