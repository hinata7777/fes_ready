module NavigationHelper
  PARENT_PATHS = {
    "home#terms" => -> { root_path },
    "home#privacy" => -> { root_path },

    "prep#show" => -> { root_path },
    "prep/festivals#index" => -> { prep_path },
    "prep/festivals#show" => -> { prep_festivals_path },
    "prep/artists#index" => -> { prep_path },
    "prep/artists#show" => -> { prep_artists_path },

    "festivals#index" => -> { root_path },
    "festivals#show" => -> { festivals_path },

    "artists#index" => -> { root_path },
    "artists#show" => -> { artists_path },

    "timetables#index" => -> { root_path },
    "timetables#show" => -> { timetables_path },

    "my_timetables#index" => -> { timetables_path },
    "my_timetables#show" => -> { my_timetables_path },
    "my_timetables#edit" => -> { my_timetables_path },

    "packing_lists#index" => -> { root_path },
    "packing_lists#show" => -> { packing_lists_path },
    "packing_lists#new" => -> { packing_lists_path },
    "packing_lists#edit" => -> { packing_lists_path },

    # 管理者向け
    "admin/home#top" => -> { root_path },
    "admin/festivals#index" => -> { admin_root_path },
    "admin/festivals#show" => -> { admin_festivals_path },
    "admin/festivals#new" => -> { admin_festivals_path },
    "admin/festivals#edit" => -> { admin_festivals_path },

    "admin/artists#index" => -> { admin_root_path },
    "admin/artists#show" => -> { admin_artists_path },
    "admin/artists#new" => -> { admin_artists_path },
    "admin/artists#edit" => -> { admin_artists_path },

    "admin/songs#index" => -> { admin_root_path },
    "admin/songs#show" => -> { admin_songs_path },
    "admin/songs#new" => -> { admin_songs_path },
    "admin/songs#edit" => -> { admin_songs_path },

    "admin/stage_performances#index" => -> { admin_root_path },
    "admin/stage_performances#show" => -> { admin_stage_performances_path },
    "admin/stage_performances#new" => -> { admin_stage_performances_path },
    "admin/stage_performances#edit" => -> { admin_stage_performances_path },

    "admin/festival_tags#index" => -> { admin_root_path },
    "admin/festival_tags#show" => -> { admin_festival_tags_path },
    "admin/festival_tags#new" => -> { admin_festival_tags_path },
    "admin/festival_tags#edit" => -> { admin_festival_tags_path },

    "admin/items#index" => -> { admin_root_path },
    "admin/items#show" => -> { admin_items_path },
    "admin/items#new" => -> { admin_items_path },
    "admin/items#edit" => -> { admin_items_path },

    "admin/packing_lists#index" => -> { admin_root_path },
    "admin/packing_lists#show" => -> { admin_packing_lists_path },
    "admin/packing_lists#new" => -> { admin_packing_lists_path },
    "admin/packing_lists#edit" => -> { admin_packing_lists_path },

    "admin/users#index" => -> { admin_root_path },

    "mypage/favorite_festivals#index" => -> { mypage_dashboard_path },
    "mypage/favorite_artists#index" => -> { mypage_dashboard_path },
    "mypage/dashboard#show" => -> { root_path }
  }.freeze

  def header_back_path
    return nil if current_page?(root_path)
    return @header_back_path if defined?(@header_back_path) && @header_back_path.present?

    key = "#{controller_path}##{action_name}"
    resolver = PARENT_PATHS[key]
    return instance_exec(&resolver) if resolver

    root_path
  end
end
