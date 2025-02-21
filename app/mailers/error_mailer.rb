class ErrorMailer < ApplicationMailer
  default to: "bnb5508@psu.edu",
          from: "L-FAMS@LISTS.PSU.EDU"

  def error_email(name, log_path)
    attachments["error.log"] = File.read(log_path)
    @integration = name
    @time = DateTime.now.strftime("%B %d, %Y at %I:%M %p")
    mail(subject: "AI Integration #{name} Error")
  end
end
