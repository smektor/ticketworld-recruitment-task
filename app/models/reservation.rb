class Reservation < ApplicationRecord
  belongs_to :ticket

  enum status: [:reserved, :paid, :not_refunded]
end
