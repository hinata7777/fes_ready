require "securerandom"

module Uuidable
  extend ActiveSupport::Concern

  included do
    before_validation :ensure_uuid!, on: :create
    validates :uuid, presence: true, uniqueness: true
  end

  def to_param
    uuid.presence || super
  end

  private

  def ensure_uuid!
    self.uuid ||= SecureRandom.uuid
  end
end
