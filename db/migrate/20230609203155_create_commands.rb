class CreateCommands < ActiveRecord::Migration[7.1]
  def change
    create_table :commands do |t|
      t.references :game, null: false, foreign_key: true
      t.references :player, null: true

      t.timestamps
    end
  end
end
