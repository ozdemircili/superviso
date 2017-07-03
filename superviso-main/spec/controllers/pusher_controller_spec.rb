require 'spec_helper'

describe PusherController do
  let(:user){create :user}
  let(:dashboard){create :dashboard, user: user}

  before :each do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end
  describe "Get 'auth'" do
    
    context "Fobidden" do
      it "returns forbidden if user is not authenticated" do
        post 'auth', format: :json
        expect(response.status).to eq(403)
      end

      it "returns forbidden when an authenticated user tries to subscribe to a dashbaord of another user" do
        sign_in user
        dashboard_b = create(:dashboard, user: create(:user))        
        post 'auth', format: :json, 
          channel_name: dashboard_b.pusher_channel, 
          socket_id: 'socket-id'
        expect(response.status).to eq(403)
      end
    end

    context "Success" do
      before :each do
        sign_in user
      end
      it "returns 200 OK" do
        post 'auth', format: :json, 
          channel_name: dashboard.pusher_channel, 
          socket_id: 'socket-id'
        expect(response.status).to eq(200)
      end

      it "calls Pusher[].athenticate" do
        mock_client = double('client')
        Pusher.stub(:[]).with(dashboard.pusher_channel).and_return(mock_client)
        mock_client.should_receive( :authenticate ).with('socket-id')
        post 'auth', format: :json, 
          channel_name: dashboard.pusher_channel, 
          socket_id: 'socket-id'
      end
      
      it "returns 200ok when an authenticated user tries to subscribe to one of his dashbaords" do
        post 'auth', format: :json, 
          channel_name: dashboard.pusher_channel, 
          socket_id: 'socket-id'
        expect(response.status).to eq(200)
      end
    end
  end
end


