class Chat < ApplicationRecord
  belongs_to :application

  after_create :update_application_chats_count


  has_many :messages, dependent: :destroy
  validates :number, presence: true
  validates :number, uniqueness: { scope: :application_id }

  def as_json(options = {})
    super(options.merge({ except: [:id, :application_id] }))
  end


  private

  def update_application_chats_count
    application.increment!(:chats_count)
  end

end