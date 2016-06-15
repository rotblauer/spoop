class DonorLogsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :require_identity_strict # only poopers can log their own poops.
  before_action :set_donor_log, only: [:show, :edit, :update, :toggle_private, :destroy]
  before_action :set_user # makes @user available per params[:user_id]

  # GET /donor_logs
  # GET /donor_logs.json
  def index
    @donor_logs = @user.donor_logs.order('time_of_passage DESC').all #OpenBiomeLog.all
    
    @dls_statsable = @donor_logs.extend(DescriptiveStatistics)

    @plucked = []
    @donor_logs.each do |obl|
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
      if !o.processable
        # (217,83,79)
        return 'rgba(217, 83, 79,' + a.to_s + ')'
      else 
        # (92,184,92)
        return 'rgba(92, 184,92, '+ a.to_s + ')'
      end
    end

    def name_processing_state(o)
      if o.processable
        return 'processable'
      else 
        return 'rejected'
      end
    end

    @user.donor_logs.order('time_of_passage DESC').each do |o|
      d.append({
        x: (o.time_of_passage.to_f * 1000).to_i,
        y: o.bristol_score,
        z: o.weight,
        name: name_processing_state(o),
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


    gon.dl_don = d
    gon.dl_heatmap = heatmap
    gon.json_heater = {}
    gon.dl_json_heater = heatmap.to_json
    gon.dl_startDate = ((@user.donor_logs.order('time_of_passage DESC').first.time_of_passage - 3.months).to_f * 1000).to_i #.time_of_passage.to_f * 1000).to_i
    gon.dl_punchcard = punchy    

    gon.dl_trulia_data = trulia_data
  end

  # GET /donor_logs/1
  # GET /donor_logs/1.json
  def show
  end

  # GET /donor_logs/new
  def new
    @donor_log = DonorLog.new
    gon.user_id = current_user.id
  end

  # GET /donor_logs/1/edit
  def edit
    gon.donor_log = @donor_log
  end

  # POST /donor_logs
  # POST /donor_logs.json
  def create
    @donor_log = DonorLog.new(donor_log_params.merge(user_id: @user.id))
    # use moment() instead of Date.now() to give time as tz correct string
    # @donor_log.time_of_passage = Time.zone.at(params[:donor_log][:time_of_passage].to_i / 1000)

    respond_to do |format|
      if @donor_log.save
        format.html { redirect_to user_path(@user), success: 'You pooped! That\'s awesome.' }
        format.json { render :show, status: :created, location: @donor_log }
      else
        format.html { render :new }
        format.json { render json: @donor_log.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /donor_logs/1
  # PATCH/PUT /donor_logs/1.json
  def update
    respond_to do |format|
      if @donor_log.update(donor_log_params)
        format.html { redirect_to user_path(@user), notice: 'Donor log was successfully updated.' }
        format.json { render :show, status: :ok, location: @donor_log }
      else
        format.html { render :edit }
        format.json { render json: @donor_log.errors, status: :unprocessable_entity }
      end
    end
  end

  def toggle_private
    @donor_log.is_private = !@donor_log.is_private
    respond_to do |format|
      if @donor_log.save
        # toggle_private.js.erb
        format.js {  }
      else
        format.js { render json: {error: 'Shit.'} }
      end
    end
  end

  # DELETE /donor_logs/1
  # DELETE /donor_logs/1.json
  def destroy
    @donor_log.destroy
    respond_to do |format|
      format.html { redirect_to user_url(@user), notice: 'Donor log was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

    def set_user
      @user = User.find(params[:user_id])
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_donor_log
      @donor_log = DonorLog.find(params[:id])
    end

    def require_identity_or_admin
      redirect_to root_path unless current_user.admin? or current_user.is_user(set_user)
    end

    def require_identity_strict
      redirect_to :back unless current_user.is_user(set_user)
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def donor_log_params
      params.require(:donor_log).permit(:user_id, :bristol_score, :weight, :donated, :processable, :notes, :time_of_passage, :date_of_passage)
    end
end
