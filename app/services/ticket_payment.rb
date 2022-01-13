# frozen_string_literal: true

class TicketPayment
  NotEnoughTicketsError = Class.new(StandardError)

  RESERVATION_TIMEOUT = 15.minutes

  def self.call(ticket, payment_token, tickets_count)
    available_tickets = ticket.available
    raise NotEnoughTicketsError, "Not enough tickets left." unless available_tickets >= tickets_count

    cost = ticket.price * tickets_count
    reservation = ActiveRecord::Base.transaction do
      reservation = ticket.reservations.create!(tickets_count: tickets_count, cost: cost, status: :reserved)
      ticket.update!(available: available_tickets - tickets_count)
      reservation
    end

    ReservationCleanupJob.set(wait: RESERVATION_TIMEOUT).perform_later(reservation, ticket, payment_token)

    Payment::Gateway.charge(amount: cost, token: payment_token)
    reservation.update(status: :paid)
  end
end
