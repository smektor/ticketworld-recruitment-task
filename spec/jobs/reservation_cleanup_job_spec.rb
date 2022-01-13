require 'rails_helper'

RSpec.describe ReservationCleanupJob, type: :job do
  describe ".perform" do
    subject { described_class.perform_now(ticket, reservation, payment_token) }

    before do
      event = create(:event)
      create(:ticket, event: event, available: available_tickets_count)
      create(:reservation, ticket: ticket, tickets_count: reserved_ticktes_count)
    end

    let(:reservation) { ticket.reservations.last }
    let(:ticket) { Ticket.last }
    let(:available_tickets_count) { 20 }
    let(:reserved_ticktes_count) { 6 }
    let(:payment_token) { "token" }

    context "when reservation was successfully paid" do
      before do
        reservation.update(status: :paid)
        subject
      end

      it "should not remove reservation" do
        expect(reservation).to be_truthy
      end
    end

    context "when reservation was not paid" do
      it "should remove reservation" do
        subject
        expect(Reservation.where(id: reservation.id)).not_to exist
      end

      it "should release tickets" do
        expect(ticket.available).to eq(available_tickets_count)
        subject
        expect(ticket.available).to eq(available_tickets_count + reserved_ticktes_count)
      end

      context "should call payment adapter" do
        it "with correct with correct refund" do
          expect(Payment::Gateway).to receive(:refund).with(amount: reservation.cost,
            token: payment_token)
          subject
        end

        context "with error during refund money" do
          let(:payment_token) { "refund_error" }

          it "should handle error and update reservation state" do
            subject
            expect(reservation).to have_attributes(status: "not_refunded")
          end
        end
      end
    end
  end
end