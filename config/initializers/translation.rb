TranslationIO.configure do |config|
config.api_key        = 'a3d3b67333704c368b791ba6b98f98f7'
config.source_locale  = 'en'
config.target_locales =[ 'he']
config.disable_gettext = true


# Uncomment this if you don't want to use gettext
# config.disable_gettext = true

# Uncomment this if you already use gettext or fast_gettext
# config.locales_path = File.join('path', 'to', 'gettext_locale')

# Find other useful usage information here:
# https://github.com/aurels/translation-gem/blob/master/README.md
end

