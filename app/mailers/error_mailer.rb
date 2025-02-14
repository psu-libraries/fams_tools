class ErrorMailer < ApplicationMailer
  default from: "L-FAMS@LISTS.PSU.EDU"

  def test_email(to, value: 'bar')
    @foo = value
    mail(to: to, subject: "This is a test email!")
  end
end
