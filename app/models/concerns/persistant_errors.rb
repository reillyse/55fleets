module PersistantErrors
    extend ActiveSupport::Concern

  included do
    has_many :persistant_errors, :as => :errorable
  end
  
  def add_error message
    persistant_errors.create! :message => message
  end

end
