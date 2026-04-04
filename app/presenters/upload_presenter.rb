class UploadPresenter < SimpleDelegator
  def initialize(upload)
    @upload = upload
    super
  end

  def file_url
    Rails.application.routes.url_helpers.rails_storage_proxy_path(@upload.file, only_path: true)
  end

  def filename
    @upload.file.filename.to_s
  end
end
