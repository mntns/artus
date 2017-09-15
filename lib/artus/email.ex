defmodule Artus.Email do
  @moduledoc "Mail builder module"
  import Bamboo.Email

  @prefix "[BIAS] "
  @admin_address "ias@monoton.space"
  @base_url "https://bias.internationalarthuriansociety.com"

  def transfer_cache_email(from_user, user, cache, comment) do
    link = @base_url <> "/caches/" <> "#{cache.id}"
    if String.trim(comment) == "" do
    new_email(
              to: user.mail,
              from: @admin_address,
              subject: @prefix <> "You received a working cache by #{from_user.name}",
              text_body: """
              Dear #{user.name},

              you received the working cache '#{cache.name}' from #{from_user.name}.
              Click the following link to review the working cache:
              #{link}

              """
            )
  else
    new_email(
              to: user.mail,
              from: @admin_address,
              subject: @prefix <> "You received a working cache by #{from_user.name}",
              text_body: """
              Dear #{user.name},

              you received the working cache '#{cache.name}' from #{from_user.name}.
              Click the following link to review the working cache:
              #{link}
              
              #{from_user.name} added a comment:
              -------------------------------------
              #{comment}
              -------------------------------------
              """
            )
  end
  end

  def new_user_email(user) do
    link = @base_url <> "/activate/" <> user.activation_code
    new_email(
      to: user.mail,
      from: @admin_address,
      subject: @prefix <> "Welcome to ArtusDB!",
      text_body: """
      Dear #{user.name}:

      Welcome to the database of the International Arthurian Society!
      
      Bibliographers are encouraged to enter new data. 
      National Bibliographers are authorized to coordinate the work of the national secretaries. 
      The International Bibliographer checks and edits data from all branches and then publishes them. 
      The International Bibliographer may refer data back to the National Bibliographer who may refer back to the bibliographer.

      Your account was registered with the following address:
      #{user.mail}
      
      Please follow this link to confirm this mail and activate your account:
      #{link}
      """
    )
  end

  def feedback_email(feedback) do
    new_email(
      to: @admin_address,
      from: feedback["mail"],
      subject: @prefix <> "Feedback",
      text_body: feedback["text"]
    )
  end

  def password_reset_email(user) do
    link = @base_url <> "/reset/" <> user.activation_code
    new_email(
      to: user.mail,
      from: @admin_address,
      subject: @prefix <> "Password reset link",
      text_body: """
      Hello #{user.name},
      your password reset link: #{link}
      """
    )
  end

end

