require "spec_helper"

describe "Login" do
  before :each do
    visit new_user_session_path
  end

  it "has an email field" do
    expect(page).to have_field("Email")
  end
  it "has a password field" do
    expect(page).to have_field("Email")
  end

  context "Success" do
    it "Authenticates valid users" do
      user = create(:user, 
                    password: "12345678", 
                    password_confirmation: "12345678")

      fill_in "Email", with: user.email
      fill_in "Password", with: "12345678"

      click_button "Login"

      expect(page).to have_link("Logout")
      expect(current_path).to eq(dashboards_path)
      expect(page).to have_link("Profile")
      expect(page).to have_link("Change password")
    end
  end

  context "Failure" do
    it "Doesn't authenticate user without password" do
      user = create(:user)
      
      fill_in "Email", with: user.email
      fill_in "Password", with: ""
      
      click_button "Login"

      expect(page).to_not have_link("Logout")
      expect(page).to have_content("Invalid email or password.")
    end
  end
end
