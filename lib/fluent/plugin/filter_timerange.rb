class Fluent::Plugin::TimerangeFilter < Fluent::Plugin::Filter
  Fluent::Plugin.register_filter('timerange', self)

  config_param :starttime, :string
  config_param :endtime, :string

  def start
    super
  end

  def shutdown
    super
  end

  def configure(conf)
    super
    @starttime = Time.parse('1970-01-01 ' << conf['starttime'])
    @endtime = Time.parse('1970-01-01 ' << conf['endtime'])
  end

  def filter(tag, time, record)
    @now = Time.parse('1970-01-01 ' << Time.at(time).strftime('%R'))
    if @now > @starttime and @now < @endtime
      return record
    else
      return nil
    end
  end

end

