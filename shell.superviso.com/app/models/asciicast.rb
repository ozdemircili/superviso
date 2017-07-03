class Asciicast < ActiveRecord::Base

  ORDER_MODES = { recency: 'created_at', popularity: 'views_count' }

  mount_uploader :stdin_data,    StdinDataUploader
  mount_uploader :stdin_timing,  StdinTimingUploader
  mount_uploader :stdout_data,   StdoutDataUploader
  mount_uploader :stdout_timing, StdoutTimingUploader
  mount_uploader :stdout_frames, StdoutFramesUploader

  serialize :snapshot, JSON

  validates :stdout_data, :stdout_timing, :presence => true
  validates :terminal_columns, :terminal_lines, :duration, :presence => true

  belongs_to :user
  has_many :comments, -> { order(:created_at) }, :dependent => :destroy
  has_many :likes, :dependent => :destroy

  scope :featured, -> { where(featured: true) }
  scope :by_recency, -> { order("created_at DESC") }
  scope :by_random, -> { order("RANDOM()") }
  scope :latest_limited, -> (n) { by_recency.limit(n).includes(:user) }
  scope :random_featured_limited, -> (n) {
    featured.by_random.limit(n).includes(:user)
  }

  def self.cache_key
    timestamps = scoped.select(:updated_at).map { |o| o.updated_at.to_i }
    Digest::MD5.hexdigest timestamps.join('/')
  end

  def self.paginate(page, per_page)
    page(page).per(per_page)
  end

  def self.for_category_ordered(category, order, page = nil, per_page = nil)
    collection = all

    if category == :featured
      collection = collection.featured
    end

    collection = collection.order("#{ORDER_MODES[order]} DESC")

    if page
      collection = collection.paginate(page, per_page)
    end

    collection
  end

  def user
    super || self.user = dummy_user
  end

  def stdout
    @stdout ||= BufferedStdout.new(stdout_data.decompressed_path,
                                   stdout_timing.decompressed_path).lazy
  end

  def with_terminal
    terminal = Terminal.new(terminal_columns, terminal_lines)
    yield(terminal)
  ensure
    terminal.release if terminal
  end

  def managable_by?(user)
    if user
      user == self.user
    else
      false
    end
  end

  private

  def dummy_user
    User.new(username: 'anonymous').tap { |u| u.dummy = true }
  end

end
