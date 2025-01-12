class Page < ApplicationRecord
  has_many :results

  validates :url, presence: true
  validates :check_type, presence: true
  validates :selector, presence: true
  validates :match_text, presence: { if: -> { check_type == "text" } }

  def run_and_notify
    run_check
    last_result = results.last
    last_result.notify if last_result.success?
  end

  def run_check
    scraper = Scraper.new(url)

    result = case check_type
    when "text"
      scraper.text(selector: selector).downcase == match_text.downcase
    when "exists"
      scraper.present?(selector: selector)
    when "not_exists"
      !scraper.present?(selector: selector)
    end

    results.create(success: result)
  end
end
