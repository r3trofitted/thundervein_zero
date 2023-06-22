class CreatePlayers < ActiveRecord::Migration[7.0]
  def change
    create_table :players do |t|
      t.string :name, null: false
      t.string :email_address, null: false

      t.timestamps
    end
    add_index :players, :email_address, unique: true
  end
end
