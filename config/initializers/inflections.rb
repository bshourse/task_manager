# Instead of the code in the application.rb for Rails 6 i add this code.. otherwise I fall to uninitialized constant when the server start
# https://github.com/rails/rails/issues/35567
ActiveSupport::Inflector.inflections(:en) do |inflect|
  inflect.acronym 'API'
end
