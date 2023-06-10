class CreateGames < ActiveRecord::Migration[7.0]
  def change
    create_table :games do |t|
      t.integer :max_players, null: false, default: 4
      
      t.timestamps
    end
  end
end
