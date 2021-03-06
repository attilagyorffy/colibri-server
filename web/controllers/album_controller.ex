defmodule Colibri.AlbumController do
  use Colibri.Web, :controller

  alias Colibri.Album

  plug :scrub_params, "album" when action in [:create, :update]

  # /artists/:artist_id/albums
  def index(conn, %{"artist_id" => artist_id}) do
    albums = Repo.all(from a in Album, where: a.artist_id == ^artist_id)
    |> Repo.preload([:artist])
    render(conn, :index, data: albums)
  end

  def index(conn, _params) do
    albums = Album
    |> Repo.all
    |> Repo.preload([:artist])
    render(conn, :index, data: albums)
  end

  def create(conn, %{"album" => album_params}) do
    changeset = Album.changeset(%Album{}, album_params)

    case Repo.insert(changeset) do
      {:ok, album} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", album_path(conn, :show, album))
        |> render(:show, data: album)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Colibri.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    album = Album
    |> Repo.get!(id)
    |> Repo.preload([:artist, :tracks])
    render(conn, :show, data: album)
  end

  def update(conn, %{"id" => id, "album" => album_params}) do
    album = Repo.get!(Album, id)
    changeset = Album.changeset(album, album_params)

    case Repo.update(changeset) do
      {:ok, album} ->
        render(conn, :show, data: album)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Colibri.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    album = Repo.get!(Album, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(album)

    send_resp(conn, :no_content, "")
  end
end
