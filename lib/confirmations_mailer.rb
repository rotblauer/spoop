# http://stackoverflow.com/questions/27698242/how-do-i-add-instance-variables-to-devise-email-templates
class ConfirmationsMailer < Devise::Mailer
  default from: '<poopislife@spoop.info>'

  def confirmation_instructions(record, token, opts={})
   @token = token
   #you can add your instance variables here
   @role = record.role 
   @donor_id = record.donor_id
   devise_mail(record, :confirmation_instructions, opts)
  end
end