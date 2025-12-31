module Users
  class FromOmniauth
    def self.call(auth)
      new(auth).call
    end

    def initialize(auth)
      @auth = auth
    end

    def call
      user = User.find_by(provider: @auth.provider, uid: @auth.uid)
      user ||= User.find_by(email: @auth.info.email)

      nickname = user&.nickname.presence || User.sanitized_nickname(@auth)

      user ||= User.new(
        email: @auth.info.email,
        password: Devise.friendly_token[0, 20],
        nickname: nickname
      )

      user.assign_attributes(provider: @auth.provider, uid: @auth.uid, nickname: nickname)
      user.save!
      user
    end
  end
end
