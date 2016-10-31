class User < ActiveRecord::Base
  has_secure_password

  def authy_approved?
    self.authy_status == 'approved'
  end
end
