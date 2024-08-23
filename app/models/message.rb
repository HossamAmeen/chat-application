class Message < ApplicationRecord
  belongs_to :chat

  after_create :update_chat_messages_count

  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

  settings index: { number_of_shards: 1, number_of_replicas: 0 } do
    mappings dynamic: false do
      indexes :body, type: :text, analyzer: :english
    end
  end

  validates :number, presence: true
  validates :number, uniqueness: { scope: :chat_id }
  validates :body, presence: true



  Message.__elasticsearch__.create_index!(force: true)
  Message.import

  def as_json(options = {})
    super(options.merge({ except: [:id, :chat_id] }))
  end

  private

  def update_chat_messages_count
    chat.increment!(:messages_count)
  end


end