ExUnit.start

Mix.Task.run "ecto.create", ~w(-r DotsServer.Repo --quiet)
Mix.Task.run "ecto.migrate", ~w(-r DotsServer.Repo --quiet)
Ecto.Adapters.SQL.begin_test_transaction(DotsServer.Repo)

