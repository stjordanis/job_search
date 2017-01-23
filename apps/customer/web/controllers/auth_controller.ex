defmodule Customer.AuthController do
  @moduledoc """
  Auth controller responsible for handling Ueberauth response
  """

  use Customer.Web, :controller
  plug Ueberauth

  def delete(conn, _params, current_user, _claims) do
    if current_user do
      conn
      |> Guardian.Plug.sign_out
      |> render("logout.json", %{message: "Signed out"})
    else
      conn
      |> render("logout.json", %{error: "Not logged in"})
    end
  end

  def callback(%{assigns: %{ueberauth_failure: _fails}} = conn, _params, _current_user, _claims) do
    conn
    |> render("callback.json", %{error: "Failed to authenticate."})
  end

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params, _current_user, _claims) do
    case UserFromAuth.get_or_create(auth) do
      {:ok, user} ->
        conn
        |> Guardian.Plug.sign_in(user)
        |> render("callback.json", %{message: "Successfully authenticated.", token: Authorization.current_auth(user.id)})

      {:error, reason} ->
        conn
        |> render("callback.json", %{error: reason})
    end
  end
end
