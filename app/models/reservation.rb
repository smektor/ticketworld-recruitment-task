class Reservation < ApplicationRecord
  belongs_to :ticket

  enum status: [:reserved, :paid, :not_refunded]

  validates :ticket, :cost, :tickets_count, presence: true
  validate :only_even, if: -> { ticket.even? }
  validate :avoid_one_left, if: -> { ticket.avoid_one? }

  def only_even
    errors.add(:tickets_count, "can't buy odd amount of tickets") unless tickets_count.even?
  end

  def avoid_one_left
    if ticket.available - tickets_count == 1
      errors.add(:tickets_count, "can't leave only one ticket")
    end
  end
end
