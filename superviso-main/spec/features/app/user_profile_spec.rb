require 'spec_helper'

describe "User Profile" do
  it "requires authentication" do
    logout(:user)
    visit profile_user_path
    expect(current_path).to eq(new_user_session_path)
  end
  context "When authenticated" do
    let(:user){FactoryGirl.create(:user)}
    before :each do
      login_as(user, :scope => :user)
      visit profile_user_path
    end


    it "permits to update name" do
      expect(page).to have_field("First name")
    end

    it "shows auth token" do
      expect(page).to have_content(user.auth_token)
    end

    it "has a submit button" do
      expect(page).to have_button("Save Changes")
    end

    context "Update" do
      it "Saves changes" do
        fill_in "First name", with: "Diego"
        fill_in "Last name", with: "Brogna"
        click_button "Save Changes"

        expect(page).to have_content("Your profile has been updated.")

        user.reload
        expect(user.first_name).to eq("Diego")
        expect(user.last_name).to eq("Brogna")
      end
    end
  end
end
