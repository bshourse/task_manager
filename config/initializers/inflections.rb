# Вместо кода в файле application.rb для Rails 6 добавляю этот код иначе падаю в uninitialized constant при старте сервера
# https://github.com/rails/rails/issues/35567
 ActiveSupport::Inflector.inflections(:en) do |inflect|
   inflect.acronym 'API'
 end
