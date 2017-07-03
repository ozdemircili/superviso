require 'spec_helper'

feature "Homepage", :js => true do

  let!(:user) { create(:user) }
  let!(:asciicast) { create(:asciicast, user: user, title: 'the title') }

  scenario 'Visiting' do
    visit root_path

    expect(page).to have_link('Browse')
    expect(page).to have_link('Docs')
    expect(page).to have_link('Start Recording')
    expect(page).to have_content(/Featured asciicasts/i)
    expect(page).to have_content(/Latest asciicasts/i)
    expect(page).to have_link("the title")
  end

end
