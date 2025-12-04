# frozen_string_literal: true

require "test_helper"

class VerdictsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @verdict = verdicts(:one)
  end

  test "should get index" do
    get verdicts_url
    assert_response :success
  end

  test "should get new" do
    get new_verdict_url
    assert_response :success
  end

  test "should create verdict" do
    assert_difference("Verdict.count") do
      post verdicts_url, params: {verdict: {}}
    end

    assert_redirected_to verdict_url(Verdict.last)
  end

  test "should show verdict" do
    get verdict_url(@verdict)
    assert_response :success
  end

  test "should get edit" do
    get edit_verdict_url(@verdict)
    assert_response :success
  end

  test "should update verdict" do
    patch verdict_url(@verdict), params: {verdict: {}}
    assert_redirected_to verdict_url(@verdict)
  end

  test "should destroy verdict" do
    assert_difference("Verdict.count", -1) do
      delete verdict_url(@verdict)
    end

    assert_redirected_to verdicts_url
  end
end
