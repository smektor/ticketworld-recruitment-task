# frozen_string_literal: true

RSpec.describe "Tickets", type: :request do
  shared_examples "event not found" do
    it "should have correct HTTP status" do
      expect(response).to have_http_status(:not_found)
    end

    it "should render error" do
      expect(response_json).to eq({ error: "Couldn't find Event with 'id'=incorrect" })
    end
  end

  shared_examples "buy tickets success status and message" do
    it "should have correct HTTP status" do
      expect(response).to have_http_status(:ok)
    end

    it "should render success message" do
      expect(response_json).to eq({ success: "Payment succeeded." })
    end
  end

  describe "GET tickets#index" do
    context "event exists" do
      subject { get "/tickets", params: params }

      let(:params) { { event_id: event.id } }

      before { subject }

      context "ticket exists" do
        let(:event) { create(:event, :with_ticket) }
        let(:ticket) { event.ticket }

        it "should have correct HTTP status" do
          expect(response).to have_http_status(:ok)
        end

        it "should have correct size" do
          expect(response_json.size).to eq(1)
        end

        it "should render event" do
          expect(response_json).to include(
            tickets: hash_including(
              available: ticket.available,
              price: ticket.price.to_s,
              event: hash_including(
                id: event.id,
                name: event.name,
                formatted_time: event.formatted_time
              )
            )
          )
        end
      end

      context "ticket does not exist" do
        let(:event) { create(:event) }

        it "should have correct HTTP status" do
          expect(response).to have_http_status(:not_found)
        end

        it "should render error" do
          expect(response_json).to eq({ error: "Ticket not found." })
        end
      end
    end

    context "event does not exist" do
      let(:params) { { event_id: "incorrect" } }

      before { get "/tickets", params: params }

      it_behaves_like "event not found"
    end
  end

  describe "POST events#buy_ticket" do
    subject { post "/tickets/buy", params: params }

    before { subject }

    context "event exists" do
      context "ticket exists" do
        let(:event) { create(:event, :with_ticket) }
        let(:ticket) { event.ticket }
        let(:params) { { event_id: event.id, token: "token", tickets_count: tickets_count.to_s } }

        context "valid params" do
          let(:tickets_count) { 3 }
          let(:reservation) { ticket.reservations.last }

          it "should have paid reservation" do
            expect(reservation.paid?).to be_truthy
          end

          it "should have reservation with correct tickets count" do
            expect(reservation.tickets_count).to eq(tickets_count)
          end

          it_behaves_like "buy tickets success status and message"
        end

        context "validate tickets with" do
          context "even validations" do
            let(:event) { create(:event, :with_even_tickets) }

            context "for event tickets amount" do
              let(:tickets_count) { 2 }

              it_behaves_like "buy tickets success status and message"
            end

            context "for odd tickets amount" do
              let(:tickets_count) { 3 }

              it "should have correct HTTP status" do
                expect(response).to have_http_status(:unprocessable_entity)
              end

              it "should render error message" do
                error_msg = "Validation failed: Tickets count can't buy odd amount of tickets"
                expect(response_json).to eq({ error: error_msg})
              end
            end
          end

          context "avoid one left validation" do
            let(:event) { create(:event, :with_avoid_one_tickets) }

            context "when more than one ticket left" do
              let(:tickets_count) { 3 }

              it_behaves_like "buy tickets success status and message"
            end

            context "when all tickets bought" do
              let(:tickets_count) { ticket.available }

              it_behaves_like "buy tickets success status and message"
            end

            context "when one ticket left" do
              let(:tickets_count) { ticket.available - 1 }

              it "should have correct HTTP status" do
                expect(response).to have_http_status(:unprocessable_entity)
              end

              it "should render error message" do
                error_msg = "Validation failed: Tickets count can't leave only one ticket"
                expect(response_json).to eq({ error: error_msg})
              end
            end
          end
        end

        context "wrong number of tickets" do
          let(:params) { { event_id: event.id, token: "token", tickets_count: "-" } }

          it "should have correct HTTP status" do
            expect(response).to have_http_status(:unprocessable_entity)
          end

          it "should render success message" do
            expect(response_json).to eq({ error: "Number of tickets must be greater than zero." })
          end
        end

        context "card error" do
          let(:params) { { event_id: event.id, token: "card_error", tickets_count: "1" } }

          it "should have correct HTTP status" do
            expect(response).to have_http_status(402)
          end

          it "should render correct error message" do
            expect(response_json).to eq({ error: "Your card has been declined." })
          end
        end

        context "payment error" do
          let(:params) { { event_id: event.id, token: "payment_error", tickets_count: "1" } }

          it "should have correct HTTP status" do
            expect(response).to have_http_status(402)
          end

          it "should render correct error message" do
            expect(response_json).to eq({ error: "Something went wrong with your transaction." })
          end
        end

        context "not enough tickets left" do
          let(:params) { { event_id: event.id, token: "token", tickets_count: ticket.available + 1 } }

          it "should have correct HTTP status" do
            expect(response).to have_http_status(409)
          end

          it "should render correct error message" do
            expect(response_json).to eq({ error: "Not enough tickets left." })
          end
        end
      end

      context "ticket does not exist" do
        let(:event) { create(:event) }
        let(:params) { { event_id: event.id, token: "token", tickets_count: "1" } }

        it "should have correct HTTP status" do
          expect(response).to have_http_status(:not_found)
        end

        it "should render error" do
          expect(response_json).to eq({ error: "Ticket not found." })
        end
      end
    end

    context "event does not exist" do
      let(:params) { { event_id: "incorrect", token: "token", tickets_count: "1" } }

      it_behaves_like "event not found"
    end
  end
end

def response_json
  JSON.parse(response.body).deep_symbolize_keys
end
