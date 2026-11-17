#==============================================================================
# WCF Test Hub
#------------------------------------------------------------------------------
# Playtest-only checkpoint state loader for Map069.  A checkpoint is responsible
# for story flags, the Player graphic, KUL cleanup, and the complete phone state.
#==============================================================================

module WCFTestHub
  ROUTE_MAPS = ([3, 6, 10, 13, 14, 19, 20] + (22..29).to_a +
    (34..40).to_a + (47..67).to_a).freeze
  ROUTE_SWITCHES = ((30..81).to_a + [4, 5, 6, 7, 8, 17, 18, 99, 238, 239]).freeze
  ROUTE_VARIABLES = ((30..58).to_a + [1, 2, 3, 4, 80, 81, 82, 83, 84]).freeze

  CONTACTS = {
    1 => ["Momo", "Má của Hải Quỳ.", [
      [:contact, "Dahria"],
      [:main, "Sao vậy mẹ?"],
      [:contact, "Con có uống cà phê thì về nhà lấy nhé. Dì vừa gửi về vài hộp đấy."],
      [:main, "Vâng, con cảm ơn. Khi nào về con sẽ lấy."]
    ]],
    2 => ["Popo", "Ba của Hải Quỳ.", [
      [:contact, "Ráng đừng thức khuya nữa đấy"],
      [:contact, "hại sức khỏe lắm."],
      [:main, "Vâng, con biết rồi."],
      [:contact, "Biết rồi mà giờ này còn nhắn hả?"]
    ]],
    3 => ["OniiOni-chan", "Ông anh ác quỷ.", [
      [:contact, "Rảnh không? Nhờ cái."],
      [:main, "Sao á hai?"],
      [:contact, "Mày làm hộ tao cái này."],
      [:contact, "( Link hỏng )"],
      [:main, "Link hỏng rồi hai ơi."],
      [:main, "Hai ơi?"]
    ]],
    4 => ["Hoàng Hà", "Đồng chí.", [
      [:contact, "Ui, Hải Bính!! Cậu có nghe về loại hộp mù mới chưa?"],
      [:main, "Hộp mù nào thế?"],
      [:contact, "Hộp mù về bộ ba vệ binh Atlantis ấy!! "],
      [:contact, "Trông xịn lắm!!"],
      [:contact, "Nao tớ mua rồi cậu khui hộ tớ nhé!"],
      [:contact, "Tớ tin tưởng vào bàn tay trân châu của cậu đấy!"],
      [:main, "OK."]
    ]],
    5 => ["Ánh Lam", "Đồng chí.", [
      [:contact, "Hải Bính."],
      [:contact, "Tớ biết thân phận thật sự của cậu rồi."],
      [:contact, "Cậu không phải Hải Bính. "],
      [:contact, "Cậu chỉ giả vờ làm Hải Bính mà thôi."],
      [:contact, "Cả Hải Bình nữa, cậu cũng giả vờ làm cậu ấy."],
      [:contact, "Cậu là Omega D-13, đúng chứ?"],
      [:contact, "Hải Bình đã chết trước khi cậu gia nhập"],
      [:contact, "Binh Đoàn Sứa Lam, đúng không?"]
    ]]
  }.freeze

  CHECKPOINTS = {
    :silverwing       => [:prologue, nil, nil, {}, {}, "!$HaiQuy"],
    :city             => [:city, nil, nil, {}, {}, "!$Base_HQ_Thuongphuct"],
    :bus              => [:bus, :christmas_test, nil, {}, {}, "!$Base_HQ_Thuongphuct"],
    :wanderer         => [:bus, :christmas_test, nil, {}, {}, "!$Base_HQ_Thuongphuct"],
    :home             => [:home, :christmas_test, 2, {30=>true,31=>true}, {30=>4}, "$HaiQuyAtHome_Base"],
    :book_shop        => [:book_shop, :christmas_test, 2, {30=>true,31=>true}, {30=>7,31=>0}, "$HaiQuyAtHome_Base"],
    :storage_dark     => [:home, :christmas_test, 2, {30=>true,31=>true,34=>true,37=>true,38=>true,40=>true}, {30=>5}, "$HaiQuyAtHome_Base"],
    :storage_lit      => [:home, :christmas_test, 2, {30=>true,31=>true,34=>true,37=>true,38=>true,39=>true,40=>true}, {30=>6}, "$HaiQuyAtHome_Base"],
    :memory           => [:home, :christmas_test, 2, {30=>true,31=>true,34=>true,37=>true,38=>true,39=>true,40=>true,42=>true}, {30=>6}, "$HaiQuy_Badend"],
    :maze             => [:home, :christmas_test, 2, {30=>true,31=>true,34=>true,35=>true,37=>true,38=>true,39=>true,40=>true,42=>true,43=>true}, {30=>8}, "$HaiQuy_Badend"],
    :encirclement     => [:home, :christmas_test, 2, {30=>true,31=>true,34=>true,35=>true,37=>true,38=>true,39=>true,40=>true,42=>true,43=>true}, {30=>9}, "$HaiQuy_Badend"],
    :chase            => [:home, :christmas_test, 2, {30=>true,31=>true,34=>true,35=>true,37=>true,38=>true,39=>true,40=>true,42=>true,43=>true}, {30=>10}, "$HaiQuy_Badend"],
    :post_chase       => [:home, :atlantis_chase_ending, nil, {30=>true,31=>true,34=>true,35=>true,36=>true,43=>true}, {30=>11}, "$HaiQuyAtHome_Base"],
    :market           => [:bus, :christmas_test, 1, {44=>true,50=>true}, {44=>1}, "!$Base_HQ_Thuongphuct"],
    :market_prep      => [:christmas_gift, :market_recipient, 1, {44=>true,50=>true}, {42=>1,43=>1,44=>2,83=>37}, "$HaiQuyAtHome_Base"],
    :market_party     => [:christmas_gift, :market_recipient, 1, {44=>true,50=>true}, {42=>1,43=>1,44=>3,83=>37}, "!$HaiQuy_GiangSinh"],
    :noodle_shop      => [:bus, :christmas_test, 1, {55=>true}, {50=>2,51=>1}, "!$Base_HQ_Thuongphuct"],
    :noodle_prep      => [:christmas_gift, :noodle_recipient, nil, {55=>true}, {50=>2,51=>2,83=>47}, "$HaiQuyAtHome_Base"],
    :noodle_kitchen   => [:christmas_gift, :noodle_recipient, nil, {55=>true}, {50=>2,51=>3}, "!$HaiQuy_GiangSinh"],
    :noodle_party     => [:christmas_gift, :noodle_recipient, nil, {55=>true}, {50=>2,51=>4}, "!$HaiQuy_GiangSinh"],
    :shy_book_prep    => [:christmas_gift, :christmas_test, 2, {61=>true}, {31=>2,52=>2,83=>49}, "$HaiQuyAtHome_Base"],
    :shy_book_party   => [:christmas_gift, :christmas_test, 2, {61=>true}, {31=>2,52=>3,83=>49}, "!$HaiQuy_GiangSinh"],
    :shy_book_end     => [:christmas_gift, :christmas_test, 2, {61=>true}, {31=>2,52=>4}, "!$HaiQuy_GiangSinh"],
    :hak_book_prep    => [:christmas_gift, :christmas_test, 2, {66=>true}, {31=>1,53=>2,83=>51}, "$HaiQuyAtHome_Base"],
    :hak_book_party   => [:christmas_gift, :christmas_test, 2, {66=>true}, {31=>1,53=>3,83=>51}, "!$HaiQuy_GiangSinh"],
    :hak_book_end     => [:christmas_gift, :christmas_test, 2, {66=>true}, {31=>1,53=>4}, "!$HaiQuy_GiangSinh"],
    :abyss_owner      => [:christmas_gift, :christmas_test, 2, {70=>true}, {54=>1}, "!$HaiQuy_GiangSinh"],
    :leo_bus          => [:bus, :christmas_test, 2, {72=>true}, {56=>1}, "!$Base_HQ_Thuongphuct"],
    # All three shop maps enter from stage 1. Maps 57/58 use their stage-2
    # pages to disable the intro autorun after it completes; starting at 2
    # selects that empty page immediately and leaves KUL fully black.
    :leo_magic        => [:book_shop, :leo_shop_choice, 3, {72=>true}, {55=>3,56=>1}, "!$Base_HQ_Thuongphuct"],
    :leo_cafe         => [:book_shop, :leo_shop_choice, 1, {72=>true}, {55=>1,56=>1}, "!$Base_HQ_Thuongphuct"],
    :leo_weapon       => [:book_shop, :leo_shop_choice, 2, {72=>true}, {55=>2,56=>1}, "!$Base_HQ_Thuongphuct"],
    :leo_prep         => [:christmas_gift, :leo_shop_choice, 1, {72=>true}, {55=>1,56=>3,83=>60}, "$HaiQuyAtHome_Base"],
    :leo_party        => [:christmas_gift, :leo_shop_choice, 1, {72=>true}, {55=>1,56=>4,83=>60}, "!$HaiQuy_GiangSinh"],
    :jewel_shop       => [:book_shop, :shylvie_jewel_invite, nil, {76=>true}, {58=>1}, "!$Base_HQ_Thuongphuct"],
    :jewel_prep       => [:christmas_gift, :shylvie_jewel_invite, nil, {76=>true}, {57=>1,58=>2,83=>65}, "$HaiQuyAtHome_Base"],
    :jewel_party      => [:christmas_gift, :shylvie_jewel_invite, nil, {76=>true}, {57=>1,58=>3,83=>65}, "!$HaiQuy_GiangSinh"],
    :jewel_end        => [:christmas_gift, :shylvie_jewel_invite, nil, {76=>true}, {57=>1,58=>4}, "!$HaiQuy_GiangSinh"]
  }.freeze

  def self.prepare(key, overrides = {})
    data = CHECKPOINTS[key]
    return false unless data
    reset_route_state
    timeline, preset, result, switches, variables, graphic = data
    switches = switches.merge(overrides[:switches] || {})
    variables = variables.merge(overrides[:variables] || {})
    result = overrides[:result] if overrides.has_key?(:result)
    graphic = overrides[:graphic] if overrides[:graphic]
    apply_route_state = lambda do
      switches.each {|id, value| $game_switches[id] = value }
      variables.each {|id, value| $game_variables[id] = value }
    end
    # Preset construction reads route variables (for example MKT_GIFT when it
    # builds the recipient chat), so expose the selected checkpoint first.
    apply_route_state.call
    set_player_graphic(graphic)
    seed_phone(timeline, preset, result)
    # Phone/timeline restoration is allowed to rebuild its own persistent
    # state.  Apply the checkpoint route state last so a selected recipient
    # can never fall back to the previous/default branch after leaving Hub.
    apply_route_state.call
    true
  end

  def self.reset_route_state
    ROUTE_SWITCHES.each {|id| $game_switches[id] = false }
    ROUTE_VARIABLES.each {|id| $game_variables[id] = 0 }
    if $game_self_switches
      data = $game_self_switches.instance_variable_get(:@data)
      data.delete_if {|key, _value| ROUTE_MAPS.include?(key[0]) } if data
      $game_map.need_refresh = true if $game_map
    end
    if $game_map
      $game_player.drop_light if $game_player.respond_to?(:drop_light)
      $game_map.effects.clear if $game_map.respond_to?(:effects)
      if $game_map.respond_to?(:layers) && $game_map.layers
        ROUTE_MAPS.each {|map_id| $game_map.layers[map_id] = [] }
      end
    end
    $game_screen.clear if $game_screen
    if $game_player
      $game_player.transparent = false
      $game_player.instance_variable_set(:@through, false)
      $game_player.instance_variable_set(:@move_speed, 4)
      $game_player.instance_variable_set(:@move_frequency, 3)
    end
    if $game_temp
      $game_temp.group_chat_data = nil if $game_temp.respond_to?(:group_chat_data=)
      $game_temp.group_chat_result = nil if $game_temp.respond_to?(:group_chat_result=)
    end
  end

  def self.set_player_graphic(name)
    return if !name || name.empty?
    actor = $game_party && $game_party.leader
    if actor
      actor.set_graphic(name, 0, actor.face_name, actor.face_index)
      $game_player.refresh
    else
      $game_player.set_graphic(name, 0)
    end
  end

  def self.seed_phone(timeline, preset, result)
    PhoneMenu::CONTACTS.clear
    CONTACTS.each do |id, data|
      PhoneMenu::CONTACTS[id] = [data[0], data[1], data[2].map {|entry| [entry[0], entry[1]] }]
    end
    $phone_menu_selected_index = 0
    PhoneMenuScript.force_timeline(timeline) if defined?(PhoneMenuScript)
    return unless $game_config && $game_config.respond_to?(:phone_group_chats)
    $game_config.clear_phone_group_chats
    install_group_chat(preset, result) if preset
    $game_config.phone_mark_all_read
  end

  def self.install_group_chat(preset, result)
    return unless defined?(GroupChatPreset) && GroupChatPreset.respond_to?(preset)
    $wcf_test_hub_capture_chat = true
    $wcf_test_hub_captured_chat = nil
    GroupChatPreset.send(preset)
    chat = $wcf_test_hub_captured_chat
    $wcf_test_hub_capture_chat = false
    $wcf_test_hub_captured_chat = nil
    return unless chat
    gid = PhoneGroupChat::DEFAULT_GROUP_ID
    group = $game_config.ensure_group_chat(gid)
    group[:messages].clear
    group[:members].clear
    chat.actors.each {|id, actor| group[:members][id] = [actor[:name], actor[:avatar]] }
    chat.entries.each {|entry| PhoneGroupChatSave.save_entry(gid, entry) }
    return if result.nil?
    choice = chat.choices.find {|item| item[:value] == result }
    label = choice ? choice[:text] : result.to_s
    $game_config.add_group_choice_result(gid, "Quỳ chọn: #{label}", result)
    (chat.choice_branches[result] || []).each do |entry|
      PhoneGroupChatSave.save_entry(gid, entry)
    end
  ensure
    $wcf_test_hub_capture_chat = false
    $wcf_test_hub_captured_chat = nil
  end

end

if defined?(GroupChat)
  module GroupChat
    class << self
      alias wcf_test_hub_original_start start unless method_defined?(:wcf_test_hub_original_start)
      def start(chat)
        if $wcf_test_hub_capture_chat
          $wcf_test_hub_captured_chat = chat
          return
        end
        wcf_test_hub_original_start(chat)
      end
    end
  end
end
