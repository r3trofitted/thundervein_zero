class CreatePlayers < ActiveRecord::Migration[7.0]
  def change
    create_table :players do |t|
      t.references :game, null: false, foreign_key: true
      t.string :email

      t.timestamps
    end
    add_index :players, :email, unique: true
  end
end
