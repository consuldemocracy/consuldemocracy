# Names for the moderation console, as a hint for moderators
# to know better how to assign users with official positions
Setting.create(key: 'official_level_0_name', value: 'No cargo público')
Setting.create(key: 'official_level_1_name', value: 'Empleados públicos')
Setting.create(key: 'official_level_2_name', value: 'Organización Municipal')
Setting.create(key: 'official_level_3_name', value: 'Directores generales')
Setting.create(key: 'official_level_4_name', value: 'Concejales')
Setting.create(key: 'official_level_5_name', value: 'Alcaldesa')

# Max percentage of allowed anonymous votes on a debate
Setting.create(key: 'max_ratio_anon_votes_on_debates', value: '50')