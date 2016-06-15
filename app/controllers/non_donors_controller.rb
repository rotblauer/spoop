class NonDonorsController < ApplicationController
  before_filter :require_admin, except: [:new, :create]
  before_action :set_non_donor, only: [:show, :edit, :update, :destroy]


  # GET /non_donors
  # GET /non_donors.json
  def index
    @non_donors = NonDonor.all
  end

  # GET /non_donors/1
  # GET /non_donors/1.json
  def show
  end

  # GET /non_donors/new
  def new
    @non_donor = NonDonor.new
  end

  # GET /non_donors/1/edit
  def edit
  end

  # POST /non_donors
  # POST /non_donors.json
  def create
    @non_donor = NonDonor.new(non_donor_params)

    respond_to do |format|
      if @non_donor.save

        # Send confirmation email that they've been added to the list. 
        NonDonorMailer.beta_pooper_email(@non_donor).deliver

        format.html { redirect_to root_path, success: 'Awesome! Thanks! You\'re signed up. (You should have an email in your inbox any second now...)' }
        format.json { render :show, status: :created, location: @non_donor }
      else
        format.html { render :new }
        format.json { render json: @non_donor.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /non_donors/1
  # PATCH/PUT /non_donors/1.json
  def update
    respond_to do |format|
      if @non_donor.update(non_donor_params)
        format.html { redirect_to @non_donor, notice: 'Non donor was successfully updated.' }
        format.json { render :show, status: :ok, location: @non_donor }
      else
        format.html { render :edit }
        format.json { render json: @non_donor.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /non_donors/1
  # DELETE /non_donors/1.json
  def destroy
    @non_donor.destroy
    respond_to do |format|
      format.html { redirect_to admin_humans_path, notice: 'Non donor was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_non_donor
      @non_donor = NonDonor.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def non_donor_params
      params.require(:non_donor).permit(:email, :message, :newsletter_ok)
    end

    def require_admin
      redirect_to root_path unless current_user && current_user.admin?     end
end
