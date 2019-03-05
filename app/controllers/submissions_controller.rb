class SubmissionsController < ApplicationController
  before_action :validate_file_presence_and_content_type, only: [:create]

  def new
    @task = API::Task.includes(:framework).find(params[:task_id]).first
  end

  def create
    task = API::Task.includes(:framework).find(params[:task_id]).first

    submission = upload_file_submission(task, params[:upload])

    redirect_to task_submission_path(task_id: task.id, id: submission.id)
  end

  def show
    @task = API::Task.includes(:framework).find(params[:task_id]).first
    @submission = API::Submission.find(params[:id]).first

    render template_for_submission(@submission)
  end

  def download
    submission = API::Submission
                 .includes(:files)
                 .find(params[:id]).first

    file = submission.files.first

    redirect_to file.temporary_download_url, status: :temporary_redirect
  end

  private

  def upload_file_submission(task, upload)
    submission = API::Submission.create(task_id: task.id, purchase_order_number: params[:purchase_order_number])
    submission_file = API::SubmissionFile.create(submission_id: submission.id)

    blob = ActiveStorage::Blob.create_after_upload!(
      io: upload,
      filename: upload.original_filename,
      content_type: upload.content_type,
      metadata: { submission_id: submission.id, submission_file_id: submission_file.id }
    )

    # The file_id has to be included in the blob's attributes so that the
    # JSONAPI::Consumer::Resource correctly routes and assigns the blob to the
    # submission file
    blob_attributes = blob
                      .attributes
                      .slice('key', 'filename', 'content_type', 'byte_size', 'checksum')
                      .merge(file_id: submission_file.id)

    API::SubmissionFileBlob.create(blob_attributes)
    task.update(status: 'in_progress')

    submission
  end

  def template_for_submission(submission)
    case submission.status
    when 'pending', 'processing' then :processing
    when 'in_review' then :in_review
    when 'validation_failed' then :validation_failed
    when 'completed' then :completed
    end
  end

  def handle_file_extension_validation
    redirect_to(
      new_task_submission_path(task_id: params[:task_id]),
      flash: { alert: 'Uploaded file must be in Microsoft Excel format (either .xlsx or .xls)' }
    )
  end

  def handle_file_presence_validation
    redirect_to(
      new_task_submission_path(task_id: params[:task_id]),
      flash: { alert: 'Please select a file' }
    )
  end

  def acceptable_file_extension?
    extension = File.extname(params[:upload].original_filename).downcase[1..-1]
    %w[xlsx xls].include?(extension)
  end

  def validate_file_presence_and_content_type
    handle_file_presence_validation && return if params[:upload].nil?

    handle_file_extension_validation unless acceptable_file_extension?
  end
end
