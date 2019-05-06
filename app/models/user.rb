class User < ApplicationRecord
  belongs_to :person, dependent: :destroy

  delegate :profile_image, :needs_profile_image?, to: :person, prefix: false

  def self.from_omniauth(authentication_data)
    user = User.where(provider: authentication_data['provider'], uid: authentication_data['uid']).first_or_create do |user|
      person = user.build_person

      person.full_name  = authentication_data.info.name
      person.nickname   = authentication_data.info.nickname
      user.access_token = authentication_data.credentials.token

      authentication_data.extra.all_emails.each do |github_email|
        person.emails.build(label: "github", address: github_email.email, is_primary: github_email.primary)
      end

      person.save

    end
  end
end
