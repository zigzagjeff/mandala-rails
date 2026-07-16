module User::Onboarding
  extend ActiveSupport::Concern

  included do
    after_create :seed_start_here_mandala
  end

  private
    def seed_start_here_mandala
      Mandala::StartHereTemplate.seed_for(self)
    end
end
