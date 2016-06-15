class NonDonorMailer < ApplicationMailer
	default from: "isaac@spoop.info"

	def beta_pooper_email(user)
	  @user = user
	  mail(to: @user.email, subject: 'You\'re on the list at Spoop!')
	end
end
