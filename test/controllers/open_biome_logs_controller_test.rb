require 'test_helper'

class OpenBiomeLogsControllerTest < ActionController::TestCase
  setup do
    @open_biome_log = open_biome_logs(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:open_biome_logs)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create open_biome_log" do
    assert_difference('OpenBiomeLog.count') do
      post :create, open_biome_log: { batch: @open_biome_log.batch, bio_safety_cabinet_number: @open_biome_log.bio_safety_cabinet_number, biologics_master_file_version_number: @open_biome_log.biologics_master_file_version_number, bristol_score: @open_biome_log.bristol_score, buffer_multiplier_used: @open_biome_log.buffer_multiplier_used, donated_on: @open_biome_log.donated_on, donor_group: @open_biome_log.donor_group, donor_number: @open_biome_log.donor_number, number_units_produced: @open_biome_log.number_units_produced, on_site_donation: @open_biome_log.on_site_donation, processed_by_name: @open_biome_log.processed_by_name, processing_state: @open_biome_log.processing_state, product: @open_biome_log.product, quarantine_state: @open_biome_log.quarantine_state, received_by_name: @open_biome_log.received_by_name, rejection_reason: @open_biome_log.rejection_reason, rejection_reason_other: @open_biome_log.rejection_reason_other, sample: @open_biome_log.sample, time_finished: @open_biome_log.time_finished, time_of_passage: @open_biome_log.time_of_passage, time_received: @open_biome_log.time_received, time_started: @open_biome_log.time_started, usage: @open_biome_log.usage, user_id: @open_biome_log.user_id, weight: @open_biome_log.weight }
    end

    assert_redirected_to open_biome_log_path(assigns(:open_biome_log))
  end

  test "should show open_biome_log" do
    get :show, id: @open_biome_log
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @open_biome_log
    assert_response :success
  end

  test "should update open_biome_log" do
    patch :update, id: @open_biome_log, open_biome_log: { batch: @open_biome_log.batch, bio_safety_cabinet_number: @open_biome_log.bio_safety_cabinet_number, biologics_master_file_version_number: @open_biome_log.biologics_master_file_version_number, bristol_score: @open_biome_log.bristol_score, buffer_multiplier_used: @open_biome_log.buffer_multiplier_used, donated_on: @open_biome_log.donated_on, donor_group: @open_biome_log.donor_group, donor_number: @open_biome_log.donor_number, number_units_produced: @open_biome_log.number_units_produced, on_site_donation: @open_biome_log.on_site_donation, processed_by_name: @open_biome_log.processed_by_name, processing_state: @open_biome_log.processing_state, product: @open_biome_log.product, quarantine_state: @open_biome_log.quarantine_state, received_by_name: @open_biome_log.received_by_name, rejection_reason: @open_biome_log.rejection_reason, rejection_reason_other: @open_biome_log.rejection_reason_other, sample: @open_biome_log.sample, time_finished: @open_biome_log.time_finished, time_of_passage: @open_biome_log.time_of_passage, time_received: @open_biome_log.time_received, time_started: @open_biome_log.time_started, usage: @open_biome_log.usage, user_id: @open_biome_log.user_id, weight: @open_biome_log.weight }
    assert_redirected_to open_biome_log_path(assigns(:open_biome_log))
  end

  test "should destroy open_biome_log" do
    assert_difference('OpenBiomeLog.count', -1) do
      delete :destroy, id: @open_biome_log
    end

    assert_redirected_to open_biome_logs_path
  end
end
