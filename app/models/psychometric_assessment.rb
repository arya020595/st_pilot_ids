# frozen_string_literal: true

class PsychometricAssessment < ApplicationRecord
  self.primary_key = 'psychometric_assessment_id'

  DEFAULT_ADMIN_DRIVE_URL = 'https://drive.google.com/drive/folders/1SXlcKoDtAU0yygW03ahbOh1JOZH9cPST?usp=drive_link'
  DEFAULT_STAFF_TEST_DRIVE_URL = 'https://drive.google.com/drive/folders/1H6abCbUu_lWnzHb4mPv7evMlrUyLdKi1?usp=drive_link'
  SUPERVISOR_DRIVE_URLS_BY_EMAIL = {
    'sdyrina@gmail.com' => 'https://drive.google.com/drive/folders/1oPRAp5mDysGxvUnZg1L7fuEYwulnf-pA?usp=sharing',
    'alexzander.palik@ids.org.my' => 'https://drive.google.com/drive/folders/1oPRAp5mDysGxvUnZg1L7fuEYwulnf-pA?usp=sharing',
    'victor.sikain@ids.org.my' => 'https://drive.google.com/drive/folders/1kyhZQ1nCAt6LGMDhiSkf6cMVSZLvTrVR?usp=sharing',
    'anita.limjoon@ids.org.my' => 'https://drive.google.com/drive/folders/14u8TStfeH1xc-L-mit-FUYbUs5hAYDZl?usp=sharing',
    'mansalasah.musa@ids.org.my' => 'https://drive.google.com/drive/folders/1Bvxsr2AjB1jLV46JD-mbiyqz5o5Ex_eh?usp=sharing',
    'masmidah.arsah@ids.org.my' => 'https://drive.google.com/drive/folders/1xvk5mcoe_02FbuqkALxyUpEaI4lnBKtD?usp=sharing',
    'masneh.maziah@ids.org.my' => 'https://drive.google.com/drive/folders/1u_neWdarzUz4mCyduv4HjKWesyVAeQU_?usp=sharing'
  }.freeze

  belongs_to :staff_profile,
             foreign_key: :staff_profile_id,
             primary_key: :staff_profile_id

  validates :staff_profile_id, presence: true, uniqueness: true
  validates :name, :grade, :position, presence: true

  def drive_url_for(user)
    return nil unless user

    if user.superadmin?
      ENV['GOOGLE_DRIVE_MAIN_FOLDER_URL'].presence || DEFAULT_ADMIN_DRIVE_URL
    else
      supervisor_link = supervisor_drive_urls_by_user_id[user.id]

      supervisor_link.presence ||
        link_google_drive.presence ||
        ENV['GOOGLE_DRIVE_STAFF_TEST_FOLDER_URL'].presence ||
        DEFAULT_STAFF_TEST_DRIVE_URL
    end
  end

  private

  def supervisor_drive_urls_by_user_id
    @supervisor_drive_urls_by_user_id ||= begin
      email_to_id = User.where(email: SUPERVISOR_DRIVE_URLS_BY_EMAIL.keys).pluck(:email, :id).to_h
      SUPERVISOR_DRIVE_URLS_BY_EMAIL.each_with_object({}) do |(email, url), mapping|
        user_id = email_to_id[email]
        mapping[user_id] = url if user_id
      end
    end
  end
end
