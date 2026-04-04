class Admin::UploadsController < Admin::BaseController
  def create
    upload = Upload.new
    upload.file.attach(params[:file])

    if upload.save
      presenter = UploadPresenter.new(upload)
      render json: {
        url: presenter.file_url,
        filename: presenter.filename
      }, status: :created
    else
      render json: { error: upload.errors.full_messages.join(", ") },
             status: :unprocessable_entity
    end
  end
end
