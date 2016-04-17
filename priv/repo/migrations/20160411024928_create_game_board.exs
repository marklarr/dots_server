defmodule DotsServer.Repo.Migrations.CreateGameBoard do
  use Ecto.Migration

  def change do
    create table(:game_boards) do
      add :board_lines_data, :binary
      add :board_fills_data, :binary
      add :next_turn_user_id, references(:users, on_delete: :nothing)

      timestamps
    end
    create index(:game_boards, [:next_turn_user_id])

  end
end
