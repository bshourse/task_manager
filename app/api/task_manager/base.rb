module TaskManager
  class Base < Grape::API
    mount TaskManager::V1::Tasks # это путь к нашему API, все методы для задач напишу в Tasks.rb
    mount TaskManager::V1::Projects
    mount TaskManager::V1::Users
  end
end
