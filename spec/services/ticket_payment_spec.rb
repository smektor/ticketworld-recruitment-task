# frozen_string_literal: true

RSpec.describe TicketPayment do
  describe ".call" do
    subject { described_class.call(ticket, token, tickets_count) }

    let(:ticket) { create(:ticket) }
    let(:token) { "token" }
    let(:tickets_count) { 2 }

    context "when tickets are available" do
      let(:reservation) { Reservation.last }
      let(:cost) { ticket.price * tickets_count}
      let(:cleanup_job) { class_double("ReservationCleanupJob") }

      it "should create reservation" do
        expect(Reservation.last).to be_nil
        subject
        expect(reservation).to have_attributes(ticket_id: ticket.id,
          tickets_count: tickets_count, cost: cost, status: "paid")
      end

      it "should call cleanup job" do
        expect(ReservationCleanupJob).to receive(:set).with(wait: 15.minutes).and_return(cleanup_job)
        expect(cleanup_job).to receive(:perform_later)
        subject
      end

      it "should call payment adapter" do
        expect(Payment::Gateway).to receive(:charge).with(amount: cost, token: token)
        subject
      end

      it "should update available tickets count" do
        expect { subject }.to change(ticket, :available).by(tickets_count * (-1))
      end
    end

    context "when tickets are not available" do
      let(:tickets_count) { ticket.available + 1 }

      it "should raise error" do
        expect { subject }.to raise_error(TicketPayment::NotEnoughTicketsError)
      end
    end
  end
end
