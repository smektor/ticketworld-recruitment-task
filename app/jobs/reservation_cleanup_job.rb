class ReservationCleanupJob < ApplicationJob
  queue_as :default

  def perform(tickets, reservation, payment_token)
    return if reservation.paid?

    begin
      Payment::Gateway.refund(amount: reservation.cost, token: payment_token)
    rescue Payment::Gateway::RefundError
      reservation.update(status: :not_refunded)
    end

    ActiveRecord::Base.transaction do
      available_tickets = tickets.available + reservation.tickets_count
      tickets.update!(available: available_tickets)
      reservation.destroy!
    end
  end
end
