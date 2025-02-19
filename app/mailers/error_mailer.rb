class ErrorMailer < ApplicationMailer
  default to: "bnb5508@psu.edu",
          from: "L-FAMS@LISTS.PSU.EDU"

  def error_email(name, log_path, errors)
    attachments["error.log"] = File.read(log_path)
    @errors = errors
    @integration = name
    @time = DateTime.now.strftime("%B %d, %Y at %I:%M %p")
    mail(subject: "AI Integration Error Report")
  end

  def test_email(to, value: 'bar')
    @foo = value
    mail(to: to, subject: "This is a test email!")
  end
end
