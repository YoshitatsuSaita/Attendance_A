# Be sure to restart your server when you modify this file.

# Add new inflection rules using the following format. Inflections
# are locale specific, and you may define rules for as many different
# locales as you wish. All of these examples are active by default:
# ActiveSupport::Inflector.inflections(:en) do |inflect|
#   inflect.plural /^(ox)$/i, "\\1en"
#   inflect.singular /^(ox)en/i, "\\1"
#   inflect.irregular "person", "people"
#   inflect.uncountable %w( fish sheep )
# end

# These inflection rules are supported but not enabled by default:
# ActiveSupport::Inflector.inflections(:en) do |inflect|
#   inflect.acronym "RESTful"
# end

# 「work_bases」は語尾が bases のため既定で単数形が「work_basis」と
# 推論される。WorkBase モデル・経路ヘルパーを単数 "work_base" に揃える。
ActiveSupport::Inflector.inflections(:en) do |inflect|
  inflect.irregular 'work_base', 'work_bases'
end
