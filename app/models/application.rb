class Application < ApplicationRecord
    has_many :chats, dependent: :destroy
    validates :token, presence: true, uniqueness: true
    validates :name, presence: true
  
    # def as_json(options = {})
    #   super(options.merge({ except: [:id] }))
    # end
  
end