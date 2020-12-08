section "Creating Sustainable Development Goals" do
  load Rails.root.join("db", "sdg.rb")

  SDG::Target.sample(30).each do |target|
    title = "Title for default locale"
    description = "Description for default locale"
    rand(2..3).times do |n|
      local_target = SDG::LocalTarget.create!(code: "#{target.code}.#{n + 1}",
                                              title: title,
                                              description: description,
                                              target: target)
      random_locales.map do |locale|
        Globalize.with_locale(locale) do
          local_target.title = "Title for locale #{locale}"
          local_target.description = "Description for locale #{locale}"
          local_target.save!
        end
      end
    end
  end
end
