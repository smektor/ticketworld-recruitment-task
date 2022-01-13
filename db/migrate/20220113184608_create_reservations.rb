class CreateReservations < ActiveRecord::Migration[6.0]
  def change
    create_table :reservations do |t|
      t.integer :tickets_count
      t.integer :status
      t.decimal :cost, precision: 8, scale: 2
      t.references :ticket, null: false, foreign_key: true

      t.timestamps
    end
  end
end
