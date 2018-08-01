require 'rails_helper'

RSpec.feature 'Signing in as a user' do
  scenario 'Signing in successfully' do
    mock_sso_with(email: 'email@example.com')
    mock_tasks_endpoint!

    visit '/tasks'

    click_on 'sign-in'

    expect(page).to have_content 'Sign out'
  end

  scenario 'Signing out' do
    mock_sso_with(email: 'email@example.com')
    mock_tasks_endpoint!

    visit '/'
    click_on 'sign-in'

    visit '/'
    click_on 'sign-out'

    expect(page).to have_content 'Sign in'
  end
end
