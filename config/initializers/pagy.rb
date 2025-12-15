require "pagy/extras/overflow"
require "pagy/extras/i18n"
require "pagy/extras/array"

Pagy::DEFAULT[:limit]    = 20
Pagy::DEFAULT[:overflow] = :last_page

Pagy::I18n.load(locale: "ja")
