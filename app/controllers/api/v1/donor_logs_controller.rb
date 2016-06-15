require 'helpers'
require 'descriptive_statistics'
class Api::V1::DonorLogsController < Api::ApiController
  before_action :authenticate
  before_action :set_donor_log, only: [:show, :update, :destroy]

  def index
    donor_logs = @api_user.donor_logs.order('time_of_passage DESC').first(40) #all
    render json: donor_logs
  end

  def create
    donor_log = @api_user.donor_logs.build(donor_log_params)

    # It's a unix date milliseconds.
    if params[:time_of_passage].class == Fixnum
      donor_log.time_of_passage = DateTime.strptime(params[:time_of_passage].to_s, '%Q').in_time_zone
    # Else it's a time-selected time like '2016-05-09T12:47:00.000Z' (which is not now)
    else 
      donor_log.time_of_passage = Time.zone.parse(params[:time_of_passage])
    end

    if donor_log.save
      render json: donor_log, status: :created, location: api_v1_donor_log_path(donor_log)
    else
      render json: donor_log.errors, status: :unprocessable_entity
    end
  end



  def show
    render json: @donor_log
  end

  def update
    if @donor_log.update(donor_log_params)
      head :no_content
    else 
      render json: @donor_log.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @donor_log.destroy
    head :no_content
  end

  #######
  ## Custom muther luvin bastards. 
  #
   def heatmap
    heaters = {}
    @api_user.meta_logs.each{ |x| heaters[x.time_of_passage.to_i] = 1 }
    render json: heaters
  end

  # is actually hour days... 
  def dayhour
    days = {}
    Array(0..23).each do |a|
      days[a] = {}
    end
    @api_user.meta_logs.all.each do |poo|
      days[poo.time_of_passage.hour][poo.time_of_passage.wday] ||= 0 # init
      days[poo.time_of_passage.hour][poo.time_of_passage.wday] += 1 # increment
    end
    render json: days
  end

  def build_stats poo_set
    all = {
      weight: [],
      bristol: []
    }

    # Argued
    poos = poo_set

    poos.each do |poo|
      all[:weight].push(poo.weight)
      all[:bristol].push(poo.bristol_score)
    end

    if poos.any?
      d = poos.order('time_of_passage ASC').first.time_of_passage.getutc.to_i 
    else 
      d = Time.zone.now.getutc.to_i
    end

    return {
      :start_date => d,
      :weight => all[:weight].descriptive_statistics,
      :bristol => all[:bristol].descriptive_statistics,
      :count => {
        processable: poos.where(processable: true).count,
        rejected: poos.where(processable: false).count
      }
    }
  end

  def statistics
    render :json => {'overall' => build_stats(@api_user.donor_logs.all), 
                     'last_two_months' => build_stats(@api_user.donor_logs.last_two_months.all),
                     'this_month' => build_stats(@api_user.donor_logs.this_month.all),
                     'this_week' => build_stats(@api_user.donor_logs.this_week.all),
                     'today' => build_stats(@api_user.donor_logs.today.all)}
  end

  private

    def set_donor_log
      @donor_log = @api_user.donor_logs.find(params[:id])
    end

    def donor_log_params
      params.require(:donor_log).permit(:user_id, :bristol_score, :weight, :donated, :processable, :notes, :time_of_passage)
    end
end
