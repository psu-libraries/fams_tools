module OutputDates
  def year(date)
    date.instance_of?(Date) ? date.year : Date.parse(date).year
  end

  def month(date)
    date.instance_of?(Date) ? date.month : Date.parse(date).month
  end

  def day(date)
    date.instance_of?(Date) ? date.day : Date.parse(date).day
  end
end
