require "rails_helper"

describe "Subscriptions" do
  let(:user) { create(:user, subscriptions_token: SecureRandom.base58(32)) }

  context "Edit page" do
    scenario "Render content in the user's preferred locale" do
      user.update!(locale: "es")
      visit edit_subscriptions_path(token: user.subscriptions_token)

      expect(page).to have_content "Notificaciones"
      expect(page).to have_field "Recibir un email cuando alguien comenta en mis contenidos", type: :checkbox
      expect(page).to have_field "Recibir un email cuando alguien contesta a mis comentarios", type: :checkbox
      expect(page).to have_field "Recibir emails con información interesante sobre la web", type: :checkbox
      expect(page).to have_field "Recibir resumen de notificaciones sobre propuestas", type: :checkbox
      expect(page).to have_field "Recibir emails con mensajes privados", type: :checkbox
      expect(page).to have_button "Guardar cambios"
    end

    scenario "Use the locale in the parameters when accessing anonymously" do
      visit edit_subscriptions_path(token: user.subscriptions_token, locale: :es)

      expect(page).to have_content "Notificaciones"
    end
  end

  context "Update" do
    scenario "Allow updating the status notification" do
      user.update!(email_on_comment: false,
                   email_on_comment_reply: true,
                   newsletter: true,
                   email_digest: false,
                   email_on_direct_message: true)
      visit edit_subscriptions_path(token: user.subscriptions_token)

      check "Notify me by email when someone comments on my contents"
      uncheck "Notify me by email when someone replies to my comments"
      uncheck "Receive relevant information by email"
      check "Receive a summary of proposal notifications"
      uncheck "Receive emails about direct messages"
      click_button "Save changes"

      expect(page).to have_content "Changes saved"
      expect(page).to have_field "Notify me by email when someone comments on my contents", checked: true
      expect(page).to have_field "Notify me by email when someone replies to my comments", checked: false
      expect(page).to have_field "Receive relevant information by email", checked: false
      expect(page).to have_field "Receive a summary of proposal notifications", checked: true
      expect(page).to have_field "Receive emails about direct messages", checked: false
    end
  end
end
