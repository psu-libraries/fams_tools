module OutputDates
  def year(date)
    date.instance_of?(Date) ? date.year : nil
  end

  def month(date)
    date.instance_of?(Date) ? date.month : nil
  end

  def day(date)
    date.instance_of?(Date) ? date.day : nil
  end
end