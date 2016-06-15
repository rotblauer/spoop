require 'date'

class OpenBiomeLogsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :require_identity_or_admin
  before_action :set_open_biome_log, only: [:show, :edit, :update, :destroy]
  before_action :set_user

  
  def index
    @open_biome_logs = @user.open_biome_logs.order('time_of_passage DESC').all #OpenBiomeLog.all
    
    @obl_statsable = @open_biome_logs.extend(DescriptiveStatistics)

    @plucked = []
    @open_biome_logs.each do |obl|
      @plucked.append([
        obl.bristol_score || 0,
        obl.weight
        ])
    end

    d = []
    heatmap = {}
    punchcard = {}
    hours = Array(1..24)
    days = Array(1..7)
    days.each do |day|
      punchcard[day] = {}
      hours.each do |hour|
        punchcard[day][hour] = 0
      end
    end

    puts "#{punchcard}"

    def set_color(o, a)
      if o.processing_state == 'rejected'
        # (217,83,79)
        return 'rgba(217, 83, 79,' + a.to_s + ')'
      elsif o.quarantine_state == 'quarantined'
        # (66,139,202)
        return 'rgba(66, 139, 202,' + a.to_s + ')'
      else 
        # (92,184,92)
        return 'rgba(92, 184,92, '+ a.to_s + ')'
      end
    end

    @user.open_biome_logs.order('time_of_passage DESC').each do |o|
      d.append({
        x: (o.time_of_passage.to_f * 1000).to_i,
        y: o.bristol_score,
        z: o.weight,
        name: o.processing_state,
        color: set_color(o, 1),
        fillColor: set_color(o, 0.1)
        })
      heatmap[o.time_of_passage.to_i] = 1 

      # punchcard[(o.time_of_passage.wday + 6) % 7][(o.time_of_passage.hour + 23) % 24] ||= 0
      # punchcard[o.time_of_passage.wday][o.time_of_passage.hour] ||= 0
      # punchcard[(o.time_of_passage.wday + 6) % 7][(o.time_of_passage.hour + 23) % 24] += 1
      punchcard[o.time_of_passage.strftime('%u').to_i][o.time_of_passage.hour] ||= 1
      punchcard[o.time_of_passage.strftime('%u').to_i][o.time_of_passage.hour] += 1

    end
    puts "PUNCHCARD"
    puts "#{punchcard}"
    punchy = []
    trulia_data = []
    days.each do |day|
      # punchcard[day] = {}
      hours.each do |hour|
        punchy.append({
          x: hour,
          y: day,
          z: punchcard[day][hour],
          #dae289
          color: 'rgba(66,66,66,0.5)'
          })
        trulia_data.append({
          day: day, # because that's how the code I copied from the internet works. 
          hour: hour,
          value: punchcard[day][hour]
          })
      end
    end


    gon.don = d
    gon.heatmap = heatmap
    gon.json_heater = heatmap.to_json
    gon.dl_json_heater = {"123" => 1}.to_json
    gon.startDate = ((@user.open_biome_logs.order('time_of_passage DESC').first.time_of_passage - 3.months).to_f * 1000).to_i #.time_of_passage.to_f * 1000).to_i
    gon.punchcard = punchy

    gon.pie_charts = {}
    gon.pie_charts['products'] = @user.open_biome_logs.where(usage: 'treatment', processing_state:'processed').group(:product).count.map { |k,v| { 'name' => k, 'y' => v } }
    gon.pie_charts['quarantine'] = @user.open_biome_logs.group(:quarantine_state).count.map { |k,v| { 'name' => k, 'y' => v } }
    gon.pie_charts['processable'] = @user.open_biome_logs.group(:processing_state).count.map { |k,v| { 'name' => k, 'y' => v } }

    gon.trulia_data = trulia_data

  end

  # GET /open_biome_logs/1
  # GET /open_biome_logs/1.json
  def show
  end

  # GET /open_biome_logs/new
  def new
    @open_biome_log = OpenBiomeLog.new
  end

  # GET /open_biome_logs/1/edit
  def edit
  end

  def import_setup
  end

  def import 
    results_for_alert = {
      saved: 0,
      updated: 0
    }
    a = OpenBiomeLog.import(params[:open_biome_log][:csv], @user)
    puts a

    respond_to do |format|

      a.each do |record|
        begin
          
          existing_record = OpenBiomeLog.find_by(user_id: @user.id, donated_on: record['donated_on'], weight: record['weight'], sample: record['sample'])
          # if record does exist
          if !existing_record.nil?
            existing_record.update_attributes(record)
            results_for_alert[:updated] += 1
          # record is new
          else 
            new_obl = OpenBiomeLog.new(record)
            results_for_alert[:saved] += 1
            new_obl.save!
          end

        rescue ActiveRecord::RecordInvalid => e
          if e.message == 'Validation failed: Email has already been taken'
            format.html { redirect_to :back, danger: 'Failed to import :-(' }
            format.json { render json: e, status: :unprocessable_entity }
         else
            format.html { redirect_to :back, error: "Failed to import. #{e.message}" }
            format.json { render json: e, status: :unprocessable_entity }
         end
        end
      end

      #success
      
      if current_user.donor?
        format.html { 
          redirect_to user_path(@user),
          success: "Successful import! Created #{results_for_alert[:saved]} new entries, and updated #{results_for_alert[:updated]} existing entries." 
        }
      else 
        format.html { 
          redirect_to admin_humans_path,
          success: "Successful import! Created #{results_for_alert[:saved]} new entries, and updated #{results_for_alert[:updated]} existing entries for donor #{@user.donor_id}." 
        }
      end
    end
  end

  # POST /open_biome_logs
  # POST /open_biome_logs.json
  def create
    @open_biome_log = current_user.open_biome_logs.build(open_biome_log_params)

    respond_to do |format|
      if @open_biome_log.save
        format.html { redirect_to user_path(@user), success: 'Open biome log was successfully created.' }
        format.json { render :show, status: :created, location: @open_biome_log }
      else
        format.html { render :new }
        format.json { render json: @open_biome_log.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /open_biome_logs/1
  # PATCH/PUT /open_biome_logs/1.json
  def update
    respond_to do |format|
      if @open_biome_log.update(open_biome_log_params)
        format.html { redirect_to user_path(@user), success: 'Open biome log was successfully updated.' }
        format.json { render :show, status: :ok, location: @open_biome_log }
      else
        format.html { render :edit }
        format.json { render json: @open_biome_log.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /open_biome_logs/1
  # DELETE /open_biome_logs/1.json
  def destroy
    @open_biome_log.destroy
    respond_to do |format|
      format.html { redirect_to user_path(@user), info: 'Open biome log was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

    def set_user
      @user = User.find(params[:user_id])
    end

    def require_identity_or_admin
      redirect_to root_path unless current_user.admin? or current_user.is_user(set_user)
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_open_biome_log
      @open_biome_log = OpenBiomeLog.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def open_biome_log_params
      params.require(:open_biome_log).permit(:user_id, :donated_on, :donor_group, :donor_number, :sample, :quarantine_state, :product, :usage, :processing_state, :weight, :bristol_score, :batch, :bio_safety_cabinet_number, :buffer_multiplier_used, :number_units_produced, :on_site_donation, :received_by_name, :processed_by_name, :time_of_passage, :time_received, :time_started, :time_finished, :rejection_reason, :rejection_reason_other, :biologics_master_file_version_number)
    end
end
