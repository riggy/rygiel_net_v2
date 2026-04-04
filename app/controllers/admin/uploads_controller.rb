class Admin::UploadsController < Admin::BaseController
  def create
    upload = Upload.new
    upload.file.attach(params[:file])

    if upload.save
      render json: {
        url: upload.file_url,
        filename: upload.file.filename.to_s
      }, status: :created
    else
      render json: { error: upload.errors.full_messages.join(", ") },
             status: :unprocessable_entity
    end
  end
end
