# frozen_string_literal: true

RSpec.describe Ticket, type: :model do
  describe "reserved_tickets" do
    before { create(:event) }

    let(:ticket) { create(:ticket, :with_reserved_and_paid_reservations, event: Event.last) }
    let(:reserved_tickets) { Reservation.where(status: :reserved).sum(:tickets_count) }
    let(:paid_tickets) { Reservation.where(status: :paid).sum(:tickets_count) }

    it "displays correct value for reserved tickets" do
      expect(ticket.reserved_count).to eq(reserved_tickets)
    end

    it "displays correct value for paid tickets" do
      expect(ticket.paid_count).to eq(paid_tickets)
    end

    it "displays correct value for no reservations" do
      ticket.reservations.destroy_all
      expect(ticket.reserved_count).to eq(0)
      expect(ticket.paid_count).to eq(0)
    end
  end
end
