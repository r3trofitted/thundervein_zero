ActiveSupport::Inflector.inflections(:en) do |inflect|
  inflect.plural /^(hex)$/i, "\\1es"
  inflect.singular /^(hex)es/i, "\\1"
end
