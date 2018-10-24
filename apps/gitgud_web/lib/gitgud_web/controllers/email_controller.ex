defmodule GitGud.Web.EmailController do
  @moduledoc """
  Module responsible for CRUD actions on `GitGud.Email`.
  """

  use GitGud.Web, :controller

  alias GitGud.DB
  alias GitGud.Email

  plug :ensure_authenticated
  plug :put_layout, :user_settings

  action_fallback GitGud.Web.FallbackController

  @doc """
  Renders emails.
  """
  @spec index(Plug.Conn.t, map) :: Plug.Conn.t
  def index(conn, _params) do
    user = DB.preload(current_user(conn), :emails)
    changeset = Email.changeset(%Email{})
    render(conn, "index.html", user: user, changeset: changeset)
  end

  @doc """
  Creates a new email.
  """
  @spec create(Plug.Conn.t, map) :: Plug.Conn.t
  def create(conn, %{"email" => key_params} = _params) do
    user = DB.preload(current_user(conn), :emails)
    case Email.create(Map.put(key_params, "user_id", user.id)) do
      {:ok, email} ->
        GitGud.Mailer.deliver_later(GitGud.Mailer.verification_email(email))
        conn
        |> put_flash(:info, "Email '#{email.email}' added.")
        |> redirect(to: Routes.email_path(conn, :index))
      {:error, changeset} ->
        conn
        |> put_flash(:error, "Something went wrong! Please check error(s) below.")
        |> put_status(:bad_request)
        |> render("index.html", user: user, changeset: %{changeset|action: :insert})
    end
  end

  @doc """
  Re-sends a verification email.
  """
  @spec resend(Plug.Conn.t, map) :: Plug.Conn.t
  def resend(conn, %{"email" => email_params} = _params) do
    user = DB.preload(current_user(conn), :emails)
    email_id = String.to_integer(email_params["id"])
    if email = Enum.find(user.emails, &(&1.id == email_id)) do
      GitGud.Mailer.deliver_later(GitGud.Mailer.verification_email(email))
      conn
      |> put_flash(:info, "A verification email has been sent to '#{email.email}'.")
      |> redirect(to: Routes.email_path(conn, :index))
    else
      {:error, :bad_request}
    end
  end

  @doc """
  Verifies an email address.
  """
  @spec resend(Plug.Conn.t, map) :: Plug.Conn.t
  def verify(conn, %{"token" => token} = _params) do
    user = DB.preload(current_user(conn), :emails)
    case Phoenix.Token.verify(conn, to_string(user.id), token, max_age: 86400) do
      {:ok, email_id} ->
        if email = Enum.find(user.emails, &(&1.id == email_id)) do
          unless email.verified do
            changeset = Ecto.Changeset.change(email, verified: true)
            email = DB.update!(changeset)
            conn
            |> put_flash(:info, "Email '#{email.email}' verified.")
            |> redirect(to: Routes.email_path(conn, :index))
          else
            conn
            |> put_flash(:info, "Email '#{email.email}' already verified.")
            |> redirect(to: Routes.email_path(conn, :index))
          end
        else
          conn
          |> put_flash(:error, "Invalid verification token.")
          |> redirect(to: Routes.email_path(conn, :index))
        end
      {:error, :invalid} ->
        conn
        |> put_flash(:error, "Invalid verification token.")
        |> redirect(to: Routes.email_path(conn, :index))
      {:error, :expired} ->
        conn
        |> put_flash(:error, "Verification token expired.")
        |> redirect(to: Routes.email_path(conn, :index))
    end
  end
end
