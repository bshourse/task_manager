module TaskManager
  class Base < Grape::API
    rescue_from ActiveRecord::RecordNotFound do |e|
      error!(e.message, 404)
    end

    rescue_from ActiveRecord::RecordInvalid do |e|
      error!(e.message, 422)
    end

    rescue_from ArgumentError do |e|
      error!(e.message, 400)
    end

    rescue_from ActiveRecord::StatementInvalid do |e|
      error!(e.message, 503)
    end

    mount TaskManager::V1::Tasks # this is a path to my API, all methods for tasks i'll write in Task.rb
    mount TaskManager::V1::Projects
    mount TaskManager::V1::Users
  end
end
