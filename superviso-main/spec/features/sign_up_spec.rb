require "spec_helper"

describe "Sign Up" do
  before :each do
    visit new_user_registration_path
  end
  it "has an email field" do
    expect(page).to have_field("user_email")
  end
  it "has a password field" do
    expect(page).to have_field("user_password")
  end
  it "has a password confirmation field" do
    expect(page).to have_field("user_password_confirmation")
  end

  context "Success" do
    before :each do
      fill_in "user_email", with: FactoryGirl.generate(:email) 
      fill_in "user_password", with: "12345678"
      fill_in "user_password_confirmation", with: "12345678"

      click_button "Sign Up"
    end

    it "after sign up the user is authenticated" do
      expect(page).to have_link("Logout")
    end
  end
end
