defmodule Vimeo.MeTest do
  use ExUnit.Case
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  alias Vimeo.TestHelper

  doctest Vimeo.Me

  setup_all do
    TestHelper.setup
    Vimeo.configure
    :ok
  end

  test "should return user informations" do
    use_cassette "my_info" do
      info = Vimeo.Me.info
      assert info.name == "louis larpin"
    end
  end

  test "should update user informations" do
    new_username = "foo"
    use_cassette "my_info_update" do
      Vimeo.Me.update(%{name: new_username})
      assert Vimeo.Me.info.name == new_username
    end
  end

  test "should return a list of a users's albums" do
    use_cassette "my_albums" do
      albums = Vimeo.Me.albums
      assert length(albums) == 1
    end
  end

  test "should create an album for a user" do
    use_cassette "my_albums_create" do
      Vimeo.Me.create_album(%{name: "foo", description: "foo desc"})
      album = Vimeo.Me.albums |> List.first

      assert album.name == "foo"
      assert album.description == "foo desc"
    end
  end

  test "should return a users's album by id" do
    use_cassette "my_album" do
      album = Vimeo.Me.album(3600066)
      assert album.name == "foo"
    end
  end

  test "should update an album" do
    use_cassette "my_album_update" do
      Vimeo.Me.update_album(3608428, %{name: "bar", description: "bar desc"})

      album = Vimeo.Me.album(3608428)
      assert album.name == "bar"
      assert album.description == "bar desc"
    end
  end

  test "should delete an album" do
    use_cassette "my_album_delete" do
      Vimeo.Me.delete_album(3608428)

      channels = Vimeo.Me.albums
      assert length(channels) == 0
    end
  end

  test "should return a list of videos in an album" do
    use_cassette "my_album_videos" do
      videos = Vimeo.Me.album_videos(3608474)
      assert length(videos) == 1
      assert List.first(videos).name == "WINTERTOUR"
    end
  end

  test "should return a video contained in an album" do
    use_cassette "my_album_video" do
      video = Vimeo.Me.album_video(3608474, 18629165)
      assert video.name == "WINTERTOUR"
    end
  end

  test "should add a video to an album" do
    use_cassette "my_album_add_video" do
      Vimeo.Me.add_album_video(3608474, 18629165)

      videos = Vimeo.Me.album_videos(3608474)
      assert length(videos) == 1
    end
  end

  test "should remove a video from an album" do
    use_cassette "my_album_remove_video" do
      Vimeo.Me.remove_album_video(3608474, 18629165)

      videos = Vimeo.Me.album_videos(3608474)
      assert length(videos) == 0
    end
  end

  test "should return a list of videos a user appears in" do
    use_cassette "my_appearances" do
      videos = Vimeo.Me.appearances
      assert length(videos) == 1
    end
  end

  test "should return a list of channels a user follows" do
    use_cassette "my_channels" do
      channels = Vimeo.Me.channels
      assert length(channels) == 1
    end
  end

  test "should check if a user follows a channel" do
    use_cassette "my_channel?" do
      assert Vimeo.Me.channel?(:foobar) == false
      assert Vimeo.Me.channel?(:themgoods) == true
    end
  end

  test "should subscribe user to a channel" do
    use_cassette "my_channels_subscribe" do
      assert Vimeo.Me.subscribe_channel(:xsjado) == :ok
      assert length(Vimeo.Me.channels) == 2
    end
  end

  test "should unsubscribe user from a channel" do
    use_cassette "my_channels_unsubscribe" do
      assert Vimeo.Me.unsubscribe_channel(:xsjado) == :ok
      assert length(Vimeo.Me.channels) == 1
    end
  end

  test "should return a list of groups a user joined" do
    use_cassette "my_groups" do
      groups = Vimeo.Me.groups
      assert length(groups) == 1
    end
  end

  test "should check if a user joined a group" do
    use_cassette "my_group?" do
      assert Vimeo.Me.group?(:foobar) == false
      assert Vimeo.Me.group?(:theconference) == true
    end
  end

  test "should join user to a group" do
    use_cassette "my_groups_join" do
      assert Vimeo.Me.join_group(:hdxs) == :ok
      assert length(Vimeo.Me.groups) == 2
    end
  end

  test "should remove user from a group" do
    use_cassette "my_groups_leave" do
      assert Vimeo.Me.leave_group(:hdxs) == :ok
      assert length(Vimeo.Me.groups) == 1
    end
  end

  test "should return a list of videos from user feed" do
    use_cassette "my_feed" do
      videos = Vimeo.Me.feed
      assert length(videos) == 25
    end
  end

  test "should return a list user's followers" do
    use_cassette "my_followers" do
      users = Vimeo.Me.followers
      assert length(users) == 2
      assert List.last(users).name == "ARTSN Video (Arsène Jurman)"
    end
  end

  test "should return a list of users that a user is following" do
    use_cassette "my_following" do
      users = Vimeo.Me.following
      assert length(users) == 1
      assert List.first(users).name == "ARTSN Video (Arsène Jurman)"
    end
  end

  test "should check if a user follows another user" do
    use_cassette "my_following?" do
      assert Vimeo.Me.following?(:foobar) == false
      assert Vimeo.Me.following?(:artsnvideo) == true
    end
  end

  test "should follow a user" do
    use_cassette "my_follow" do
      assert Vimeo.Me.follow(:themgoods1) == :ok
      assert length(Vimeo.Me.following) == 2
    end
  end

  test "should unfollow a user" do
    use_cassette "my_unfollow" do
      assert Vimeo.Me.unfollow(:themgoods1) == :ok
      assert length(Vimeo.Me.following) == 1
    end
  end

  test "should check if a user likes a video" do
    use_cassette "my_like?" do
      assert Vimeo.Me.like?(123) == false
      assert Vimeo.Me.like?(141849348) == true
    end
  end
end
