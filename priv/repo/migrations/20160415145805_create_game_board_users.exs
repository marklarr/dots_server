defmodule DotsServer.Repo.Migrations.CreateGameBoardUsers do
  use Ecto.Migration

  def change do
    create table(:game_board_users) do
      add :user_id, references(:users, on_delete: :nothing)
      add :game_board_id, references(:game_boards, on_delete: :nothing)

      timestamps
    end
    create index(:game_board_users, [:user_id])
    create index(:game_board_users, [:game_board_id])

  end
end
