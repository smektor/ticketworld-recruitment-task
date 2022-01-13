# frozen_string_literal: true

Rails.application.routes.draw do
  scope defaults: { format: 'json' } do
    resources :events, only: %i(index show) do
      collection do
        get :available
      end
    end

    resources :tickets, only: %i(index) do
      collection do
        post :buy
      end
    end
  end
end
