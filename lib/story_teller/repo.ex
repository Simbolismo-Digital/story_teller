defmodule StoryTeller.Repo do
  use Ecto.Repo,
    otp_app: :story_teller,
    adapter: Ecto.Adapters.Postgres
end
