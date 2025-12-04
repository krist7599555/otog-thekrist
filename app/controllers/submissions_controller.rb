# frozen_string_literal: true

class SubmissionsController < ApplicationController
  before_action :set_submission, only: %i[show edit update destroy]

  # GET /submissions
  def index
    @submissions = Submission.all
  end

  # GET /submissions/1
  def show
  end

  # GET /submissions/new
  def new
    @submission = Submission.new
  end

  # GET /submissions/1/edit
  def edit
  end

  # POST /submissions
  def create
    puts "submission_params", submission_params
    @submission = Submission.new(submission_params)

    if @submission.save
      redirect_to @submission, notice: "Submission was successfully created."
    else
      render :new, status: :unprocessable_content
    end
  end

  # PATCH/PUT /submissions/1
  def update
    if @submission.update(submission_params)
      redirect_to @submission, notice: "Submission was successfully updated.", status: :see_other
    else
      render :edit, status: :unprocessable_content
    end
  end

  # DELETE /submissions/1
  def destroy
    @submission.destroy!
    redirect_to submissions_path, notice: "Submission was successfully destroyed.", status: :see_other
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_submission
    @submission = Submission.find(params.expect(:id))
  end

  # Only allow a list of trusted parameters through.
  def submission_params
    params.fetch(:submission, {}).permit(
      :grading_detail,
      :grading_status,
      :lang,
      :score,
      :source_code,
      :time_used,
      :task_id,
      :user_id,
      task_attributes: [:id],
      user_attributes: [:id]
    )
  end
end
