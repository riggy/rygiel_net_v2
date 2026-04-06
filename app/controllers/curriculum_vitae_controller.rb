class CurriculumVitaeController < ApplicationController
  def show
    @curriculum_vitae = CurriculumVitaePresenter.new(CurriculumVitae.current)

    respond_to do |format|
      format.html
      format.pdf do
        pdf = Grover.new(cv_print_url, format: "A4", print_background: true,
          margin: { top: "1.5cm", right: "2cm", bottom: "1.5cm", left: "2cm" }).to_pdf
        send_data pdf, filename: "cv.pdf", type: "application/pdf", disposition: "inline"
      end
    end
  end

  def print
    @curriculum_vitae = CurriculumVitaePresenter.new(CurriculumVitae.current)
    render layout: "print"
  end
end
