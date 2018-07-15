module API
  class Task < Base
    has_one :framework

    # GET /tasks/:id/complete
    custom_endpoint :complete, on: :member, request_method: :post
  end
end
