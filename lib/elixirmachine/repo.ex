defmodule Elixirmachine.Repo do
  use Ecto.Repo,
    otp_app: :elixirmachine,
    adapter: Ecto.Adapters.Postgres
end
