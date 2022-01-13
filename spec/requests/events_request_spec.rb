# frozen_string_literal: true

RSpec::Matchers.define :a_big_decimal_around do |expected|
  match do |actual|
    BigDecimal(actual.to_s).round(2) == BigDecimal(expected.to_s).round(2)
  end
end

RSpec.describe "Events", type: :request do
  shared_examples "event not found" do
    it "should have correct HTTP status" do
      expect(response).to have_http_status(:not_found)
    end

    it "should render error" do
      expect(response_json).to eq({ error: "Couldn't find Event with 'id'=incorrect" })
    end
  end

  before do
    create_list(:event, 5, :with_ticket)
  end

  describe "GET events#index" do
    subject { get "/events" }

    before { subject }

    it "should have correct HTTP status" do
      expect(response).to have_http_status(:ok)
    end

    it "should render all events" do
      expect(response_json[:events].size).to eq(5)
    end
  end

  describe "GET events#available" do
    subject { get "/events/available" }

    let(:events_size) do
      Event.where(time: DateTime.now..).count
    end

    before do
      Event.take.update(time: DateTime.now - 1.hour)
      subject
    end

    it "should have correct HTTP status" do
      expect(response).to have_http_status(:ok)
    end

    it "should render all available events" do
      expect(response_json[:events].size).to eq(events_size)
    end
  end

  describe "GET events#show" do
    context "event exists" do
      subject { get "/events/#{event.id}" }

      let(:event) { Event.first }

      before { subject }

      it "should have correct HTTP status" do
        expect(response).to have_http_status(:ok)
      end

      it "should have correct size" do
        expect(response_json.size).to eq(1)
      end

      it "should render event" do
        expect(response_json).to include(
          event: hash_including(
            id: event.id,
            name: event.name,
            formatted_time: event.formatted_time
          )
        )
      end
    end

    context "event does not exist" do
      before { get "/events/incorrect" }
      it_behaves_like "event not found"
    end
  end

  describe "GET events#tickets" do
    subject { get "/events/#{event.id}/tickets" }

    let(:event) { Event.first }
    let(:ticket) { event.ticket }

    before do
      create(:reservation, ticket: ticket, status: :reserved)
      create(:reservation, ticket: ticket, status: :paid)
      subject
    end

    it "should have correct HTTP status" do
      expect(response).to have_http_status(:ok)
    end

    it "should render event tickets informations" do
      expect(response_json).to include(
        tickets: hash_including(
          available: ticket.available,
          reserved: ticket.reserved_count,
          paid: ticket.paid_count,
          price: a_big_decimal_around(ticket.price)
        )
      )
    end

    context "event does not exist" do
      before { get "/events/incorrect/tickets" }
      it_behaves_like "event not found"
    end
  end
end

def response_json
  JSON.parse(response.body).deep_symbolize_keys
end
