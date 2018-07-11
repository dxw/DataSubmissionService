class SubmissionsController < ApplicationController
  before_action :ensure_user_signed_in
  before_action :validate_file_presence_and_content_type, only: [:create]

  def new
    @task = API::Task.includes(:framework).find(params[:task_id]).first

    if params[:type] && params[:type] == 'nil_return'
      render 'nil_return'
    else
      render 'completed_return'
    end
  end

  def create
    task = API::Task.includes(:framework).find(params[:task_id]).first
    submission = API::Submission.create(task_id: task.id)
    task.update(status: 'in_progress')

    blob = ActiveStorage::Blob.create_after_upload!(
      io: params[:upload],
      filename: params[:upload].original_filename,
      content_type: params[:upload].content_type,
      metadata: { submission_id: submission.id }
    )

    redirect_to(
      task_submission_review_processing_path(task_id: task.id, submission_id: submission.id),
      flash: { notice: "#{blob.filename} file upload successful!" }
    )
  end

  private

  def handle_content_type_validation
    redirect_to(
      new_task_submission_path(task_id: params[:task_id]),
      flash: { alert: 'File content_type must be an xlsx or xlx' }
    )
  end

  def handle_file_presence_validation
    redirect_to(
      new_task_submission_path(task_id: params[:task_id]),
      flash: { alert: 'Please select a file' }
    )
  end

  def content_type_valid?
    excel_mime_types.include? params[:upload].content_type
  end

  def excel_mime_types
    %w[application/vnd.ms-excel
       application/vnd.openxmlformats-officedocument.spreadsheetml.sheet]
  end

  def validate_file_presence_and_content_type
    handle_file_presence_validation && return if params[:upload].nil?

    handle_content_type_validation unless content_type_valid?
  end
end
