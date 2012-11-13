class Picture < ActiveRecord::Base
  attr_protected

  validates :date, presence: true

  scope :latest, lambda {
    order('date DESC')
  }

  def next_picture
    self.class.where('date > ?', date).order('date ASC').first
  end

  def previous_picture
    self.class.where('date < ?', date).order('date DESC').first
  end

  def to_param
    # update for year >=2095
    date.strftime 'ap%y%m%d'
  end

  alias :apid :to_param

  def serializable_hash(options = {})
    super options.merge!({
      only: [:title, :date, :media],
      methods: [:apid]
    })
  end

  def self.date_from_apid(id)
    parts = id.scan(%r[\d{2}]).map(&:to_i)

    if parts.size == 3
      parts[0] = parts[0] + (parts[0] >= 95 ? 1900 : 2000)

      Date.new(*parts) rescue nil
    end
  end
end
