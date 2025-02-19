namespace :email do
  desc "Send a test error email with mock error data"
  task send_test_error: :environment do

    log_path = "test_error.log"
    File.write(log_path, "Hello world\n")

    
    mock_errors = [
      {
        response: "Failed to sync faculty data",
        affected_faculty: "abc123",
        affected_osps: "OSP123, OSP456"
      },
      {
        response: "Invalid publication format",
        affected_faculty: "Alice Johnson",
        affected_osps: nil
      }
    ]

    begin
      ErrorMailer.error_email("Test Integration", log_path, mock_errors).deliver_now
      puts "Test error email sent successfully!"
    rescue StandardError => e
      puts "Failed to send test error email: #{e.message}"
    end

    File.delete(log_path) if File.exist?(log_path)
    puts "Test log file deleted"
  end
end