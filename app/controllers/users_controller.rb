require 'helpers'
require 'descriptive_statistics'
class UsersController < ApplicationController 
  before_filter :authenticate_user!
  before_filter :require_admin, only: [:index, :new, :create, :edit, :update, :destroy]
  before_filter :require_identity_or_admin
  before_filter :require_identity_strict, only: [:show, :create_api_key, :destroy_api_key]
  before_filter :redirect_admins, only: [:show]
  before_filter :no_editing_the_robot, only: [:edit, :update, :destroy, :create_api_key, :destroy_api_key]
  before_action :set_user, only: [:api_info, :begin, :show, :edit, :update, :destroy, :create_api_key, :destroy_api_key]
  
    # --> @user = User.find(params[:id])

  def create_api_key
    if @user.api_key.nil?
      if @user.create_api_key(role: @user.role)
        redirect_to api_info_user_path(@user), success: "One fresh pressed API key just for you!"
      else 
        redirect_to api_info_user_path(@user), error: "Failed to create API key."
      end
    else 
      redirect_to api_info_user_path(@user), warning: "But you already have an API key!"
    end 
  end
  def destroy_api_key
    if @user.api_key.present?
      @user.api_key.destroy
      redirect_to api_info_user_path(@user), info: "Destruction complete! Your API key is no more."
    else 
      redirect_to api_info_user_path(@user), warning: "But you don't have an API key to destroy! How'd you get this number anyway?"
    end 
  end  

  # GET /users
  # GET /users.json
  def index
    @users = User.all
  end

  def begin
  end

  def api_info
    @user_api_key = @user.api_key
  end

  # GET /users/1
  # GET /users/1.json
  # TODO -- move away from abstracted Poo and use a concrete model, ie MetaLog. 
  # TODO - get rid of all this shit. 170 lines of code should be more like 20, max. 
  def show
    @meta_logs = @user.meta_logs.order('time_of_passage DESC').all.includes(:donor_log, :open_biome_log)
    # @open_biome_logs = @meta_logs.map(&:open_biome_log) #@user.open_biome_logs.all
    
    # If there are no resources for the user yet...
    redirect_to begin_user_path(@user) if !@meta_logs.any?
    
    @open_biome_logs = @user.open_biome_logs.all
    @donor_logs = @user.donor_logs.all

    @tags_processable = @donor_logs.where(processable: true).tag_counts_on(:tags).limit(15)
    @tags_rejected = @donor_logs.where(donated: true).where(processable: false).tag_counts_on(:tags).limit(15)
    @tags_not_donated = @donor_logs.where(donated: false).tag_counts_on(:tags).limit(15)
    
    def set_color(obj, transparency)
      if obj.processable == false && obj.donated == true
        # (217,83,79)
        return 'rgba(217, 83, 79,' + transparency.to_s + ')'
      elsif obj.donated == false
        # (66,139,202)
        return 'rgba(248, 148, 6,' + transparency.to_s + ')'
      else 
        # (92,184,92)
        return 'rgba(92, 184,92, '+ transparency.to_s + ')'
      end
    end

    @count_today = {}
    @count_week = {}
    @count_month = {}
    @count_two_months = {}
    @count_all_time = {}

    @activities_statisticsable = []
    time_bristol_weight = []

    @punchcard = Helpers.punchcard_day_hour

    @meta_logs.each do |a,i|

      log = a.open_biome_log ? a.open_biome_log : a.donor_log
     
      time_bristol_weight.append({
        x: (log.time_of_passage.to_f * 1000).to_i,
        y: log.bristol_score,
        z: log.weight,
        name: log.processable ? 'Accepted' : 'Rejected',
        color: set_color(log, 1),
        fillColor: set_color(log, 0.1)
        })
      

      # Punch punchcard.
      @punchcard[a.time_of_passage.strftime('%u').to_i][a.time_of_passage.hour] ||= 1
      @punchcard[a.time_of_passage.strftime('%u').to_i][a.time_of_passage.hour] += 1


          @count_today['processable'] ||= 0 
          @count_today['rejected'] ||= 0 
          @count_today['not_donated'] ||= 0 
          @count_week['processable'] ||= 0 
          @count_week['rejected'] ||= 0 
          @count_week['not_donated'] ||= 0 
          @count_month['processable'] ||= 0 
          @count_month['rejected'] ||= 0 
          @count_month['not_donated'] ||= 0 
          @count_two_months['processable'] ||= 0 
          @count_two_months['rejected'] ||= 0 
          @count_two_months['not_donated'] ||= 0 
          @count_all_time['processable'] ||= 0 
          @count_all_time['rejected'] ||= 0 
          @count_all_time['not_donated'] ||= 0 

          if (a.time_of_passage > Time.zone.now.beginning_of_day)
            
            @count_today['processable'] += 1 if log.processable
            
            @count_today['rejected'] += 1 if !log.processable && log.donated
            
            @count_today['not_donated'] +=1 if !log.donated
          end
          if log.time_of_passage > Time.zone.now - 1.week
            
            @count_week['processable'] += 1 if log.processable
            
            @count_week['rejected'] += 1 if !log.processable && log.donated
            
            @count_week['not_donated'] +=1 if !log.donated
          end
          if log.time_of_passage > Time.zone.now - 1.month
            
            @count_month['processable'] += 1 if log.processable
            
            @count_month['rejected'] += 1 if !log.processable && log.donated
            
            @count_month['not_donated'] +=1 if !log.donated
          end
          if log.time_of_passage > Time.zone.now - 2.months
            
            @count_two_months['processable'] += 1 if log.processable
            
            @count_two_months['rejected'] += 1 if !log.processable && log.donated
            
            @count_two_months['not_donated'] +=1 if !log.donated
          end
          
            
            @count_all_time['processable'] += 1 if log.processable
            
            @count_all_time['rejected'] += 1 if !log.processable && log.donated
            
            @count_all_time['not_donated'] +=1 if !log.donated
          

        @activities_statisticsable.append(a)
        
      
    end

    gon.count_today = @count_today
    gon.count_week = @count_week  
    gon.count_month = @count_month 
    gon.count_two_months = @count_two_months 
    gon.count_all_time = @count_all_time 


    trulia_data = []
    punchcard_range = []
    (1..7).to_a.each do |day|
      # @punchcard[day] = {}
      (1..24).to_a.each do |hour|
        punchcard_range.append(@punchcard[day][hour])
        trulia_data.append({
          day: day, # because that's how the code I copied from the internet works. 
          hour: hour,
          value: @punchcard[day][hour]
          })
      end
    end
    puts "#{punchcard_range}"

    #figure out css for manual punchcard range
    @ds = punchcard_range.descriptive_statistics
 
    if @meta_logs.any?
      gon.us_start_date = {
        big: ((@meta_logs.first.time_of_passage - 3.months).to_f * 1000).to_i,
        small: ((@meta_logs.first.time_of_passage).to_f * 1000).to_i,
      }
    end
    gon.us_timebristolweight = time_bristol_weight
    gon.us_trulia_data = trulia_data
    gon.us_pie_charts_products = @open_biome_logs.processed.where(usage: 'treatment').group(:product).count.map { |k,v| { 'name' => k, 'y' => v } }
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, success: 'User was successfully created.' }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to @user, success: 'User was successfully updated.' }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url, info: 'User was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

    def no_editing_the_robot
      set_user
      if @user.demo
        redirect_to @user 
        flash[:danger] = "Hey! No tinkering with the robot!" 
      end
    end
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    def require_admin
      redirect_to current_user unless current_user.admin? 
    end

    def require_identity_strict
      redirect_to root_path unless current_user.is_user(set_user)
    end

    def require_identity_or_admin
      redirect_to root_path unless current_user.admin? or current_user.is_user(set_user)
    end

    def redirect_admins
      redirect_to admin_humans_path if current_user.admin?     
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:donor_id, :name, :email, :password, :password_confirmation)
    end
end
