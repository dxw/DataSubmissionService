require 'rails_helper'

RSpec.feature 'User can access a page' do
  scenario 'with instructions and a link to the URN list.' do
    mock_sso_with(email: 'email@example.com')
    mock_tasks_endpoint!
    mock_task_with_framework_endpoint!

    visit '/'
    click_link 'sign-in'

    visit '/tools'
    expect(page).to have_link('Download CCS URN List (July 2018).xls', href: '/urn/CCS URN List (July 2018).xls')
  end
end