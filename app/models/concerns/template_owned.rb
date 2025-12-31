module TemplateOwned
  extend ActiveSupport::Concern

  included do
    scope :templates, -> { where(template: true) }
    scope :owned_by, ->(user) { where(user_id: user.id) }

    validates :user_id, presence: true, unless: :template?
    validates :template, inclusion: { in: [ true, false ] }
  end
end
