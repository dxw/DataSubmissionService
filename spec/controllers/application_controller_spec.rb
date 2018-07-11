require 'rails_helper'

RSpec.describe ApplicationController do
  describe '#ensure_user_signed_in' do
    controller do
      before_action :ensure_user_signed_in

      def index
        render inline: 'hello'
      end
    end

    it 'allows signed in users to access' do
      user = FactoryBot.create(:user)
      session[:user_id] = user.id

      get :index

      expect(response).to have_http_status(:ok)
    end

    it 'redirects guest users to the home page' do
      get :index

      expect(response).to redirect_to(root_path)
    end
  end
end