require 'rails_helper'

RSpec.describe 'the submission page' do
  before do
    mock_task_with_framework_endpoint!
  end

  it 'refuses users that are not signed in' do
    mock_pending_submission_endpoint!
    get task_submission_path(task_id: mock_task_id, id: mock_submission_id)

    expect(response).to redirect_to(root_path)
  end

  context 'when signed-in' do
    before { stub_signed_in_user }

    it 'shows the "processing" screen for a "pending" submission' do
      mock_pending_submission_endpoint!
      get task_submission_path(task_id: mock_task_id, id: mock_submission_id)

      expect(response).to be_successful
      expect(response.body).to include 'Checking file'
    end

    it 'shows the "processing" screen for a "processing submission' do
      mock_submission_with_entries_pending_endpoint!
      get task_submission_path(task_id: mock_task_id, id: mock_submission_id)

      expect(response).to be_successful
      expect(response.body).to include 'Checking file'
    end

    it 'shows the details for a valid submission' do
      mock_submission_with_entries_validated_endpoint!
      get task_submission_path(task_id: mock_task_id, id: mock_submission_id)

      expect(response).to be_successful
      expect(response.body).to include 'Review & submit'
    end

    it 'shows the errors for an invalid submission' do
      mock_submission_with_entries_errored_endpoint!
      get task_submission_path(task_id: mock_task_id, id: mock_submission_id)

      expect(response).to be_successful
      expect(response.body).to include 'Errors to correct'
      expect(response.body).to include 'Some other error'
    end

    it 'shows completed submission page for a "completed" submission' do
      mock_submission_completed_endpoint!
      get task_submission_path(task_id: mock_task_id, id: mock_submission_id)

      expect(response).to be_successful
      expect(response.body).to include 'Submission completed'
    end
  end
end
