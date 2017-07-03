require 'spec_helper'
describe "/collect" do
  let(:body){ {}.to_json }

  context "Http Request" do
    before do
      User.stub(:authenticated?).and_return(true)
      User.stub(:authorized?).and_return(true)
      post '/' , body, {'Content-Type' => 'application/json'}
    end

    subject{last_response}

    it{should be_ok}
  end

  context "Authentication and Authorization" do
    context "Success" do
      it "authenticates the user" do
        app.any_instance.should_receive(:authenticate!).with(no_args).once
        User.stub(:authorized?).and_return(true) 
        post '/' , body, {'Content-Type' => 'application/json'}
      end
      it "authorizes push data on widget" do
        User.stub(:authenticated?).and_return(true)
        app.any_instance.should_receive(:authorize!).with(no_args).once
        post '/' , body, {'Content-Type' => 'application/json'}
      end
    end
    context "Failure" do
      it "responds with 401 Unauthorized when unauthenticated" do
        User.stub(:authenticated?).and_return(false)
        post '/' , body, {'Content-Type' => 'application/json'}
        last_response.status.should be(401)
      end
      it "responds with 401 Unauthorized when unauthorized" do
        User.stub(:authenticated?).and_return(true)
        User.stub(:authorized?).and_return(false)
        post '/' , body, {'Content-Type' => 'application/json'}
        last_response.status.should be(401)
      end
    end
  end
end
