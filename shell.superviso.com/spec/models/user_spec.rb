require 'spec_helper'

describe User do

  it "is not dummy by default" do
    expect(described_class.new).to_not be_dummy
  end

  it 'gets an auth_token upon creation' do
    attrs = attributes_for(:user)
    attrs.delete(:auth_token)
    user = described_class.create!(attrs)

    expect(user.auth_token).to be_kind_of(String)
  end

  describe "#valid?" do
    let!(:existing_user) { create(:user) }
    let(:user) { described_class.new }

    it { should validate_presence_of(:username) }

    context "when user is dummy" do
      before do
        user.dummy = true
      end

      it "doesn't check for username uniqueness" do
        user.username = existing_user.username
        user.valid?
        expect(user.errors[:username]).to be_empty
      end

      it "doesn't check for email presence" do
        user.email = nil
        user.valid?
        expect(user.errors[:email]).to be_empty
      end

      it "doesn't check for email uniqueness" do
        user.email = existing_user.email
        user.valid?
        expect(user.errors[:email]).to be_empty
      end
    end

    context "when user is real" do
      before do
        user.dummy = false
      end

      it "checks for username uniqueness" do
        user.username = existing_user.username
        user.valid?
        expect(user.errors[:username]).to_not be_empty
      end

      it "checks for email presence" do
        user.email = nil
        user.valid?
        expect(user.errors[:email]).to_not be_empty
      end

      it "checks for email uniqueness" do
        user.email = existing_user.email
        user.valid?
        expect(user.errors[:email]).to_not be_empty
      end
    end
  end

  describe '.generate_auth_token' do
    it 'generates a string token' do
      token = described_class.generate_auth_token

      expect(token).to be_kind_of(String)
    end

    it 'generates unique token' do
      token_1 = described_class.generate_auth_token
      token_2 = described_class.generate_auth_token

      expect(token_1).to_not eq(token_2)
    end
  end

  describe '.for_credentials' do
    subject { described_class.for_credentials(credentials) }

    let!(:user) { create(:user, provider: 'twitter', uid: '1') }

    context "when there is matching record" do
      let(:credentials) { double('credentials', provider: 'twitter', uid: '1') }

      it { should eq(user) }
    end

    context "when there isn't matching record" do
      let(:credentials) { double('credentials', provider: 'twitter', uid: '2') }

      it { should be(nil) }
    end
  end

  describe '.for_email' do
    subject { described_class.for_email(email) }

    let!(:user) { create(:user, email: 'foo@bar.com') }

    context "when there is matching record" do
      let(:email) { 'foo@bar.com' }

      it { should eq(user) }
    end

    context "when there isn't matching record" do
      let(:email) { 'qux@bar.com' }

      it { should be(nil) }
    end
  end

  describe '.for_api_token' do
    subject { described_class.for_api_token(token) }

    let(:token) { 'f33e6188-f53c-11e2-abf4-84a6c827e88b' }

    context "when token exists" do
      let!(:existing_token) { create(:api_token, token: token) }

      it { should eq(existing_token.user) }
    end

    context "when token doesn't exist" do
      it { should be(nil) }
    end
  end

  describe '.for_auth_token' do
    subject { described_class.for_auth_token(auth_token) }

    context "when user with given token exists" do
      let(:auth_token) { user.auth_token }
      let(:user) { create(:user) }

      it { should eq(user) }
    end

    context "when user with given token doesn't exist" do
      let(:auth_token) { 'Km3u8ZsAZ_Qo0qgBT0rE0g' }

      it { should be(nil) }
    end
  end

  describe '.create_dummy' do
    subject { described_class.create_dummy(token, username) }

    let(:token) { 'f33e6188-f53c-11e2-abf4-84a6c827e88b' }
    let(:username) { 'somerandomguy' }

    it "returns a persisted user record" do
      expect(subject.id).not_to be(nil)
    end

    it "assigns given username to the user" do
      expect(subject.username).to eq(username)
    end

    it "assigns given api token to the user" do
      expect(subject.api_tokens.reload.first.token).to eq(token)
    end

    context "when token is blank" do
      let(:token) { '' }

      it { should be(nil) }
    end

    context "when username is nil" do
      let(:username) { nil }

      it "returns a persisted user record" do
        expect(subject.id).not_to be(nil)
      end

      it "assigns 'anonymous' as username to the user" do
        expect(subject.username).to eq('anonymous')
      end
    end

    context "when username is an empty string" do
      let(:username) { nil }

      it "returns a persisted user record" do
        expect(subject.id).not_to be(nil)
      end

      it "assigns 'anonymous' as username to the user" do
        expect(subject.username).to eq('anonymous')
      end
    end
  end

  describe '#username=' do
    it 'strips the whitespace' do
      user = described_class.new(username: ' sickill ')

      expect(user.username).to eq('sickill')
    end
  end

  describe '#email=' do
    it 'strips the whitespace' do
      user = described_class.new(email: ' foo@bar.com ')

      expect(user.email).to eq('foo@bar.com')
    end
  end

  describe '#assign_api_token' do
    subject { user.assign_api_token(token) }

    let(:user) { create(:user) }
    let(:token) { 'a33e6188-f53c-11e2-abf4-84a6c827e88b' }

    before do
      allow(ApiToken).to receive(:for_token).with(token) { api_token }
    end

    context "when given token doesn't exist" do
      let(:api_token) { nil }

      it { should be_kind_of(ApiToken) }
      it { should be_persisted }
      specify { expect(subject.token).to eq(token) }
    end

    context "when given token already exists" do
      let(:api_token) { double('api_token', reassign_to: nil) }

      it "reassigns it to the user" do
        subject
        expect(api_token).to have_received(:reassign_to).with(user)
      end

      it { should be(api_token) }
    end
  end

  describe '#asciicast_count' do
    subject { user.asciicast_count }

    let(:user) { create(:user) }

    before do
      2.times { create(:asciicast, user: user) }
    end

    it { should eq(2) }
  end

  describe '#asciicasts_excluding' do
    subject { user.asciicasts_excluding(asciicast, 1) }

    let(:user) { create(:user) }
    let(:asciicast) { create(:asciicast, user: user) }

    it "returns other asciicasts by user excluding the given one" do
      other = create(:asciicast, user: user)
      expect(subject).to eq([other])
    end
  end

  describe '#editable_by?' do
    subject { user.editable_by?(other) }

    let(:user) { create(:user) }

    context "when it's the same user" do
      let(:other) { user }

      it { should be(true) }
    end

    context "when it's a different user" do
      let(:other) { create(:user) }

      it { should be(false) }
    end
  end

  describe '#merge_to' do
    subject { user.merge_to(target_user) }

    let(:user) { create(:user) }
    let(:target_user) { create(:user) }
    let!(:api_token_1) { create(:api_token, user: user) }
    let!(:api_token_2) { create(:api_token, user: user) }
    let!(:asciicast_1) { create(:asciicast, user: user) }
    let!(:asciicast_2) { create(:asciicast, user: user) }

    before do
      subject
    end

    it "reassigns all user api tokens to the target user" do
      api_token_1.reload
      api_token_2.reload

      expect(api_token_1.user).to eq(target_user)
      expect(api_token_2.user).to eq(target_user)
    end

    it "reassigns all user asciicasts to the target user" do
      asciicast_1.reload
      asciicast_2.reload

      expect(asciicast_1.user).to eq(target_user)
      expect(asciicast_2.user).to eq(target_user)
    end

    it "removes the source user" do
      expect(user).to be_destroyed
    end
  end
end
