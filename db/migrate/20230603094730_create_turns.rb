class CreateTurns < ActiveRecord::Migration[7.0]
  def change
    create_table :turns do |t|
      t.references :game, null: false, foreign_key: true
      t.integer :number, null: false, default: 1
      t.text :board
      t.integer :status

      t.timestamps
    end
    add_index :turns, [:game_id, :number], unique: true
  end
end
