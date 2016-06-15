# Preview all emails at http://localhost:3000/rails/mailers/non_donor_mailer
class NonDonorMailerPreview < ActionMailer::Preview
	def beta_pooper_email
	   NonDonorMailer.beta_pooper_email(User.first)
	 end
end
