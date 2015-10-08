defmodule VimeoTest do
  use ShouldI
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  doctest Vimeo

  setup_all do
    ExVCR.Config.cassette_library_dir("fixture/vcr_cassettes", "fixture/custom_cassettes")
    ExVCR.Config.filter_url_params(true)

    ExVCR.Config.filter_sensitive_data("client_id=.+", "<REMOVED>")
    ExVCR.Config.filter_sensitive_data("client_secret=.+", "<REMOVED>")

    Dotenv.load!
    Vimeo.configure
    :ok
  end

  test "gets current configuration" do
    config = Vimeo.Config.get
    assert config.client_id != nil
    assert config.client_secret != nil
    assert config.redirect_uri != nil
  end

  test "gets an access token, and test it's validity" do
    code = "XXXXXX"
    use_cassette "access_token" do
      token = Vimeo.get_token!(code: code)
      user = Vimeo.my_info(token.access_token)
      assert user.name == "louis larp"
    end
  end

  test "raise an exception when a bad access token is used" do
    use_cassette "oauth_exception" do
      assert_raise Vimeo.Error, fn -> Vimeo.my_info end
    end
  end

  with "explicit access token" do

    # ------- Explicitly authenticated

    setup context do
      Dict.put context, :token, System.get_env("VIMEO_ACCESS_TOKEN")
    end


    # ------- Categories


    should "return a list of categories", context do
      use_cassette "categories_expl" do
        categories = Vimeo.categories(context[:token])
        assert length(categories) == 16
      end
    end

    should "return a category for id", context do
      use_cassette "category_expl" do
        category = Vimeo.category(:animation, context[:token])
        assert category.name == "Animation"
      end
    end

    should "return a list of channels for category id", context do
      use_cassette "category_channels_expl" do
        channels = Vimeo.category_channels(:animation, context[:token])
        assert length(channels) == 24
      end
    end

    should "return a list of groups for category id", context do
      use_cassette "category_groups_expl" do
        groups = Vimeo.category_groups(:animation, context[:token])
        assert length(groups) == 25
      end
    end

    should "return a list of videos for category id", context do
      use_cassette "category_videos_expl" do
        videos = Vimeo.category_videos(:animation, context[:token])
        assert length(videos) == 25
      end
    end


    # ------- Channels


    should "return a list of channels", context do
      use_cassette "channels_expl" do
        channels = Vimeo.channels(context[:token])
        assert length(channels) == 25
      end
    end

    should "return a channel for id", context do
      use_cassette "channel_expl" do
        channel = Vimeo.channel(2981, context[:token])
        assert channel.name == "Everything Animated"
      end
    end

    should "create a new channel", context do
      use_cassette "create_channel" do
        data = %{name: "foo", description: "foo desc", privacy: "anybody"}
        assert Vimeo.create_channel(data, context[:token]) == :ok

        channel = List.first(Vimeo.my_channels(context[:token]))
        assert channel.name == "foo"
        assert channel.description == "foo desc"
      end
    end


    # ------- Me


    should "update current user informations", context do
      new_username = "foo"
      use_cassette "update_info_expl" do
        assert Vimeo.update_profile(%{name: new_username}, context[:token]) == :ok
        assert Vimeo.my_info(context[:token]).name == new_username
      end
    end

    should "return a list of albums for the authenticated user", context do
      use_cassette "my_albums_expl" do
        albums = Vimeo.my_albums(context[:token])
        assert length(albums) == 1
        assert List.first(albums).name == "foo"
      end
    end

    should "return an album by id for the authenticated user", context do
      use_cassette "my_album_expl" do
        album = Vimeo.my_album(3600066, context[:token])
        assert album.name == "foo"
      end
    end

    test "return followed channels for authenticated user", context do
      use_cassette "my_channels_expl" do
        channels = Vimeo.my_channels(context[:token])
        assert length(channels) == 1
        assert List.first(channels).name == "Themgoods"
      end
    end
  end

  with "globally configured access token" do

    # ------- Globally authenticated

    setup context do
      Vimeo.configure(:global, System.get_env("VIMEO_ACCESS_TOKEN"))

      context
    end

    # ------- Categories (globally authenticated)

    should "return a list of categories" do
      use_cassette "categories_glob" do
        categories = Vimeo.categories
        assert length(categories) == 16
      end
    end

    should "return a category for id" do
      use_cassette "category_glob" do
        category = Vimeo.category(:animation)
        assert category.name == "Animation"
      end
    end

    should "return a list of channels for category id" do
      use_cassette "category_channels_glob" do
        channels = Vimeo.category_channels(:animation)
        assert length(channels) == 24
      end
    end

    should "return a list of groups for category id" do
      use_cassette "category_groups_glob" do
        groups = Vimeo.category_groups(:animation)
        assert length(groups) == 25
      end
    end

    should "return a list videos for category id" do
      use_cassette "category_videos_glob" do
        videos = Vimeo.category_videos(:animation)
        assert length(videos) == 25
      end
    end


    # ------- Channels


    should "return a list of channels" do
      use_cassette "channels_glob" do
        channels = Vimeo.channels()
        assert length(channels) == 25
      end
    end

    should "return a channel for id" do
      use_cassette "channel_glob" do
        channel = Vimeo.channel(2981)
        assert channel.name == "Everything Animated"
      end
    end

    should "create a new channel" do
      use_cassette "create_channel" do
        data = %{name: "foo", description: "foo desc", privacy: "anybody"}
        assert Vimeo.create_channel(data) == :ok

        channel = List.first(Vimeo.my_channels())
        assert channel.name == "foo"
        assert channel.description == "foo desc"
      end
    end


    # ------- Me


    should "update current user informations" do
      new_username = "bar"
      use_cassette "update_profile_glob" do
        assert Vimeo.update_profile(%{name: new_username}) == :ok
        assert Vimeo.my_info.name == new_username
      end
    end

    should "return a list of albums for the current user" do
      use_cassette "my_albums_glob" do
        albums = Vimeo.my_albums
        assert length(albums) == 1
        assert List.first(albums).name == "foo"
      end
    end

    should "return an album by id for the current user" do
      use_cassette "my_album_glob" do
        album = Vimeo.my_album(3600066)
        assert album.name == "foo"
      end
    end

    should "return followed channels for authenticated user" do
      use_cassette "my_channels_glob" do
        channels = Vimeo.my_channels
        assert length(channels) == 1
        assert List.first(channels).name == "Themgoods"
      end
    end
  end
end
