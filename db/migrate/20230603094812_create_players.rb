class CreatePlayers < ActiveRecord::Migration[7.0]
  def change
    create_table :players do |t|
      t.references :game, null: false, foreign_key: true
      t.string :name, null: false
      t.string :email_address, null: false

      t.timestamps
    end
    add_index :players, [:game_id, :name], unique: true
    add_index :players, [:game_id, :email_address], unique: true
  end
end
