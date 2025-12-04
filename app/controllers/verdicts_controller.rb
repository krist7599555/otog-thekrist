# frozen_string_literal: true

class VerdictsController < ApplicationController
  before_action :set_verdict, only: %i[show edit update destroy]

  # GET /verdicts
  def index
    @verdicts = Verdict.all
  end

  # GET /verdicts/1
  def show
  end

  # GET /verdicts/new
  def new
    @verdict = Verdict.new
  end

  # GET /verdicts/1/edit
  def edit
  end

  # POST /verdicts
  def create
    @verdict = Verdict.new(verdict_params)

    if @verdict.save
      redirect_to @verdict, notice: "Verdict was successfully created."
    else
      render :new, status: :unprocessable_content
    end
  end

  # PATCH/PUT /verdicts/1
  def update
    if @verdict.update(verdict_params)
      redirect_to @verdict, notice: "Verdict was successfully updated.", status: :see_other
    else
      render :edit, status: :unprocessable_content
    end
  end

  # DELETE /verdicts/1
  def destroy
    @verdict.destroy!
    redirect_to verdicts_path, notice: "Verdict was successfully destroyed.", status: :see_other
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_verdict
    @verdict = Verdict.find(params.expect(:id))
  end

  # Only allow a list of trusted parameters through.
  def verdict_params
    params.fetch(:verdict, {})
  end
end
