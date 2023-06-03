class Order < ApplicationRecord
  belongs_to :turn
  belongs_to :player
  
  delegate :board, to: :turn
  
  def origin
    board.public_send super
  end
  
  def target
    board.public_send super
  end
end
