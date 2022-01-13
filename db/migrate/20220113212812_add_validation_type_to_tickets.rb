class AddValidationTypeToTickets < ActiveRecord::Migration[6.0]
  def change
    add_column :tickets, :validation_type, :integer
  end
end
