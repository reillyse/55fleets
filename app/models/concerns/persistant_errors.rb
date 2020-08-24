module PersistantErrors
  extend ActiveSupport::Concern

  included { has_many :persistant_errors, as: :errorable }

  def add_error(message)
    persistant_errors.create! message: message
  end
end
