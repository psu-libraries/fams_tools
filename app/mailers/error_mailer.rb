class ErrorMailer < ApplicationMailer
  default to: %w[nmg110@psu.edu ljd149@psu.edu],
          from: 'L-FAMS@LISTS.PSU.EDU'

  def error_email(name, log_path)
    @has_log = File.exist?(log_path)
    @integration = name
    @time = DateTime.now.strftime('%B %d, %Y at %I:%M %p')
    attachments['error.log'] = File.read(log_path) if @has_log
    mail(subject: "AI Integration #{name} Error")
  end
end
