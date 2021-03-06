class Run < ActiveRecord::Base
  before_save :assign_entry_status
  belongs_to :entry, counter_cache: true

  validates :entry_id, presence: true
  validates :status, presence: true

  enum status: [:ok, :dns, :dnf, :dsq]

  acts_as_list :scope => :entry
  default_scope -> { order('position ASC')}

  scope :unprocessed, -> { where.not(status: 0) }

  def difference_from(run)
    values = []
    values << (self.start - run.start unless self.start.nil? or run.start.nil?)
    values << (self.split2 - run.split2 unless self.split2.nil? or run.split2.nil?)
    values << (self.split3 - run.split3 unless self.split3.nil? or run.split3.nil?)
    values << (self.split4 - run.split4 unless self.split4.nil? or run.split4.nil?)
    values << (self.split5 - run.split5 unless self.split5.nil? or run.split5.nil?)
    values << (self.finish - run.finish unless self.finish.nil? or run.finish.nil?)
    values
  end

  def int1
    split2 - start if split2 && start
  end

  def int2
    split3 - split2 if split3 && split2
  end

  def int3
    split4 - split3 if split4 && split3
  end

  def int4
    split5 - split4 if split5 && split4
  end

  def int5
    finish - split5 if finish && split5
  end

  private

    def assign_entry_status
      if dnf?
        entry.status = "dnf"
      elsif dns?
        entry.status = "dns"
      elsif dsq?
        entry.status = "dsq"
      else
        entry.status = "ok"
      end
      entry.save
    end

end
