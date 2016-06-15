require 'descriptive_statistics'
class AdminController < ApplicationController
	before_filter :authenticate_user!
	before_filter :require_admin 
  before_filter :require_site_admin, only: [:meta_spoop]
	before_action :set_donors_and_logs
	respond_to :json, :js, :html
		# => @donors = User.donors.all
		# 	 @logs = OpenBiomeLog.all + DonorLog.shared

	def meta_spoop
		@non_donors = NonDonor.all
	end
	def humans
		@donors = User.donors.no_robots.order('donor_id ASC').all
		@admins = User.g_open_biome.admins.all
		@non_donors = NonDonor.all
	end

  def donations
  	@start_date = ((Time.zone.now - 3.months).to_f * 1000).to_i

  	array = []
  	OpenBiomeLog.no_robots.group(:donor_number).average(:weight).each do |k,v|
  		array.append({id: (k || 1).to_s, value: v.round})
  	end
  	gon.avg_weights = array
  	gon.overview_heatmap_data = OpenBiomeLog.heatmap_data('time_of_passage > ?', Time.zone.now - 3.years)

  	@open_biome_logs = OpenBiomeLog.no_robots.all
  end

  def ob_logs_by_donor_daily
  	render json: OpenBiomeLog.no_robots.where('time_of_passage > ?', Time.zone.now - 4.month).order('donor_number ASC').group(:donor_number).group_by_week(:time_of_passage).count.chart_json
  end

  def logs
  	@open_biome_logs = OpenBiomeLog.no_robots.all
  end

  #donor_insights.json.jbuilder
  def donor_insights
  	@donor_logs = DonorLog.no_robots.shared.order('time_of_passage DESC').all
  	# gon.donor_logs = @donor_logs
  end

  private

	  def require_admin
	    redirect_to current_user unless current_user.admin? 	  
    end
    def require_site_admin
      redirect_to current_user unless current_user.site_admin?
    end

	  def set_donors_and_logs
	  	@donors = User.donors.all
	  	@open_biome_logs = OpenBiomeLog.order('time_of_passage DESC').all
	  	@donor_logs = DonorLog.shared
	  end
end
