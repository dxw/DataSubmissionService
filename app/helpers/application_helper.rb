module ApplicationHelper
  def support_email_address
    'report-mi@crowncommercial.gov.uk'
  end

  def task_status(task)
    task.status == 'completed' ? 'Task Completed' : "Due by #{task.due_on.to_date}"
  end

  def task_due_date(task)
    task.due_on.to_date
  end
end
