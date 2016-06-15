class Api::V1::OpenBiomeLogsController < Api::ApiController
	before_action :authenticate
	before_action :set_open_biome_log, only: [:show, :update, :destroy]
	
	def index
		ob_logs = @api_user.open_biome_logs.all
		render json: ob_logs
	end

	def create
		open_biome_log = current_user.open_biome_logs.build(open_biome_log_params)

		if open_biome_log.save
		  render json: open_biome_log, status: :created, location: open_biome_log
		else
		  render json: open_biome_log.errors, status: :unprocessable_entity
		end
	end

	def show
		render json: @open_biome_log
	end

	def update
		if @open_biome_log.update(open_biome_log_params)
		  head :no_content
		else
		  render json: @open_biome_log.errors, status: :unprocessable_entity
		end
	end

	def destroy
		@open_biome_log.destroy
		head :no_content
	end

	private

		def set_open_biome_log
			@open_biome_log = @api_user.open_biome_logs.find(params[:id])
		end

		def open_biome_log_params
			params.require(:open_biome_log).permit(:user_id, :donated_on, :donor_group, :donor_number, :sample, :quarantine_state, :product, :usage, :processing_state, :weight, :bristol_score, :batch, :bio_safety_cabinet_number, :buffer_multiplier_used, :number_units_produced, :on_site_donation, :received_by_name, :processed_by_name, :time_of_passage, :time_received, :time_started, :time_finished, :rejection_reason, :rejection_reason_other, :biologics_master_file_version_number)
		end
end
