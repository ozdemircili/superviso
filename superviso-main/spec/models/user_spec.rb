require 'spec_helper'

describe User do
  it { should validate_uniqueness_of(:email) }
  it { should validate_presence_of(:email) }
  it { should validate_presence_of(:password) }
  it { should have_many(:dashboards) }
  it { should have_many(:widgets) }

  context "#auth_token" do
    it "generate auth_token is called before create" do
      user = build(:user)
      user.should_receive(:generate_auth_token)
      user.save
    end
    it "is valorized on create" do
      user = create(:user)
      expect(user.auth_token).to_not be_nil
    end
    it "doesn't change on update" do
      user = create(:user)
      token = user.auth_token 
      user.update_attributes({email: "fake@example.com"})
      expect(user.auth_token).to eq(token)
    end
  end

end
