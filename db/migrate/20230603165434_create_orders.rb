class CreateOrders < ActiveRecord::Migration[7.0]
  def change
    create_table :orders do |t|
      t.string :type
      t.references :turn, null: false, foreign_key: true
      t.references :player, null: false, foreign_key: true
      t.string :origin, null: false
      t.string :target, null: false
      t.integer :units, null: false
      t.integer :engagement

      t.timestamps
    end
  end
end
