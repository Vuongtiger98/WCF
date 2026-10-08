window.WCF_CONTENT = {
  "meta": {
    "title": "Wonder Christmas Fiesta — Playtest",
    "version": 4,
    "routeCount": 33,
    "updatedAt": "2026-09-30",
    "update": "Đồng bộ toàn bộ thoại từ game và bổ sung playtest mới cho mê cung gương Map28"
  },
  "statusLabels": {
    "untested": "Chưa thử",
    "testing": "Đang thử",
    "pass": "Diễn ra đúng",
    "bug": "Có lỗi",
    "blocked": "Không thể tiếp tục",
    "retest": "Cần thử lại"
  },
  "checks": {
    "open.map3": {
      "action": "Hoàn thành đoạn mở đầu tại Map3 (Văn phòng Silver Wing).",
      "result": "Hội thoại đúng thứ tự/người nói; nhân vật không bị kẹt khi tự đi.",
      "error": "Sai người nói, camera lệch hoặc nhân vật bị kẹt."
    },
    "open.map17": {
      "action": "Nếu đi qua Map17 (Hành lang Silver Wing), đi hết hành lang tới thành phố.",
      "result": "Hải Quỳ tới đúng vị trí ở Map6; không tiếp tục tự chạy theo lộ trình cũ.",
      "error": "Sang map mới nhưng nhân vật vẫn tự chạy hoặc xuất hiện lệch vị trí."
    },
    "open.map6": {
      "action": "Đi qua Map6 (Thành phố) và lên xe bus.",
      "result": "Camera bắt kịp Hải Quỳ và chuyển lên xe bus bình thường.",
      "error": "Camera bỏ lại nhân vật hoặc chuyển map sai."
    },
    "open.map10": {
      "action": "Ở Map10 (Trong xe bus), xem hết đoạn suy nghĩ và chọn điểm đến.",
      "result": "Lời kể hiện bình thường; mỗi nút chọn dẫn đúng nơi ghi trên nút.",
      "error": "Màn hình đen vĩnh viễn, lóe sáng hoặc chọn một nơi nhưng tới nơi khác."
    },
    "prep.sleep": {
      "action": "Xem đoạn Hải Quỳ đặt quà rồi ngủ.",
      "result": "Hải Quỳ ngủ trước rồi mới thức dậy.",
      "error": "Cảnh bị bỏ qua hoặc thứ tự đảo."
    },
    "prep.outfit": {
      "action": "Xem trọn cảnh thử trang phục.",
      "result": "Các bộ đồ chạy đúng thứ tự; chỉ đổi sang đồ Giáng sinh sau bộ cuối.",
      "error": "Sprite đổi quá sớm hoặc lóe sai hình khi màn hình tối."
    },
    "prep.light": {
      "action": "Chờ cảnh chuẩn bị kết thúc.",
      "result": "Màn hình sáng trở lại và câu chuyện tiếp tục.",
      "error": "Màn hình tối vĩnh viễn hoặc lóe sáng bất thường."
    },
    "party.arrival": {
      "action": "Đi vào Map38 (Văn phòng Wanderer trong tiệc Giáng sinh).",
      "result": "Phần mở đầu của bữa tiệc khớp route hiện tại.",
      "error": "Thoại/ảnh của route khác xuất hiện."
    },
    "party.free": {
      "action": "Tới đoạn được tự do khám phá trong tiệc.",
      "result": "Có thể đi lại, vào khu vực phụ và nói chuyện với các thành viên.",
      "error": "Màn hình còn đen hoặc không điều khiển được Hải Quỳ."
    },
    "party.snow": {
      "action": "Thử mở ném tuyết từ phần khám phá tự do.",
      "result": "Có thể thách đấu Shylvie, Kohi, Leo hoặc Hakase và quay lại bữa tiệc.",
      "error": "Minigame không mở hoặc quay về sai trạng thái."
    },
    "party.continue": {
      "action": "Chọn tiếp tục bữa tiệc.",
      "result": "Cảnh trao quà chạy đúng một lần rồi chuyển sang phần sau của route.",
      "error": "Scene lặp, crash hoặc tiếp tục sai route."
    },
    "super.bus": {
      "action": "Khi vừa tới Map19 (Siêu thị), quan sát xe bus ngoài cửa.",
      "result": "Xe tiếp tục chạy sang trái rồi rời màn hình.",
      "error": "Xe đứng yên hoặc biến mất sai cách."
    },
    "super.view4": {
      "action": "Xem cả bốn món quà trước khi quyết định.",
      "result": "Có thể xem đủ bốn món.",
      "error": "Một món không xem được hoặc route bị khóa quá sớm."
    },
    "super.freeaftergift": {
      "action": "Chọn một món quà rồi thử đi lại trước khi thanh toán.",
      "result": "Hải Quỳ vẫn tự do đi lại; chỉ thanh toán khi chủ động ra cửa.",
      "error": "Game tự kéo Hải Quỳ tới quầy hoặc khóa điều khiển."
    },
    "super.recipient": {
      "action": "Sau thanh toán, chọn người nhận.",
      "result": "Bắt buộc chọn Leo, Kohi, Shylvie hoặc Hakase; không thoát khi chưa chọn.",
      "error": "Thoát màn hình chọn mà chưa chọn ai hoặc người nhận sai."
    },
    "super.image": {
      "action": "Quan sát ảnh món quà sau khi chọn.",
      "result": "Ảnh đúng món vừa chọn.",
      "error": "Ảnh thuộc món khác."
    },
    "super.consistency": {
      "action": "Theo route tới chuẩn bị quà, tiệc, sau tiệc và gợi ý cuối.",
      "result": "Món quà và người nhận giữ nguyên xuyên suốt.",
      "error": "Một đoạn bất kỳ đổi sang món/người khác."
    },
    "coffee.map40": {
      "action": "Tới Map40 (Chuyến xuống Atlantis lấy cà phê).",
      "result": "Màn hình đang đen; lời kể dùng hộp thoại bình thường. Sau tin quái vật/mái nhà và việc quán hết cà phê mới hiện lựa chọn.",
      "error": "Lời thoại nổi sai kiểu, lựa chọn xuất hiện quá sớm hoặc route bỏ qua đoạn này."
    },
    "coffee.regular": {
      "action": "Chọn dùng cà phê thường.",
      "result": "Bỏ qua minigame và tiếp tục route với nội dung cà phê thường.",
      "error": "Route vẫn ghi nhận cà phê Atlantis hoặc bắt buộc vào minigame."
    },
    "coffee.atlantis": {
      "action": "Chọn đi câu tôm và lấy đủ mười cà phê Atlantis.",
      "result": "Chỉ khi đủ mười mới tiếp tục; phần sau ghi nhận cà phê Atlantis.",
      "error": "Thoát sớm vẫn được tính đủ hoặc route quay về nội dung cà phê thường."
    },
    "noodle.fixedleo": {
      "action": "Theo route mua mì cay.",
      "result": "Người nhận luôn là Leo; không xuất hiện màn hình chọn bốn người.",
      "error": "Xuất hiện lựa chọn người nhận khác."
    },
    "noodle.map14once": {
      "action": "Tới Map14 (Nhà bếp Wanderer) và hoàn thành cảnh nấu.",
      "result": "Cảnh nấu chỉ chạy một lần; hình tô mì đúng người nấu.",
      "error": "Cảnh chạy lặp hoặc dùng hình sai nhánh."
    },
    "noodle.party": {
      "action": "Tới bữa tiệc.",
      "result": "Có nồi mì cay, bình Sting 20 lít, cảnh tuyết và các cảnh ăn uống liên quan.",
      "error": "Thiếu các chi tiết chính hoặc lẫn route quà khác."
    },
    "noodle.end": {
      "action": "Sau cuộc gọi từ Silver Wing, đi tới đoạn cuối.",
      "result": "Route đi thẳng tới gợi ý cuối; không tự thêm buổi sáng hôm sau.",
      "error": "Xuất hiện cảnh sáng hôm sau không thuộc route."
    },
    "askleo.three": {
      "action": "Tại Map13, nói chuyện với Leo đủ ba lần.",
      "result": "Sau lần thứ ba game tự vào cuộc trò chuyện riêng và cho chọn ba địa điểm.",
      "error": "Không mở lựa chọn hoặc mở trước lần thứ ba."
    },
    "askleo.shopauto": {
      "action": "Chọn cửa hàng và tới đúng nơi.",
      "result": "Scene mua quà tự bắt đầu khi vừa tới đúng cửa hàng.",
      "error": "Tới sai cửa hàng hoặc scene không tự bắt đầu."
    },
    "askleo.map60": {
      "action": "Tới Map60 (Chuẩn bị quà theo lời Leo).",
      "result": "Quà vừa mua được giữ đúng; không phát thoại của route mua đá.",
      "error": "Quà/thoại bị đổi route."
    },
    "askleo.outfit": {
      "action": "Xem cảnh thử đồ ở Map60.",
      "result": "Chỉ đổi sang trang phục Giáng sinh sau khi xem xong.",
      "error": "Đổi sprite trước khi cảnh thử đồ kết thúc."
    },
    "askleo.party": {
      "action": "Tới Map38.",
      "result": "Màn hình sáng lại và người chơi được tự do khám phá.",
      "error": "Màn hình tối hoặc bị khóa điều khiển."
    },
    "stone.unlock": {
      "action": "Tại Map13, nói chuyện với Shylvie tới khi nhận tọa độ tiệm đá phong thủy.",
      "result": "Route dẫn tới đúng tiệm đá.",
      "error": "Bị đưa tới tiệm của route hỏi Leo."
    },
    "stone.browse": {
      "action": "Tại tiệm đá, xem các kệ và chọn người nhận.",
      "result": "Có đủ bốn lựa chọn Leo, Kohi, Shylvie, Hakase.",
      "error": "Thiếu lựa chọn hoặc ảnh đá không khớp."
    },
    "stone.consistency": {
      "action": "Theo route qua chuẩn bị quà, tiệc và đoạn sau.",
      "result": "Người nhận, ảnh viên đá, hiệu ứng và gợi ý cuối giữ cùng một nhánh.",
      "error": "Bất kỳ đoạn nào đổi sang đá/người khác."
    },
    "book.housepath": {
      "action": "Từ Map10 đi qua Map22 (Nhà Hải Quỳ), Map21 và tới Map23 (Tiệm sách phép Atlantis).",
      "result": "Đường đi liền mạch, không kẹt ở map trống/tối.",
      "error": "Sai map hoặc màn hình tối vĩnh viễn."
    },
    "book.late": {
      "action": "Sau khi chuẩn bị sách, xem cảnh Hải Quỳ ngủ quên và tới văn phòng muộn.",
      "result": "Sprite chỉ đổi sau cảnh thay đồ; khi tới Map38 không phát lại toàn bộ đoạn chuẩn bị tiệc.",
      "error": "Đổi sprite sớm hoặc phát nhầm cảnh tới sớm."
    },
    "warehouse.keylight": {
      "action": "Ở Map22/Map26, tìm chìa khóa, vào phòng kho và bật đèn.",
      "result": "Trước khi bật đèn chỉ báo quá tối; sau khi bật mới dùng được các tương tác thật.",
      "error": "Có thể đọc đồ trong tối hoặc nhiều điểm bật đèn gây sai tiến độ."
    },
    "warehouse.letter": {
      "action": "Đọc hết Lá thư cuối của Dahria.",
      "result": "Đọc xong dẫn thẳng vào ký ức/rượt đuổi.",
      "error": "Quay sang route chọn sách hoặc đứng lại trong kho."
    },
    "clone.11": {
      "action": "Tại Map34 (Vòng vây clone), chờ đủ clone áp sát.",
      "result": "Cả 11 clone chạy sát quanh Hải Quỳ trước câu “Buông tao ra!”.",
      "error": "Thiếu clone hoặc câu thoại chạy quá sớm."
    },
    "clone.monster": {
      "action": "Sau khi Hải Quỳ đánh văng clone, quan sát quái vật.",
      "result": "Dấu chấm than/quay lên xảy ra trước; quái vật bước vào khung hình rồi mới gầm và rung màn hình.",
      "error": "Quái vật/gầm/rung sai thứ tự."
    },
    "chase.camera": {
      "action": "Tại Map29, theo dõi Hải Quỳ và quái vật.",
      "result": "Cả hai chạy xuống; quái vật ở phía trên và tiến gần dần nhưng không xuyên qua Hải Quỳ.",
      "error": "Camera bỏ nhân vật hoặc quái vật vượt xuyên qua."
    },
    "paulie.drop": {
      "action": "Sau khi thoát rượt đuổi, xem Paulie xuất hiện.",
      "result": "Hải Quỳ nhảy lùi; camera đưa Hải Quỳ/quái vật khỏi khung rồi chỉ một Paulie rơi từ trên cao.",
      "error": "Có hai Paulie hoặc thứ tự camera/rơi sai."
    },
    "paulie.land": {
      "action": "Quan sát chuỗi Paulie đáp đất.",
      "result": "Ba hình đầu lặp khi rơi; hiệu ứng đáp đất tại Paulie; sau hiệu ứng trở về hình đứng thường.",
      "error": "Animation/hiệu ứng sai vị trí hoặc không trở về hình đứng."
    },
    "paulie.bind": {
      "action": "Quan sát Paulie khống chế quái vật.",
      "result": "Paulie hô tên đòn; hiệu ứng xuất hiện ở quái vật rồi mới chuyển sang hình bị trói.",
      "error": "Quái vật bị trói trước hiệu ứng hoặc hiệu ứng sai vị trí."
    },
    "paulie.talk": {
      "action": "Xem hội thoại hai anh em.",
      "result": "Paulie nhảy sang bên phải Hải Quỳ khoảng hai ô; hai người quay mặt vào nhau.",
      "error": "Vị trí/hướng nhìn sai."
    },
    "paulie.finish": {
      "action": "Xem Hải Quỳ kết liễu quái vật.",
      "result": "Đòn trúng quái vật, xác vỡ; màn hình tối dần và chỉ khi tối hẳn mới sang Map35.",
      "error": "Chuyển map quá sớm hoặc xác/hiệu ứng sai."
    },
    "paulie.leave": {
      "action": "Khi Paulie rời đi, quan sát hiệu ứng dịch chuyển và điện thoại.",
      "result": "Paulie biến mất trước, hiệu ứng vẫn phát đủ ở vị trí cũ; hộp thoại điện thoại không còn đuôi.",
      "error": "Hiệu ứng bị cắt hoặc hộp thoại điện thoại có đuôi sai."
    },
    "visual.dialogue": {
      "action": "Quan sát hộp thoại trong scene.",
      "result": "Khi map/nhân vật hiện, thoại nổi trỏ đúng người; khi màn hình đen/CG hoặc là suy nghĩ thì dùng thoại bình thường.",
      "error": "Đuôi thoại trỏ sai, CG bị thoại nổi che hoặc suy nghĩ bị gắn vào NPC."
    },
    "visual.faces": {
      "action": "Quan sát ảnh khuôn mặt và biểu cảm.",
      "result": "Đúng nhân vật và cảm xúc dễ nhận ra.",
      "error": "Sai nhân vật hoặc biểu cảm không phù hợp."
    },
    "visual.text": {
      "action": "Quan sát chữ tiếng Việt.",
      "result": "Chữ hiện đủ, đặc biệt ký tự cuối dòng.",
      "error": "Mất ký tự hoặc cắt dòng."
    },
    "visual.transition": {
      "action": "Quan sát chuyển cảnh/ánh sáng/camera.",
      "result": "Tối/sáng mượt, không lóe một frame; camera theo đúng nhân vật và trở về trạng thái phù hợp sau rung/zoom.",
      "error": "Lóe sáng, tối vĩnh viễn, camera lệch hoặc hiệu ứng còn sót."
    },
    "map13.nav": {
      "action": "Khám phá Map13 (Văn phòng Wanderer).",
      "result": "Laser/xác thực, Leo, Shylvie, két sắt, nhà bếp, phòng riêng, phòng họp và phòng chế tạo đều dùng được.",
      "error": "Một khu vực/cửa không hoạt động hoặc đưa sai nơi."
    },
    "map14.return": {
      "action": "Từ Map14 (Nhà bếp Wanderer), thử quay lại văn phòng.",
      "result": "Trở về đúng phiên bản văn phòng vừa rời đi.",
      "error": "Luôn quay về Map13 dù đi vào từ phiên bản khác."
    },
    "map15.return": {
      "action": "Khám phá Map15 (Phòng tắm Wanderer) và quay lại.",
      "result": "Các vật thể dùng được và đường về đúng nơi.",
      "error": "Kẹt/đi sai phiên bản văn phòng."
    },
    "map19.interactions": {
      "action": "Khám phá các kệ, hai quầy thu ngân, game bắn phi thuyền, vuốt mèo và cửa ra ở Map19.",
      "result": "Các tương tác mở đúng, thoát về đúng siêu thị.",
      "error": "Tương tác lỗi, minigame để lại UI hoặc cửa ra sai."
    },
    "map20.choice": {
      "action": "Tại Map20 (Tiệm mì cay), thử hội thoại mua mì.",
      "result": "Có đúng hai lựa chọn Tin Aira / Không tin Aira và route tiếp tục đúng nhánh.",
      "error": "Thiếu lựa chọn hoặc đi sai nhánh."
    },
    "map21.link": {
      "action": "Đi qua Map21 (Điểm xuống Atlantis).",
      "result": "Đoạn nối tới tiệm sách liền mạch.",
      "error": "Bị để lại ở map trống/tối."
    },
    "map23.counter": {
      "action": "Thử cả hai vị trí trước cùng quầy tại Map23.",
      "result": "Cùng nói chuyện với một bà chủ và dùng chung tiến độ hội thoại; hộp thoại trỏ đúng bà chủ.",
      "error": "Hai vị trí chạy tiến độ khác nhau hoặc thoại trỏ sai."
    },
    "map23.objects": {
      "action": "Khám phá hai sách route, quả địa cầu, giá sách, cửa phụ và vật thể lore.",
      "result": "Các tương tác đúng nội dung và không tự đổi route ngoài lựa chọn của người chơi.",
      "error": "Một vật thể làm nhảy nhầm route."
    },
    "map28.light": {
      "action": "Vào Map28 và đi qua các vùng Region tối/sáng của mê cung.",
      "result": "Ánh sáng vàng/cam luôn bám theo Hải Quỳ, đủ rõ để đọc đường đi; Region vẫn tạo bóng đúng trên parallax và không có mảng đen nhấp nháy bất thường.",
      "error": "Không thấy đường, ánh sáng không bám player, Region không ảnh hưởng bóng hoặc xuất hiện mảng đen nhấp nháy."
    },
    "map28.clone.spawn": {
      "action": "Đi qua nhiều sensor gọi clone, gồm cả các sensor đã được di chuyển hoặc nhân bản.",
      "result": "Sensor chỉ kích hoạt bẫy; clone luôn chui ra tại một ô hợp lệ sát gương tương ứng, không xuất hiện tại sensor hoặc chồng lên Hải Quỳ.",
      "error": "Clone xuất hiện tại sensor/player, sai gương, trong tường hoặc không xuất hiện dù còn ô sát gương hợp lệ."
    },
    "map28.clone.contact": {
      "action": "Đứng yên để một clone tự đuổi và chạm vào Hải Quỳ; thử lại bằng cách chủ động đi vào clone.",
      "result": "Cả hai hướng va chạm đều tính đúng một lần choáng; clone không đứng im vô hại cạnh player và biến mất sau khi gây choáng.",
      "error": "Chỉ player chủ động đâm vào mới bị choáng, clone đứng kẹt cạnh player, hoặc một va chạm bị tính nhiều lần."
    },
    "map28.barrel": {
      "action": "Tương tác một thùng lửa rồi dẫn một clone còn sống tới gần một thùng lửa khác.",
      "result": "Thùng được tương tác chuyển sang hình không lửa và ánh sáng quanh player rộng hơn; clone tới gần thùng còn cháy sẽ nổ, thùng tắt và điểm choáng giảm một nhưng không dưới 0.",
      "error": "Thùng không đổi hình/ánh sáng, player không sáng rộng hơn, clone không nổ hoặc điểm choáng giảm sai."
    },
    "map28.spikes": {
      "action": "Đi qua dãy gai ở nhịp ban đầu và cố bước vào ở từng frame nâng/hạ khác nhau.",
      "result": "Chỉ frame gai hạ xuống hoàn toàn mới an toàn; mọi frame còn nhô, đang nâng hoặc đang hạ đều gây đúng một lần choáng mỗi lượt chạm.",
      "error": "Có thể đi qua quá sớm khi gai còn nhô, frame an toàn vẫn gây choáng hoặc một lần đứng trên gai bị tính lặp liên tục."
    },
    "map28.boulder": {
      "action": "Chạm trigger event 29, thử để đá event 28 đụng player rồi thử né để đá lăn tới event 37.",
      "result": "Đá lăn ngang tốc độ player và có ánh sáng; chạm player lập tức đạt 4 choáng và chạy chuỗi reset; nếu né được, đá vỡ bằng animation tại event 37 rồi biến mất.",
      "error": "Đá không chạy/sai tốc độ/không có sáng, va chạm không đủ 4 choáng hoặc đá không vỡ và biến mất tại cuối đường."
    },
    "map28.gauntlet": {
      "action": "Chạm event 48 hoặc 49 rồi xem trọn cảnh cửa–nút; quay lại nút qua đường gai và bấm event 47.",
      "result": "Hải Quỳ bất ngờ; cửa 38/39 đóng có ánh sáng; camera giới thiệu nút 47; nút xuất hiện với ánh sáng vàng ổn định, không có chớp đen. Một trong ba pattern gai khó được giữ cho đường quay lại. Bấm nút đổi sprite, tắt sáng nút, camera về cửa và cửa mở đúng animation.",
      "error": "Nút hiện từ đầu, cửa/camera/animation sai thứ tự, ánh sáng nút chớp đen, gai không đổi pattern hoặc bấm nút không mở cửa."
    },
    "map28.daze": {
      "action": "Nhận lần lượt ba sát thương từ clone/gai rồi nhận lần thứ tư.",
      "result": "Mỗi lần chỉ tăng một điểm choáng. Rung/wave/blur mạnh ngắn lúc trúng rồi giảm dần về mức nhẹ mà không tự giảm điểm; ở mốc nguy hiểm cuối viền đỏ vẫn giữ. Lần thứ tư xoay Hải Quỳ nằm xuống, tối màn hình, trả về đầu mê cung và reset clone, sensor, thùng, gai, đá, cửa và nút trước khi sáng lại; không Game Over.",
      "error": "Hiệu ứng mạnh kéo dài gây chóng mặt, điểm tự giảm, mất viền đỏ, Game Over, camera sai sau reset hoặc một bẫy không trở về trạng thái đầu."
    },
    "map28.exit": {
      "action": "Hoàn thành thử thách và đi tới lối ra Map28.",
      "result": "Hải Quỳ tới được event lối ra và chuyển tiếp đúng sang phần vòng vây clone, không kẹt va chạm hoặc bị giữ camera/ánh sáng từ mê cung.",
      "error": "Không tới được lối ra, chuyển sai map hoặc camera/ánh sáng/hiệu ứng mê cung còn sót sau chuyển cảnh."
    },
    "map57.shop": {
      "action": "Khám phá Map57 (Tiệm ma pháp).",
      "result": "Chủ tiệm hút thuốc, vật thể và cảnh mua áo choàng hoạt động; ba hình hút thuốc lặp đúng nhịp.",
      "error": "Animation/scene mua sai."
    },
    "map58.shop": {
      "action": "Khám phá Map58 (Tiệm cà phê).",
      "result": "Hội thoại mua cà phê hoạt động; nhân vật gần giữa màn hình và hộp thoại trỏ đúng vị trí.",
      "error": "Nhân vật lệch màn hình hoặc thoại trỏ sai."
    },
    "map59.shop": {
      "action": "Khám phá Map59 (Cửa hàng vũ khí).",
      "result": "NPC, vật phẩm, va chạm và cảnh mua quà cho Shylvie hoạt động.",
      "error": "Kẹt va chạm hoặc mua sai món/route."
    },
    "map22.house": {
      "action": "Khám phá Map22 (Nhà Hải Quỳ).",
      "result": "Đồ vật, điểm pha mì, chìa khóa, cầu thang và đường tới Atlantis dùng được.",
      "error": "Một đường đi/tương tác chính không hoạt động."
    },
    "map22.stairs": {
      "action": "Lên/xuống cầu thang giữa Map22 và Map41.",
      "result": "Hải Quỳ trở lại tốc độ bình thường, không xuyên tường, không tự đi tiếp trên nền phẳng.",
      "error": "Còn hiệu ứng đi cầu thang sau khi chuyển tầng."
    },
    "map41.room": {
      "action": "Khám phá Map41 (Phòng Hải Quỳ ở nhà).",
      "result": "Hồ sơ, sách, đầu đĩa, tủ đầu giường và máy chơi game hoạt động; không nhầm với phòng tại Wanderer.",
      "error": "Tương tác/thoại thuộc Map42 xuất hiện."
    },
    "map26.dark": {
      "action": "Vào Map26 khi chưa bật đèn và thử vài vật thể.",
      "result": "Tất cả chỉ báo căn phòng quá tối; chỉ một điểm bật đèn.",
      "error": "Đọc được nội dung thật trong tối hoặc có nhiều công tắc tiến độ độc lập."
    },
    "map26.diaries": {
      "action": "Sau khi bật đèn, xem nhật ký thời thơ ấu, nhật ký cũ, lá thư và album.",
      "result": "Mỗi vật có câu giới thiệu rồi mở đúng bộ ảnh; album mở Album 1–4; thư cuối dẫn tới ký ức/rượt đuổi.",
      "error": "Mở sai bộ ảnh hoặc thư không chuyển nhánh."
    },
    "map26.cassette": {
      "action": "Khi đã có băng, dùng đầu đĩa.",
      "result": "Hải Quỳ nói bỏ đúng băng vào máy; lời sau là âm thanh từ máy, không dùng chân dung Hải Quỳ.",
      "error": "Sai băng hoặc thoại máy dùng mặt Hải Quỳ."
    },
    "map42.safe": {
      "action": "Tại Map42, mở két mã và tương tác nhiều lần.",
      "result": "Mã 0290120240012202 mở được; các lần tương tác lần lượt hiện Blu-ray, album ảnh thẻ và bản thiết kế với lựa chọn xem/để sau.",
      "error": "Sai tiến độ hoặc lựa chọn không hoạt động."
    },
    "map42.bath": {
      "action": "Dùng bồn tắm ở góc dưới trái Map42.",
      "result": "Ba hình đầu lặp ba lần; các hình sau chạy tiếp; hình cuối giữ một lúc rồi tối và kết thúc.",
      "error": "Animation sai thứ tự hoặc kết thúc đột ngột."
    },
    "map42.tv": {
      "action": "Dùng TV ở góc trên trái Map42.",
      "result": "Hải Quỳ ngồi trước TV; 9 hình chạy theo nhịp tối–đổi hình–sáng; sau hình 9 tới bad ending “Thêm tập nữa thôi!”.",
      "error": "TV mới che nhân vật, đổi hình lúc sáng hoặc ending tới sai thời điểm."
    },
    "map42.return": {
      "action": "Rời Map42.",
      "result": "Trở về đúng phiên bản văn phòng đã đi vào.",
      "error": "Luôn quay về Map13."
    },
    "map43.room": {
      "action": "Khám phá Map43 (Phòng Shylvie).",
      "result": "Đồ vật, trạng thái bật/tắt đèn và vật nhiều ô tiến triển một mạch hội thoại.",
      "error": "Mỗi ô của cùng vật lặp lại như vật riêng."
    },
    "map43.return": {
      "action": "Rời Map43.",
      "result": "Trở về đúng phiên bản văn phòng đã đi vào.",
      "error": "Luôn quay về Map13."
    },
    "map44.room": {
      "action": "Khám phá Map44 (Phòng Leo).",
      "result": "Đồ vật/lore hoạt động; vật góc trên trái có phần hội thoại tiếp theo riêng; kệ game có đủ các lần tương tác.",
      "error": "Tương tác lặp/sai tiến độ."
    },
    "map44.return": {
      "action": "Rời Map44.",
      "result": "Trở về đúng phiên bản văn phòng đã đi vào.",
      "error": "Luôn quay về Map13."
    },
    "map45.room": {
      "action": "Khám phá Map45 (Phòng Hakase).",
      "result": "Thiết bị, khe lắp RAM, đầu đĩa và ghi chú âm thanh hoạt động.",
      "error": "RAM/đầu đĩa/tương tác không phản hồi hoặc sai nội dung."
    },
    "map45.return": {
      "action": "Rời Map45.",
      "result": "Trở về đúng phiên bản văn phòng đã đi vào.",
      "error": "Luôn quay về Map13."
    },
    "map46.ram": {
      "action": "Tại Map46, lấy thanh RAM dưới giường.",
      "result": "RAM chỉ lấy được một lần và có thể mang sang phòng Hakase.",
      "error": "Lấy lặp vô hạn hoặc không dùng được ở Map45."
    },
    "map46.room": {
      "action": "Khám phá đồ vật còn lại trong Map46 (Phòng Kohi).",
      "result": "Đồ vật của Kohi hoạt động đúng nội dung.",
      "error": "Tương tác thiếu/sai."
    },
    "map46.return": {
      "action": "Rời Map46.",
      "result": "Trở về đúng phiên bản văn phòng đã đi vào.",
      "error": "Luôn quay về Map13."
    },
    "map61.room": {
      "action": "Vào Map61 (Phòng họp).",
      "result": "Va chạm khớp nền, vị trí vào không đè lối ra và quay lại đúng nơi xuất phát.",
      "error": "Kẹt cửa/va chạm hoặc quay sai nơi."
    },
    "map62.room": {
      "action": "Vào Map62 (Phòng họp Movie Night).",
      "result": "Va chạm khớp nền, vị trí vào không đè lối ra và quay lại đúng nơi xuất phát.",
      "error": "Kẹt cửa/va chạm hoặc quay sai nơi."
    },
    "map63.room": {
      "action": "Khám phá Map63 (Phòng chế tạo).",
      "result": "Bàn chế tạo, máy móc, thùng thiết bị, xác sinh vật, dụng cụ phẫu thuật, Nethervoid và tháp dò tín hiệu đều có tương tác.",
      "error": "Thiếu nhóm tương tác hoặc vật nhiều ô phát lại như nhiều vật khác nhau."
    },
    "map38.rooms": {
      "action": "Trong phần tự do ở Map38, thử các lối phụ.",
      "result": "Vào được nhà bếp, 5 phòng riêng, phòng họp và phòng chế tạo.",
      "error": "Một lối không mở hoặc quay về sai phiên bản văn phòng."
    },
    "map39.rooms": {
      "action": "Từ Map39 (Văn phòng Wanderer sáng hôm sau), thử phòng họp/phòng chế tạo/phòng riêng.",
      "result": "Phòng họp tới Map61, phòng chế tạo tới Map63 và khi quay lại vẫn là Map39.",
      "error": "Quay về Map13/Map38 sai ngữ cảnh."
    },
    "map48.rooms": {
      "action": "Từ Map48 (Văn phòng route mì cay), thử phòng họp/phòng chế tạo.",
      "result": "Phòng họp tới Map62, phòng chế tạo tới Map63 và quay lại Map48.",
      "error": "Đi sai phòng họp hoặc quay sai nơi."
    },
    "map50.rooms": {
      "action": "Từ Map50 (Văn phòng sau route sách Shylvie), thử lối phụ.",
      "result": "Phòng họp tới Map61, phòng chế tạo tới Map63 và quay lại Map50.",
      "error": "Quay sai phiên bản văn phòng."
    },
    "map52.rooms": {
      "action": "Từ Map52 (Văn phòng sau route sách Hakase), thử lối phụ.",
      "result": "Phòng họp tới Map61, phòng chế tạo tới Map63 và quay lại Map52.",
      "error": "Quay sai phiên bản văn phòng."
    },
    "map54.rooms": {
      "action": "Từ Map54 (Văn phòng trong cảnh đi tìm Hải Quỳ), thử lối phụ.",
      "result": "Phòng họp tới Map62, phòng chế tạo tới Map63 và quay lại Map54.",
      "error": "Quay sai phiên bản văn phòng."
    },
    "map40.scene": {
      "action": "Tại Map40, đi hết phần kể chuyện và lựa chọn cà phê.",
      "result": "Màn hình đang đen; lời kể dùng hộp thoại bình thường. Sau tin quái vật/mái nhà và việc quán hết cà phê mới hiện lựa chọn.",
      "error": "Lời thoại nổi sai kiểu, lựa chọn xuất hiện quá sớm hoặc route bỏ qua đoạn này."
    },
    "snow.common.ui": {
      "action": "Bắt đầu một trận ném tuyết.",
      "result": "Thanh máu, lượt, Perfect, Miss và sát thương cập nhật rõ ràng.",
      "error": "UI không cập nhật hoặc lẫn nhân vật."
    },
    "snow.common.cleanup": {
      "action": "Kết thúc trận bằng thắng, thua hoặc chủ động dừng.",
      "result": "Tuyết, nhân vật, giao diện và âm thanh minigame biến mất trước khi quay về tiệc.",
      "error": "UI/âm thanh còn sót trên Map38."
    },
    "snow.common.memory": {
      "action": "Thắng một đối thủ rồi thử người khác.",
      "result": "Kết quả thắng từng người được ghi nhớ độc lập.",
      "error": "Thắng người mới làm mất kết quả cũ."
    },
    "snow.shylvie": {
      "action": "Thử thắng và thua Shylvie.",
      "result": "Nhịp tấn công, phản công, hình nhân vật và hai kết quả đều đúng Shylvie.",
      "error": "Lẫn hình/finisher của người khác."
    },
    "snow.kohi": {
      "action": "Thử thắng và thua Kohi.",
      "result": "Cơ chế nhập chuỗi theo tỷ lệ hoàn thành chỉ xuất hiện ở phần Kohi.",
      "error": "Cơ chế xuất hiện ở người khác hoặc kết quả lẫn nhân vật."
    },
    "snow.leo": {
      "action": "Thử thắng và thua Leo.",
      "result": "Hướng đòn/mũi tên dễ nhìn; hình tấn công/phòng thủ đúng Leo.",
      "error": "Mũi tên/hình nhân vật sai."
    },
    "snow.hakase": {
      "action": "Thử thắng và thua Hakase.",
      "result": "Mũi tên đẩy ma lực luôn thấy rõ; quỹ đạo/hình/kết quả đúng Hakase.",
      "error": "Mũi tên bị che hoặc lẫn Leo/Kohi."
    },
    "fish.controls": {
      "action": "Mở minigame câu tôm.",
      "result": "Z thả/kéo/bắn tùy dụng cụ; Shift đổi cần câu/găng tay; X/Esc thoát.",
      "error": "Phím không hoạt động hoặc thoát sai trạng thái."
    },
    "fish.black": {
      "action": "Kéo tôm khi còn đen.",
      "result": "Hải Quỳ thả lại biển; bộ đếm không tăng.",
      "error": "Vẫn được tính cà phê."
    },
    "fish.yellow": {
      "action": "Kéo đúng lúc tôm chuyển vàng.",
      "result": "Tôm nhả cà phê Atlantis và bộ đếm tăng một.",
      "error": "Không tăng hoặc tăng sai."
    },
    "fish.red": {
      "action": "Cố kéo quá muộn.",
      "result": "Tôm đỏ rồi phát nổ; không tính thành công.",
      "error": "Vẫn tăng bộ đếm."
    },
    "fish.struggle": {
      "action": "Gặp lúc tôm giằng dây.",
      "result": "Làm theo hướng hiển thị; sai/chậm thì tôm thoát.",
      "error": "Không có hướng hoặc kết quả sai."
    },
    "fish.beam": {
      "action": "Đổi sang găng tay và dùng beam.",
      "result": "Có cảnh báo, vùng tác dụng rõ và thời gian hồi.",
      "error": "Beam không cảnh báo/vùng mơ hồ/không hồi."
    },
    "fish.exit9": {
      "action": "Thoát trước khi đủ mười.",
      "result": "Quay lại lựa chọn; route chưa coi là có cà phê Atlantis.",
      "error": "Vẫn đi tiếp như đã đủ."
    },
    "fish.exit10": {
      "action": "Đạt đủ mười rồi rời minigame.",
      "result": "Game báo đủ, cho quay lại quán và tiếp tục route; không còn UI/cá/tôm/beam/âm thanh minigame.",
      "error": "Không báo đủ hoặc tài nguyên minigame còn sót."
    },
    "chase.rules": {
      "action": "Trong Map29, gặp clone cản đường và nhập chuỗi ba phím.",
      "result": "Phím có thể là Z, X, Shift, ↑, ↓; sai/hết giờ tăng nguy hiểm; lỗi bốn lần Game Over.",
      "error": "Chuỗi/phạt/Game Over sai."
    },
    "chase.11": {
      "action": "Sống đủ lâu trong một lượt hoàn chỉnh.",
      "result": "Cả 11 clone khác nhau xuất hiện trước khi lặp; không kết thúc trước 60 giây hoặc trước đủ 11 lần cản.",
      "error": "Kết thúc sớm hoặc clone lặp trước khi đủ 11."
    },
    "chase.cleanup": {
      "action": "Thắng hoặc thua rượt đuổi.",
      "result": "Thắng: dọn UI/clone rồi tới Map25. Thua: Game Over sạch, không giữ UI.",
      "error": "UI/clone còn sót."
    },
    "ship.play": {
      "action": "Mở game bắn phi thuyền tại Map19, thử hoàn thành và thử thua/thoát.",
      "result": "Khi quay lại siêu thị, UI/điều khiển minigame biến mất.",
      "error": "UI hoặc điều khiển còn sót."
    },
    "ship.reward": {
      "action": "Đạt đủ điểm yêu cầu.",
      "result": "Phần thưởng biến hình mở đúng một lần.",
      "error": "Mở lặp hoặc không mở."
    },
    "cat.play": {
      "action": "Mở trò vuốt mèo tại Map19, tương tác rồi thoát.",
      "result": "Quay lại đúng vị trí trong siêu thị, không crash và không giữ hình bàn tay/mèo.",
      "error": "Crash, sai vị trí hoặc hình còn sót."
    },
    "route.lockpick.leo": {
      "action": "Hoàn thành nhánh Bộ phá khóa tặng Leo.",
      "result": "Leo nhận bộ phá khóa và về sau dùng nó mở cửa cứu Hải Quỳ bị kẹt. Lời gợi ý cuối nhắc món quà kỳ lạ đã cứu tình huống.",
      "error": "Phản ứng/hậu truyện/gợi ý thuộc người nhận khác."
    },
    "route.lockpick.kohi": {
      "action": "Hoàn thành nhánh Bộ phá khóa tặng Kohi.",
      "result": "Kohi nhận bộ phá khóa. Đoạn sau chủ ý chuyển sang chuyện máy pha cà phê. Không coi việc chuyển chủ đề máy pha cà phê là đi nhầm route.",
      "error": "Phản ứng/hậu truyện/gợi ý thuộc người nhận khác."
    },
    "route.lockpick.shylvie": {
      "action": "Hoàn thành nhánh Bộ phá khóa tặng Shylvie.",
      "result": "Shylvie nhận bộ phá khóa rồi nâng cấp thành dụng cụ phá phép. Đoạn sau có rắc rối với nhóm đầu ổ khóa.",
      "error": "Phản ứng/hậu truyện/gợi ý thuộc người nhận khác."
    },
    "route.lockpick.hakase": {
      "action": "Hoàn thành nhánh Bộ phá khóa tặng Hakase.",
      "result": "Hakase nhận bộ phá khóa và luyện mở khóa. Đoạn sau Hakase bị cảnh sát hiểu nhầm là trộm.",
      "error": "Phản ứng/hậu truyện/gợi ý thuộc người nhận khác."
    },
    "route.knife.leo": {
      "action": "Hoàn thành nhánh Dao và chảo tặng Leo.",
      "result": "Leo nhận đúng combo dao và chảo; đoạn sau liên hệ việc Leo biết nấu mì cay.",
      "error": "Phản ứng/đoạn sau thuộc người nhận khác."
    },
    "route.knife.kohi": {
      "action": "Hoàn thành nhánh Dao và chảo tặng Kohi.",
      "result": "Kohi nhận đúng combo dao và chảo; đoạn sau liên hệ món phở và việc cô làm gãy thớt.",
      "error": "Phản ứng/đoạn sau thuộc người nhận khác."
    },
    "route.knife.shylvie": {
      "action": "Hoàn thành nhánh Dao và chảo tặng Shylvie.",
      "result": "Shylvie nhận đúng combo dao và chảo; đoạn sau giữ hướng Shylvie thích dụng cụ làm bếp.",
      "error": "Phản ứng/đoạn sau thuộc người nhận khác."
    },
    "route.knife.hakase": {
      "action": "Hoàn thành nhánh Dao và chảo tặng Hakase.",
      "result": "Hakase nhận đúng combo dao và chảo; đoạn sau liên hệ omurice trứng hắc ám và thịt Leviathan chiên xù.",
      "error": "Phản ứng/đoạn sau thuộc người nhận khác."
    },
    "route.scarf.leo": {
      "action": "Hoàn thành nhánh Khăn len tặng Leo.",
      "result": "Leo nhận khăn và vẫn khen dù chiếc khăn chưa đẹp. Các route khăn len dùng cảnh kết chung theo kịch bản.",
      "error": "Mô tả/đoạn kết bị biến thành hậu truyện riêng sai nhánh."
    },
    "route.scarf.kohi": {
      "action": "Hoàn thành nhánh Khăn len tặng Kohi.",
      "result": "Khăn có chi tiết hình hạt cà phê; Kohi vui vẻ nhận, quàng khăn và ôm Hải Quỳ. Các route khăn len dùng cảnh kết chung theo kịch bản.",
      "error": "Mô tả/đoạn kết bị biến thành hậu truyện riêng sai nhánh."
    },
    "route.scarf.shylvie": {
      "action": "Hoàn thành nhánh Khăn len tặng Shylvie.",
      "result": "Khăn dành cho Shylvie có chi tiết gợi tới chiếc khiên; phản ứng không bị thay bằng người khác. Các route khăn len dùng cảnh kết chung theo kịch bản.",
      "error": "Mô tả/đoạn kết bị biến thành hậu truyện riêng sai nhánh."
    },
    "route.scarf.hakase": {
      "action": "Hoàn thành nhánh Khăn len tặng Hakase.",
      "result": "Hakase nhận khăn; lời gợi ý cuối hướng tới khả năng tặng Hakase một quyển sách phép. Các route khăn len dùng cảnh kết chung theo kịch bản.",
      "error": "Mô tả/đoạn kết bị biến thành hậu truyện riêng sai nhánh."
    },
    "route.coffee.leo.regular": {
      "action": "Hoàn thành nhánh Máy pha cà phê → Leo / Cà phê thường.",
      "result": "Leo nhận máy pha cà phê; toàn bộ phần sau giữ đúng trường hợp Cà phê thường.",
      "error": "Phần sau quay sang loại cà phê hoặc người nhận khác."
    },
    "route.coffee.leo.atlantis": {
      "action": "Hoàn thành nhánh Máy pha cà phê → Leo / Cà phê Atlantis.",
      "result": "Leo nhận máy pha cà phê; toàn bộ phần sau giữ đúng trường hợp Cà phê Atlantis.",
      "error": "Phần sau quay sang loại cà phê hoặc người nhận khác."
    },
    "route.coffee.kohi.regular": {
      "action": "Hoàn thành nhánh Máy pha cà phê → Kohi / Cà phê thường.",
      "result": "Kohi nhận máy pha cà phê; toàn bộ phần sau giữ đúng trường hợp Cà phê thường.",
      "error": "Phần sau quay sang loại cà phê hoặc người nhận khác."
    },
    "route.coffee.kohi.atlantis": {
      "action": "Hoàn thành nhánh Máy pha cà phê → Kohi / Cà phê Atlantis.",
      "result": "Kohi nhận máy pha cà phê; toàn bộ phần sau giữ đúng trường hợp Cà phê Atlantis.",
      "error": "Phần sau quay sang loại cà phê hoặc người nhận khác."
    },
    "route.coffee.shylvie.regular": {
      "action": "Hoàn thành nhánh Máy pha cà phê → Shylvie / Cà phê thường.",
      "result": "Shylvie nhận máy pha cà phê; toàn bộ phần sau giữ đúng trường hợp Cà phê thường.",
      "error": "Phần sau quay sang loại cà phê hoặc người nhận khác."
    },
    "route.coffee.shylvie.atlantis": {
      "action": "Hoàn thành nhánh Máy pha cà phê → Shylvie / Cà phê Atlantis.",
      "result": "Shylvie nhận máy pha cà phê; toàn bộ phần sau giữ đúng trường hợp Cà phê Atlantis.",
      "error": "Phần sau quay sang loại cà phê hoặc người nhận khác."
    },
    "route.coffee.hakase.regular": {
      "action": "Hoàn thành nhánh Máy pha cà phê → Hakase / Cà phê thường.",
      "result": "Hakase nhận máy pha cà phê; toàn bộ phần sau giữ đúng trường hợp Cà phê thường.",
      "error": "Phần sau quay sang loại cà phê hoặc người nhận khác."
    },
    "route.coffee.hakase.atlantis": {
      "action": "Hoàn thành nhánh Máy pha cà phê → Hakase / Cà phê Atlantis.",
      "result": "Hakase nhận máy pha cà phê; toàn bộ phần sau giữ đúng trường hợp Cà phê Atlantis. Đoạn sau có hậu quả mạnh của món quà và gợi ý cuối trách Hải Quỳ vì lựa chọn này.",
      "error": "Phần sau quay sang loại cà phê hoặc người nhận khác."
    },
    "route.noodle.aira": {
      "action": "Hoàn thành nhánh mì cay: Tin Aira.",
      "result": "Aira chọn nguyên liệu và phụ trách hướng nấu; có đoạn mua nguyên liệu ở Map19 nhưng không vào hệ thống chọn quà.",
      "error": "Nội dung bị lẫn với nhánh còn lại hoặc hệ thống chọn quà siêu thị."
    },
    "route.noodle.self": {
      "action": "Hoàn thành nhánh mì cay: Không tin Aira.",
      "result": "Hải Quỳ ăn nhiều tô mì, phân tích công thức rồi tự chuẩn bị hướng nấu.",
      "error": "Nội dung bị lẫn với nhánh còn lại hoặc hệ thống chọn quà siêu thị."
    },
    "route.askleo.coffee": {
      "action": "Hoàn thành nhánh hỏi Leo → Tiệm cà phê.",
      "result": "Tới Map58 (Tiệm cà phê), mua Cà phê Luminous cho Kohi, dự tiệc và kết thúc bằng Lời gợi ý về cà phê Luminous.",
      "error": "Bị đưa tới cửa hàng khác hoặc phần sau dùng quà/người nhận sai."
    },
    "route.askleo.weapon": {
      "action": "Hoàn thành nhánh hỏi Leo → Cửa hàng vũ khí.",
      "result": "Tới Map59 (Cửa hàng vũ khí), mua Khiên cho Shylvie, dự tiệc và kết thúc bằng Lời gợi ý về chiếc khiên.",
      "error": "Bị đưa tới cửa hàng khác hoặc phần sau dùng quà/người nhận sai."
    },
    "route.askleo.magic": {
      "action": "Hoàn thành nhánh hỏi Leo → Tiệm ma pháp.",
      "result": "Tới Map57 (Tiệm ma pháp), mua Áo choàng luyện tàng hình cho Hakase, dự tiệc và kết thúc bằng Gợi ý có Drosalya.",
      "error": "Bị đưa tới cửa hàng khác hoặc phần sau dùng quà/người nhận sai."
    },
    "route.stone.leo": {
      "action": "Hoàn thành nhánh đá phong thủy → Leo / Purple Garnet.",
      "result": "Viên đá tím giúp giải trừ trạng thái bất lợi/độc tố và hỗ trợ tinh thần; Leo thấy mệt mỏi tan biến, sau đó đá vỡ và được làm chuông gió.",
      "error": "Ảnh đá, hiệu ứng, người nhận hoặc đoạn sau không khớp."
    },
    "route.stone.kohi": {
      "action": "Hoàn thành nhánh đá phong thủy → Kohi / Kim cương hình hạt cà phê.",
      "result": "Kohi vui mừng, cài viên kim cương lên tóc; gợi ý cuối nhắc công dụng xua đuổi ma quỷ bị Hải Quỳ bỏ qua.",
      "error": "Ảnh đá, hiệu ứng, người nhận hoặc đoạn sau không khớp."
    },
    "route.stone.shylvie": {
      "action": "Hoàn thành nhánh đá phong thủy → Shylvie / Congo Tourmaline.",
      "result": "Viên đá phát sáng và triệu hồi một chiếc khiên phép thuật trong suốt.",
      "error": "Ảnh đá, hiệu ứng, người nhận hoặc đoạn sau không khớp."
    },
    "route.stone.hakase": {
      "action": "Hoàn thành nhánh đá phong thủy → Hakase / Rainbow Fluorite.",
      "result": "Đá tri thức chứa ngẫu nhiên phép thuật; Hakase học các phép biến đổi và dùng đá lưu ma lực/thông tin.",
      "error": "Ảnh đá, hiệu ứng, người nhận hoặc đoạn sau không khớp."
    },
    "route.book.shylvie": {
      "action": "Chọn sách Phép thuật dịch chuyển nâng cao và mang ra quầy.",
      "result": "Sau khi chọn không đổi sang Ma Vương Cổ Đại; Shylvie nhận đúng sách; đoạn sau nói về phép hoán đổi/dịch chuyển và đúng gợi ý route.",
      "error": "Sách/người nhận/đoạn sau bị đổi."
    },
    "route.book.hakase": {
      "action": "Chọn sách Ma Vương Cổ Đại và mang ra quầy.",
      "result": "Sau khi chọn không đổi sang sách dịch chuyển; Hakase nhận đúng sách; đoạn sau nói về hấp thụ ma lực Ma Vương; vòng quà có váy và ốp lưng đúng thời điểm; gợi ý cuối đúng route.",
      "error": "Sách/người nhận/đoạn sau bị đổi."
    },
    "route.shopkeeper.explosion": {
      "action": "Nói chuyện với chủ tiệm trước khi chọn sách.",
      "result": "Tạo vật Vực Sâu phát nổ và chiếm hữu Hải Quỳ/Aira.",
      "error": "Không kích hoạt route hoặc lại đi vào chọn sách bình thường."
    },
    "route.shopkeeper.seal": {
      "action": "Theo dõi Hải Quỳ tự phong ấn và nhóm Wanderer đi tìm.",
      "result": "Hải Quỳ tự phong ấn trong lồng; nhóm Wanderer lần theo dấu vết và tới giải cứu.",
      "error": "Bỏ qua tự phong ấn/giải cứu."
    },
    "route.shopkeeper.cracks": {
      "action": "Quan sát lồng giam khi giải cứu.",
      "result": "Vết nứt đầu chậm/nặng, các vết sau nhanh dần tới khi vỡ.",
      "error": "Nhịp vỡ không tăng dần hoặc lồng vỡ quá sớm."
    },
    "route.shopkeeper.end": {
      "action": "Hoàn thành giải cứu.",
      "result": "Không mở khám phá tiệc và không đi qua Paulie rượt quái vật; đi tới gợi ý cuối và Title.",
      "error": "Nhảy vào route tiệc/rượt đuổi sai."
    },
    "routeinst.super-lock-leo.00": {
      "action": "Hoàn thành đoạn mở đầu tại Map3 (Văn phòng Silver Wing).",
      "result": "Hội thoại đúng thứ tự/người nói; nhân vật không bị kẹt khi tự đi.",
      "error": "Sai người nói, camera lệch hoặc nhân vật bị kẹt.",
      "syncTo": "open.map3"
    },
    "routeinst.super-lock-leo.01": {
      "action": "Nếu đi qua Map17 (Hành lang Silver Wing), đi hết hành lang tới thành phố.",
      "result": "Hải Quỳ tới đúng vị trí ở Map6; không tiếp tục tự chạy theo lộ trình cũ.",
      "error": "Sang map mới nhưng nhân vật vẫn tự chạy hoặc xuất hiện lệch vị trí.",
      "syncTo": "open.map17"
    },
    "routeinst.super-lock-leo.02": {
      "action": "Đi qua Map6 (Thành phố) và lên xe bus.",
      "result": "Camera bắt kịp Hải Quỳ và chuyển lên xe bus bình thường.",
      "error": "Camera bỏ lại nhân vật hoặc chuyển map sai.",
      "syncTo": "open.map6"
    },
    "routeinst.super-lock-leo.03": {
      "action": "Ở Map10 (Trong xe bus), xem hết đoạn suy nghĩ và chọn điểm đến.",
      "result": "Lời kể hiện bình thường; mỗi nút chọn dẫn đúng nơi ghi trên nút.",
      "error": "Màn hình đen vĩnh viễn, lóe sáng hoặc chọn một nơi nhưng tới nơi khác.",
      "syncTo": "open.map10"
    },
    "routeinst.super-lock-leo.04": {
      "action": "Khi vừa tới Map19 (Siêu thị), quan sát xe bus ngoài cửa.",
      "result": "Xe tiếp tục chạy sang trái rồi rời màn hình.",
      "error": "Xe đứng yên hoặc biến mất sai cách.",
      "syncTo": "super.bus"
    },
    "routeinst.super-lock-leo.05": {
      "action": "Xem cả bốn món quà trước khi quyết định.",
      "result": "Có thể xem đủ bốn món.",
      "error": "Một món không xem được hoặc route bị khóa quá sớm.",
      "syncTo": "super.view4"
    },
    "routeinst.super-lock-leo.06": {
      "action": "Chọn một món quà rồi thử đi lại trước khi thanh toán.",
      "result": "Hải Quỳ vẫn tự do đi lại; chỉ thanh toán khi chủ động ra cửa.",
      "error": "Game tự kéo Hải Quỳ tới quầy hoặc khóa điều khiển.",
      "syncTo": "super.freeaftergift"
    },
    "routeinst.super-lock-leo.07": {
      "action": "Sau thanh toán, chọn người nhận.",
      "result": "Bắt buộc chọn Leo, Kohi, Shylvie hoặc Hakase; không thoát khi chưa chọn.",
      "error": "Thoát màn hình chọn mà chưa chọn ai hoặc người nhận sai.",
      "syncTo": "super.recipient"
    },
    "routeinst.super-lock-leo.08": {
      "action": "Quan sát ảnh món quà sau khi chọn.",
      "result": "Ảnh đúng món vừa chọn.",
      "error": "Ảnh thuộc món khác.",
      "syncTo": "super.image"
    },
    "routeinst.super-lock-leo.09": {
      "action": "Theo route tới chuẩn bị quà, tiệc, sau tiệc và gợi ý cuối.",
      "result": "Món quà và người nhận giữ nguyên xuyên suốt.",
      "error": "Một đoạn bất kỳ đổi sang món/người khác.",
      "syncTo": "super.consistency"
    },
    "routeinst.super-lock-leo.10": {
      "action": "Hoàn thành nhánh Bộ phá khóa tặng Leo.",
      "result": "Leo nhận bộ phá khóa và về sau dùng nó mở cửa cứu Hải Quỳ bị kẹt. Lời gợi ý cuối nhắc món quà kỳ lạ đã cứu tình huống.",
      "error": "Phản ứng/hậu truyện/gợi ý thuộc người nhận khác.",
      "syncTo": "route.lockpick.leo"
    },
    "routeinst.super-lock-leo.11": {
      "action": "Xem đoạn Hải Quỳ đặt quà rồi ngủ.",
      "result": "Hải Quỳ ngủ trước rồi mới thức dậy.",
      "error": "Cảnh bị bỏ qua hoặc thứ tự đảo.",
      "syncTo": "prep.sleep"
    },
    "routeinst.super-lock-leo.12": {
      "action": "Xem trọn cảnh thử trang phục.",
      "result": "Các bộ đồ chạy đúng thứ tự; chỉ đổi sang đồ Giáng sinh sau bộ cuối.",
      "error": "Sprite đổi quá sớm hoặc lóe sai hình khi màn hình tối.",
      "syncTo": "prep.outfit"
    },
    "routeinst.super-lock-leo.13": {
      "action": "Chờ cảnh chuẩn bị kết thúc.",
      "result": "Màn hình sáng trở lại và câu chuyện tiếp tục.",
      "error": "Màn hình tối vĩnh viễn hoặc lóe sáng bất thường.",
      "syncTo": "prep.light"
    },
    "routeinst.super-lock-leo.14": {
      "action": "Đi vào Map38 (Văn phòng Wanderer trong tiệc Giáng sinh).",
      "result": "Phần mở đầu của bữa tiệc khớp route hiện tại.",
      "error": "Thoại/ảnh của route khác xuất hiện.",
      "syncTo": "party.arrival"
    },
    "routeinst.super-lock-leo.15": {
      "action": "Tới đoạn được tự do khám phá trong tiệc.",
      "result": "Có thể đi lại, vào khu vực phụ và nói chuyện với các thành viên.",
      "error": "Màn hình còn đen hoặc không điều khiển được Hải Quỳ.",
      "syncTo": "party.free"
    },
    "routeinst.super-lock-leo.16": {
      "action": "Thử mở ném tuyết từ phần khám phá tự do.",
      "result": "Có thể thách đấu Shylvie, Kohi, Leo hoặc Hakase và quay lại bữa tiệc.",
      "error": "Minigame không mở hoặc quay về sai trạng thái.",
      "syncTo": "party.snow"
    },
    "routeinst.super-lock-leo.17": {
      "action": "Chọn tiếp tục bữa tiệc.",
      "result": "Cảnh trao quà chạy đúng một lần rồi chuyển sang phần sau của route.",
      "error": "Scene lặp, crash hoặc tiếp tục sai route.",
      "syncTo": "party.continue"
    },
    "routeinst.super-lock-kohi.00": {
      "action": "Hoàn thành đoạn mở đầu tại Map3 (Văn phòng Silver Wing).",
      "result": "Hội thoại đúng thứ tự/người nói; nhân vật không bị kẹt khi tự đi.",
      "error": "Sai người nói, camera lệch hoặc nhân vật bị kẹt.",
      "syncTo": "open.map3"
    },
    "routeinst.super-lock-kohi.01": {
      "action": "Nếu đi qua Map17 (Hành lang Silver Wing), đi hết hành lang tới thành phố.",
      "result": "Hải Quỳ tới đúng vị trí ở Map6; không tiếp tục tự chạy theo lộ trình cũ.",
      "error": "Sang map mới nhưng nhân vật vẫn tự chạy hoặc xuất hiện lệch vị trí.",
      "syncTo": "open.map17"
    },
    "routeinst.super-lock-kohi.02": {
      "action": "Đi qua Map6 (Thành phố) và lên xe bus.",
      "result": "Camera bắt kịp Hải Quỳ và chuyển lên xe bus bình thường.",
      "error": "Camera bỏ lại nhân vật hoặc chuyển map sai.",
      "syncTo": "open.map6"
    },
    "routeinst.super-lock-kohi.03": {
      "action": "Ở Map10 (Trong xe bus), xem hết đoạn suy nghĩ và chọn điểm đến.",
      "result": "Lời kể hiện bình thường; mỗi nút chọn dẫn đúng nơi ghi trên nút.",
      "error": "Màn hình đen vĩnh viễn, lóe sáng hoặc chọn một nơi nhưng tới nơi khác.",
      "syncTo": "open.map10"
    },
    "routeinst.super-lock-kohi.04": {
      "action": "Khi vừa tới Map19 (Siêu thị), quan sát xe bus ngoài cửa.",
      "result": "Xe tiếp tục chạy sang trái rồi rời màn hình.",
      "error": "Xe đứng yên hoặc biến mất sai cách.",
      "syncTo": "super.bus"
    },
    "routeinst.super-lock-kohi.05": {
      "action": "Xem cả bốn món quà trước khi quyết định.",
      "result": "Có thể xem đủ bốn món.",
      "error": "Một món không xem được hoặc route bị khóa quá sớm.",
      "syncTo": "super.view4"
    },
    "routeinst.super-lock-kohi.06": {
      "action": "Chọn một món quà rồi thử đi lại trước khi thanh toán.",
      "result": "Hải Quỳ vẫn tự do đi lại; chỉ thanh toán khi chủ động ra cửa.",
      "error": "Game tự kéo Hải Quỳ tới quầy hoặc khóa điều khiển.",
      "syncTo": "super.freeaftergift"
    },
    "routeinst.super-lock-kohi.07": {
      "action": "Sau thanh toán, chọn người nhận.",
      "result": "Bắt buộc chọn Leo, Kohi, Shylvie hoặc Hakase; không thoát khi chưa chọn.",
      "error": "Thoát màn hình chọn mà chưa chọn ai hoặc người nhận sai.",
      "syncTo": "super.recipient"
    },
    "routeinst.super-lock-kohi.08": {
      "action": "Quan sát ảnh món quà sau khi chọn.",
      "result": "Ảnh đúng món vừa chọn.",
      "error": "Ảnh thuộc món khác.",
      "syncTo": "super.image"
    },
    "routeinst.super-lock-kohi.09": {
      "action": "Theo route tới chuẩn bị quà, tiệc, sau tiệc và gợi ý cuối.",
      "result": "Món quà và người nhận giữ nguyên xuyên suốt.",
      "error": "Một đoạn bất kỳ đổi sang món/người khác.",
      "syncTo": "super.consistency"
    },
    "routeinst.super-lock-kohi.10": {
      "action": "Hoàn thành nhánh Bộ phá khóa tặng Kohi.",
      "result": "Kohi nhận bộ phá khóa. Đoạn sau chủ ý chuyển sang chuyện máy pha cà phê. Không coi việc chuyển chủ đề máy pha cà phê là đi nhầm route.",
      "error": "Phản ứng/hậu truyện/gợi ý thuộc người nhận khác.",
      "syncTo": "route.lockpick.kohi"
    },
    "routeinst.super-lock-kohi.11": {
      "action": "Xem đoạn Hải Quỳ đặt quà rồi ngủ.",
      "result": "Hải Quỳ ngủ trước rồi mới thức dậy.",
      "error": "Cảnh bị bỏ qua hoặc thứ tự đảo.",
      "syncTo": "prep.sleep"
    },
    "routeinst.super-lock-kohi.12": {
      "action": "Xem trọn cảnh thử trang phục.",
      "result": "Các bộ đồ chạy đúng thứ tự; chỉ đổi sang đồ Giáng sinh sau bộ cuối.",
      "error": "Sprite đổi quá sớm hoặc lóe sai hình khi màn hình tối.",
      "syncTo": "prep.outfit"
    },
    "routeinst.super-lock-kohi.13": {
      "action": "Chờ cảnh chuẩn bị kết thúc.",
      "result": "Màn hình sáng trở lại và câu chuyện tiếp tục.",
      "error": "Màn hình tối vĩnh viễn hoặc lóe sáng bất thường.",
      "syncTo": "prep.light"
    },
    "routeinst.super-lock-kohi.14": {
      "action": "Đi vào Map38 (Văn phòng Wanderer trong tiệc Giáng sinh).",
      "result": "Phần mở đầu của bữa tiệc khớp route hiện tại.",
      "error": "Thoại/ảnh của route khác xuất hiện.",
      "syncTo": "party.arrival"
    },
    "routeinst.super-lock-kohi.15": {
      "action": "Tới đoạn được tự do khám phá trong tiệc.",
      "result": "Có thể đi lại, vào khu vực phụ và nói chuyện với các thành viên.",
      "error": "Màn hình còn đen hoặc không điều khiển được Hải Quỳ.",
      "syncTo": "party.free"
    },
    "routeinst.super-lock-kohi.16": {
      "action": "Thử mở ném tuyết từ phần khám phá tự do.",
      "result": "Có thể thách đấu Shylvie, Kohi, Leo hoặc Hakase và quay lại bữa tiệc.",
      "error": "Minigame không mở hoặc quay về sai trạng thái.",
      "syncTo": "party.snow"
    },
    "routeinst.super-lock-kohi.17": {
      "action": "Chọn tiếp tục bữa tiệc.",
      "result": "Cảnh trao quà chạy đúng một lần rồi chuyển sang phần sau của route.",
      "error": "Scene lặp, crash hoặc tiếp tục sai route.",
      "syncTo": "party.continue"
    },
    "routeinst.super-lock-shylvie.00": {
      "action": "Hoàn thành đoạn mở đầu tại Map3 (Văn phòng Silver Wing).",
      "result": "Hội thoại đúng thứ tự/người nói; nhân vật không bị kẹt khi tự đi.",
      "error": "Sai người nói, camera lệch hoặc nhân vật bị kẹt.",
      "syncTo": "open.map3"
    },
    "routeinst.super-lock-shylvie.01": {
      "action": "Nếu đi qua Map17 (Hành lang Silver Wing), đi hết hành lang tới thành phố.",
      "result": "Hải Quỳ tới đúng vị trí ở Map6; không tiếp tục tự chạy theo lộ trình cũ.",
      "error": "Sang map mới nhưng nhân vật vẫn tự chạy hoặc xuất hiện lệch vị trí.",
      "syncTo": "open.map17"
    },
    "routeinst.super-lock-shylvie.02": {
      "action": "Đi qua Map6 (Thành phố) và lên xe bus.",
      "result": "Camera bắt kịp Hải Quỳ và chuyển lên xe bus bình thường.",
      "error": "Camera bỏ lại nhân vật hoặc chuyển map sai.",
      "syncTo": "open.map6"
    },
    "routeinst.super-lock-shylvie.03": {
      "action": "Ở Map10 (Trong xe bus), xem hết đoạn suy nghĩ và chọn điểm đến.",
      "result": "Lời kể hiện bình thường; mỗi nút chọn dẫn đúng nơi ghi trên nút.",
      "error": "Màn hình đen vĩnh viễn, lóe sáng hoặc chọn một nơi nhưng tới nơi khác.",
      "syncTo": "open.map10"
    },
    "routeinst.super-lock-shylvie.04": {
      "action": "Khi vừa tới Map19 (Siêu thị), quan sát xe bus ngoài cửa.",
      "result": "Xe tiếp tục chạy sang trái rồi rời màn hình.",
      "error": "Xe đứng yên hoặc biến mất sai cách.",
      "syncTo": "super.bus"
    },
    "routeinst.super-lock-shylvie.05": {
      "action": "Xem cả bốn món quà trước khi quyết định.",
      "result": "Có thể xem đủ bốn món.",
      "error": "Một món không xem được hoặc route bị khóa quá sớm.",
      "syncTo": "super.view4"
    },
    "routeinst.super-lock-shylvie.06": {
      "action": "Chọn một món quà rồi thử đi lại trước khi thanh toán.",
      "result": "Hải Quỳ vẫn tự do đi lại; chỉ thanh toán khi chủ động ra cửa.",
      "error": "Game tự kéo Hải Quỳ tới quầy hoặc khóa điều khiển.",
      "syncTo": "super.freeaftergift"
    },
    "routeinst.super-lock-shylvie.07": {
      "action": "Sau thanh toán, chọn người nhận.",
      "result": "Bắt buộc chọn Leo, Kohi, Shylvie hoặc Hakase; không thoát khi chưa chọn.",
      "error": "Thoát màn hình chọn mà chưa chọn ai hoặc người nhận sai.",
      "syncTo": "super.recipient"
    },
    "routeinst.super-lock-shylvie.08": {
      "action": "Quan sát ảnh món quà sau khi chọn.",
      "result": "Ảnh đúng món vừa chọn.",
      "error": "Ảnh thuộc món khác.",
      "syncTo": "super.image"
    },
    "routeinst.super-lock-shylvie.09": {
      "action": "Theo route tới chuẩn bị quà, tiệc, sau tiệc và gợi ý cuối.",
      "result": "Món quà và người nhận giữ nguyên xuyên suốt.",
      "error": "Một đoạn bất kỳ đổi sang món/người khác.",
      "syncTo": "super.consistency"
    },
    "routeinst.super-lock-shylvie.10": {
      "action": "Hoàn thành nhánh Bộ phá khóa tặng Shylvie.",
      "result": "Shylvie nhận bộ phá khóa rồi nâng cấp thành dụng cụ phá phép. Đoạn sau có rắc rối với nhóm đầu ổ khóa.",
      "error": "Phản ứng/hậu truyện/gợi ý thuộc người nhận khác.",
      "syncTo": "route.lockpick.shylvie"
    },
    "routeinst.super-lock-shylvie.11": {
      "action": "Xem đoạn Hải Quỳ đặt quà rồi ngủ.",
      "result": "Hải Quỳ ngủ trước rồi mới thức dậy.",
      "error": "Cảnh bị bỏ qua hoặc thứ tự đảo.",
      "syncTo": "prep.sleep"
    },
    "routeinst.super-lock-shylvie.12": {
      "action": "Xem trọn cảnh thử trang phục.",
      "result": "Các bộ đồ chạy đúng thứ tự; chỉ đổi sang đồ Giáng sinh sau bộ cuối.",
      "error": "Sprite đổi quá sớm hoặc lóe sai hình khi màn hình tối.",
      "syncTo": "prep.outfit"
    },
    "routeinst.super-lock-shylvie.13": {
      "action": "Chờ cảnh chuẩn bị kết thúc.",
      "result": "Màn hình sáng trở lại và câu chuyện tiếp tục.",
      "error": "Màn hình tối vĩnh viễn hoặc lóe sáng bất thường.",
      "syncTo": "prep.light"
    },
    "routeinst.super-lock-shylvie.14": {
      "action": "Đi vào Map38 (Văn phòng Wanderer trong tiệc Giáng sinh).",
      "result": "Phần mở đầu của bữa tiệc khớp route hiện tại.",
      "error": "Thoại/ảnh của route khác xuất hiện.",
      "syncTo": "party.arrival"
    },
    "routeinst.super-lock-shylvie.15": {
      "action": "Tới đoạn được tự do khám phá trong tiệc.",
      "result": "Có thể đi lại, vào khu vực phụ và nói chuyện với các thành viên.",
      "error": "Màn hình còn đen hoặc không điều khiển được Hải Quỳ.",
      "syncTo": "party.free"
    },
    "routeinst.super-lock-shylvie.16": {
      "action": "Thử mở ném tuyết từ phần khám phá tự do.",
      "result": "Có thể thách đấu Shylvie, Kohi, Leo hoặc Hakase và quay lại bữa tiệc.",
      "error": "Minigame không mở hoặc quay về sai trạng thái.",
      "syncTo": "party.snow"
    },
    "routeinst.super-lock-shylvie.17": {
      "action": "Chọn tiếp tục bữa tiệc.",
      "result": "Cảnh trao quà chạy đúng một lần rồi chuyển sang phần sau của route.",
      "error": "Scene lặp, crash hoặc tiếp tục sai route.",
      "syncTo": "party.continue"
    },
    "routeinst.super-lock-hakase.00": {
      "action": "Hoàn thành đoạn mở đầu tại Map3 (Văn phòng Silver Wing).",
      "result": "Hội thoại đúng thứ tự/người nói; nhân vật không bị kẹt khi tự đi.",
      "error": "Sai người nói, camera lệch hoặc nhân vật bị kẹt.",
      "syncTo": "open.map3"
    },
    "routeinst.super-lock-hakase.01": {
      "action": "Nếu đi qua Map17 (Hành lang Silver Wing), đi hết hành lang tới thành phố.",
      "result": "Hải Quỳ tới đúng vị trí ở Map6; không tiếp tục tự chạy theo lộ trình cũ.",
      "error": "Sang map mới nhưng nhân vật vẫn tự chạy hoặc xuất hiện lệch vị trí.",
      "syncTo": "open.map17"
    },
    "routeinst.super-lock-hakase.02": {
      "action": "Đi qua Map6 (Thành phố) và lên xe bus.",
      "result": "Camera bắt kịp Hải Quỳ và chuyển lên xe bus bình thường.",
      "error": "Camera bỏ lại nhân vật hoặc chuyển map sai.",
      "syncTo": "open.map6"
    },
    "routeinst.super-lock-hakase.03": {
      "action": "Ở Map10 (Trong xe bus), xem hết đoạn suy nghĩ và chọn điểm đến.",
      "result": "Lời kể hiện bình thường; mỗi nút chọn dẫn đúng nơi ghi trên nút.",
      "error": "Màn hình đen vĩnh viễn, lóe sáng hoặc chọn một nơi nhưng tới nơi khác.",
      "syncTo": "open.map10"
    },
    "routeinst.super-lock-hakase.04": {
      "action": "Khi vừa tới Map19 (Siêu thị), quan sát xe bus ngoài cửa.",
      "result": "Xe tiếp tục chạy sang trái rồi rời màn hình.",
      "error": "Xe đứng yên hoặc biến mất sai cách.",
      "syncTo": "super.bus"
    },
    "routeinst.super-lock-hakase.05": {
      "action": "Xem cả bốn món quà trước khi quyết định.",
      "result": "Có thể xem đủ bốn món.",
      "error": "Một món không xem được hoặc route bị khóa quá sớm.",
      "syncTo": "super.view4"
    },
    "routeinst.super-lock-hakase.06": {
      "action": "Chọn một món quà rồi thử đi lại trước khi thanh toán.",
      "result": "Hải Quỳ vẫn tự do đi lại; chỉ thanh toán khi chủ động ra cửa.",
      "error": "Game tự kéo Hải Quỳ tới quầy hoặc khóa điều khiển.",
      "syncTo": "super.freeaftergift"
    },
    "routeinst.super-lock-hakase.07": {
      "action": "Sau thanh toán, chọn người nhận.",
      "result": "Bắt buộc chọn Leo, Kohi, Shylvie hoặc Hakase; không thoát khi chưa chọn.",
      "error": "Thoát màn hình chọn mà chưa chọn ai hoặc người nhận sai.",
      "syncTo": "super.recipient"
    },
    "routeinst.super-lock-hakase.08": {
      "action": "Quan sát ảnh món quà sau khi chọn.",
      "result": "Ảnh đúng món vừa chọn.",
      "error": "Ảnh thuộc món khác.",
      "syncTo": "super.image"
    },
    "routeinst.super-lock-hakase.09": {
      "action": "Theo route tới chuẩn bị quà, tiệc, sau tiệc và gợi ý cuối.",
      "result": "Món quà và người nhận giữ nguyên xuyên suốt.",
      "error": "Một đoạn bất kỳ đổi sang món/người khác.",
      "syncTo": "super.consistency"
    },
    "routeinst.super-lock-hakase.10": {
      "action": "Hoàn thành nhánh Bộ phá khóa tặng Hakase.",
      "result": "Hakase nhận bộ phá khóa và luyện mở khóa. Đoạn sau Hakase bị cảnh sát hiểu nhầm là trộm.",
      "error": "Phản ứng/hậu truyện/gợi ý thuộc người nhận khác.",
      "syncTo": "route.lockpick.hakase"
    },
    "routeinst.super-lock-hakase.11": {
      "action": "Xem đoạn Hải Quỳ đặt quà rồi ngủ.",
      "result": "Hải Quỳ ngủ trước rồi mới thức dậy.",
      "error": "Cảnh bị bỏ qua hoặc thứ tự đảo.",
      "syncTo": "prep.sleep"
    },
    "routeinst.super-lock-hakase.12": {
      "action": "Xem trọn cảnh thử trang phục.",
      "result": "Các bộ đồ chạy đúng thứ tự; chỉ đổi sang đồ Giáng sinh sau bộ cuối.",
      "error": "Sprite đổi quá sớm hoặc lóe sai hình khi màn hình tối.",
      "syncTo": "prep.outfit"
    },
    "routeinst.super-lock-hakase.13": {
      "action": "Chờ cảnh chuẩn bị kết thúc.",
      "result": "Màn hình sáng trở lại và câu chuyện tiếp tục.",
      "error": "Màn hình tối vĩnh viễn hoặc lóe sáng bất thường.",
      "syncTo": "prep.light"
    },
    "routeinst.super-lock-hakase.14": {
      "action": "Đi vào Map38 (Văn phòng Wanderer trong tiệc Giáng sinh).",
      "result": "Phần mở đầu của bữa tiệc khớp route hiện tại.",
      "error": "Thoại/ảnh của route khác xuất hiện.",
      "syncTo": "party.arrival"
    },
    "routeinst.super-lock-hakase.15": {
      "action": "Tới đoạn được tự do khám phá trong tiệc.",
      "result": "Có thể đi lại, vào khu vực phụ và nói chuyện với các thành viên.",
      "error": "Màn hình còn đen hoặc không điều khiển được Hải Quỳ.",
      "syncTo": "party.free"
    },
    "routeinst.super-lock-hakase.16": {
      "action": "Thử mở ném tuyết từ phần khám phá tự do.",
      "result": "Có thể thách đấu Shylvie, Kohi, Leo hoặc Hakase và quay lại bữa tiệc.",
      "error": "Minigame không mở hoặc quay về sai trạng thái.",
      "syncTo": "party.snow"
    },
    "routeinst.super-lock-hakase.17": {
      "action": "Chọn tiếp tục bữa tiệc.",
      "result": "Cảnh trao quà chạy đúng một lần rồi chuyển sang phần sau của route.",
      "error": "Scene lặp, crash hoặc tiếp tục sai route.",
      "syncTo": "party.continue"
    },
    "routeinst.super-knife-leo.00": {
      "action": "Hoàn thành đoạn mở đầu tại Map3 (Văn phòng Silver Wing).",
      "result": "Hội thoại đúng thứ tự/người nói; nhân vật không bị kẹt khi tự đi.",
      "error": "Sai người nói, camera lệch hoặc nhân vật bị kẹt.",
      "syncTo": "open.map3"
    },
    "routeinst.super-knife-leo.01": {
      "action": "Nếu đi qua Map17 (Hành lang Silver Wing), đi hết hành lang tới thành phố.",
      "result": "Hải Quỳ tới đúng vị trí ở Map6; không tiếp tục tự chạy theo lộ trình cũ.",
      "error": "Sang map mới nhưng nhân vật vẫn tự chạy hoặc xuất hiện lệch vị trí.",
      "syncTo": "open.map17"
    },
    "routeinst.super-knife-leo.02": {
      "action": "Đi qua Map6 (Thành phố) và lên xe bus.",
      "result": "Camera bắt kịp Hải Quỳ và chuyển lên xe bus bình thường.",
      "error": "Camera bỏ lại nhân vật hoặc chuyển map sai.",
      "syncTo": "open.map6"
    },
    "routeinst.super-knife-leo.03": {
      "action": "Ở Map10 (Trong xe bus), xem hết đoạn suy nghĩ và chọn điểm đến.",
      "result": "Lời kể hiện bình thường; mỗi nút chọn dẫn đúng nơi ghi trên nút.",
      "error": "Màn hình đen vĩnh viễn, lóe sáng hoặc chọn một nơi nhưng tới nơi khác.",
      "syncTo": "open.map10"
    },
    "routeinst.super-knife-leo.04": {
      "action": "Khi vừa tới Map19 (Siêu thị), quan sát xe bus ngoài cửa.",
      "result": "Xe tiếp tục chạy sang trái rồi rời màn hình.",
      "error": "Xe đứng yên hoặc biến mất sai cách.",
      "syncTo": "super.bus"
    },
    "routeinst.super-knife-leo.05": {
      "action": "Xem cả bốn món quà trước khi quyết định.",
      "result": "Có thể xem đủ bốn món.",
      "error": "Một món không xem được hoặc route bị khóa quá sớm.",
      "syncTo": "super.view4"
    },
    "routeinst.super-knife-leo.06": {
      "action": "Chọn một món quà rồi thử đi lại trước khi thanh toán.",
      "result": "Hải Quỳ vẫn tự do đi lại; chỉ thanh toán khi chủ động ra cửa.",
      "error": "Game tự kéo Hải Quỳ tới quầy hoặc khóa điều khiển.",
      "syncTo": "super.freeaftergift"
    },
    "routeinst.super-knife-leo.07": {
      "action": "Sau thanh toán, chọn người nhận.",
      "result": "Bắt buộc chọn Leo, Kohi, Shylvie hoặc Hakase; không thoát khi chưa chọn.",
      "error": "Thoát màn hình chọn mà chưa chọn ai hoặc người nhận sai.",
      "syncTo": "super.recipient"
    },
    "routeinst.super-knife-leo.08": {
      "action": "Quan sát ảnh món quà sau khi chọn.",
      "result": "Ảnh đúng món vừa chọn.",
      "error": "Ảnh thuộc món khác.",
      "syncTo": "super.image"
    },
    "routeinst.super-knife-leo.09": {
      "action": "Theo route tới chuẩn bị quà, tiệc, sau tiệc và gợi ý cuối.",
      "result": "Món quà và người nhận giữ nguyên xuyên suốt.",
      "error": "Một đoạn bất kỳ đổi sang món/người khác.",
      "syncTo": "super.consistency"
    },
    "routeinst.super-knife-leo.10": {
      "action": "Hoàn thành nhánh Dao và chảo tặng Leo.",
      "result": "Leo nhận đúng combo dao và chảo; đoạn sau liên hệ việc Leo biết nấu mì cay.",
      "error": "Phản ứng/đoạn sau thuộc người nhận khác.",
      "syncTo": "route.knife.leo"
    },
    "routeinst.super-knife-leo.11": {
      "action": "Xem đoạn Hải Quỳ đặt quà rồi ngủ.",
      "result": "Hải Quỳ ngủ trước rồi mới thức dậy.",
      "error": "Cảnh bị bỏ qua hoặc thứ tự đảo.",
      "syncTo": "prep.sleep"
    },
    "routeinst.super-knife-leo.12": {
      "action": "Xem trọn cảnh thử trang phục.",
      "result": "Các bộ đồ chạy đúng thứ tự; chỉ đổi sang đồ Giáng sinh sau bộ cuối.",
      "error": "Sprite đổi quá sớm hoặc lóe sai hình khi màn hình tối.",
      "syncTo": "prep.outfit"
    },
    "routeinst.super-knife-leo.13": {
      "action": "Chờ cảnh chuẩn bị kết thúc.",
      "result": "Màn hình sáng trở lại và câu chuyện tiếp tục.",
      "error": "Màn hình tối vĩnh viễn hoặc lóe sáng bất thường.",
      "syncTo": "prep.light"
    },
    "routeinst.super-knife-leo.14": {
      "action": "Đi vào Map38 (Văn phòng Wanderer trong tiệc Giáng sinh).",
      "result": "Phần mở đầu của bữa tiệc khớp route hiện tại.",
      "error": "Thoại/ảnh của route khác xuất hiện.",
      "syncTo": "party.arrival"
    },
    "routeinst.super-knife-leo.15": {
      "action": "Tới đoạn được tự do khám phá trong tiệc.",
      "result": "Có thể đi lại, vào khu vực phụ và nói chuyện với các thành viên.",
      "error": "Màn hình còn đen hoặc không điều khiển được Hải Quỳ.",
      "syncTo": "party.free"
    },
    "routeinst.super-knife-leo.16": {
      "action": "Thử mở ném tuyết từ phần khám phá tự do.",
      "result": "Có thể thách đấu Shylvie, Kohi, Leo hoặc Hakase và quay lại bữa tiệc.",
      "error": "Minigame không mở hoặc quay về sai trạng thái.",
      "syncTo": "party.snow"
    },
    "routeinst.super-knife-leo.17": {
      "action": "Chọn tiếp tục bữa tiệc.",
      "result": "Cảnh trao quà chạy đúng một lần rồi chuyển sang phần sau của route.",
      "error": "Scene lặp, crash hoặc tiếp tục sai route.",
      "syncTo": "party.continue"
    },
    "routeinst.super-knife-kohi.00": {
      "action": "Hoàn thành đoạn mở đầu tại Map3 (Văn phòng Silver Wing).",
      "result": "Hội thoại đúng thứ tự/người nói; nhân vật không bị kẹt khi tự đi.",
      "error": "Sai người nói, camera lệch hoặc nhân vật bị kẹt.",
      "syncTo": "open.map3"
    },
    "routeinst.super-knife-kohi.01": {
      "action": "Nếu đi qua Map17 (Hành lang Silver Wing), đi hết hành lang tới thành phố.",
      "result": "Hải Quỳ tới đúng vị trí ở Map6; không tiếp tục tự chạy theo lộ trình cũ.",
      "error": "Sang map mới nhưng nhân vật vẫn tự chạy hoặc xuất hiện lệch vị trí.",
      "syncTo": "open.map17"
    },
    "routeinst.super-knife-kohi.02": {
      "action": "Đi qua Map6 (Thành phố) và lên xe bus.",
      "result": "Camera bắt kịp Hải Quỳ và chuyển lên xe bus bình thường.",
      "error": "Camera bỏ lại nhân vật hoặc chuyển map sai.",
      "syncTo": "open.map6"
    },
    "routeinst.super-knife-kohi.03": {
      "action": "Ở Map10 (Trong xe bus), xem hết đoạn suy nghĩ và chọn điểm đến.",
      "result": "Lời kể hiện bình thường; mỗi nút chọn dẫn đúng nơi ghi trên nút.",
      "error": "Màn hình đen vĩnh viễn, lóe sáng hoặc chọn một nơi nhưng tới nơi khác.",
      "syncTo": "open.map10"
    },
    "routeinst.super-knife-kohi.04": {
      "action": "Khi vừa tới Map19 (Siêu thị), quan sát xe bus ngoài cửa.",
      "result": "Xe tiếp tục chạy sang trái rồi rời màn hình.",
      "error": "Xe đứng yên hoặc biến mất sai cách.",
      "syncTo": "super.bus"
    },
    "routeinst.super-knife-kohi.05": {
      "action": "Xem cả bốn món quà trước khi quyết định.",
      "result": "Có thể xem đủ bốn món.",
      "error": "Một món không xem được hoặc route bị khóa quá sớm.",
      "syncTo": "super.view4"
    },
    "routeinst.super-knife-kohi.06": {
      "action": "Chọn một món quà rồi thử đi lại trước khi thanh toán.",
      "result": "Hải Quỳ vẫn tự do đi lại; chỉ thanh toán khi chủ động ra cửa.",
      "error": "Game tự kéo Hải Quỳ tới quầy hoặc khóa điều khiển.",
      "syncTo": "super.freeaftergift"
    },
    "routeinst.super-knife-kohi.07": {
      "action": "Sau thanh toán, chọn người nhận.",
      "result": "Bắt buộc chọn Leo, Kohi, Shylvie hoặc Hakase; không thoát khi chưa chọn.",
      "error": "Thoát màn hình chọn mà chưa chọn ai hoặc người nhận sai.",
      "syncTo": "super.recipient"
    },
    "routeinst.super-knife-kohi.08": {
      "action": "Quan sát ảnh món quà sau khi chọn.",
      "result": "Ảnh đúng món vừa chọn.",
      "error": "Ảnh thuộc món khác.",
      "syncTo": "super.image"
    },
    "routeinst.super-knife-kohi.09": {
      "action": "Theo route tới chuẩn bị quà, tiệc, sau tiệc và gợi ý cuối.",
      "result": "Món quà và người nhận giữ nguyên xuyên suốt.",
      "error": "Một đoạn bất kỳ đổi sang món/người khác.",
      "syncTo": "super.consistency"
    },
    "routeinst.super-knife-kohi.10": {
      "action": "Hoàn thành nhánh Dao và chảo tặng Kohi.",
      "result": "Kohi nhận đúng combo dao và chảo; đoạn sau liên hệ món phở và việc cô làm gãy thớt.",
      "error": "Phản ứng/đoạn sau thuộc người nhận khác.",
      "syncTo": "route.knife.kohi"
    },
    "routeinst.super-knife-kohi.11": {
      "action": "Xem đoạn Hải Quỳ đặt quà rồi ngủ.",
      "result": "Hải Quỳ ngủ trước rồi mới thức dậy.",
      "error": "Cảnh bị bỏ qua hoặc thứ tự đảo.",
      "syncTo": "prep.sleep"
    },
    "routeinst.super-knife-kohi.12": {
      "action": "Xem trọn cảnh thử trang phục.",
      "result": "Các bộ đồ chạy đúng thứ tự; chỉ đổi sang đồ Giáng sinh sau bộ cuối.",
      "error": "Sprite đổi quá sớm hoặc lóe sai hình khi màn hình tối.",
      "syncTo": "prep.outfit"
    },
    "routeinst.super-knife-kohi.13": {
      "action": "Chờ cảnh chuẩn bị kết thúc.",
      "result": "Màn hình sáng trở lại và câu chuyện tiếp tục.",
      "error": "Màn hình tối vĩnh viễn hoặc lóe sáng bất thường.",
      "syncTo": "prep.light"
    },
    "routeinst.super-knife-kohi.14": {
      "action": "Đi vào Map38 (Văn phòng Wanderer trong tiệc Giáng sinh).",
      "result": "Phần mở đầu của bữa tiệc khớp route hiện tại.",
      "error": "Thoại/ảnh của route khác xuất hiện.",
      "syncTo": "party.arrival"
    },
    "routeinst.super-knife-kohi.15": {
      "action": "Tới đoạn được tự do khám phá trong tiệc.",
      "result": "Có thể đi lại, vào khu vực phụ và nói chuyện với các thành viên.",
      "error": "Màn hình còn đen hoặc không điều khiển được Hải Quỳ.",
      "syncTo": "party.free"
    },
    "routeinst.super-knife-kohi.16": {
      "action": "Thử mở ném tuyết từ phần khám phá tự do.",
      "result": "Có thể thách đấu Shylvie, Kohi, Leo hoặc Hakase và quay lại bữa tiệc.",
      "error": "Minigame không mở hoặc quay về sai trạng thái.",
      "syncTo": "party.snow"
    },
    "routeinst.super-knife-kohi.17": {
      "action": "Chọn tiếp tục bữa tiệc.",
      "result": "Cảnh trao quà chạy đúng một lần rồi chuyển sang phần sau của route.",
      "error": "Scene lặp, crash hoặc tiếp tục sai route.",
      "syncTo": "party.continue"
    },
    "routeinst.super-knife-shylvie.00": {
      "action": "Hoàn thành đoạn mở đầu tại Map3 (Văn phòng Silver Wing).",
      "result": "Hội thoại đúng thứ tự/người nói; nhân vật không bị kẹt khi tự đi.",
      "error": "Sai người nói, camera lệch hoặc nhân vật bị kẹt.",
      "syncTo": "open.map3"
    },
    "routeinst.super-knife-shylvie.01": {
      "action": "Nếu đi qua Map17 (Hành lang Silver Wing), đi hết hành lang tới thành phố.",
      "result": "Hải Quỳ tới đúng vị trí ở Map6; không tiếp tục tự chạy theo lộ trình cũ.",
      "error": "Sang map mới nhưng nhân vật vẫn tự chạy hoặc xuất hiện lệch vị trí.",
      "syncTo": "open.map17"
    },
    "routeinst.super-knife-shylvie.02": {
      "action": "Đi qua Map6 (Thành phố) và lên xe bus.",
      "result": "Camera bắt kịp Hải Quỳ và chuyển lên xe bus bình thường.",
      "error": "Camera bỏ lại nhân vật hoặc chuyển map sai.",
      "syncTo": "open.map6"
    },
    "routeinst.super-knife-shylvie.03": {
      "action": "Ở Map10 (Trong xe bus), xem hết đoạn suy nghĩ và chọn điểm đến.",
      "result": "Lời kể hiện bình thường; mỗi nút chọn dẫn đúng nơi ghi trên nút.",
      "error": "Màn hình đen vĩnh viễn, lóe sáng hoặc chọn một nơi nhưng tới nơi khác.",
      "syncTo": "open.map10"
    },
    "routeinst.super-knife-shylvie.04": {
      "action": "Khi vừa tới Map19 (Siêu thị), quan sát xe bus ngoài cửa.",
      "result": "Xe tiếp tục chạy sang trái rồi rời màn hình.",
      "error": "Xe đứng yên hoặc biến mất sai cách.",
      "syncTo": "super.bus"
    },
    "routeinst.super-knife-shylvie.05": {
      "action": "Xem cả bốn món quà trước khi quyết định.",
      "result": "Có thể xem đủ bốn món.",
      "error": "Một món không xem được hoặc route bị khóa quá sớm.",
      "syncTo": "super.view4"
    },
    "routeinst.super-knife-shylvie.06": {
      "action": "Chọn một món quà rồi thử đi lại trước khi thanh toán.",
      "result": "Hải Quỳ vẫn tự do đi lại; chỉ thanh toán khi chủ động ra cửa.",
      "error": "Game tự kéo Hải Quỳ tới quầy hoặc khóa điều khiển.",
      "syncTo": "super.freeaftergift"
    },
    "routeinst.super-knife-shylvie.07": {
      "action": "Sau thanh toán, chọn người nhận.",
      "result": "Bắt buộc chọn Leo, Kohi, Shylvie hoặc Hakase; không thoát khi chưa chọn.",
      "error": "Thoát màn hình chọn mà chưa chọn ai hoặc người nhận sai.",
      "syncTo": "super.recipient"
    },
    "routeinst.super-knife-shylvie.08": {
      "action": "Quan sát ảnh món quà sau khi chọn.",
      "result": "Ảnh đúng món vừa chọn.",
      "error": "Ảnh thuộc món khác.",
      "syncTo": "super.image"
    },
    "routeinst.super-knife-shylvie.09": {
      "action": "Theo route tới chuẩn bị quà, tiệc, sau tiệc và gợi ý cuối.",
      "result": "Món quà và người nhận giữ nguyên xuyên suốt.",
      "error": "Một đoạn bất kỳ đổi sang món/người khác.",
      "syncTo": "super.consistency"
    },
    "routeinst.super-knife-shylvie.10": {
      "action": "Hoàn thành nhánh Dao và chảo tặng Shylvie.",
      "result": "Shylvie nhận đúng combo dao và chảo; đoạn sau giữ hướng Shylvie thích dụng cụ làm bếp.",
      "error": "Phản ứng/đoạn sau thuộc người nhận khác.",
      "syncTo": "route.knife.shylvie"
    },
    "routeinst.super-knife-shylvie.11": {
      "action": "Xem đoạn Hải Quỳ đặt quà rồi ngủ.",
      "result": "Hải Quỳ ngủ trước rồi mới thức dậy.",
      "error": "Cảnh bị bỏ qua hoặc thứ tự đảo.",
      "syncTo": "prep.sleep"
    },
    "routeinst.super-knife-shylvie.12": {
      "action": "Xem trọn cảnh thử trang phục.",
      "result": "Các bộ đồ chạy đúng thứ tự; chỉ đổi sang đồ Giáng sinh sau bộ cuối.",
      "error": "Sprite đổi quá sớm hoặc lóe sai hình khi màn hình tối.",
      "syncTo": "prep.outfit"
    },
    "routeinst.super-knife-shylvie.13": {
      "action": "Chờ cảnh chuẩn bị kết thúc.",
      "result": "Màn hình sáng trở lại và câu chuyện tiếp tục.",
      "error": "Màn hình tối vĩnh viễn hoặc lóe sáng bất thường.",
      "syncTo": "prep.light"
    },
    "routeinst.super-knife-shylvie.14": {
      "action": "Đi vào Map38 (Văn phòng Wanderer trong tiệc Giáng sinh).",
      "result": "Phần mở đầu của bữa tiệc khớp route hiện tại.",
      "error": "Thoại/ảnh của route khác xuất hiện.",
      "syncTo": "party.arrival"
    },
    "routeinst.super-knife-shylvie.15": {
      "action": "Tới đoạn được tự do khám phá trong tiệc.",
      "result": "Có thể đi lại, vào khu vực phụ và nói chuyện với các thành viên.",
      "error": "Màn hình còn đen hoặc không điều khiển được Hải Quỳ.",
      "syncTo": "party.free"
    },
    "routeinst.super-knife-shylvie.16": {
      "action": "Thử mở ném tuyết từ phần khám phá tự do.",
      "result": "Có thể thách đấu Shylvie, Kohi, Leo hoặc Hakase và quay lại bữa tiệc.",
      "error": "Minigame không mở hoặc quay về sai trạng thái.",
      "syncTo": "party.snow"
    },
    "routeinst.super-knife-shylvie.17": {
      "action": "Chọn tiếp tục bữa tiệc.",
      "result": "Cảnh trao quà chạy đúng một lần rồi chuyển sang phần sau của route.",
      "error": "Scene lặp, crash hoặc tiếp tục sai route.",
      "syncTo": "party.continue"
    },
    "routeinst.super-knife-hakase.00": {
      "action": "Hoàn thành đoạn mở đầu tại Map3 (Văn phòng Silver Wing).",
      "result": "Hội thoại đúng thứ tự/người nói; nhân vật không bị kẹt khi tự đi.",
      "error": "Sai người nói, camera lệch hoặc nhân vật bị kẹt.",
      "syncTo": "open.map3"
    },
    "routeinst.super-knife-hakase.01": {
      "action": "Nếu đi qua Map17 (Hành lang Silver Wing), đi hết hành lang tới thành phố.",
      "result": "Hải Quỳ tới đúng vị trí ở Map6; không tiếp tục tự chạy theo lộ trình cũ.",
      "error": "Sang map mới nhưng nhân vật vẫn tự chạy hoặc xuất hiện lệch vị trí.",
      "syncTo": "open.map17"
    },
    "routeinst.super-knife-hakase.02": {
      "action": "Đi qua Map6 (Thành phố) và lên xe bus.",
      "result": "Camera bắt kịp Hải Quỳ và chuyển lên xe bus bình thường.",
      "error": "Camera bỏ lại nhân vật hoặc chuyển map sai.",
      "syncTo": "open.map6"
    },
    "routeinst.super-knife-hakase.03": {
      "action": "Ở Map10 (Trong xe bus), xem hết đoạn suy nghĩ và chọn điểm đến.",
      "result": "Lời kể hiện bình thường; mỗi nút chọn dẫn đúng nơi ghi trên nút.",
      "error": "Màn hình đen vĩnh viễn, lóe sáng hoặc chọn một nơi nhưng tới nơi khác.",
      "syncTo": "open.map10"
    },
    "routeinst.super-knife-hakase.04": {
      "action": "Khi vừa tới Map19 (Siêu thị), quan sát xe bus ngoài cửa.",
      "result": "Xe tiếp tục chạy sang trái rồi rời màn hình.",
      "error": "Xe đứng yên hoặc biến mất sai cách.",
      "syncTo": "super.bus"
    },
    "routeinst.super-knife-hakase.05": {
      "action": "Xem cả bốn món quà trước khi quyết định.",
      "result": "Có thể xem đủ bốn món.",
      "error": "Một món không xem được hoặc route bị khóa quá sớm.",
      "syncTo": "super.view4"
    },
    "routeinst.super-knife-hakase.06": {
      "action": "Chọn một món quà rồi thử đi lại trước khi thanh toán.",
      "result": "Hải Quỳ vẫn tự do đi lại; chỉ thanh toán khi chủ động ra cửa.",
      "error": "Game tự kéo Hải Quỳ tới quầy hoặc khóa điều khiển.",
      "syncTo": "super.freeaftergift"
    },
    "routeinst.super-knife-hakase.07": {
      "action": "Sau thanh toán, chọn người nhận.",
      "result": "Bắt buộc chọn Leo, Kohi, Shylvie hoặc Hakase; không thoát khi chưa chọn.",
      "error": "Thoát màn hình chọn mà chưa chọn ai hoặc người nhận sai.",
      "syncTo": "super.recipient"
    },
    "routeinst.super-knife-hakase.08": {
      "action": "Quan sát ảnh món quà sau khi chọn.",
      "result": "Ảnh đúng món vừa chọn.",
      "error": "Ảnh thuộc món khác.",
      "syncTo": "super.image"
    },
    "routeinst.super-knife-hakase.09": {
      "action": "Theo route tới chuẩn bị quà, tiệc, sau tiệc và gợi ý cuối.",
      "result": "Món quà và người nhận giữ nguyên xuyên suốt.",
      "error": "Một đoạn bất kỳ đổi sang món/người khác.",
      "syncTo": "super.consistency"
    },
    "routeinst.super-knife-hakase.10": {
      "action": "Hoàn thành nhánh Dao và chảo tặng Hakase.",
      "result": "Hakase nhận đúng combo dao và chảo; đoạn sau liên hệ omurice trứng hắc ám và thịt Leviathan chiên xù.",
      "error": "Phản ứng/đoạn sau thuộc người nhận khác.",
      "syncTo": "route.knife.hakase"
    },
    "routeinst.super-knife-hakase.11": {
      "action": "Xem đoạn Hải Quỳ đặt quà rồi ngủ.",
      "result": "Hải Quỳ ngủ trước rồi mới thức dậy.",
      "error": "Cảnh bị bỏ qua hoặc thứ tự đảo.",
      "syncTo": "prep.sleep"
    },
    "routeinst.super-knife-hakase.12": {
      "action": "Xem trọn cảnh thử trang phục.",
      "result": "Các bộ đồ chạy đúng thứ tự; chỉ đổi sang đồ Giáng sinh sau bộ cuối.",
      "error": "Sprite đổi quá sớm hoặc lóe sai hình khi màn hình tối.",
      "syncTo": "prep.outfit"
    },
    "routeinst.super-knife-hakase.13": {
      "action": "Chờ cảnh chuẩn bị kết thúc.",
      "result": "Màn hình sáng trở lại và câu chuyện tiếp tục.",
      "error": "Màn hình tối vĩnh viễn hoặc lóe sáng bất thường.",
      "syncTo": "prep.light"
    },
    "routeinst.super-knife-hakase.14": {
      "action": "Đi vào Map38 (Văn phòng Wanderer trong tiệc Giáng sinh).",
      "result": "Phần mở đầu của bữa tiệc khớp route hiện tại.",
      "error": "Thoại/ảnh của route khác xuất hiện.",
      "syncTo": "party.arrival"
    },
    "routeinst.super-knife-hakase.15": {
      "action": "Tới đoạn được tự do khám phá trong tiệc.",
      "result": "Có thể đi lại, vào khu vực phụ và nói chuyện với các thành viên.",
      "error": "Màn hình còn đen hoặc không điều khiển được Hải Quỳ.",
      "syncTo": "party.free"
    },
    "routeinst.super-knife-hakase.16": {
      "action": "Thử mở ném tuyết từ phần khám phá tự do.",
      "result": "Có thể thách đấu Shylvie, Kohi, Leo hoặc Hakase và quay lại bữa tiệc.",
      "error": "Minigame không mở hoặc quay về sai trạng thái.",
      "syncTo": "party.snow"
    },
    "routeinst.super-knife-hakase.17": {
      "action": "Chọn tiếp tục bữa tiệc.",
      "result": "Cảnh trao quà chạy đúng một lần rồi chuyển sang phần sau của route.",
      "error": "Scene lặp, crash hoặc tiếp tục sai route.",
      "syncTo": "party.continue"
    },
    "routeinst.super-scarf-leo.00": {
      "action": "Hoàn thành đoạn mở đầu tại Map3 (Văn phòng Silver Wing).",
      "result": "Hội thoại đúng thứ tự/người nói; nhân vật không bị kẹt khi tự đi.",
      "error": "Sai người nói, camera lệch hoặc nhân vật bị kẹt.",
      "syncTo": "open.map3"
    },
    "routeinst.super-scarf-leo.01": {
      "action": "Nếu đi qua Map17 (Hành lang Silver Wing), đi hết hành lang tới thành phố.",
      "result": "Hải Quỳ tới đúng vị trí ở Map6; không tiếp tục tự chạy theo lộ trình cũ.",
      "error": "Sang map mới nhưng nhân vật vẫn tự chạy hoặc xuất hiện lệch vị trí.",
      "syncTo": "open.map17"
    },
    "routeinst.super-scarf-leo.02": {
      "action": "Đi qua Map6 (Thành phố) và lên xe bus.",
      "result": "Camera bắt kịp Hải Quỳ và chuyển lên xe bus bình thường.",
      "error": "Camera bỏ lại nhân vật hoặc chuyển map sai.",
      "syncTo": "open.map6"
    },
    "routeinst.super-scarf-leo.03": {
      "action": "Ở Map10 (Trong xe bus), xem hết đoạn suy nghĩ và chọn điểm đến.",
      "result": "Lời kể hiện bình thường; mỗi nút chọn dẫn đúng nơi ghi trên nút.",
      "error": "Màn hình đen vĩnh viễn, lóe sáng hoặc chọn một nơi nhưng tới nơi khác.",
      "syncTo": "open.map10"
    },
    "routeinst.super-scarf-leo.04": {
      "action": "Khi vừa tới Map19 (Siêu thị), quan sát xe bus ngoài cửa.",
      "result": "Xe tiếp tục chạy sang trái rồi rời màn hình.",
      "error": "Xe đứng yên hoặc biến mất sai cách.",
      "syncTo": "super.bus"
    },
    "routeinst.super-scarf-leo.05": {
      "action": "Xem cả bốn món quà trước khi quyết định.",
      "result": "Có thể xem đủ bốn món.",
      "error": "Một món không xem được hoặc route bị khóa quá sớm.",
      "syncTo": "super.view4"
    },
    "routeinst.super-scarf-leo.06": {
      "action": "Chọn một món quà rồi thử đi lại trước khi thanh toán.",
      "result": "Hải Quỳ vẫn tự do đi lại; chỉ thanh toán khi chủ động ra cửa.",
      "error": "Game tự kéo Hải Quỳ tới quầy hoặc khóa điều khiển.",
      "syncTo": "super.freeaftergift"
    },
    "routeinst.super-scarf-leo.07": {
      "action": "Sau thanh toán, chọn người nhận.",
      "result": "Bắt buộc chọn Leo, Kohi, Shylvie hoặc Hakase; không thoát khi chưa chọn.",
      "error": "Thoát màn hình chọn mà chưa chọn ai hoặc người nhận sai.",
      "syncTo": "super.recipient"
    },
    "routeinst.super-scarf-leo.08": {
      "action": "Quan sát ảnh món quà sau khi chọn.",
      "result": "Ảnh đúng món vừa chọn.",
      "error": "Ảnh thuộc món khác.",
      "syncTo": "super.image"
    },
    "routeinst.super-scarf-leo.09": {
      "action": "Theo route tới chuẩn bị quà, tiệc, sau tiệc và gợi ý cuối.",
      "result": "Món quà và người nhận giữ nguyên xuyên suốt.",
      "error": "Một đoạn bất kỳ đổi sang món/người khác.",
      "syncTo": "super.consistency"
    },
    "routeinst.super-scarf-leo.10": {
      "action": "Hoàn thành nhánh Khăn len tặng Leo.",
      "result": "Leo nhận khăn và vẫn khen dù chiếc khăn chưa đẹp. Các route khăn len dùng cảnh kết chung theo kịch bản.",
      "error": "Mô tả/đoạn kết bị biến thành hậu truyện riêng sai nhánh.",
      "syncTo": "route.scarf.leo"
    },
    "routeinst.super-scarf-leo.11": {
      "action": "Xem đoạn Hải Quỳ đặt quà rồi ngủ.",
      "result": "Hải Quỳ ngủ trước rồi mới thức dậy.",
      "error": "Cảnh bị bỏ qua hoặc thứ tự đảo.",
      "syncTo": "prep.sleep"
    },
    "routeinst.super-scarf-leo.12": {
      "action": "Xem trọn cảnh thử trang phục.",
      "result": "Các bộ đồ chạy đúng thứ tự; chỉ đổi sang đồ Giáng sinh sau bộ cuối.",
      "error": "Sprite đổi quá sớm hoặc lóe sai hình khi màn hình tối.",
      "syncTo": "prep.outfit"
    },
    "routeinst.super-scarf-leo.13": {
      "action": "Chờ cảnh chuẩn bị kết thúc.",
      "result": "Màn hình sáng trở lại và câu chuyện tiếp tục.",
      "error": "Màn hình tối vĩnh viễn hoặc lóe sáng bất thường.",
      "syncTo": "prep.light"
    },
    "routeinst.super-scarf-leo.14": {
      "action": "Đi vào Map38 (Văn phòng Wanderer trong tiệc Giáng sinh).",
      "result": "Phần mở đầu của bữa tiệc khớp route hiện tại.",
      "error": "Thoại/ảnh của route khác xuất hiện.",
      "syncTo": "party.arrival"
    },
    "routeinst.super-scarf-leo.15": {
      "action": "Tới đoạn được tự do khám phá trong tiệc.",
      "result": "Có thể đi lại, vào khu vực phụ và nói chuyện với các thành viên.",
      "error": "Màn hình còn đen hoặc không điều khiển được Hải Quỳ.",
      "syncTo": "party.free"
    },
    "routeinst.super-scarf-leo.16": {
      "action": "Thử mở ném tuyết từ phần khám phá tự do.",
      "result": "Có thể thách đấu Shylvie, Kohi, Leo hoặc Hakase và quay lại bữa tiệc.",
      "error": "Minigame không mở hoặc quay về sai trạng thái.",
      "syncTo": "party.snow"
    },
    "routeinst.super-scarf-leo.17": {
      "action": "Chọn tiếp tục bữa tiệc.",
      "result": "Cảnh trao quà chạy đúng một lần rồi chuyển sang phần sau của route.",
      "error": "Scene lặp, crash hoặc tiếp tục sai route.",
      "syncTo": "party.continue"
    },
    "routeinst.super-scarf-kohi.00": {
      "action": "Hoàn thành đoạn mở đầu tại Map3 (Văn phòng Silver Wing).",
      "result": "Hội thoại đúng thứ tự/người nói; nhân vật không bị kẹt khi tự đi.",
      "error": "Sai người nói, camera lệch hoặc nhân vật bị kẹt.",
      "syncTo": "open.map3"
    },
    "routeinst.super-scarf-kohi.01": {
      "action": "Nếu đi qua Map17 (Hành lang Silver Wing), đi hết hành lang tới thành phố.",
      "result": "Hải Quỳ tới đúng vị trí ở Map6; không tiếp tục tự chạy theo lộ trình cũ.",
      "error": "Sang map mới nhưng nhân vật vẫn tự chạy hoặc xuất hiện lệch vị trí.",
      "syncTo": "open.map17"
    },
    "routeinst.super-scarf-kohi.02": {
      "action": "Đi qua Map6 (Thành phố) và lên xe bus.",
      "result": "Camera bắt kịp Hải Quỳ và chuyển lên xe bus bình thường.",
      "error": "Camera bỏ lại nhân vật hoặc chuyển map sai.",
      "syncTo": "open.map6"
    },
    "routeinst.super-scarf-kohi.03": {
      "action": "Ở Map10 (Trong xe bus), xem hết đoạn suy nghĩ và chọn điểm đến.",
      "result": "Lời kể hiện bình thường; mỗi nút chọn dẫn đúng nơi ghi trên nút.",
      "error": "Màn hình đen vĩnh viễn, lóe sáng hoặc chọn một nơi nhưng tới nơi khác.",
      "syncTo": "open.map10"
    },
    "routeinst.super-scarf-kohi.04": {
      "action": "Khi vừa tới Map19 (Siêu thị), quan sát xe bus ngoài cửa.",
      "result": "Xe tiếp tục chạy sang trái rồi rời màn hình.",
      "error": "Xe đứng yên hoặc biến mất sai cách.",
      "syncTo": "super.bus"
    },
    "routeinst.super-scarf-kohi.05": {
      "action": "Xem cả bốn món quà trước khi quyết định.",
      "result": "Có thể xem đủ bốn món.",
      "error": "Một món không xem được hoặc route bị khóa quá sớm.",
      "syncTo": "super.view4"
    },
    "routeinst.super-scarf-kohi.06": {
      "action": "Chọn một món quà rồi thử đi lại trước khi thanh toán.",
      "result": "Hải Quỳ vẫn tự do đi lại; chỉ thanh toán khi chủ động ra cửa.",
      "error": "Game tự kéo Hải Quỳ tới quầy hoặc khóa điều khiển.",
      "syncTo": "super.freeaftergift"
    },
    "routeinst.super-scarf-kohi.07": {
      "action": "Sau thanh toán, chọn người nhận.",
      "result": "Bắt buộc chọn Leo, Kohi, Shylvie hoặc Hakase; không thoát khi chưa chọn.",
      "error": "Thoát màn hình chọn mà chưa chọn ai hoặc người nhận sai.",
      "syncTo": "super.recipient"
    },
    "routeinst.super-scarf-kohi.08": {
      "action": "Quan sát ảnh món quà sau khi chọn.",
      "result": "Ảnh đúng món vừa chọn.",
      "error": "Ảnh thuộc món khác.",
      "syncTo": "super.image"
    },
    "routeinst.super-scarf-kohi.09": {
      "action": "Theo route tới chuẩn bị quà, tiệc, sau tiệc và gợi ý cuối.",
      "result": "Món quà và người nhận giữ nguyên xuyên suốt.",
      "error": "Một đoạn bất kỳ đổi sang món/người khác.",
      "syncTo": "super.consistency"
    },
    "routeinst.super-scarf-kohi.10": {
      "action": "Hoàn thành nhánh Khăn len tặng Kohi.",
      "result": "Khăn có chi tiết hình hạt cà phê; Kohi vui vẻ nhận, quàng khăn và ôm Hải Quỳ. Các route khăn len dùng cảnh kết chung theo kịch bản.",
      "error": "Mô tả/đoạn kết bị biến thành hậu truyện riêng sai nhánh.",
      "syncTo": "route.scarf.kohi"
    },
    "routeinst.super-scarf-kohi.11": {
      "action": "Xem đoạn Hải Quỳ đặt quà rồi ngủ.",
      "result": "Hải Quỳ ngủ trước rồi mới thức dậy.",
      "error": "Cảnh bị bỏ qua hoặc thứ tự đảo.",
      "syncTo": "prep.sleep"
    },
    "routeinst.super-scarf-kohi.12": {
      "action": "Xem trọn cảnh thử trang phục.",
      "result": "Các bộ đồ chạy đúng thứ tự; chỉ đổi sang đồ Giáng sinh sau bộ cuối.",
      "error": "Sprite đổi quá sớm hoặc lóe sai hình khi màn hình tối.",
      "syncTo": "prep.outfit"
    },
    "routeinst.super-scarf-kohi.13": {
      "action": "Chờ cảnh chuẩn bị kết thúc.",
      "result": "Màn hình sáng trở lại và câu chuyện tiếp tục.",
      "error": "Màn hình tối vĩnh viễn hoặc lóe sáng bất thường.",
      "syncTo": "prep.light"
    },
    "routeinst.super-scarf-kohi.14": {
      "action": "Đi vào Map38 (Văn phòng Wanderer trong tiệc Giáng sinh).",
      "result": "Phần mở đầu của bữa tiệc khớp route hiện tại.",
      "error": "Thoại/ảnh của route khác xuất hiện.",
      "syncTo": "party.arrival"
    },
    "routeinst.super-scarf-kohi.15": {
      "action": "Tới đoạn được tự do khám phá trong tiệc.",
      "result": "Có thể đi lại, vào khu vực phụ và nói chuyện với các thành viên.",
      "error": "Màn hình còn đen hoặc không điều khiển được Hải Quỳ.",
      "syncTo": "party.free"
    },
    "routeinst.super-scarf-kohi.16": {
      "action": "Thử mở ném tuyết từ phần khám phá tự do.",
      "result": "Có thể thách đấu Shylvie, Kohi, Leo hoặc Hakase và quay lại bữa tiệc.",
      "error": "Minigame không mở hoặc quay về sai trạng thái.",
      "syncTo": "party.snow"
    },
    "routeinst.super-scarf-kohi.17": {
      "action": "Chọn tiếp tục bữa tiệc.",
      "result": "Cảnh trao quà chạy đúng một lần rồi chuyển sang phần sau của route.",
      "error": "Scene lặp, crash hoặc tiếp tục sai route.",
      "syncTo": "party.continue"
    },
    "routeinst.super-scarf-shylvie.00": {
      "action": "Hoàn thành đoạn mở đầu tại Map3 (Văn phòng Silver Wing).",
      "result": "Hội thoại đúng thứ tự/người nói; nhân vật không bị kẹt khi tự đi.",
      "error": "Sai người nói, camera lệch hoặc nhân vật bị kẹt.",
      "syncTo": "open.map3"
    },
    "routeinst.super-scarf-shylvie.01": {
      "action": "Nếu đi qua Map17 (Hành lang Silver Wing), đi hết hành lang tới thành phố.",
      "result": "Hải Quỳ tới đúng vị trí ở Map6; không tiếp tục tự chạy theo lộ trình cũ.",
      "error": "Sang map mới nhưng nhân vật vẫn tự chạy hoặc xuất hiện lệch vị trí.",
      "syncTo": "open.map17"
    },
    "routeinst.super-scarf-shylvie.02": {
      "action": "Đi qua Map6 (Thành phố) và lên xe bus.",
      "result": "Camera bắt kịp Hải Quỳ và chuyển lên xe bus bình thường.",
      "error": "Camera bỏ lại nhân vật hoặc chuyển map sai.",
      "syncTo": "open.map6"
    },
    "routeinst.super-scarf-shylvie.03": {
      "action": "Ở Map10 (Trong xe bus), xem hết đoạn suy nghĩ và chọn điểm đến.",
      "result": "Lời kể hiện bình thường; mỗi nút chọn dẫn đúng nơi ghi trên nút.",
      "error": "Màn hình đen vĩnh viễn, lóe sáng hoặc chọn một nơi nhưng tới nơi khác.",
      "syncTo": "open.map10"
    },
    "routeinst.super-scarf-shylvie.04": {
      "action": "Khi vừa tới Map19 (Siêu thị), quan sát xe bus ngoài cửa.",
      "result": "Xe tiếp tục chạy sang trái rồi rời màn hình.",
      "error": "Xe đứng yên hoặc biến mất sai cách.",
      "syncTo": "super.bus"
    },
    "routeinst.super-scarf-shylvie.05": {
      "action": "Xem cả bốn món quà trước khi quyết định.",
      "result": "Có thể xem đủ bốn món.",
      "error": "Một món không xem được hoặc route bị khóa quá sớm.",
      "syncTo": "super.view4"
    },
    "routeinst.super-scarf-shylvie.06": {
      "action": "Chọn một món quà rồi thử đi lại trước khi thanh toán.",
      "result": "Hải Quỳ vẫn tự do đi lại; chỉ thanh toán khi chủ động ra cửa.",
      "error": "Game tự kéo Hải Quỳ tới quầy hoặc khóa điều khiển.",
      "syncTo": "super.freeaftergift"
    },
    "routeinst.super-scarf-shylvie.07": {
      "action": "Sau thanh toán, chọn người nhận.",
      "result": "Bắt buộc chọn Leo, Kohi, Shylvie hoặc Hakase; không thoát khi chưa chọn.",
      "error": "Thoát màn hình chọn mà chưa chọn ai hoặc người nhận sai.",
      "syncTo": "super.recipient"
    },
    "routeinst.super-scarf-shylvie.08": {
      "action": "Quan sát ảnh món quà sau khi chọn.",
      "result": "Ảnh đúng món vừa chọn.",
      "error": "Ảnh thuộc món khác.",
      "syncTo": "super.image"
    },
    "routeinst.super-scarf-shylvie.09": {
      "action": "Theo route tới chuẩn bị quà, tiệc, sau tiệc và gợi ý cuối.",
      "result": "Món quà và người nhận giữ nguyên xuyên suốt.",
      "error": "Một đoạn bất kỳ đổi sang món/người khác.",
      "syncTo": "super.consistency"
    },
    "routeinst.super-scarf-shylvie.10": {
      "action": "Hoàn thành nhánh Khăn len tặng Shylvie.",
      "result": "Khăn dành cho Shylvie có chi tiết gợi tới chiếc khiên; phản ứng không bị thay bằng người khác. Các route khăn len dùng cảnh kết chung theo kịch bản.",
      "error": "Mô tả/đoạn kết bị biến thành hậu truyện riêng sai nhánh.",
      "syncTo": "route.scarf.shylvie"
    },
    "routeinst.super-scarf-shylvie.11": {
      "action": "Xem đoạn Hải Quỳ đặt quà rồi ngủ.",
      "result": "Hải Quỳ ngủ trước rồi mới thức dậy.",
      "error": "Cảnh bị bỏ qua hoặc thứ tự đảo.",
      "syncTo": "prep.sleep"
    },
    "routeinst.super-scarf-shylvie.12": {
      "action": "Xem trọn cảnh thử trang phục.",
      "result": "Các bộ đồ chạy đúng thứ tự; chỉ đổi sang đồ Giáng sinh sau bộ cuối.",
      "error": "Sprite đổi quá sớm hoặc lóe sai hình khi màn hình tối.",
      "syncTo": "prep.outfit"
    },
    "routeinst.super-scarf-shylvie.13": {
      "action": "Chờ cảnh chuẩn bị kết thúc.",
      "result": "Màn hình sáng trở lại và câu chuyện tiếp tục.",
      "error": "Màn hình tối vĩnh viễn hoặc lóe sáng bất thường.",
      "syncTo": "prep.light"
    },
    "routeinst.super-scarf-shylvie.14": {
      "action": "Đi vào Map38 (Văn phòng Wanderer trong tiệc Giáng sinh).",
      "result": "Phần mở đầu của bữa tiệc khớp route hiện tại.",
      "error": "Thoại/ảnh của route khác xuất hiện.",
      "syncTo": "party.arrival"
    },
    "routeinst.super-scarf-shylvie.15": {
      "action": "Tới đoạn được tự do khám phá trong tiệc.",
      "result": "Có thể đi lại, vào khu vực phụ và nói chuyện với các thành viên.",
      "error": "Màn hình còn đen hoặc không điều khiển được Hải Quỳ.",
      "syncTo": "party.free"
    },
    "routeinst.super-scarf-shylvie.16": {
      "action": "Thử mở ném tuyết từ phần khám phá tự do.",
      "result": "Có thể thách đấu Shylvie, Kohi, Leo hoặc Hakase và quay lại bữa tiệc.",
      "error": "Minigame không mở hoặc quay về sai trạng thái.",
      "syncTo": "party.snow"
    },
    "routeinst.super-scarf-shylvie.17": {
      "action": "Chọn tiếp tục bữa tiệc.",
      "result": "Cảnh trao quà chạy đúng một lần rồi chuyển sang phần sau của route.",
      "error": "Scene lặp, crash hoặc tiếp tục sai route.",
      "syncTo": "party.continue"
    },
    "routeinst.super-scarf-hakase.00": {
      "action": "Hoàn thành đoạn mở đầu tại Map3 (Văn phòng Silver Wing).",
      "result": "Hội thoại đúng thứ tự/người nói; nhân vật không bị kẹt khi tự đi.",
      "error": "Sai người nói, camera lệch hoặc nhân vật bị kẹt.",
      "syncTo": "open.map3"
    },
    "routeinst.super-scarf-hakase.01": {
      "action": "Nếu đi qua Map17 (Hành lang Silver Wing), đi hết hành lang tới thành phố.",
      "result": "Hải Quỳ tới đúng vị trí ở Map6; không tiếp tục tự chạy theo lộ trình cũ.",
      "error": "Sang map mới nhưng nhân vật vẫn tự chạy hoặc xuất hiện lệch vị trí.",
      "syncTo": "open.map17"
    },
    "routeinst.super-scarf-hakase.02": {
      "action": "Đi qua Map6 (Thành phố) và lên xe bus.",
      "result": "Camera bắt kịp Hải Quỳ và chuyển lên xe bus bình thường.",
      "error": "Camera bỏ lại nhân vật hoặc chuyển map sai.",
      "syncTo": "open.map6"
    },
    "routeinst.super-scarf-hakase.03": {
      "action": "Ở Map10 (Trong xe bus), xem hết đoạn suy nghĩ và chọn điểm đến.",
      "result": "Lời kể hiện bình thường; mỗi nút chọn dẫn đúng nơi ghi trên nút.",
      "error": "Màn hình đen vĩnh viễn, lóe sáng hoặc chọn một nơi nhưng tới nơi khác.",
      "syncTo": "open.map10"
    },
    "routeinst.super-scarf-hakase.04": {
      "action": "Khi vừa tới Map19 (Siêu thị), quan sát xe bus ngoài cửa.",
      "result": "Xe tiếp tục chạy sang trái rồi rời màn hình.",
      "error": "Xe đứng yên hoặc biến mất sai cách.",
      "syncTo": "super.bus"
    },
    "routeinst.super-scarf-hakase.05": {
      "action": "Xem cả bốn món quà trước khi quyết định.",
      "result": "Có thể xem đủ bốn món.",
      "error": "Một món không xem được hoặc route bị khóa quá sớm.",
      "syncTo": "super.view4"
    },
    "routeinst.super-scarf-hakase.06": {
      "action": "Chọn một món quà rồi thử đi lại trước khi thanh toán.",
      "result": "Hải Quỳ vẫn tự do đi lại; chỉ thanh toán khi chủ động ra cửa.",
      "error": "Game tự kéo Hải Quỳ tới quầy hoặc khóa điều khiển.",
      "syncTo": "super.freeaftergift"
    },
    "routeinst.super-scarf-hakase.07": {
      "action": "Sau thanh toán, chọn người nhận.",
      "result": "Bắt buộc chọn Leo, Kohi, Shylvie hoặc Hakase; không thoát khi chưa chọn.",
      "error": "Thoát màn hình chọn mà chưa chọn ai hoặc người nhận sai.",
      "syncTo": "super.recipient"
    },
    "routeinst.super-scarf-hakase.08": {
      "action": "Quan sát ảnh món quà sau khi chọn.",
      "result": "Ảnh đúng món vừa chọn.",
      "error": "Ảnh thuộc món khác.",
      "syncTo": "super.image"
    },
    "routeinst.super-scarf-hakase.09": {
      "action": "Theo route tới chuẩn bị quà, tiệc, sau tiệc và gợi ý cuối.",
      "result": "Món quà và người nhận giữ nguyên xuyên suốt.",
      "error": "Một đoạn bất kỳ đổi sang món/người khác.",
      "syncTo": "super.consistency"
    },
    "routeinst.super-scarf-hakase.10": {
      "action": "Hoàn thành nhánh Khăn len tặng Hakase.",
      "result": "Hakase nhận khăn; lời gợi ý cuối hướng tới khả năng tặng Hakase một quyển sách phép. Các route khăn len dùng cảnh kết chung theo kịch bản.",
      "error": "Mô tả/đoạn kết bị biến thành hậu truyện riêng sai nhánh.",
      "syncTo": "route.scarf.hakase"
    },
    "routeinst.super-scarf-hakase.11": {
      "action": "Xem đoạn Hải Quỳ đặt quà rồi ngủ.",
      "result": "Hải Quỳ ngủ trước rồi mới thức dậy.",
      "error": "Cảnh bị bỏ qua hoặc thứ tự đảo.",
      "syncTo": "prep.sleep"
    },
    "routeinst.super-scarf-hakase.12": {
      "action": "Xem trọn cảnh thử trang phục.",
      "result": "Các bộ đồ chạy đúng thứ tự; chỉ đổi sang đồ Giáng sinh sau bộ cuối.",
      "error": "Sprite đổi quá sớm hoặc lóe sai hình khi màn hình tối.",
      "syncTo": "prep.outfit"
    },
    "routeinst.super-scarf-hakase.13": {
      "action": "Chờ cảnh chuẩn bị kết thúc.",
      "result": "Màn hình sáng trở lại và câu chuyện tiếp tục.",
      "error": "Màn hình tối vĩnh viễn hoặc lóe sáng bất thường.",
      "syncTo": "prep.light"
    },
    "routeinst.super-scarf-hakase.14": {
      "action": "Đi vào Map38 (Văn phòng Wanderer trong tiệc Giáng sinh).",
      "result": "Phần mở đầu của bữa tiệc khớp route hiện tại.",
      "error": "Thoại/ảnh của route khác xuất hiện.",
      "syncTo": "party.arrival"
    },
    "routeinst.super-scarf-hakase.15": {
      "action": "Tới đoạn được tự do khám phá trong tiệc.",
      "result": "Có thể đi lại, vào khu vực phụ và nói chuyện với các thành viên.",
      "error": "Màn hình còn đen hoặc không điều khiển được Hải Quỳ.",
      "syncTo": "party.free"
    },
    "routeinst.super-scarf-hakase.16": {
      "action": "Thử mở ném tuyết từ phần khám phá tự do.",
      "result": "Có thể thách đấu Shylvie, Kohi, Leo hoặc Hakase và quay lại bữa tiệc.",
      "error": "Minigame không mở hoặc quay về sai trạng thái.",
      "syncTo": "party.snow"
    },
    "routeinst.super-scarf-hakase.17": {
      "action": "Chọn tiếp tục bữa tiệc.",
      "result": "Cảnh trao quà chạy đúng một lần rồi chuyển sang phần sau của route.",
      "error": "Scene lặp, crash hoặc tiếp tục sai route.",
      "syncTo": "party.continue"
    },
    "routeinst.super-coffee-leo-regular.00": {
      "action": "Hoàn thành đoạn mở đầu tại Map3 (Văn phòng Silver Wing).",
      "result": "Hội thoại đúng thứ tự/người nói; nhân vật không bị kẹt khi tự đi.",
      "error": "Sai người nói, camera lệch hoặc nhân vật bị kẹt.",
      "syncTo": "open.map3"
    },
    "routeinst.super-coffee-leo-regular.01": {
      "action": "Nếu đi qua Map17 (Hành lang Silver Wing), đi hết hành lang tới thành phố.",
      "result": "Hải Quỳ tới đúng vị trí ở Map6; không tiếp tục tự chạy theo lộ trình cũ.",
      "error": "Sang map mới nhưng nhân vật vẫn tự chạy hoặc xuất hiện lệch vị trí.",
      "syncTo": "open.map17"
    },
    "routeinst.super-coffee-leo-regular.02": {
      "action": "Đi qua Map6 (Thành phố) và lên xe bus.",
      "result": "Camera bắt kịp Hải Quỳ và chuyển lên xe bus bình thường.",
      "error": "Camera bỏ lại nhân vật hoặc chuyển map sai.",
      "syncTo": "open.map6"
    },
    "routeinst.super-coffee-leo-regular.03": {
      "action": "Ở Map10 (Trong xe bus), xem hết đoạn suy nghĩ và chọn điểm đến.",
      "result": "Lời kể hiện bình thường; mỗi nút chọn dẫn đúng nơi ghi trên nút.",
      "error": "Màn hình đen vĩnh viễn, lóe sáng hoặc chọn một nơi nhưng tới nơi khác.",
      "syncTo": "open.map10"
    },
    "routeinst.super-coffee-leo-regular.04": {
      "action": "Khi vừa tới Map19 (Siêu thị), quan sát xe bus ngoài cửa.",
      "result": "Xe tiếp tục chạy sang trái rồi rời màn hình.",
      "error": "Xe đứng yên hoặc biến mất sai cách.",
      "syncTo": "super.bus"
    },
    "routeinst.super-coffee-leo-regular.05": {
      "action": "Xem cả bốn món quà trước khi quyết định.",
      "result": "Có thể xem đủ bốn món.",
      "error": "Một món không xem được hoặc route bị khóa quá sớm.",
      "syncTo": "super.view4"
    },
    "routeinst.super-coffee-leo-regular.06": {
      "action": "Chọn một món quà rồi thử đi lại trước khi thanh toán.",
      "result": "Hải Quỳ vẫn tự do đi lại; chỉ thanh toán khi chủ động ra cửa.",
      "error": "Game tự kéo Hải Quỳ tới quầy hoặc khóa điều khiển.",
      "syncTo": "super.freeaftergift"
    },
    "routeinst.super-coffee-leo-regular.07": {
      "action": "Sau thanh toán, chọn người nhận.",
      "result": "Bắt buộc chọn Leo, Kohi, Shylvie hoặc Hakase; không thoát khi chưa chọn.",
      "error": "Thoát màn hình chọn mà chưa chọn ai hoặc người nhận sai.",
      "syncTo": "super.recipient"
    },
    "routeinst.super-coffee-leo-regular.08": {
      "action": "Quan sát ảnh món quà sau khi chọn.",
      "result": "Ảnh đúng món vừa chọn.",
      "error": "Ảnh thuộc món khác.",
      "syncTo": "super.image"
    },
    "routeinst.super-coffee-leo-regular.09": {
      "action": "Theo route tới chuẩn bị quà, tiệc, sau tiệc và gợi ý cuối.",
      "result": "Món quà và người nhận giữ nguyên xuyên suốt.",
      "error": "Một đoạn bất kỳ đổi sang món/người khác.",
      "syncTo": "super.consistency"
    },
    "routeinst.super-coffee-leo-regular.10": {
      "action": "Tới Map40 (Chuyến xuống Atlantis lấy cà phê).",
      "result": "Màn hình đang đen; lời kể dùng hộp thoại bình thường. Sau tin quái vật/mái nhà và việc quán hết cà phê mới hiện lựa chọn.",
      "error": "Lời thoại nổi sai kiểu, lựa chọn xuất hiện quá sớm hoặc route bỏ qua đoạn này.",
      "syncTo": "coffee.map40"
    },
    "routeinst.super-coffee-leo-regular.11": {
      "action": "Chọn dùng cà phê thường.",
      "result": "Bỏ qua minigame và tiếp tục route với nội dung cà phê thường.",
      "error": "Route vẫn ghi nhận cà phê Atlantis hoặc bắt buộc vào minigame.",
      "syncTo": "coffee.regular"
    },
    "routeinst.super-coffee-leo-regular.12": {
      "action": "Hoàn thành nhánh Máy pha cà phê → Leo / Cà phê thường.",
      "result": "Leo nhận máy pha cà phê; toàn bộ phần sau giữ đúng trường hợp Cà phê thường.",
      "error": "Phần sau quay sang loại cà phê hoặc người nhận khác.",
      "syncTo": "route.coffee.leo.regular"
    },
    "routeinst.super-coffee-leo-regular.13": {
      "action": "Xem đoạn Hải Quỳ đặt quà rồi ngủ.",
      "result": "Hải Quỳ ngủ trước rồi mới thức dậy.",
      "error": "Cảnh bị bỏ qua hoặc thứ tự đảo.",
      "syncTo": "prep.sleep"
    },
    "routeinst.super-coffee-leo-regular.14": {
      "action": "Xem trọn cảnh thử trang phục.",
      "result": "Các bộ đồ chạy đúng thứ tự; chỉ đổi sang đồ Giáng sinh sau bộ cuối.",
      "error": "Sprite đổi quá sớm hoặc lóe sai hình khi màn hình tối.",
      "syncTo": "prep.outfit"
    },
    "routeinst.super-coffee-leo-regular.15": {
      "action": "Chờ cảnh chuẩn bị kết thúc.",
      "result": "Màn hình sáng trở lại và câu chuyện tiếp tục.",
      "error": "Màn hình tối vĩnh viễn hoặc lóe sáng bất thường.",
      "syncTo": "prep.light"
    },
    "routeinst.super-coffee-leo-regular.16": {
      "action": "Đi vào Map38 (Văn phòng Wanderer trong tiệc Giáng sinh).",
      "result": "Phần mở đầu của bữa tiệc khớp route hiện tại.",
      "error": "Thoại/ảnh của route khác xuất hiện.",
      "syncTo": "party.arrival"
    },
    "routeinst.super-coffee-leo-regular.17": {
      "action": "Tới đoạn được tự do khám phá trong tiệc.",
      "result": "Có thể đi lại, vào khu vực phụ và nói chuyện với các thành viên.",
      "error": "Màn hình còn đen hoặc không điều khiển được Hải Quỳ.",
      "syncTo": "party.free"
    },
    "routeinst.super-coffee-leo-regular.18": {
      "action": "Thử mở ném tuyết từ phần khám phá tự do.",
      "result": "Có thể thách đấu Shylvie, Kohi, Leo hoặc Hakase và quay lại bữa tiệc.",
      "error": "Minigame không mở hoặc quay về sai trạng thái.",
      "syncTo": "party.snow"
    },
    "routeinst.super-coffee-leo-regular.19": {
      "action": "Chọn tiếp tục bữa tiệc.",
      "result": "Cảnh trao quà chạy đúng một lần rồi chuyển sang phần sau của route.",
      "error": "Scene lặp, crash hoặc tiếp tục sai route.",
      "syncTo": "party.continue"
    },
    "routeinst.super-coffee-leo-atlantis.00": {
      "action": "Hoàn thành đoạn mở đầu tại Map3 (Văn phòng Silver Wing).",
      "result": "Hội thoại đúng thứ tự/người nói; nhân vật không bị kẹt khi tự đi.",
      "error": "Sai người nói, camera lệch hoặc nhân vật bị kẹt.",
      "syncTo": "open.map3"
    },
    "routeinst.super-coffee-leo-atlantis.01": {
      "action": "Nếu đi qua Map17 (Hành lang Silver Wing), đi hết hành lang tới thành phố.",
      "result": "Hải Quỳ tới đúng vị trí ở Map6; không tiếp tục tự chạy theo lộ trình cũ.",
      "error": "Sang map mới nhưng nhân vật vẫn tự chạy hoặc xuất hiện lệch vị trí.",
      "syncTo": "open.map17"
    },
    "routeinst.super-coffee-leo-atlantis.02": {
      "action": "Đi qua Map6 (Thành phố) và lên xe bus.",
      "result": "Camera bắt kịp Hải Quỳ và chuyển lên xe bus bình thường.",
      "error": "Camera bỏ lại nhân vật hoặc chuyển map sai.",
      "syncTo": "open.map6"
    },
    "routeinst.super-coffee-leo-atlantis.03": {
      "action": "Ở Map10 (Trong xe bus), xem hết đoạn suy nghĩ và chọn điểm đến.",
      "result": "Lời kể hiện bình thường; mỗi nút chọn dẫn đúng nơi ghi trên nút.",
      "error": "Màn hình đen vĩnh viễn, lóe sáng hoặc chọn một nơi nhưng tới nơi khác.",
      "syncTo": "open.map10"
    },
    "routeinst.super-coffee-leo-atlantis.04": {
      "action": "Khi vừa tới Map19 (Siêu thị), quan sát xe bus ngoài cửa.",
      "result": "Xe tiếp tục chạy sang trái rồi rời màn hình.",
      "error": "Xe đứng yên hoặc biến mất sai cách.",
      "syncTo": "super.bus"
    },
    "routeinst.super-coffee-leo-atlantis.05": {
      "action": "Xem cả bốn món quà trước khi quyết định.",
      "result": "Có thể xem đủ bốn món.",
      "error": "Một món không xem được hoặc route bị khóa quá sớm.",
      "syncTo": "super.view4"
    },
    "routeinst.super-coffee-leo-atlantis.06": {
      "action": "Chọn một món quà rồi thử đi lại trước khi thanh toán.",
      "result": "Hải Quỳ vẫn tự do đi lại; chỉ thanh toán khi chủ động ra cửa.",
      "error": "Game tự kéo Hải Quỳ tới quầy hoặc khóa điều khiển.",
      "syncTo": "super.freeaftergift"
    },
    "routeinst.super-coffee-leo-atlantis.07": {
      "action": "Sau thanh toán, chọn người nhận.",
      "result": "Bắt buộc chọn Leo, Kohi, Shylvie hoặc Hakase; không thoát khi chưa chọn.",
      "error": "Thoát màn hình chọn mà chưa chọn ai hoặc người nhận sai.",
      "syncTo": "super.recipient"
    },
    "routeinst.super-coffee-leo-atlantis.08": {
      "action": "Quan sát ảnh món quà sau khi chọn.",
      "result": "Ảnh đúng món vừa chọn.",
      "error": "Ảnh thuộc món khác.",
      "syncTo": "super.image"
    },
    "routeinst.super-coffee-leo-atlantis.09": {
      "action": "Theo route tới chuẩn bị quà, tiệc, sau tiệc và gợi ý cuối.",
      "result": "Món quà và người nhận giữ nguyên xuyên suốt.",
      "error": "Một đoạn bất kỳ đổi sang món/người khác.",
      "syncTo": "super.consistency"
    },
    "routeinst.super-coffee-leo-atlantis.10": {
      "action": "Tới Map40 (Chuyến xuống Atlantis lấy cà phê).",
      "result": "Màn hình đang đen; lời kể dùng hộp thoại bình thường. Sau tin quái vật/mái nhà và việc quán hết cà phê mới hiện lựa chọn.",
      "error": "Lời thoại nổi sai kiểu, lựa chọn xuất hiện quá sớm hoặc route bỏ qua đoạn này.",
      "syncTo": "coffee.map40"
    },
    "routeinst.super-coffee-leo-atlantis.11": {
      "action": "Chọn đi câu tôm và lấy đủ mười cà phê Atlantis.",
      "result": "Chỉ khi đủ mười mới tiếp tục; phần sau ghi nhận cà phê Atlantis.",
      "error": "Thoát sớm vẫn được tính đủ hoặc route quay về nội dung cà phê thường.",
      "syncTo": "coffee.atlantis"
    },
    "routeinst.super-coffee-leo-atlantis.12": {
      "action": "Hoàn thành nhánh Máy pha cà phê → Leo / Cà phê Atlantis.",
      "result": "Leo nhận máy pha cà phê; toàn bộ phần sau giữ đúng trường hợp Cà phê Atlantis.",
      "error": "Phần sau quay sang loại cà phê hoặc người nhận khác.",
      "syncTo": "route.coffee.leo.atlantis"
    },
    "routeinst.super-coffee-leo-atlantis.13": {
      "action": "Xem đoạn Hải Quỳ đặt quà rồi ngủ.",
      "result": "Hải Quỳ ngủ trước rồi mới thức dậy.",
      "error": "Cảnh bị bỏ qua hoặc thứ tự đảo.",
      "syncTo": "prep.sleep"
    },
    "routeinst.super-coffee-leo-atlantis.14": {
      "action": "Xem trọn cảnh thử trang phục.",
      "result": "Các bộ đồ chạy đúng thứ tự; chỉ đổi sang đồ Giáng sinh sau bộ cuối.",
      "error": "Sprite đổi quá sớm hoặc lóe sai hình khi màn hình tối.",
      "syncTo": "prep.outfit"
    },
    "routeinst.super-coffee-leo-atlantis.15": {
      "action": "Chờ cảnh chuẩn bị kết thúc.",
      "result": "Màn hình sáng trở lại và câu chuyện tiếp tục.",
      "error": "Màn hình tối vĩnh viễn hoặc lóe sáng bất thường.",
      "syncTo": "prep.light"
    },
    "routeinst.super-coffee-leo-atlantis.16": {
      "action": "Đi vào Map38 (Văn phòng Wanderer trong tiệc Giáng sinh).",
      "result": "Phần mở đầu của bữa tiệc khớp route hiện tại.",
      "error": "Thoại/ảnh của route khác xuất hiện.",
      "syncTo": "party.arrival"
    },
    "routeinst.super-coffee-leo-atlantis.17": {
      "action": "Tới đoạn được tự do khám phá trong tiệc.",
      "result": "Có thể đi lại, vào khu vực phụ và nói chuyện với các thành viên.",
      "error": "Màn hình còn đen hoặc không điều khiển được Hải Quỳ.",
      "syncTo": "party.free"
    },
    "routeinst.super-coffee-leo-atlantis.18": {
      "action": "Thử mở ném tuyết từ phần khám phá tự do.",
      "result": "Có thể thách đấu Shylvie, Kohi, Leo hoặc Hakase và quay lại bữa tiệc.",
      "error": "Minigame không mở hoặc quay về sai trạng thái.",
      "syncTo": "party.snow"
    },
    "routeinst.super-coffee-leo-atlantis.19": {
      "action": "Chọn tiếp tục bữa tiệc.",
      "result": "Cảnh trao quà chạy đúng một lần rồi chuyển sang phần sau của route.",
      "error": "Scene lặp, crash hoặc tiếp tục sai route.",
      "syncTo": "party.continue"
    },
    "routeinst.super-coffee-kohi-regular.00": {
      "action": "Hoàn thành đoạn mở đầu tại Map3 (Văn phòng Silver Wing).",
      "result": "Hội thoại đúng thứ tự/người nói; nhân vật không bị kẹt khi tự đi.",
      "error": "Sai người nói, camera lệch hoặc nhân vật bị kẹt.",
      "syncTo": "open.map3"
    },
    "routeinst.super-coffee-kohi-regular.01": {
      "action": "Nếu đi qua Map17 (Hành lang Silver Wing), đi hết hành lang tới thành phố.",
      "result": "Hải Quỳ tới đúng vị trí ở Map6; không tiếp tục tự chạy theo lộ trình cũ.",
      "error": "Sang map mới nhưng nhân vật vẫn tự chạy hoặc xuất hiện lệch vị trí.",
      "syncTo": "open.map17"
    },
    "routeinst.super-coffee-kohi-regular.02": {
      "action": "Đi qua Map6 (Thành phố) và lên xe bus.",
      "result": "Camera bắt kịp Hải Quỳ và chuyển lên xe bus bình thường.",
      "error": "Camera bỏ lại nhân vật hoặc chuyển map sai.",
      "syncTo": "open.map6"
    },
    "routeinst.super-coffee-kohi-regular.03": {
      "action": "Ở Map10 (Trong xe bus), xem hết đoạn suy nghĩ và chọn điểm đến.",
      "result": "Lời kể hiện bình thường; mỗi nút chọn dẫn đúng nơi ghi trên nút.",
      "error": "Màn hình đen vĩnh viễn, lóe sáng hoặc chọn một nơi nhưng tới nơi khác.",
      "syncTo": "open.map10"
    },
    "routeinst.super-coffee-kohi-regular.04": {
      "action": "Khi vừa tới Map19 (Siêu thị), quan sát xe bus ngoài cửa.",
      "result": "Xe tiếp tục chạy sang trái rồi rời màn hình.",
      "error": "Xe đứng yên hoặc biến mất sai cách.",
      "syncTo": "super.bus"
    },
    "routeinst.super-coffee-kohi-regular.05": {
      "action": "Xem cả bốn món quà trước khi quyết định.",
      "result": "Có thể xem đủ bốn món.",
      "error": "Một món không xem được hoặc route bị khóa quá sớm.",
      "syncTo": "super.view4"
    },
    "routeinst.super-coffee-kohi-regular.06": {
      "action": "Chọn một món quà rồi thử đi lại trước khi thanh toán.",
      "result": "Hải Quỳ vẫn tự do đi lại; chỉ thanh toán khi chủ động ra cửa.",
      "error": "Game tự kéo Hải Quỳ tới quầy hoặc khóa điều khiển.",
      "syncTo": "super.freeaftergift"
    },
    "routeinst.super-coffee-kohi-regular.07": {
      "action": "Sau thanh toán, chọn người nhận.",
      "result": "Bắt buộc chọn Leo, Kohi, Shylvie hoặc Hakase; không thoát khi chưa chọn.",
      "error": "Thoát màn hình chọn mà chưa chọn ai hoặc người nhận sai.",
      "syncTo": "super.recipient"
    },
    "routeinst.super-coffee-kohi-regular.08": {
      "action": "Quan sát ảnh món quà sau khi chọn.",
      "result": "Ảnh đúng món vừa chọn.",
      "error": "Ảnh thuộc món khác.",
      "syncTo": "super.image"
    },
    "routeinst.super-coffee-kohi-regular.09": {
      "action": "Theo route tới chuẩn bị quà, tiệc, sau tiệc và gợi ý cuối.",
      "result": "Món quà và người nhận giữ nguyên xuyên suốt.",
      "error": "Một đoạn bất kỳ đổi sang món/người khác.",
      "syncTo": "super.consistency"
    },
    "routeinst.super-coffee-kohi-regular.10": {
      "action": "Tới Map40 (Chuyến xuống Atlantis lấy cà phê).",
      "result": "Màn hình đang đen; lời kể dùng hộp thoại bình thường. Sau tin quái vật/mái nhà và việc quán hết cà phê mới hiện lựa chọn.",
      "error": "Lời thoại nổi sai kiểu, lựa chọn xuất hiện quá sớm hoặc route bỏ qua đoạn này.",
      "syncTo": "coffee.map40"
    },
    "routeinst.super-coffee-kohi-regular.11": {
      "action": "Chọn dùng cà phê thường.",
      "result": "Bỏ qua minigame và tiếp tục route với nội dung cà phê thường.",
      "error": "Route vẫn ghi nhận cà phê Atlantis hoặc bắt buộc vào minigame.",
      "syncTo": "coffee.regular"
    },
    "routeinst.super-coffee-kohi-regular.12": {
      "action": "Hoàn thành nhánh Máy pha cà phê → Kohi / Cà phê thường.",
      "result": "Kohi nhận máy pha cà phê; toàn bộ phần sau giữ đúng trường hợp Cà phê thường.",
      "error": "Phần sau quay sang loại cà phê hoặc người nhận khác.",
      "syncTo": "route.coffee.kohi.regular"
    },
    "routeinst.super-coffee-kohi-regular.13": {
      "action": "Xem đoạn Hải Quỳ đặt quà rồi ngủ.",
      "result": "Hải Quỳ ngủ trước rồi mới thức dậy.",
      "error": "Cảnh bị bỏ qua hoặc thứ tự đảo.",
      "syncTo": "prep.sleep"
    },
    "routeinst.super-coffee-kohi-regular.14": {
      "action": "Xem trọn cảnh thử trang phục.",
      "result": "Các bộ đồ chạy đúng thứ tự; chỉ đổi sang đồ Giáng sinh sau bộ cuối.",
      "error": "Sprite đổi quá sớm hoặc lóe sai hình khi màn hình tối.",
      "syncTo": "prep.outfit"
    },
    "routeinst.super-coffee-kohi-regular.15": {
      "action": "Chờ cảnh chuẩn bị kết thúc.",
      "result": "Màn hình sáng trở lại và câu chuyện tiếp tục.",
      "error": "Màn hình tối vĩnh viễn hoặc lóe sáng bất thường.",
      "syncTo": "prep.light"
    },
    "routeinst.super-coffee-kohi-regular.16": {
      "action": "Đi vào Map38 (Văn phòng Wanderer trong tiệc Giáng sinh).",
      "result": "Phần mở đầu của bữa tiệc khớp route hiện tại.",
      "error": "Thoại/ảnh của route khác xuất hiện.",
      "syncTo": "party.arrival"
    },
    "routeinst.super-coffee-kohi-regular.17": {
      "action": "Tới đoạn được tự do khám phá trong tiệc.",
      "result": "Có thể đi lại, vào khu vực phụ và nói chuyện với các thành viên.",
      "error": "Màn hình còn đen hoặc không điều khiển được Hải Quỳ.",
      "syncTo": "party.free"
    },
    "routeinst.super-coffee-kohi-regular.18": {
      "action": "Thử mở ném tuyết từ phần khám phá tự do.",
      "result": "Có thể thách đấu Shylvie, Kohi, Leo hoặc Hakase và quay lại bữa tiệc.",
      "error": "Minigame không mở hoặc quay về sai trạng thái.",
      "syncTo": "party.snow"
    },
    "routeinst.super-coffee-kohi-regular.19": {
      "action": "Chọn tiếp tục bữa tiệc.",
      "result": "Cảnh trao quà chạy đúng một lần rồi chuyển sang phần sau của route.",
      "error": "Scene lặp, crash hoặc tiếp tục sai route.",
      "syncTo": "party.continue"
    },
    "routeinst.super-coffee-kohi-atlantis.00": {
      "action": "Hoàn thành đoạn mở đầu tại Map3 (Văn phòng Silver Wing).",
      "result": "Hội thoại đúng thứ tự/người nói; nhân vật không bị kẹt khi tự đi.",
      "error": "Sai người nói, camera lệch hoặc nhân vật bị kẹt.",
      "syncTo": "open.map3"
    },
    "routeinst.super-coffee-kohi-atlantis.01": {
      "action": "Nếu đi qua Map17 (Hành lang Silver Wing), đi hết hành lang tới thành phố.",
      "result": "Hải Quỳ tới đúng vị trí ở Map6; không tiếp tục tự chạy theo lộ trình cũ.",
      "error": "Sang map mới nhưng nhân vật vẫn tự chạy hoặc xuất hiện lệch vị trí.",
      "syncTo": "open.map17"
    },
    "routeinst.super-coffee-kohi-atlantis.02": {
      "action": "Đi qua Map6 (Thành phố) và lên xe bus.",
      "result": "Camera bắt kịp Hải Quỳ và chuyển lên xe bus bình thường.",
      "error": "Camera bỏ lại nhân vật hoặc chuyển map sai.",
      "syncTo": "open.map6"
    },
    "routeinst.super-coffee-kohi-atlantis.03": {
      "action": "Ở Map10 (Trong xe bus), xem hết đoạn suy nghĩ và chọn điểm đến.",
      "result": "Lời kể hiện bình thường; mỗi nút chọn dẫn đúng nơi ghi trên nút.",
      "error": "Màn hình đen vĩnh viễn, lóe sáng hoặc chọn một nơi nhưng tới nơi khác.",
      "syncTo": "open.map10"
    },
    "routeinst.super-coffee-kohi-atlantis.04": {
      "action": "Khi vừa tới Map19 (Siêu thị), quan sát xe bus ngoài cửa.",
      "result": "Xe tiếp tục chạy sang trái rồi rời màn hình.",
      "error": "Xe đứng yên hoặc biến mất sai cách.",
      "syncTo": "super.bus"
    },
    "routeinst.super-coffee-kohi-atlantis.05": {
      "action": "Xem cả bốn món quà trước khi quyết định.",
      "result": "Có thể xem đủ bốn món.",
      "error": "Một món không xem được hoặc route bị khóa quá sớm.",
      "syncTo": "super.view4"
    },
    "routeinst.super-coffee-kohi-atlantis.06": {
      "action": "Chọn một món quà rồi thử đi lại trước khi thanh toán.",
      "result": "Hải Quỳ vẫn tự do đi lại; chỉ thanh toán khi chủ động ra cửa.",
      "error": "Game tự kéo Hải Quỳ tới quầy hoặc khóa điều khiển.",
      "syncTo": "super.freeaftergift"
    },
    "routeinst.super-coffee-kohi-atlantis.07": {
      "action": "Sau thanh toán, chọn người nhận.",
      "result": "Bắt buộc chọn Leo, Kohi, Shylvie hoặc Hakase; không thoát khi chưa chọn.",
      "error": "Thoát màn hình chọn mà chưa chọn ai hoặc người nhận sai.",
      "syncTo": "super.recipient"
    },
    "routeinst.super-coffee-kohi-atlantis.08": {
      "action": "Quan sát ảnh món quà sau khi chọn.",
      "result": "Ảnh đúng món vừa chọn.",
      "error": "Ảnh thuộc món khác.",
      "syncTo": "super.image"
    },
    "routeinst.super-coffee-kohi-atlantis.09": {
      "action": "Theo route tới chuẩn bị quà, tiệc, sau tiệc và gợi ý cuối.",
      "result": "Món quà và người nhận giữ nguyên xuyên suốt.",
      "error": "Một đoạn bất kỳ đổi sang món/người khác.",
      "syncTo": "super.consistency"
    },
    "routeinst.super-coffee-kohi-atlantis.10": {
      "action": "Tới Map40 (Chuyến xuống Atlantis lấy cà phê).",
      "result": "Màn hình đang đen; lời kể dùng hộp thoại bình thường. Sau tin quái vật/mái nhà và việc quán hết cà phê mới hiện lựa chọn.",
      "error": "Lời thoại nổi sai kiểu, lựa chọn xuất hiện quá sớm hoặc route bỏ qua đoạn này.",
      "syncTo": "coffee.map40"
    },
    "routeinst.super-coffee-kohi-atlantis.11": {
      "action": "Chọn đi câu tôm và lấy đủ mười cà phê Atlantis.",
      "result": "Chỉ khi đủ mười mới tiếp tục; phần sau ghi nhận cà phê Atlantis.",
      "error": "Thoát sớm vẫn được tính đủ hoặc route quay về nội dung cà phê thường.",
      "syncTo": "coffee.atlantis"
    },
    "routeinst.super-coffee-kohi-atlantis.12": {
      "action": "Hoàn thành nhánh Máy pha cà phê → Kohi / Cà phê Atlantis.",
      "result": "Kohi nhận máy pha cà phê; toàn bộ phần sau giữ đúng trường hợp Cà phê Atlantis.",
      "error": "Phần sau quay sang loại cà phê hoặc người nhận khác.",
      "syncTo": "route.coffee.kohi.atlantis"
    },
    "routeinst.super-coffee-kohi-atlantis.13": {
      "action": "Xem đoạn Hải Quỳ đặt quà rồi ngủ.",
      "result": "Hải Quỳ ngủ trước rồi mới thức dậy.",
      "error": "Cảnh bị bỏ qua hoặc thứ tự đảo.",
      "syncTo": "prep.sleep"
    },
    "routeinst.super-coffee-kohi-atlantis.14": {
      "action": "Xem trọn cảnh thử trang phục.",
      "result": "Các bộ đồ chạy đúng thứ tự; chỉ đổi sang đồ Giáng sinh sau bộ cuối.",
      "error": "Sprite đổi quá sớm hoặc lóe sai hình khi màn hình tối.",
      "syncTo": "prep.outfit"
    },
    "routeinst.super-coffee-kohi-atlantis.15": {
      "action": "Chờ cảnh chuẩn bị kết thúc.",
      "result": "Màn hình sáng trở lại và câu chuyện tiếp tục.",
      "error": "Màn hình tối vĩnh viễn hoặc lóe sáng bất thường.",
      "syncTo": "prep.light"
    },
    "routeinst.super-coffee-kohi-atlantis.16": {
      "action": "Đi vào Map38 (Văn phòng Wanderer trong tiệc Giáng sinh).",
      "result": "Phần mở đầu của bữa tiệc khớp route hiện tại.",
      "error": "Thoại/ảnh của route khác xuất hiện.",
      "syncTo": "party.arrival"
    },
    "routeinst.super-coffee-kohi-atlantis.17": {
      "action": "Tới đoạn được tự do khám phá trong tiệc.",
      "result": "Có thể đi lại, vào khu vực phụ và nói chuyện với các thành viên.",
      "error": "Màn hình còn đen hoặc không điều khiển được Hải Quỳ.",
      "syncTo": "party.free"
    },
    "routeinst.super-coffee-kohi-atlantis.18": {
      "action": "Thử mở ném tuyết từ phần khám phá tự do.",
      "result": "Có thể thách đấu Shylvie, Kohi, Leo hoặc Hakase và quay lại bữa tiệc.",
      "error": "Minigame không mở hoặc quay về sai trạng thái.",
      "syncTo": "party.snow"
    },
    "routeinst.super-coffee-kohi-atlantis.19": {
      "action": "Chọn tiếp tục bữa tiệc.",
      "result": "Cảnh trao quà chạy đúng một lần rồi chuyển sang phần sau của route.",
      "error": "Scene lặp, crash hoặc tiếp tục sai route.",
      "syncTo": "party.continue"
    },
    "routeinst.super-coffee-shylvie-regular.00": {
      "action": "Hoàn thành đoạn mở đầu tại Map3 (Văn phòng Silver Wing).",
      "result": "Hội thoại đúng thứ tự/người nói; nhân vật không bị kẹt khi tự đi.",
      "error": "Sai người nói, camera lệch hoặc nhân vật bị kẹt.",
      "syncTo": "open.map3"
    },
    "routeinst.super-coffee-shylvie-regular.01": {
      "action": "Nếu đi qua Map17 (Hành lang Silver Wing), đi hết hành lang tới thành phố.",
      "result": "Hải Quỳ tới đúng vị trí ở Map6; không tiếp tục tự chạy theo lộ trình cũ.",
      "error": "Sang map mới nhưng nhân vật vẫn tự chạy hoặc xuất hiện lệch vị trí.",
      "syncTo": "open.map17"
    },
    "routeinst.super-coffee-shylvie-regular.02": {
      "action": "Đi qua Map6 (Thành phố) và lên xe bus.",
      "result": "Camera bắt kịp Hải Quỳ và chuyển lên xe bus bình thường.",
      "error": "Camera bỏ lại nhân vật hoặc chuyển map sai.",
      "syncTo": "open.map6"
    },
    "routeinst.super-coffee-shylvie-regular.03": {
      "action": "Ở Map10 (Trong xe bus), xem hết đoạn suy nghĩ và chọn điểm đến.",
      "result": "Lời kể hiện bình thường; mỗi nút chọn dẫn đúng nơi ghi trên nút.",
      "error": "Màn hình đen vĩnh viễn, lóe sáng hoặc chọn một nơi nhưng tới nơi khác.",
      "syncTo": "open.map10"
    },
    "routeinst.super-coffee-shylvie-regular.04": {
      "action": "Khi vừa tới Map19 (Siêu thị), quan sát xe bus ngoài cửa.",
      "result": "Xe tiếp tục chạy sang trái rồi rời màn hình.",
      "error": "Xe đứng yên hoặc biến mất sai cách.",
      "syncTo": "super.bus"
    },
    "routeinst.super-coffee-shylvie-regular.05": {
      "action": "Xem cả bốn món quà trước khi quyết định.",
      "result": "Có thể xem đủ bốn món.",
      "error": "Một món không xem được hoặc route bị khóa quá sớm.",
      "syncTo": "super.view4"
    },
    "routeinst.super-coffee-shylvie-regular.06": {
      "action": "Chọn một món quà rồi thử đi lại trước khi thanh toán.",
      "result": "Hải Quỳ vẫn tự do đi lại; chỉ thanh toán khi chủ động ra cửa.",
      "error": "Game tự kéo Hải Quỳ tới quầy hoặc khóa điều khiển.",
      "syncTo": "super.freeaftergift"
    },
    "routeinst.super-coffee-shylvie-regular.07": {
      "action": "Sau thanh toán, chọn người nhận.",
      "result": "Bắt buộc chọn Leo, Kohi, Shylvie hoặc Hakase; không thoát khi chưa chọn.",
      "error": "Thoát màn hình chọn mà chưa chọn ai hoặc người nhận sai.",
      "syncTo": "super.recipient"
    },
    "routeinst.super-coffee-shylvie-regular.08": {
      "action": "Quan sát ảnh món quà sau khi chọn.",
      "result": "Ảnh đúng món vừa chọn.",
      "error": "Ảnh thuộc món khác.",
      "syncTo": "super.image"
    },
    "routeinst.super-coffee-shylvie-regular.09": {
      "action": "Theo route tới chuẩn bị quà, tiệc, sau tiệc và gợi ý cuối.",
      "result": "Món quà và người nhận giữ nguyên xuyên suốt.",
      "error": "Một đoạn bất kỳ đổi sang món/người khác.",
      "syncTo": "super.consistency"
    },
    "routeinst.super-coffee-shylvie-regular.10": {
      "action": "Tới Map40 (Chuyến xuống Atlantis lấy cà phê).",
      "result": "Màn hình đang đen; lời kể dùng hộp thoại bình thường. Sau tin quái vật/mái nhà và việc quán hết cà phê mới hiện lựa chọn.",
      "error": "Lời thoại nổi sai kiểu, lựa chọn xuất hiện quá sớm hoặc route bỏ qua đoạn này.",
      "syncTo": "coffee.map40"
    },
    "routeinst.super-coffee-shylvie-regular.11": {
      "action": "Chọn dùng cà phê thường.",
      "result": "Bỏ qua minigame và tiếp tục route với nội dung cà phê thường.",
      "error": "Route vẫn ghi nhận cà phê Atlantis hoặc bắt buộc vào minigame.",
      "syncTo": "coffee.regular"
    },
    "routeinst.super-coffee-shylvie-regular.12": {
      "action": "Hoàn thành nhánh Máy pha cà phê → Shylvie / Cà phê thường.",
      "result": "Shylvie nhận máy pha cà phê; toàn bộ phần sau giữ đúng trường hợp Cà phê thường.",
      "error": "Phần sau quay sang loại cà phê hoặc người nhận khác.",
      "syncTo": "route.coffee.shylvie.regular"
    },
    "routeinst.super-coffee-shylvie-regular.13": {
      "action": "Xem đoạn Hải Quỳ đặt quà rồi ngủ.",
      "result": "Hải Quỳ ngủ trước rồi mới thức dậy.",
      "error": "Cảnh bị bỏ qua hoặc thứ tự đảo.",
      "syncTo": "prep.sleep"
    },
    "routeinst.super-coffee-shylvie-regular.14": {
      "action": "Xem trọn cảnh thử trang phục.",
      "result": "Các bộ đồ chạy đúng thứ tự; chỉ đổi sang đồ Giáng sinh sau bộ cuối.",
      "error": "Sprite đổi quá sớm hoặc lóe sai hình khi màn hình tối.",
      "syncTo": "prep.outfit"
    },
    "routeinst.super-coffee-shylvie-regular.15": {
      "action": "Chờ cảnh chuẩn bị kết thúc.",
      "result": "Màn hình sáng trở lại và câu chuyện tiếp tục.",
      "error": "Màn hình tối vĩnh viễn hoặc lóe sáng bất thường.",
      "syncTo": "prep.light"
    },
    "routeinst.super-coffee-shylvie-regular.16": {
      "action": "Đi vào Map38 (Văn phòng Wanderer trong tiệc Giáng sinh).",
      "result": "Phần mở đầu của bữa tiệc khớp route hiện tại.",
      "error": "Thoại/ảnh của route khác xuất hiện.",
      "syncTo": "party.arrival"
    },
    "routeinst.super-coffee-shylvie-regular.17": {
      "action": "Tới đoạn được tự do khám phá trong tiệc.",
      "result": "Có thể đi lại, vào khu vực phụ và nói chuyện với các thành viên.",
      "error": "Màn hình còn đen hoặc không điều khiển được Hải Quỳ.",
      "syncTo": "party.free"
    },
    "routeinst.super-coffee-shylvie-regular.18": {
      "action": "Thử mở ném tuyết từ phần khám phá tự do.",
      "result": "Có thể thách đấu Shylvie, Kohi, Leo hoặc Hakase và quay lại bữa tiệc.",
      "error": "Minigame không mở hoặc quay về sai trạng thái.",
      "syncTo": "party.snow"
    },
    "routeinst.super-coffee-shylvie-regular.19": {
      "action": "Chọn tiếp tục bữa tiệc.",
      "result": "Cảnh trao quà chạy đúng một lần rồi chuyển sang phần sau của route.",
      "error": "Scene lặp, crash hoặc tiếp tục sai route.",
      "syncTo": "party.continue"
    },
    "routeinst.super-coffee-shylvie-atlantis.00": {
      "action": "Hoàn thành đoạn mở đầu tại Map3 (Văn phòng Silver Wing).",
      "result": "Hội thoại đúng thứ tự/người nói; nhân vật không bị kẹt khi tự đi.",
      "error": "Sai người nói, camera lệch hoặc nhân vật bị kẹt.",
      "syncTo": "open.map3"
    },
    "routeinst.super-coffee-shylvie-atlantis.01": {
      "action": "Nếu đi qua Map17 (Hành lang Silver Wing), đi hết hành lang tới thành phố.",
      "result": "Hải Quỳ tới đúng vị trí ở Map6; không tiếp tục tự chạy theo lộ trình cũ.",
      "error": "Sang map mới nhưng nhân vật vẫn tự chạy hoặc xuất hiện lệch vị trí.",
      "syncTo": "open.map17"
    },
    "routeinst.super-coffee-shylvie-atlantis.02": {
      "action": "Đi qua Map6 (Thành phố) và lên xe bus.",
      "result": "Camera bắt kịp Hải Quỳ và chuyển lên xe bus bình thường.",
      "error": "Camera bỏ lại nhân vật hoặc chuyển map sai.",
      "syncTo": "open.map6"
    },
    "routeinst.super-coffee-shylvie-atlantis.03": {
      "action": "Ở Map10 (Trong xe bus), xem hết đoạn suy nghĩ và chọn điểm đến.",
      "result": "Lời kể hiện bình thường; mỗi nút chọn dẫn đúng nơi ghi trên nút.",
      "error": "Màn hình đen vĩnh viễn, lóe sáng hoặc chọn một nơi nhưng tới nơi khác.",
      "syncTo": "open.map10"
    },
    "routeinst.super-coffee-shylvie-atlantis.04": {
      "action": "Khi vừa tới Map19 (Siêu thị), quan sát xe bus ngoài cửa.",
      "result": "Xe tiếp tục chạy sang trái rồi rời màn hình.",
      "error": "Xe đứng yên hoặc biến mất sai cách.",
      "syncTo": "super.bus"
    },
    "routeinst.super-coffee-shylvie-atlantis.05": {
      "action": "Xem cả bốn món quà trước khi quyết định.",
      "result": "Có thể xem đủ bốn món.",
      "error": "Một món không xem được hoặc route bị khóa quá sớm.",
      "syncTo": "super.view4"
    },
    "routeinst.super-coffee-shylvie-atlantis.06": {
      "action": "Chọn một món quà rồi thử đi lại trước khi thanh toán.",
      "result": "Hải Quỳ vẫn tự do đi lại; chỉ thanh toán khi chủ động ra cửa.",
      "error": "Game tự kéo Hải Quỳ tới quầy hoặc khóa điều khiển.",
      "syncTo": "super.freeaftergift"
    },
    "routeinst.super-coffee-shylvie-atlantis.07": {
      "action": "Sau thanh toán, chọn người nhận.",
      "result": "Bắt buộc chọn Leo, Kohi, Shylvie hoặc Hakase; không thoát khi chưa chọn.",
      "error": "Thoát màn hình chọn mà chưa chọn ai hoặc người nhận sai.",
      "syncTo": "super.recipient"
    },
    "routeinst.super-coffee-shylvie-atlantis.08": {
      "action": "Quan sát ảnh món quà sau khi chọn.",
      "result": "Ảnh đúng món vừa chọn.",
      "error": "Ảnh thuộc món khác.",
      "syncTo": "super.image"
    },
    "routeinst.super-coffee-shylvie-atlantis.09": {
      "action": "Theo route tới chuẩn bị quà, tiệc, sau tiệc và gợi ý cuối.",
      "result": "Món quà và người nhận giữ nguyên xuyên suốt.",
      "error": "Một đoạn bất kỳ đổi sang món/người khác.",
      "syncTo": "super.consistency"
    },
    "routeinst.super-coffee-shylvie-atlantis.10": {
      "action": "Tới Map40 (Chuyến xuống Atlantis lấy cà phê).",
      "result": "Màn hình đang đen; lời kể dùng hộp thoại bình thường. Sau tin quái vật/mái nhà và việc quán hết cà phê mới hiện lựa chọn.",
      "error": "Lời thoại nổi sai kiểu, lựa chọn xuất hiện quá sớm hoặc route bỏ qua đoạn này.",
      "syncTo": "coffee.map40"
    },
    "routeinst.super-coffee-shylvie-atlantis.11": {
      "action": "Chọn đi câu tôm và lấy đủ mười cà phê Atlantis.",
      "result": "Chỉ khi đủ mười mới tiếp tục; phần sau ghi nhận cà phê Atlantis.",
      "error": "Thoát sớm vẫn được tính đủ hoặc route quay về nội dung cà phê thường.",
      "syncTo": "coffee.atlantis"
    },
    "routeinst.super-coffee-shylvie-atlantis.12": {
      "action": "Hoàn thành nhánh Máy pha cà phê → Shylvie / Cà phê Atlantis.",
      "result": "Shylvie nhận máy pha cà phê; toàn bộ phần sau giữ đúng trường hợp Cà phê Atlantis.",
      "error": "Phần sau quay sang loại cà phê hoặc người nhận khác.",
      "syncTo": "route.coffee.shylvie.atlantis"
    },
    "routeinst.super-coffee-shylvie-atlantis.13": {
      "action": "Xem đoạn Hải Quỳ đặt quà rồi ngủ.",
      "result": "Hải Quỳ ngủ trước rồi mới thức dậy.",
      "error": "Cảnh bị bỏ qua hoặc thứ tự đảo.",
      "syncTo": "prep.sleep"
    },
    "routeinst.super-coffee-shylvie-atlantis.14": {
      "action": "Xem trọn cảnh thử trang phục.",
      "result": "Các bộ đồ chạy đúng thứ tự; chỉ đổi sang đồ Giáng sinh sau bộ cuối.",
      "error": "Sprite đổi quá sớm hoặc lóe sai hình khi màn hình tối.",
      "syncTo": "prep.outfit"
    },
    "routeinst.super-coffee-shylvie-atlantis.15": {
      "action": "Chờ cảnh chuẩn bị kết thúc.",
      "result": "Màn hình sáng trở lại và câu chuyện tiếp tục.",
      "error": "Màn hình tối vĩnh viễn hoặc lóe sáng bất thường.",
      "syncTo": "prep.light"
    },
    "routeinst.super-coffee-shylvie-atlantis.16": {
      "action": "Đi vào Map38 (Văn phòng Wanderer trong tiệc Giáng sinh).",
      "result": "Phần mở đầu của bữa tiệc khớp route hiện tại.",
      "error": "Thoại/ảnh của route khác xuất hiện.",
      "syncTo": "party.arrival"
    },
    "routeinst.super-coffee-shylvie-atlantis.17": {
      "action": "Tới đoạn được tự do khám phá trong tiệc.",
      "result": "Có thể đi lại, vào khu vực phụ và nói chuyện với các thành viên.",
      "error": "Màn hình còn đen hoặc không điều khiển được Hải Quỳ.",
      "syncTo": "party.free"
    },
    "routeinst.super-coffee-shylvie-atlantis.18": {
      "action": "Thử mở ném tuyết từ phần khám phá tự do.",
      "result": "Có thể thách đấu Shylvie, Kohi, Leo hoặc Hakase và quay lại bữa tiệc.",
      "error": "Minigame không mở hoặc quay về sai trạng thái.",
      "syncTo": "party.snow"
    },
    "routeinst.super-coffee-shylvie-atlantis.19": {
      "action": "Chọn tiếp tục bữa tiệc.",
      "result": "Cảnh trao quà chạy đúng một lần rồi chuyển sang phần sau của route.",
      "error": "Scene lặp, crash hoặc tiếp tục sai route.",
      "syncTo": "party.continue"
    },
    "routeinst.super-coffee-hakase-regular.00": {
      "action": "Hoàn thành đoạn mở đầu tại Map3 (Văn phòng Silver Wing).",
      "result": "Hội thoại đúng thứ tự/người nói; nhân vật không bị kẹt khi tự đi.",
      "error": "Sai người nói, camera lệch hoặc nhân vật bị kẹt.",
      "syncTo": "open.map3"
    },
    "routeinst.super-coffee-hakase-regular.01": {
      "action": "Nếu đi qua Map17 (Hành lang Silver Wing), đi hết hành lang tới thành phố.",
      "result": "Hải Quỳ tới đúng vị trí ở Map6; không tiếp tục tự chạy theo lộ trình cũ.",
      "error": "Sang map mới nhưng nhân vật vẫn tự chạy hoặc xuất hiện lệch vị trí.",
      "syncTo": "open.map17"
    },
    "routeinst.super-coffee-hakase-regular.02": {
      "action": "Đi qua Map6 (Thành phố) và lên xe bus.",
      "result": "Camera bắt kịp Hải Quỳ và chuyển lên xe bus bình thường.",
      "error": "Camera bỏ lại nhân vật hoặc chuyển map sai.",
      "syncTo": "open.map6"
    },
    "routeinst.super-coffee-hakase-regular.03": {
      "action": "Ở Map10 (Trong xe bus), xem hết đoạn suy nghĩ và chọn điểm đến.",
      "result": "Lời kể hiện bình thường; mỗi nút chọn dẫn đúng nơi ghi trên nút.",
      "error": "Màn hình đen vĩnh viễn, lóe sáng hoặc chọn một nơi nhưng tới nơi khác.",
      "syncTo": "open.map10"
    },
    "routeinst.super-coffee-hakase-regular.04": {
      "action": "Khi vừa tới Map19 (Siêu thị), quan sát xe bus ngoài cửa.",
      "result": "Xe tiếp tục chạy sang trái rồi rời màn hình.",
      "error": "Xe đứng yên hoặc biến mất sai cách.",
      "syncTo": "super.bus"
    },
    "routeinst.super-coffee-hakase-regular.05": {
      "action": "Xem cả bốn món quà trước khi quyết định.",
      "result": "Có thể xem đủ bốn món.",
      "error": "Một món không xem được hoặc route bị khóa quá sớm.",
      "syncTo": "super.view4"
    },
    "routeinst.super-coffee-hakase-regular.06": {
      "action": "Chọn một món quà rồi thử đi lại trước khi thanh toán.",
      "result": "Hải Quỳ vẫn tự do đi lại; chỉ thanh toán khi chủ động ra cửa.",
      "error": "Game tự kéo Hải Quỳ tới quầy hoặc khóa điều khiển.",
      "syncTo": "super.freeaftergift"
    },
    "routeinst.super-coffee-hakase-regular.07": {
      "action": "Sau thanh toán, chọn người nhận.",
      "result": "Bắt buộc chọn Leo, Kohi, Shylvie hoặc Hakase; không thoát khi chưa chọn.",
      "error": "Thoát màn hình chọn mà chưa chọn ai hoặc người nhận sai.",
      "syncTo": "super.recipient"
    },
    "routeinst.super-coffee-hakase-regular.08": {
      "action": "Quan sát ảnh món quà sau khi chọn.",
      "result": "Ảnh đúng món vừa chọn.",
      "error": "Ảnh thuộc món khác.",
      "syncTo": "super.image"
    },
    "routeinst.super-coffee-hakase-regular.09": {
      "action": "Theo route tới chuẩn bị quà, tiệc, sau tiệc và gợi ý cuối.",
      "result": "Món quà và người nhận giữ nguyên xuyên suốt.",
      "error": "Một đoạn bất kỳ đổi sang món/người khác.",
      "syncTo": "super.consistency"
    },
    "routeinst.super-coffee-hakase-regular.10": {
      "action": "Tới Map40 (Chuyến xuống Atlantis lấy cà phê).",
      "result": "Màn hình đang đen; lời kể dùng hộp thoại bình thường. Sau tin quái vật/mái nhà và việc quán hết cà phê mới hiện lựa chọn.",
      "error": "Lời thoại nổi sai kiểu, lựa chọn xuất hiện quá sớm hoặc route bỏ qua đoạn này.",
      "syncTo": "coffee.map40"
    },
    "routeinst.super-coffee-hakase-regular.11": {
      "action": "Chọn dùng cà phê thường.",
      "result": "Bỏ qua minigame và tiếp tục route với nội dung cà phê thường.",
      "error": "Route vẫn ghi nhận cà phê Atlantis hoặc bắt buộc vào minigame.",
      "syncTo": "coffee.regular"
    },
    "routeinst.super-coffee-hakase-regular.12": {
      "action": "Hoàn thành nhánh Máy pha cà phê → Hakase / Cà phê thường.",
      "result": "Hakase nhận máy pha cà phê; toàn bộ phần sau giữ đúng trường hợp Cà phê thường.",
      "error": "Phần sau quay sang loại cà phê hoặc người nhận khác.",
      "syncTo": "route.coffee.hakase.regular"
    },
    "routeinst.super-coffee-hakase-regular.13": {
      "action": "Xem đoạn Hải Quỳ đặt quà rồi ngủ.",
      "result": "Hải Quỳ ngủ trước rồi mới thức dậy.",
      "error": "Cảnh bị bỏ qua hoặc thứ tự đảo.",
      "syncTo": "prep.sleep"
    },
    "routeinst.super-coffee-hakase-regular.14": {
      "action": "Xem trọn cảnh thử trang phục.",
      "result": "Các bộ đồ chạy đúng thứ tự; chỉ đổi sang đồ Giáng sinh sau bộ cuối.",
      "error": "Sprite đổi quá sớm hoặc lóe sai hình khi màn hình tối.",
      "syncTo": "prep.outfit"
    },
    "routeinst.super-coffee-hakase-regular.15": {
      "action": "Chờ cảnh chuẩn bị kết thúc.",
      "result": "Màn hình sáng trở lại và câu chuyện tiếp tục.",
      "error": "Màn hình tối vĩnh viễn hoặc lóe sáng bất thường.",
      "syncTo": "prep.light"
    },
    "routeinst.super-coffee-hakase-regular.16": {
      "action": "Đi vào Map38 (Văn phòng Wanderer trong tiệc Giáng sinh).",
      "result": "Phần mở đầu của bữa tiệc khớp route hiện tại.",
      "error": "Thoại/ảnh của route khác xuất hiện.",
      "syncTo": "party.arrival"
    },
    "routeinst.super-coffee-hakase-regular.17": {
      "action": "Tới đoạn được tự do khám phá trong tiệc.",
      "result": "Có thể đi lại, vào khu vực phụ và nói chuyện với các thành viên.",
      "error": "Màn hình còn đen hoặc không điều khiển được Hải Quỳ.",
      "syncTo": "party.free"
    },
    "routeinst.super-coffee-hakase-regular.18": {
      "action": "Thử mở ném tuyết từ phần khám phá tự do.",
      "result": "Có thể thách đấu Shylvie, Kohi, Leo hoặc Hakase và quay lại bữa tiệc.",
      "error": "Minigame không mở hoặc quay về sai trạng thái.",
      "syncTo": "party.snow"
    },
    "routeinst.super-coffee-hakase-regular.19": {
      "action": "Chọn tiếp tục bữa tiệc.",
      "result": "Cảnh trao quà chạy đúng một lần rồi chuyển sang phần sau của route.",
      "error": "Scene lặp, crash hoặc tiếp tục sai route.",
      "syncTo": "party.continue"
    },
    "routeinst.super-coffee-hakase-atlantis.00": {
      "action": "Hoàn thành đoạn mở đầu tại Map3 (Văn phòng Silver Wing).",
      "result": "Hội thoại đúng thứ tự/người nói; nhân vật không bị kẹt khi tự đi.",
      "error": "Sai người nói, camera lệch hoặc nhân vật bị kẹt.",
      "syncTo": "open.map3"
    },
    "routeinst.super-coffee-hakase-atlantis.01": {
      "action": "Nếu đi qua Map17 (Hành lang Silver Wing), đi hết hành lang tới thành phố.",
      "result": "Hải Quỳ tới đúng vị trí ở Map6; không tiếp tục tự chạy theo lộ trình cũ.",
      "error": "Sang map mới nhưng nhân vật vẫn tự chạy hoặc xuất hiện lệch vị trí.",
      "syncTo": "open.map17"
    },
    "routeinst.super-coffee-hakase-atlantis.02": {
      "action": "Đi qua Map6 (Thành phố) và lên xe bus.",
      "result": "Camera bắt kịp Hải Quỳ và chuyển lên xe bus bình thường.",
      "error": "Camera bỏ lại nhân vật hoặc chuyển map sai.",
      "syncTo": "open.map6"
    },
    "routeinst.super-coffee-hakase-atlantis.03": {
      "action": "Ở Map10 (Trong xe bus), xem hết đoạn suy nghĩ và chọn điểm đến.",
      "result": "Lời kể hiện bình thường; mỗi nút chọn dẫn đúng nơi ghi trên nút.",
      "error": "Màn hình đen vĩnh viễn, lóe sáng hoặc chọn một nơi nhưng tới nơi khác.",
      "syncTo": "open.map10"
    },
    "routeinst.super-coffee-hakase-atlantis.04": {
      "action": "Khi vừa tới Map19 (Siêu thị), quan sát xe bus ngoài cửa.",
      "result": "Xe tiếp tục chạy sang trái rồi rời màn hình.",
      "error": "Xe đứng yên hoặc biến mất sai cách.",
      "syncTo": "super.bus"
    },
    "routeinst.super-coffee-hakase-atlantis.05": {
      "action": "Xem cả bốn món quà trước khi quyết định.",
      "result": "Có thể xem đủ bốn món.",
      "error": "Một món không xem được hoặc route bị khóa quá sớm.",
      "syncTo": "super.view4"
    },
    "routeinst.super-coffee-hakase-atlantis.06": {
      "action": "Chọn một món quà rồi thử đi lại trước khi thanh toán.",
      "result": "Hải Quỳ vẫn tự do đi lại; chỉ thanh toán khi chủ động ra cửa.",
      "error": "Game tự kéo Hải Quỳ tới quầy hoặc khóa điều khiển.",
      "syncTo": "super.freeaftergift"
    },
    "routeinst.super-coffee-hakase-atlantis.07": {
      "action": "Sau thanh toán, chọn người nhận.",
      "result": "Bắt buộc chọn Leo, Kohi, Shylvie hoặc Hakase; không thoát khi chưa chọn.",
      "error": "Thoát màn hình chọn mà chưa chọn ai hoặc người nhận sai.",
      "syncTo": "super.recipient"
    },
    "routeinst.super-coffee-hakase-atlantis.08": {
      "action": "Quan sát ảnh món quà sau khi chọn.",
      "result": "Ảnh đúng món vừa chọn.",
      "error": "Ảnh thuộc món khác.",
      "syncTo": "super.image"
    },
    "routeinst.super-coffee-hakase-atlantis.09": {
      "action": "Theo route tới chuẩn bị quà, tiệc, sau tiệc và gợi ý cuối.",
      "result": "Món quà và người nhận giữ nguyên xuyên suốt.",
      "error": "Một đoạn bất kỳ đổi sang món/người khác.",
      "syncTo": "super.consistency"
    },
    "routeinst.super-coffee-hakase-atlantis.10": {
      "action": "Tới Map40 (Chuyến xuống Atlantis lấy cà phê).",
      "result": "Màn hình đang đen; lời kể dùng hộp thoại bình thường. Sau tin quái vật/mái nhà và việc quán hết cà phê mới hiện lựa chọn.",
      "error": "Lời thoại nổi sai kiểu, lựa chọn xuất hiện quá sớm hoặc route bỏ qua đoạn này.",
      "syncTo": "coffee.map40"
    },
    "routeinst.super-coffee-hakase-atlantis.11": {
      "action": "Chọn đi câu tôm và lấy đủ mười cà phê Atlantis.",
      "result": "Chỉ khi đủ mười mới tiếp tục; phần sau ghi nhận cà phê Atlantis.",
      "error": "Thoát sớm vẫn được tính đủ hoặc route quay về nội dung cà phê thường.",
      "syncTo": "coffee.atlantis"
    },
    "routeinst.super-coffee-hakase-atlantis.12": {
      "action": "Hoàn thành nhánh Máy pha cà phê → Hakase / Cà phê Atlantis.",
      "result": "Hakase nhận máy pha cà phê; toàn bộ phần sau giữ đúng trường hợp Cà phê Atlantis. Đoạn sau có hậu quả mạnh của món quà và gợi ý cuối trách Hải Quỳ vì lựa chọn này.",
      "error": "Phần sau quay sang loại cà phê hoặc người nhận khác.",
      "syncTo": "route.coffee.hakase.atlantis"
    },
    "routeinst.super-coffee-hakase-atlantis.13": {
      "action": "Xem đoạn Hải Quỳ đặt quà rồi ngủ.",
      "result": "Hải Quỳ ngủ trước rồi mới thức dậy.",
      "error": "Cảnh bị bỏ qua hoặc thứ tự đảo.",
      "syncTo": "prep.sleep"
    },
    "routeinst.super-coffee-hakase-atlantis.14": {
      "action": "Xem trọn cảnh thử trang phục.",
      "result": "Các bộ đồ chạy đúng thứ tự; chỉ đổi sang đồ Giáng sinh sau bộ cuối.",
      "error": "Sprite đổi quá sớm hoặc lóe sai hình khi màn hình tối.",
      "syncTo": "prep.outfit"
    },
    "routeinst.super-coffee-hakase-atlantis.15": {
      "action": "Chờ cảnh chuẩn bị kết thúc.",
      "result": "Màn hình sáng trở lại và câu chuyện tiếp tục.",
      "error": "Màn hình tối vĩnh viễn hoặc lóe sáng bất thường.",
      "syncTo": "prep.light"
    },
    "routeinst.super-coffee-hakase-atlantis.16": {
      "action": "Đi vào Map38 (Văn phòng Wanderer trong tiệc Giáng sinh).",
      "result": "Phần mở đầu của bữa tiệc khớp route hiện tại.",
      "error": "Thoại/ảnh của route khác xuất hiện.",
      "syncTo": "party.arrival"
    },
    "routeinst.super-coffee-hakase-atlantis.17": {
      "action": "Tới đoạn được tự do khám phá trong tiệc.",
      "result": "Có thể đi lại, vào khu vực phụ và nói chuyện với các thành viên.",
      "error": "Màn hình còn đen hoặc không điều khiển được Hải Quỳ.",
      "syncTo": "party.free"
    },
    "routeinst.super-coffee-hakase-atlantis.18": {
      "action": "Thử mở ném tuyết từ phần khám phá tự do.",
      "result": "Có thể thách đấu Shylvie, Kohi, Leo hoặc Hakase và quay lại bữa tiệc.",
      "error": "Minigame không mở hoặc quay về sai trạng thái.",
      "syncTo": "party.snow"
    },
    "routeinst.super-coffee-hakase-atlantis.19": {
      "action": "Chọn tiếp tục bữa tiệc.",
      "result": "Cảnh trao quà chạy đúng một lần rồi chuyển sang phần sau của route.",
      "error": "Scene lặp, crash hoặc tiếp tục sai route.",
      "syncTo": "party.continue"
    },
    "routeinst.noodle-aira.00": {
      "action": "Hoàn thành đoạn mở đầu tại Map3 (Văn phòng Silver Wing).",
      "result": "Hội thoại đúng thứ tự/người nói; nhân vật không bị kẹt khi tự đi.",
      "error": "Sai người nói, camera lệch hoặc nhân vật bị kẹt.",
      "syncTo": "open.map3"
    },
    "routeinst.noodle-aira.01": {
      "action": "Nếu đi qua Map17 (Hành lang Silver Wing), đi hết hành lang tới thành phố.",
      "result": "Hải Quỳ tới đúng vị trí ở Map6; không tiếp tục tự chạy theo lộ trình cũ.",
      "error": "Sang map mới nhưng nhân vật vẫn tự chạy hoặc xuất hiện lệch vị trí.",
      "syncTo": "open.map17"
    },
    "routeinst.noodle-aira.02": {
      "action": "Đi qua Map6 (Thành phố) và lên xe bus.",
      "result": "Camera bắt kịp Hải Quỳ và chuyển lên xe bus bình thường.",
      "error": "Camera bỏ lại nhân vật hoặc chuyển map sai.",
      "syncTo": "open.map6"
    },
    "routeinst.noodle-aira.03": {
      "action": "Ở Map10 (Trong xe bus), xem hết đoạn suy nghĩ và chọn điểm đến.",
      "result": "Lời kể hiện bình thường; mỗi nút chọn dẫn đúng nơi ghi trên nút.",
      "error": "Màn hình đen vĩnh viễn, lóe sáng hoặc chọn một nơi nhưng tới nơi khác.",
      "syncTo": "open.map10"
    },
    "routeinst.noodle-aira.04": {
      "action": "Theo route mua mì cay.",
      "result": "Người nhận luôn là Leo; không xuất hiện màn hình chọn bốn người.",
      "error": "Xuất hiện lựa chọn người nhận khác.",
      "syncTo": "noodle.fixedleo"
    },
    "routeinst.noodle-aira.05": {
      "action": "Hoàn thành nhánh mì cay: Tin Aira.",
      "result": "Aira chọn nguyên liệu và phụ trách hướng nấu; có đoạn mua nguyên liệu ở Map19 nhưng không vào hệ thống chọn quà.",
      "error": "Nội dung bị lẫn với nhánh còn lại hoặc hệ thống chọn quà siêu thị.",
      "syncTo": "route.noodle.aira"
    },
    "routeinst.noodle-aira.06": {
      "action": "Tới Map14 (Nhà bếp Wanderer) và hoàn thành cảnh nấu.",
      "result": "Cảnh nấu chỉ chạy một lần; hình tô mì đúng người nấu.",
      "error": "Cảnh chạy lặp hoặc dùng hình sai nhánh.",
      "syncTo": "noodle.map14once"
    },
    "routeinst.noodle-aira.07": {
      "action": "Tới đoạn được tự do khám phá trong tiệc.",
      "result": "Có thể đi lại, vào khu vực phụ và nói chuyện với các thành viên.",
      "error": "Màn hình còn đen hoặc không điều khiển được Hải Quỳ.",
      "syncTo": "party.free"
    },
    "routeinst.noodle-aira.08": {
      "action": "Thử mở ném tuyết từ phần khám phá tự do.",
      "result": "Có thể thách đấu Shylvie, Kohi, Leo hoặc Hakase và quay lại bữa tiệc.",
      "error": "Minigame không mở hoặc quay về sai trạng thái.",
      "syncTo": "party.snow"
    },
    "routeinst.noodle-aira.09": {
      "action": "Tới bữa tiệc.",
      "result": "Có nồi mì cay, bình Sting 20 lít, cảnh tuyết và các cảnh ăn uống liên quan.",
      "error": "Thiếu các chi tiết chính hoặc lẫn route quà khác.",
      "syncTo": "noodle.party"
    },
    "routeinst.noodle-aira.10": {
      "action": "Sau cuộc gọi từ Silver Wing, đi tới đoạn cuối.",
      "result": "Route đi thẳng tới gợi ý cuối; không tự thêm buổi sáng hôm sau.",
      "error": "Xuất hiện cảnh sáng hôm sau không thuộc route.",
      "syncTo": "noodle.end"
    },
    "routeinst.noodle-self.00": {
      "action": "Hoàn thành đoạn mở đầu tại Map3 (Văn phòng Silver Wing).",
      "result": "Hội thoại đúng thứ tự/người nói; nhân vật không bị kẹt khi tự đi.",
      "error": "Sai người nói, camera lệch hoặc nhân vật bị kẹt.",
      "syncTo": "open.map3"
    },
    "routeinst.noodle-self.01": {
      "action": "Nếu đi qua Map17 (Hành lang Silver Wing), đi hết hành lang tới thành phố.",
      "result": "Hải Quỳ tới đúng vị trí ở Map6; không tiếp tục tự chạy theo lộ trình cũ.",
      "error": "Sang map mới nhưng nhân vật vẫn tự chạy hoặc xuất hiện lệch vị trí.",
      "syncTo": "open.map17"
    },
    "routeinst.noodle-self.02": {
      "action": "Đi qua Map6 (Thành phố) và lên xe bus.",
      "result": "Camera bắt kịp Hải Quỳ và chuyển lên xe bus bình thường.",
      "error": "Camera bỏ lại nhân vật hoặc chuyển map sai.",
      "syncTo": "open.map6"
    },
    "routeinst.noodle-self.03": {
      "action": "Ở Map10 (Trong xe bus), xem hết đoạn suy nghĩ và chọn điểm đến.",
      "result": "Lời kể hiện bình thường; mỗi nút chọn dẫn đúng nơi ghi trên nút.",
      "error": "Màn hình đen vĩnh viễn, lóe sáng hoặc chọn một nơi nhưng tới nơi khác.",
      "syncTo": "open.map10"
    },
    "routeinst.noodle-self.04": {
      "action": "Theo route mua mì cay.",
      "result": "Người nhận luôn là Leo; không xuất hiện màn hình chọn bốn người.",
      "error": "Xuất hiện lựa chọn người nhận khác.",
      "syncTo": "noodle.fixedleo"
    },
    "routeinst.noodle-self.05": {
      "action": "Hoàn thành nhánh mì cay: Không tin Aira.",
      "result": "Hải Quỳ ăn nhiều tô mì, phân tích công thức rồi tự chuẩn bị hướng nấu.",
      "error": "Nội dung bị lẫn với nhánh còn lại hoặc hệ thống chọn quà siêu thị.",
      "syncTo": "route.noodle.self"
    },
    "routeinst.noodle-self.06": {
      "action": "Tới Map14 (Nhà bếp Wanderer) và hoàn thành cảnh nấu.",
      "result": "Cảnh nấu chỉ chạy một lần; hình tô mì đúng người nấu.",
      "error": "Cảnh chạy lặp hoặc dùng hình sai nhánh.",
      "syncTo": "noodle.map14once"
    },
    "routeinst.noodle-self.07": {
      "action": "Tới đoạn được tự do khám phá trong tiệc.",
      "result": "Có thể đi lại, vào khu vực phụ và nói chuyện với các thành viên.",
      "error": "Màn hình còn đen hoặc không điều khiển được Hải Quỳ.",
      "syncTo": "party.free"
    },
    "routeinst.noodle-self.08": {
      "action": "Thử mở ném tuyết từ phần khám phá tự do.",
      "result": "Có thể thách đấu Shylvie, Kohi, Leo hoặc Hakase và quay lại bữa tiệc.",
      "error": "Minigame không mở hoặc quay về sai trạng thái.",
      "syncTo": "party.snow"
    },
    "routeinst.noodle-self.09": {
      "action": "Tới bữa tiệc.",
      "result": "Có nồi mì cay, bình Sting 20 lít, cảnh tuyết và các cảnh ăn uống liên quan.",
      "error": "Thiếu các chi tiết chính hoặc lẫn route quà khác.",
      "syncTo": "noodle.party"
    },
    "routeinst.noodle-self.10": {
      "action": "Sau cuộc gọi từ Silver Wing, đi tới đoạn cuối.",
      "result": "Route đi thẳng tới gợi ý cuối; không tự thêm buổi sáng hôm sau.",
      "error": "Xuất hiện cảnh sáng hôm sau không thuộc route.",
      "syncTo": "noodle.end"
    },
    "routeinst.ask-leo-coffee.00": {
      "action": "Tại Map13, nói chuyện với Leo đủ ba lần.",
      "result": "Sau lần thứ ba game tự vào cuộc trò chuyện riêng và cho chọn ba địa điểm.",
      "error": "Không mở lựa chọn hoặc mở trước lần thứ ba.",
      "syncTo": "askleo.three"
    },
    "routeinst.ask-leo-coffee.01": {
      "action": "Chọn cửa hàng và tới đúng nơi.",
      "result": "Scene mua quà tự bắt đầu khi vừa tới đúng cửa hàng.",
      "error": "Tới sai cửa hàng hoặc scene không tự bắt đầu.",
      "syncTo": "askleo.shopauto"
    },
    "routeinst.ask-leo-coffee.02": {
      "action": "Hoàn thành nhánh hỏi Leo → Tiệm cà phê.",
      "result": "Tới Map58 (Tiệm cà phê), mua Cà phê Luminous cho Kohi, dự tiệc và kết thúc bằng Lời gợi ý về cà phê Luminous.",
      "error": "Bị đưa tới cửa hàng khác hoặc phần sau dùng quà/người nhận sai.",
      "syncTo": "route.askleo.coffee"
    },
    "routeinst.ask-leo-coffee.03": {
      "action": "Tới Map60 (Chuẩn bị quà theo lời Leo).",
      "result": "Quà vừa mua được giữ đúng; không phát thoại của route mua đá.",
      "error": "Quà/thoại bị đổi route.",
      "syncTo": "askleo.map60"
    },
    "routeinst.ask-leo-coffee.04": {
      "action": "Xem cảnh thử đồ ở Map60.",
      "result": "Chỉ đổi sang trang phục Giáng sinh sau khi xem xong.",
      "error": "Đổi sprite trước khi cảnh thử đồ kết thúc.",
      "syncTo": "askleo.outfit"
    },
    "routeinst.ask-leo-coffee.05": {
      "action": "Tới Map38.",
      "result": "Màn hình sáng lại và người chơi được tự do khám phá.",
      "error": "Màn hình tối hoặc bị khóa điều khiển.",
      "syncTo": "askleo.party"
    },
    "routeinst.ask-leo-coffee.06": {
      "action": "Tới đoạn được tự do khám phá trong tiệc.",
      "result": "Có thể đi lại, vào khu vực phụ và nói chuyện với các thành viên.",
      "error": "Màn hình còn đen hoặc không điều khiển được Hải Quỳ.",
      "syncTo": "party.free"
    },
    "routeinst.ask-leo-coffee.07": {
      "action": "Thử mở ném tuyết từ phần khám phá tự do.",
      "result": "Có thể thách đấu Shylvie, Kohi, Leo hoặc Hakase và quay lại bữa tiệc.",
      "error": "Minigame không mở hoặc quay về sai trạng thái.",
      "syncTo": "party.snow"
    },
    "routeinst.ask-leo-coffee.08": {
      "action": "Chọn tiếp tục bữa tiệc.",
      "result": "Cảnh trao quà chạy đúng một lần rồi chuyển sang phần sau của route.",
      "error": "Scene lặp, crash hoặc tiếp tục sai route.",
      "syncTo": "party.continue"
    },
    "routeinst.ask-leo-weapon.00": {
      "action": "Tại Map13, nói chuyện với Leo đủ ba lần.",
      "result": "Sau lần thứ ba game tự vào cuộc trò chuyện riêng và cho chọn ba địa điểm.",
      "error": "Không mở lựa chọn hoặc mở trước lần thứ ba.",
      "syncTo": "askleo.three"
    },
    "routeinst.ask-leo-weapon.01": {
      "action": "Chọn cửa hàng và tới đúng nơi.",
      "result": "Scene mua quà tự bắt đầu khi vừa tới đúng cửa hàng.",
      "error": "Tới sai cửa hàng hoặc scene không tự bắt đầu.",
      "syncTo": "askleo.shopauto"
    },
    "routeinst.ask-leo-weapon.02": {
      "action": "Hoàn thành nhánh hỏi Leo → Cửa hàng vũ khí.",
      "result": "Tới Map59 (Cửa hàng vũ khí), mua Khiên cho Shylvie, dự tiệc và kết thúc bằng Lời gợi ý về chiếc khiên.",
      "error": "Bị đưa tới cửa hàng khác hoặc phần sau dùng quà/người nhận sai.",
      "syncTo": "route.askleo.weapon"
    },
    "routeinst.ask-leo-weapon.03": {
      "action": "Tới Map60 (Chuẩn bị quà theo lời Leo).",
      "result": "Quà vừa mua được giữ đúng; không phát thoại của route mua đá.",
      "error": "Quà/thoại bị đổi route.",
      "syncTo": "askleo.map60"
    },
    "routeinst.ask-leo-weapon.04": {
      "action": "Xem cảnh thử đồ ở Map60.",
      "result": "Chỉ đổi sang trang phục Giáng sinh sau khi xem xong.",
      "error": "Đổi sprite trước khi cảnh thử đồ kết thúc.",
      "syncTo": "askleo.outfit"
    },
    "routeinst.ask-leo-weapon.05": {
      "action": "Tới Map38.",
      "result": "Màn hình sáng lại và người chơi được tự do khám phá.",
      "error": "Màn hình tối hoặc bị khóa điều khiển.",
      "syncTo": "askleo.party"
    },
    "routeinst.ask-leo-weapon.06": {
      "action": "Tới đoạn được tự do khám phá trong tiệc.",
      "result": "Có thể đi lại, vào khu vực phụ và nói chuyện với các thành viên.",
      "error": "Màn hình còn đen hoặc không điều khiển được Hải Quỳ.",
      "syncTo": "party.free"
    },
    "routeinst.ask-leo-weapon.07": {
      "action": "Thử mở ném tuyết từ phần khám phá tự do.",
      "result": "Có thể thách đấu Shylvie, Kohi, Leo hoặc Hakase và quay lại bữa tiệc.",
      "error": "Minigame không mở hoặc quay về sai trạng thái.",
      "syncTo": "party.snow"
    },
    "routeinst.ask-leo-weapon.08": {
      "action": "Chọn tiếp tục bữa tiệc.",
      "result": "Cảnh trao quà chạy đúng một lần rồi chuyển sang phần sau của route.",
      "error": "Scene lặp, crash hoặc tiếp tục sai route.",
      "syncTo": "party.continue"
    },
    "routeinst.ask-leo-magic.00": {
      "action": "Tại Map13, nói chuyện với Leo đủ ba lần.",
      "result": "Sau lần thứ ba game tự vào cuộc trò chuyện riêng và cho chọn ba địa điểm.",
      "error": "Không mở lựa chọn hoặc mở trước lần thứ ba.",
      "syncTo": "askleo.three"
    },
    "routeinst.ask-leo-magic.01": {
      "action": "Chọn cửa hàng và tới đúng nơi.",
      "result": "Scene mua quà tự bắt đầu khi vừa tới đúng cửa hàng.",
      "error": "Tới sai cửa hàng hoặc scene không tự bắt đầu.",
      "syncTo": "askleo.shopauto"
    },
    "routeinst.ask-leo-magic.02": {
      "action": "Hoàn thành nhánh hỏi Leo → Tiệm ma pháp.",
      "result": "Tới Map57 (Tiệm ma pháp), mua Áo choàng luyện tàng hình cho Hakase, dự tiệc và kết thúc bằng Gợi ý có Drosalya.",
      "error": "Bị đưa tới cửa hàng khác hoặc phần sau dùng quà/người nhận sai.",
      "syncTo": "route.askleo.magic"
    },
    "routeinst.ask-leo-magic.03": {
      "action": "Tới Map60 (Chuẩn bị quà theo lời Leo).",
      "result": "Quà vừa mua được giữ đúng; không phát thoại của route mua đá.",
      "error": "Quà/thoại bị đổi route.",
      "syncTo": "askleo.map60"
    },
    "routeinst.ask-leo-magic.04": {
      "action": "Xem cảnh thử đồ ở Map60.",
      "result": "Chỉ đổi sang trang phục Giáng sinh sau khi xem xong.",
      "error": "Đổi sprite trước khi cảnh thử đồ kết thúc.",
      "syncTo": "askleo.outfit"
    },
    "routeinst.ask-leo-magic.05": {
      "action": "Tới Map38.",
      "result": "Màn hình sáng lại và người chơi được tự do khám phá.",
      "error": "Màn hình tối hoặc bị khóa điều khiển.",
      "syncTo": "askleo.party"
    },
    "routeinst.ask-leo-magic.06": {
      "action": "Tới đoạn được tự do khám phá trong tiệc.",
      "result": "Có thể đi lại, vào khu vực phụ và nói chuyện với các thành viên.",
      "error": "Màn hình còn đen hoặc không điều khiển được Hải Quỳ.",
      "syncTo": "party.free"
    },
    "routeinst.ask-leo-magic.07": {
      "action": "Thử mở ném tuyết từ phần khám phá tự do.",
      "result": "Có thể thách đấu Shylvie, Kohi, Leo hoặc Hakase và quay lại bữa tiệc.",
      "error": "Minigame không mở hoặc quay về sai trạng thái.",
      "syncTo": "party.snow"
    },
    "routeinst.ask-leo-magic.08": {
      "action": "Chọn tiếp tục bữa tiệc.",
      "result": "Cảnh trao quà chạy đúng một lần rồi chuyển sang phần sau của route.",
      "error": "Scene lặp, crash hoặc tiếp tục sai route.",
      "syncTo": "party.continue"
    },
    "routeinst.stone-leo.00": {
      "action": "Tại Map13, nói chuyện với Shylvie tới khi nhận tọa độ tiệm đá phong thủy.",
      "result": "Route dẫn tới đúng tiệm đá.",
      "error": "Bị đưa tới tiệm của route hỏi Leo.",
      "syncTo": "stone.unlock"
    },
    "routeinst.stone-leo.01": {
      "action": "Tại tiệm đá, xem các kệ và chọn người nhận.",
      "result": "Có đủ bốn lựa chọn Leo, Kohi, Shylvie, Hakase.",
      "error": "Thiếu lựa chọn hoặc ảnh đá không khớp.",
      "syncTo": "stone.browse"
    },
    "routeinst.stone-leo.02": {
      "action": "Hoàn thành nhánh đá phong thủy → Leo / Purple Garnet.",
      "result": "Viên đá tím giúp giải trừ trạng thái bất lợi/độc tố và hỗ trợ tinh thần; Leo thấy mệt mỏi tan biến, sau đó đá vỡ và được làm chuông gió.",
      "error": "Ảnh đá, hiệu ứng, người nhận hoặc đoạn sau không khớp.",
      "syncTo": "route.stone.leo"
    },
    "routeinst.stone-leo.03": {
      "action": "Theo route qua chuẩn bị quà, tiệc và đoạn sau.",
      "result": "Người nhận, ảnh viên đá, hiệu ứng và gợi ý cuối giữ cùng một nhánh.",
      "error": "Bất kỳ đoạn nào đổi sang đá/người khác.",
      "syncTo": "stone.consistency"
    },
    "routeinst.stone-leo.04": {
      "action": "Xem đoạn Hải Quỳ đặt quà rồi ngủ.",
      "result": "Hải Quỳ ngủ trước rồi mới thức dậy.",
      "error": "Cảnh bị bỏ qua hoặc thứ tự đảo.",
      "syncTo": "prep.sleep"
    },
    "routeinst.stone-leo.05": {
      "action": "Xem trọn cảnh thử trang phục.",
      "result": "Các bộ đồ chạy đúng thứ tự; chỉ đổi sang đồ Giáng sinh sau bộ cuối.",
      "error": "Sprite đổi quá sớm hoặc lóe sai hình khi màn hình tối.",
      "syncTo": "prep.outfit"
    },
    "routeinst.stone-leo.06": {
      "action": "Chờ cảnh chuẩn bị kết thúc.",
      "result": "Màn hình sáng trở lại và câu chuyện tiếp tục.",
      "error": "Màn hình tối vĩnh viễn hoặc lóe sáng bất thường.",
      "syncTo": "prep.light"
    },
    "routeinst.stone-leo.07": {
      "action": "Đi vào Map38 (Văn phòng Wanderer trong tiệc Giáng sinh).",
      "result": "Phần mở đầu của bữa tiệc khớp route hiện tại.",
      "error": "Thoại/ảnh của route khác xuất hiện.",
      "syncTo": "party.arrival"
    },
    "routeinst.stone-leo.08": {
      "action": "Tới đoạn được tự do khám phá trong tiệc.",
      "result": "Có thể đi lại, vào khu vực phụ và nói chuyện với các thành viên.",
      "error": "Màn hình còn đen hoặc không điều khiển được Hải Quỳ.",
      "syncTo": "party.free"
    },
    "routeinst.stone-leo.09": {
      "action": "Thử mở ném tuyết từ phần khám phá tự do.",
      "result": "Có thể thách đấu Shylvie, Kohi, Leo hoặc Hakase và quay lại bữa tiệc.",
      "error": "Minigame không mở hoặc quay về sai trạng thái.",
      "syncTo": "party.snow"
    },
    "routeinst.stone-leo.10": {
      "action": "Chọn tiếp tục bữa tiệc.",
      "result": "Cảnh trao quà chạy đúng một lần rồi chuyển sang phần sau của route.",
      "error": "Scene lặp, crash hoặc tiếp tục sai route.",
      "syncTo": "party.continue"
    },
    "routeinst.stone-kohi.00": {
      "action": "Tại Map13, nói chuyện với Shylvie tới khi nhận tọa độ tiệm đá phong thủy.",
      "result": "Route dẫn tới đúng tiệm đá.",
      "error": "Bị đưa tới tiệm của route hỏi Leo.",
      "syncTo": "stone.unlock"
    },
    "routeinst.stone-kohi.01": {
      "action": "Tại tiệm đá, xem các kệ và chọn người nhận.",
      "result": "Có đủ bốn lựa chọn Leo, Kohi, Shylvie, Hakase.",
      "error": "Thiếu lựa chọn hoặc ảnh đá không khớp.",
      "syncTo": "stone.browse"
    },
    "routeinst.stone-kohi.02": {
      "action": "Hoàn thành nhánh đá phong thủy → Kohi / Kim cương hình hạt cà phê.",
      "result": "Kohi vui mừng, cài viên kim cương lên tóc; gợi ý cuối nhắc công dụng xua đuổi ma quỷ bị Hải Quỳ bỏ qua.",
      "error": "Ảnh đá, hiệu ứng, người nhận hoặc đoạn sau không khớp.",
      "syncTo": "route.stone.kohi"
    },
    "routeinst.stone-kohi.03": {
      "action": "Theo route qua chuẩn bị quà, tiệc và đoạn sau.",
      "result": "Người nhận, ảnh viên đá, hiệu ứng và gợi ý cuối giữ cùng một nhánh.",
      "error": "Bất kỳ đoạn nào đổi sang đá/người khác.",
      "syncTo": "stone.consistency"
    },
    "routeinst.stone-kohi.04": {
      "action": "Xem đoạn Hải Quỳ đặt quà rồi ngủ.",
      "result": "Hải Quỳ ngủ trước rồi mới thức dậy.",
      "error": "Cảnh bị bỏ qua hoặc thứ tự đảo.",
      "syncTo": "prep.sleep"
    },
    "routeinst.stone-kohi.05": {
      "action": "Xem trọn cảnh thử trang phục.",
      "result": "Các bộ đồ chạy đúng thứ tự; chỉ đổi sang đồ Giáng sinh sau bộ cuối.",
      "error": "Sprite đổi quá sớm hoặc lóe sai hình khi màn hình tối.",
      "syncTo": "prep.outfit"
    },
    "routeinst.stone-kohi.06": {
      "action": "Chờ cảnh chuẩn bị kết thúc.",
      "result": "Màn hình sáng trở lại và câu chuyện tiếp tục.",
      "error": "Màn hình tối vĩnh viễn hoặc lóe sáng bất thường.",
      "syncTo": "prep.light"
    },
    "routeinst.stone-kohi.07": {
      "action": "Đi vào Map38 (Văn phòng Wanderer trong tiệc Giáng sinh).",
      "result": "Phần mở đầu của bữa tiệc khớp route hiện tại.",
      "error": "Thoại/ảnh của route khác xuất hiện.",
      "syncTo": "party.arrival"
    },
    "routeinst.stone-kohi.08": {
      "action": "Tới đoạn được tự do khám phá trong tiệc.",
      "result": "Có thể đi lại, vào khu vực phụ và nói chuyện với các thành viên.",
      "error": "Màn hình còn đen hoặc không điều khiển được Hải Quỳ.",
      "syncTo": "party.free"
    },
    "routeinst.stone-kohi.09": {
      "action": "Thử mở ném tuyết từ phần khám phá tự do.",
      "result": "Có thể thách đấu Shylvie, Kohi, Leo hoặc Hakase và quay lại bữa tiệc.",
      "error": "Minigame không mở hoặc quay về sai trạng thái.",
      "syncTo": "party.snow"
    },
    "routeinst.stone-kohi.10": {
      "action": "Chọn tiếp tục bữa tiệc.",
      "result": "Cảnh trao quà chạy đúng một lần rồi chuyển sang phần sau của route.",
      "error": "Scene lặp, crash hoặc tiếp tục sai route.",
      "syncTo": "party.continue"
    },
    "routeinst.stone-shylvie.00": {
      "action": "Tại Map13, nói chuyện với Shylvie tới khi nhận tọa độ tiệm đá phong thủy.",
      "result": "Route dẫn tới đúng tiệm đá.",
      "error": "Bị đưa tới tiệm của route hỏi Leo.",
      "syncTo": "stone.unlock"
    },
    "routeinst.stone-shylvie.01": {
      "action": "Tại tiệm đá, xem các kệ và chọn người nhận.",
      "result": "Có đủ bốn lựa chọn Leo, Kohi, Shylvie, Hakase.",
      "error": "Thiếu lựa chọn hoặc ảnh đá không khớp.",
      "syncTo": "stone.browse"
    },
    "routeinst.stone-shylvie.02": {
      "action": "Hoàn thành nhánh đá phong thủy → Shylvie / Congo Tourmaline.",
      "result": "Viên đá phát sáng và triệu hồi một chiếc khiên phép thuật trong suốt.",
      "error": "Ảnh đá, hiệu ứng, người nhận hoặc đoạn sau không khớp.",
      "syncTo": "route.stone.shylvie"
    },
    "routeinst.stone-shylvie.03": {
      "action": "Theo route qua chuẩn bị quà, tiệc và đoạn sau.",
      "result": "Người nhận, ảnh viên đá, hiệu ứng và gợi ý cuối giữ cùng một nhánh.",
      "error": "Bất kỳ đoạn nào đổi sang đá/người khác.",
      "syncTo": "stone.consistency"
    },
    "routeinst.stone-shylvie.04": {
      "action": "Xem đoạn Hải Quỳ đặt quà rồi ngủ.",
      "result": "Hải Quỳ ngủ trước rồi mới thức dậy.",
      "error": "Cảnh bị bỏ qua hoặc thứ tự đảo.",
      "syncTo": "prep.sleep"
    },
    "routeinst.stone-shylvie.05": {
      "action": "Xem trọn cảnh thử trang phục.",
      "result": "Các bộ đồ chạy đúng thứ tự; chỉ đổi sang đồ Giáng sinh sau bộ cuối.",
      "error": "Sprite đổi quá sớm hoặc lóe sai hình khi màn hình tối.",
      "syncTo": "prep.outfit"
    },
    "routeinst.stone-shylvie.06": {
      "action": "Chờ cảnh chuẩn bị kết thúc.",
      "result": "Màn hình sáng trở lại và câu chuyện tiếp tục.",
      "error": "Màn hình tối vĩnh viễn hoặc lóe sáng bất thường.",
      "syncTo": "prep.light"
    },
    "routeinst.stone-shylvie.07": {
      "action": "Đi vào Map38 (Văn phòng Wanderer trong tiệc Giáng sinh).",
      "result": "Phần mở đầu của bữa tiệc khớp route hiện tại.",
      "error": "Thoại/ảnh của route khác xuất hiện.",
      "syncTo": "party.arrival"
    },
    "routeinst.stone-shylvie.08": {
      "action": "Tới đoạn được tự do khám phá trong tiệc.",
      "result": "Có thể đi lại, vào khu vực phụ và nói chuyện với các thành viên.",
      "error": "Màn hình còn đen hoặc không điều khiển được Hải Quỳ.",
      "syncTo": "party.free"
    },
    "routeinst.stone-shylvie.09": {
      "action": "Thử mở ném tuyết từ phần khám phá tự do.",
      "result": "Có thể thách đấu Shylvie, Kohi, Leo hoặc Hakase và quay lại bữa tiệc.",
      "error": "Minigame không mở hoặc quay về sai trạng thái.",
      "syncTo": "party.snow"
    },
    "routeinst.stone-shylvie.10": {
      "action": "Chọn tiếp tục bữa tiệc.",
      "result": "Cảnh trao quà chạy đúng một lần rồi chuyển sang phần sau của route.",
      "error": "Scene lặp, crash hoặc tiếp tục sai route.",
      "syncTo": "party.continue"
    },
    "routeinst.stone-hakase.00": {
      "action": "Tại Map13, nói chuyện với Shylvie tới khi nhận tọa độ tiệm đá phong thủy.",
      "result": "Route dẫn tới đúng tiệm đá.",
      "error": "Bị đưa tới tiệm của route hỏi Leo.",
      "syncTo": "stone.unlock"
    },
    "routeinst.stone-hakase.01": {
      "action": "Tại tiệm đá, xem các kệ và chọn người nhận.",
      "result": "Có đủ bốn lựa chọn Leo, Kohi, Shylvie, Hakase.",
      "error": "Thiếu lựa chọn hoặc ảnh đá không khớp.",
      "syncTo": "stone.browse"
    },
    "routeinst.stone-hakase.02": {
      "action": "Hoàn thành nhánh đá phong thủy → Hakase / Rainbow Fluorite.",
      "result": "Đá tri thức chứa ngẫu nhiên phép thuật; Hakase học các phép biến đổi và dùng đá lưu ma lực/thông tin.",
      "error": "Ảnh đá, hiệu ứng, người nhận hoặc đoạn sau không khớp.",
      "syncTo": "route.stone.hakase"
    },
    "routeinst.stone-hakase.03": {
      "action": "Theo route qua chuẩn bị quà, tiệc và đoạn sau.",
      "result": "Người nhận, ảnh viên đá, hiệu ứng và gợi ý cuối giữ cùng một nhánh.",
      "error": "Bất kỳ đoạn nào đổi sang đá/người khác.",
      "syncTo": "stone.consistency"
    },
    "routeinst.stone-hakase.04": {
      "action": "Xem đoạn Hải Quỳ đặt quà rồi ngủ.",
      "result": "Hải Quỳ ngủ trước rồi mới thức dậy.",
      "error": "Cảnh bị bỏ qua hoặc thứ tự đảo.",
      "syncTo": "prep.sleep"
    },
    "routeinst.stone-hakase.05": {
      "action": "Xem trọn cảnh thử trang phục.",
      "result": "Các bộ đồ chạy đúng thứ tự; chỉ đổi sang đồ Giáng sinh sau bộ cuối.",
      "error": "Sprite đổi quá sớm hoặc lóe sai hình khi màn hình tối.",
      "syncTo": "prep.outfit"
    },
    "routeinst.stone-hakase.06": {
      "action": "Chờ cảnh chuẩn bị kết thúc.",
      "result": "Màn hình sáng trở lại và câu chuyện tiếp tục.",
      "error": "Màn hình tối vĩnh viễn hoặc lóe sáng bất thường.",
      "syncTo": "prep.light"
    },
    "routeinst.stone-hakase.07": {
      "action": "Đi vào Map38 (Văn phòng Wanderer trong tiệc Giáng sinh).",
      "result": "Phần mở đầu của bữa tiệc khớp route hiện tại.",
      "error": "Thoại/ảnh của route khác xuất hiện.",
      "syncTo": "party.arrival"
    },
    "routeinst.stone-hakase.08": {
      "action": "Tới đoạn được tự do khám phá trong tiệc.",
      "result": "Có thể đi lại, vào khu vực phụ và nói chuyện với các thành viên.",
      "error": "Màn hình còn đen hoặc không điều khiển được Hải Quỳ.",
      "syncTo": "party.free"
    },
    "routeinst.stone-hakase.09": {
      "action": "Thử mở ném tuyết từ phần khám phá tự do.",
      "result": "Có thể thách đấu Shylvie, Kohi, Leo hoặc Hakase và quay lại bữa tiệc.",
      "error": "Minigame không mở hoặc quay về sai trạng thái.",
      "syncTo": "party.snow"
    },
    "routeinst.stone-hakase.10": {
      "action": "Chọn tiếp tục bữa tiệc.",
      "result": "Cảnh trao quà chạy đúng một lần rồi chuyển sang phần sau của route.",
      "error": "Scene lặp, crash hoặc tiếp tục sai route.",
      "syncTo": "party.continue"
    },
    "routeinst.book-shylvie.00": {
      "action": "Hoàn thành đoạn mở đầu tại Map3 (Văn phòng Silver Wing).",
      "result": "Hội thoại đúng thứ tự/người nói; nhân vật không bị kẹt khi tự đi.",
      "error": "Sai người nói, camera lệch hoặc nhân vật bị kẹt.",
      "syncTo": "open.map3"
    },
    "routeinst.book-shylvie.01": {
      "action": "Nếu đi qua Map17 (Hành lang Silver Wing), đi hết hành lang tới thành phố.",
      "result": "Hải Quỳ tới đúng vị trí ở Map6; không tiếp tục tự chạy theo lộ trình cũ.",
      "error": "Sang map mới nhưng nhân vật vẫn tự chạy hoặc xuất hiện lệch vị trí.",
      "syncTo": "open.map17"
    },
    "routeinst.book-shylvie.02": {
      "action": "Đi qua Map6 (Thành phố) và lên xe bus.",
      "result": "Camera bắt kịp Hải Quỳ và chuyển lên xe bus bình thường.",
      "error": "Camera bỏ lại nhân vật hoặc chuyển map sai.",
      "syncTo": "open.map6"
    },
    "routeinst.book-shylvie.03": {
      "action": "Ở Map10 (Trong xe bus), xem hết đoạn suy nghĩ và chọn điểm đến.",
      "result": "Lời kể hiện bình thường; mỗi nút chọn dẫn đúng nơi ghi trên nút.",
      "error": "Màn hình đen vĩnh viễn, lóe sáng hoặc chọn một nơi nhưng tới nơi khác.",
      "syncTo": "open.map10"
    },
    "routeinst.book-shylvie.04": {
      "action": "Từ Map10 đi qua Map22 (Nhà Hải Quỳ), Map21 và tới Map23 (Tiệm sách phép Atlantis).",
      "result": "Đường đi liền mạch, không kẹt ở map trống/tối.",
      "error": "Sai map hoặc màn hình tối vĩnh viễn.",
      "syncTo": "book.housepath"
    },
    "routeinst.book-shylvie.05": {
      "action": "Chọn sách Phép thuật dịch chuyển nâng cao và mang ra quầy.",
      "result": "Sau khi chọn không đổi sang Ma Vương Cổ Đại; Shylvie nhận đúng sách; đoạn sau nói về phép hoán đổi/dịch chuyển và đúng gợi ý route.",
      "error": "Sách/người nhận/đoạn sau bị đổi.",
      "syncTo": "route.book.shylvie"
    },
    "routeinst.book-shylvie.06": {
      "action": "Xem đoạn Hải Quỳ đặt quà rồi ngủ.",
      "result": "Hải Quỳ ngủ trước rồi mới thức dậy.",
      "error": "Cảnh bị bỏ qua hoặc thứ tự đảo.",
      "syncTo": "prep.sleep"
    },
    "routeinst.book-shylvie.07": {
      "action": "Xem trọn cảnh thử trang phục.",
      "result": "Các bộ đồ chạy đúng thứ tự; chỉ đổi sang đồ Giáng sinh sau bộ cuối.",
      "error": "Sprite đổi quá sớm hoặc lóe sai hình khi màn hình tối.",
      "syncTo": "prep.outfit"
    },
    "routeinst.book-shylvie.08": {
      "action": "Chờ cảnh chuẩn bị kết thúc.",
      "result": "Màn hình sáng trở lại và câu chuyện tiếp tục.",
      "error": "Màn hình tối vĩnh viễn hoặc lóe sáng bất thường.",
      "syncTo": "prep.light"
    },
    "routeinst.book-shylvie.09": {
      "action": "Sau khi chuẩn bị sách, xem cảnh Hải Quỳ ngủ quên và tới văn phòng muộn.",
      "result": "Sprite chỉ đổi sau cảnh thay đồ; khi tới Map38 không phát lại toàn bộ đoạn chuẩn bị tiệc.",
      "error": "Đổi sprite sớm hoặc phát nhầm cảnh tới sớm.",
      "syncTo": "book.late"
    },
    "routeinst.book-shylvie.10": {
      "action": "Tới đoạn được tự do khám phá trong tiệc.",
      "result": "Có thể đi lại, vào khu vực phụ và nói chuyện với các thành viên.",
      "error": "Màn hình còn đen hoặc không điều khiển được Hải Quỳ.",
      "syncTo": "party.free"
    },
    "routeinst.book-shylvie.11": {
      "action": "Thử mở ném tuyết từ phần khám phá tự do.",
      "result": "Có thể thách đấu Shylvie, Kohi, Leo hoặc Hakase và quay lại bữa tiệc.",
      "error": "Minigame không mở hoặc quay về sai trạng thái.",
      "syncTo": "party.snow"
    },
    "routeinst.book-shylvie.12": {
      "action": "Chọn tiếp tục bữa tiệc.",
      "result": "Cảnh trao quà chạy đúng một lần rồi chuyển sang phần sau của route.",
      "error": "Scene lặp, crash hoặc tiếp tục sai route.",
      "syncTo": "party.continue"
    },
    "routeinst.book-hakase.00": {
      "action": "Hoàn thành đoạn mở đầu tại Map3 (Văn phòng Silver Wing).",
      "result": "Hội thoại đúng thứ tự/người nói; nhân vật không bị kẹt khi tự đi.",
      "error": "Sai người nói, camera lệch hoặc nhân vật bị kẹt.",
      "syncTo": "open.map3"
    },
    "routeinst.book-hakase.01": {
      "action": "Nếu đi qua Map17 (Hành lang Silver Wing), đi hết hành lang tới thành phố.",
      "result": "Hải Quỳ tới đúng vị trí ở Map6; không tiếp tục tự chạy theo lộ trình cũ.",
      "error": "Sang map mới nhưng nhân vật vẫn tự chạy hoặc xuất hiện lệch vị trí.",
      "syncTo": "open.map17"
    },
    "routeinst.book-hakase.02": {
      "action": "Đi qua Map6 (Thành phố) và lên xe bus.",
      "result": "Camera bắt kịp Hải Quỳ và chuyển lên xe bus bình thường.",
      "error": "Camera bỏ lại nhân vật hoặc chuyển map sai.",
      "syncTo": "open.map6"
    },
    "routeinst.book-hakase.03": {
      "action": "Ở Map10 (Trong xe bus), xem hết đoạn suy nghĩ và chọn điểm đến.",
      "result": "Lời kể hiện bình thường; mỗi nút chọn dẫn đúng nơi ghi trên nút.",
      "error": "Màn hình đen vĩnh viễn, lóe sáng hoặc chọn một nơi nhưng tới nơi khác.",
      "syncTo": "open.map10"
    },
    "routeinst.book-hakase.04": {
      "action": "Từ Map10 đi qua Map22 (Nhà Hải Quỳ), Map21 và tới Map23 (Tiệm sách phép Atlantis).",
      "result": "Đường đi liền mạch, không kẹt ở map trống/tối.",
      "error": "Sai map hoặc màn hình tối vĩnh viễn.",
      "syncTo": "book.housepath"
    },
    "routeinst.book-hakase.05": {
      "action": "Chọn sách Ma Vương Cổ Đại và mang ra quầy.",
      "result": "Sau khi chọn không đổi sang sách dịch chuyển; Hakase nhận đúng sách; đoạn sau nói về hấp thụ ma lực Ma Vương; vòng quà có váy và ốp lưng đúng thời điểm; gợi ý cuối đúng route.",
      "error": "Sách/người nhận/đoạn sau bị đổi.",
      "syncTo": "route.book.hakase"
    },
    "routeinst.book-hakase.06": {
      "action": "Xem đoạn Hải Quỳ đặt quà rồi ngủ.",
      "result": "Hải Quỳ ngủ trước rồi mới thức dậy.",
      "error": "Cảnh bị bỏ qua hoặc thứ tự đảo.",
      "syncTo": "prep.sleep"
    },
    "routeinst.book-hakase.07": {
      "action": "Xem trọn cảnh thử trang phục.",
      "result": "Các bộ đồ chạy đúng thứ tự; chỉ đổi sang đồ Giáng sinh sau bộ cuối.",
      "error": "Sprite đổi quá sớm hoặc lóe sai hình khi màn hình tối.",
      "syncTo": "prep.outfit"
    },
    "routeinst.book-hakase.08": {
      "action": "Chờ cảnh chuẩn bị kết thúc.",
      "result": "Màn hình sáng trở lại và câu chuyện tiếp tục.",
      "error": "Màn hình tối vĩnh viễn hoặc lóe sáng bất thường.",
      "syncTo": "prep.light"
    },
    "routeinst.book-hakase.09": {
      "action": "Sau khi chuẩn bị sách, xem cảnh Hải Quỳ ngủ quên và tới văn phòng muộn.",
      "result": "Sprite chỉ đổi sau cảnh thay đồ; khi tới Map38 không phát lại toàn bộ đoạn chuẩn bị tiệc.",
      "error": "Đổi sprite sớm hoặc phát nhầm cảnh tới sớm.",
      "syncTo": "book.late"
    },
    "routeinst.book-hakase.10": {
      "action": "Tới đoạn được tự do khám phá trong tiệc.",
      "result": "Có thể đi lại, vào khu vực phụ và nói chuyện với các thành viên.",
      "error": "Màn hình còn đen hoặc không điều khiển được Hải Quỳ.",
      "syncTo": "party.free"
    },
    "routeinst.book-hakase.11": {
      "action": "Thử mở ném tuyết từ phần khám phá tự do.",
      "result": "Có thể thách đấu Shylvie, Kohi, Leo hoặc Hakase và quay lại bữa tiệc.",
      "error": "Minigame không mở hoặc quay về sai trạng thái.",
      "syncTo": "party.snow"
    },
    "routeinst.book-hakase.12": {
      "action": "Chọn tiếp tục bữa tiệc.",
      "result": "Cảnh trao quà chạy đúng một lần rồi chuyển sang phần sau của route.",
      "error": "Scene lặp, crash hoặc tiếp tục sai route.",
      "syncTo": "party.continue"
    },
    "routeinst.shopkeeper-first.00": {
      "action": "Nói chuyện với chủ tiệm trước khi chọn sách.",
      "result": "Tạo vật Vực Sâu phát nổ và chiếm hữu Hải Quỳ/Aira.",
      "error": "Không kích hoạt route hoặc lại đi vào chọn sách bình thường.",
      "syncTo": "route.shopkeeper.explosion"
    },
    "routeinst.shopkeeper-first.01": {
      "action": "Theo dõi Hải Quỳ tự phong ấn và nhóm Wanderer đi tìm.",
      "result": "Hải Quỳ tự phong ấn trong lồng; nhóm Wanderer lần theo dấu vết và tới giải cứu.",
      "error": "Bỏ qua tự phong ấn/giải cứu.",
      "syncTo": "route.shopkeeper.seal"
    },
    "routeinst.shopkeeper-first.02": {
      "action": "Quan sát lồng giam khi giải cứu.",
      "result": "Vết nứt đầu chậm/nặng, các vết sau nhanh dần tới khi vỡ.",
      "error": "Nhịp vỡ không tăng dần hoặc lồng vỡ quá sớm.",
      "syncTo": "route.shopkeeper.cracks"
    },
    "routeinst.shopkeeper-first.03": {
      "action": "Hoàn thành giải cứu.",
      "result": "Không mở khám phá tiệc và không đi qua Paulie rượt quái vật; đi tới gợi ý cuối và Title.",
      "error": "Nhảy vào route tiệc/rượt đuổi sai.",
      "syncTo": "route.shopkeeper.end"
    },
    "routeinst.warehouse-chase.00": {
      "action": "Ở Map22/Map26, tìm chìa khóa, vào phòng kho và bật đèn.",
      "result": "Trước khi bật đèn chỉ báo quá tối; sau khi bật mới dùng được các tương tác thật.",
      "error": "Có thể đọc đồ trong tối hoặc nhiều điểm bật đèn gây sai tiến độ.",
      "syncTo": "warehouse.keylight"
    },
    "routeinst.warehouse-chase.01": {
      "action": "Đọc hết Lá thư cuối của Dahria.",
      "result": "Đọc xong dẫn thẳng vào ký ức/rượt đuổi.",
      "error": "Quay sang route chọn sách hoặc đứng lại trong kho.",
      "syncTo": "warehouse.letter"
    },
    "routeinst.warehouse-chase.02": {
      "action": "Tại Map34 (Vòng vây clone), chờ đủ clone áp sát.",
      "result": "Cả 11 clone chạy sát quanh Hải Quỳ trước câu “Buông tao ra!”.",
      "error": "Thiếu clone hoặc câu thoại chạy quá sớm.",
      "syncTo": "clone.11"
    },
    "routeinst.warehouse-chase.03": {
      "action": "Sau khi Hải Quỳ đánh văng clone, quan sát quái vật.",
      "result": "Dấu chấm than/quay lên xảy ra trước; quái vật bước vào khung hình rồi mới gầm và rung màn hình.",
      "error": "Quái vật/gầm/rung sai thứ tự.",
      "syncTo": "clone.monster"
    },
    "routeinst.warehouse-chase.04": {
      "action": "Tại Map29, theo dõi Hải Quỳ và quái vật.",
      "result": "Cả hai chạy xuống; quái vật ở phía trên và tiến gần dần nhưng không xuyên qua Hải Quỳ.",
      "error": "Camera bỏ nhân vật hoặc quái vật vượt xuyên qua.",
      "syncTo": "chase.camera"
    },
    "routeinst.warehouse-chase.05": {
      "action": "Sau khi thoát rượt đuổi, xem Paulie xuất hiện.",
      "result": "Hải Quỳ nhảy lùi; camera đưa Hải Quỳ/quái vật khỏi khung rồi chỉ một Paulie rơi từ trên cao.",
      "error": "Có hai Paulie hoặc thứ tự camera/rơi sai.",
      "syncTo": "paulie.drop"
    },
    "routeinst.warehouse-chase.06": {
      "action": "Quan sát chuỗi Paulie đáp đất.",
      "result": "Ba hình đầu lặp khi rơi; hiệu ứng đáp đất tại Paulie; sau hiệu ứng trở về hình đứng thường.",
      "error": "Animation/hiệu ứng sai vị trí hoặc không trở về hình đứng.",
      "syncTo": "paulie.land"
    },
    "routeinst.warehouse-chase.07": {
      "action": "Quan sát Paulie khống chế quái vật.",
      "result": "Paulie hô tên đòn; hiệu ứng xuất hiện ở quái vật rồi mới chuyển sang hình bị trói.",
      "error": "Quái vật bị trói trước hiệu ứng hoặc hiệu ứng sai vị trí.",
      "syncTo": "paulie.bind"
    },
    "routeinst.warehouse-chase.08": {
      "action": "Xem hội thoại hai anh em.",
      "result": "Paulie nhảy sang bên phải Hải Quỳ khoảng hai ô; hai người quay mặt vào nhau.",
      "error": "Vị trí/hướng nhìn sai.",
      "syncTo": "paulie.talk"
    },
    "routeinst.warehouse-chase.09": {
      "action": "Xem Hải Quỳ kết liễu quái vật.",
      "result": "Đòn trúng quái vật, xác vỡ; màn hình tối dần và chỉ khi tối hẳn mới sang Map35.",
      "error": "Chuyển map quá sớm hoặc xác/hiệu ứng sai.",
      "syncTo": "paulie.finish"
    },
    "routeinst.warehouse-chase.10": {
      "action": "Khi Paulie rời đi, quan sát hiệu ứng dịch chuyển và điện thoại.",
      "result": "Paulie biến mất trước, hiệu ứng vẫn phát đủ ở vị trí cũ; hộp thoại điện thoại không còn đuôi.",
      "error": "Hiệu ứng bị cắt hoặc hộp thoại điện thoại có đuôi sai.",
      "syncTo": "paulie.leave"
    },
    "scene.noodlehome": {
      "action": "Xem cảnh Hải Quỳ và Paulie ăn mì ở nhà.",
      "result": "Hai người ngồi đối diện gần trung tâm; nền đúng theo hình dạng Hải Quỳ; suy nghĩ dùng thoại bình thường; kết thúc chuyển nơi tiếp theo với ánh sáng bình thường.",
      "error": "Camera dồn mép, nền sai, thoại suy nghĩ nổi hoặc chuyển cảnh tối."
    },
    "scene.snowbury": {
      "action": "Xem phân đoạn Hải Quỳ/Aira bị vùi trong tuyết.",
      "result": "Màn hình tối; thoại bình thường; CG6 cho Hải Quỳ, CG7 cho Bully Quỳ; chỉ sáng lại khi trả quyền đi lại.",
      "error": "CG/thoại sai hoặc sáng lại quá sớm."
    },
    "mapstone.shop": {
      "action": "Khám phá Tiệm đá phong thủy.",
      "result": "Các kệ đá, chủ tiệm, bốn lựa chọn người nhận và ảnh Purple Garnet / kim cương hạt cà phê / Congo Tourmaline / Rainbow Fluorite đều đúng.",
      "error": "Thiếu kệ/lựa chọn hoặc ảnh đá sai."
    },
    "miniinst.snow-shylvie.00": {
      "action": "Bắt đầu một trận ném tuyết.",
      "result": "Thanh máu, lượt, Perfect, Miss và sát thương cập nhật rõ ràng.",
      "error": "UI không cập nhật hoặc lẫn nhân vật."
    },
    "miniinst.snow-shylvie.01": {
      "action": "Thử thắng và thua Shylvie.",
      "result": "Nhịp tấn công, phản công, hình nhân vật và hai kết quả đều đúng Shylvie.",
      "error": "Lẫn hình/finisher của người khác."
    },
    "miniinst.snow-shylvie.02": {
      "action": "Kết thúc trận bằng thắng, thua hoặc chủ động dừng.",
      "result": "Tuyết, nhân vật, giao diện và âm thanh minigame biến mất trước khi quay về tiệc.",
      "error": "UI/âm thanh còn sót trên Map38."
    },
    "miniinst.snow-shylvie.03": {
      "action": "Thắng một đối thủ rồi thử người khác.",
      "result": "Kết quả thắng từng người được ghi nhớ độc lập.",
      "error": "Thắng người mới làm mất kết quả cũ."
    },
    "miniinst.snow-kohi.00": {
      "action": "Bắt đầu một trận ném tuyết.",
      "result": "Thanh máu, lượt, Perfect, Miss và sát thương cập nhật rõ ràng.",
      "error": "UI không cập nhật hoặc lẫn nhân vật."
    },
    "miniinst.snow-kohi.01": {
      "action": "Thử thắng và thua Kohi.",
      "result": "Cơ chế nhập chuỗi theo tỷ lệ hoàn thành chỉ xuất hiện ở phần Kohi.",
      "error": "Cơ chế xuất hiện ở người khác hoặc kết quả lẫn nhân vật."
    },
    "miniinst.snow-kohi.02": {
      "action": "Kết thúc trận bằng thắng, thua hoặc chủ động dừng.",
      "result": "Tuyết, nhân vật, giao diện và âm thanh minigame biến mất trước khi quay về tiệc.",
      "error": "UI/âm thanh còn sót trên Map38."
    },
    "miniinst.snow-kohi.03": {
      "action": "Thắng một đối thủ rồi thử người khác.",
      "result": "Kết quả thắng từng người được ghi nhớ độc lập.",
      "error": "Thắng người mới làm mất kết quả cũ."
    },
    "miniinst.snow-leo.00": {
      "action": "Bắt đầu một trận ném tuyết.",
      "result": "Thanh máu, lượt, Perfect, Miss và sát thương cập nhật rõ ràng.",
      "error": "UI không cập nhật hoặc lẫn nhân vật."
    },
    "miniinst.snow-leo.01": {
      "action": "Thử thắng và thua Leo.",
      "result": "Hướng đòn/mũi tên dễ nhìn; hình tấn công/phòng thủ đúng Leo.",
      "error": "Mũi tên/hình nhân vật sai."
    },
    "miniinst.snow-leo.02": {
      "action": "Kết thúc trận bằng thắng, thua hoặc chủ động dừng.",
      "result": "Tuyết, nhân vật, giao diện và âm thanh minigame biến mất trước khi quay về tiệc.",
      "error": "UI/âm thanh còn sót trên Map38."
    },
    "miniinst.snow-leo.03": {
      "action": "Thắng một đối thủ rồi thử người khác.",
      "result": "Kết quả thắng từng người được ghi nhớ độc lập.",
      "error": "Thắng người mới làm mất kết quả cũ."
    },
    "miniinst.snow-hakase.00": {
      "action": "Bắt đầu một trận ném tuyết.",
      "result": "Thanh máu, lượt, Perfect, Miss và sát thương cập nhật rõ ràng.",
      "error": "UI không cập nhật hoặc lẫn nhân vật."
    },
    "miniinst.snow-hakase.01": {
      "action": "Thử thắng và thua Hakase.",
      "result": "Mũi tên đẩy ma lực luôn thấy rõ; quỹ đạo/hình/kết quả đúng Hakase.",
      "error": "Mũi tên bị che hoặc lẫn Leo/Kohi."
    },
    "miniinst.snow-hakase.02": {
      "action": "Kết thúc trận bằng thắng, thua hoặc chủ động dừng.",
      "result": "Tuyết, nhân vật, giao diện và âm thanh minigame biến mất trước khi quay về tiệc.",
      "error": "UI/âm thanh còn sót trên Map38."
    },
    "miniinst.snow-hakase.03": {
      "action": "Thắng một đối thủ rồi thử người khác.",
      "result": "Kết quả thắng từng người được ghi nhớ độc lập.",
      "error": "Thắng người mới làm mất kết quả cũ."
    },
    "miniinst.fishing.00": {
      "action": "Mở minigame câu tôm.",
      "result": "Z thả/kéo/bắn tùy dụng cụ; Shift đổi cần câu/găng tay; X/Esc thoát.",
      "error": "Phím không hoạt động hoặc thoát sai trạng thái."
    },
    "miniinst.fishing.01": {
      "action": "Kéo tôm khi còn đen.",
      "result": "Hải Quỳ thả lại biển; bộ đếm không tăng.",
      "error": "Vẫn được tính cà phê."
    },
    "miniinst.fishing.02": {
      "action": "Kéo đúng lúc tôm chuyển vàng.",
      "result": "Tôm nhả cà phê Atlantis và bộ đếm tăng một.",
      "error": "Không tăng hoặc tăng sai."
    },
    "miniinst.fishing.03": {
      "action": "Cố kéo quá muộn.",
      "result": "Tôm đỏ rồi phát nổ; không tính thành công.",
      "error": "Vẫn tăng bộ đếm."
    },
    "miniinst.fishing.04": {
      "action": "Gặp lúc tôm giằng dây.",
      "result": "Làm theo hướng hiển thị; sai/chậm thì tôm thoát.",
      "error": "Không có hướng hoặc kết quả sai."
    },
    "miniinst.fishing.05": {
      "action": "Đổi sang găng tay và dùng beam.",
      "result": "Có cảnh báo, vùng tác dụng rõ và thời gian hồi.",
      "error": "Beam không cảnh báo/vùng mơ hồ/không hồi."
    },
    "miniinst.fishing.06": {
      "action": "Thoát trước khi đủ mười.",
      "result": "Quay lại lựa chọn; route chưa coi là có cà phê Atlantis.",
      "error": "Vẫn đi tiếp như đã đủ."
    },
    "miniinst.fishing.07": {
      "action": "Đạt đủ mười rồi rời minigame.",
      "result": "Game báo đủ, cho quay lại quán và tiếp tục route; không còn UI/cá/tôm/beam/âm thanh minigame.",
      "error": "Không báo đủ hoặc tài nguyên minigame còn sót."
    },
    "miniinst.chase-direct.00": {
      "action": "Tại Map29, theo dõi Hải Quỳ và quái vật.",
      "result": "Cả hai chạy xuống; quái vật ở phía trên và tiến gần dần nhưng không xuyên qua Hải Quỳ.",
      "error": "Camera bỏ nhân vật hoặc quái vật vượt xuyên qua."
    },
    "miniinst.chase-direct.01": {
      "action": "Trong Map29, gặp clone cản đường và nhập chuỗi ba phím.",
      "result": "Phím có thể là Z, X, Shift, ↑, ↓; sai/hết giờ tăng nguy hiểm; lỗi bốn lần Game Over.",
      "error": "Chuỗi/phạt/Game Over sai."
    },
    "miniinst.chase-direct.02": {
      "action": "Sống đủ lâu trong một lượt hoàn chỉnh.",
      "result": "Cả 11 clone khác nhau xuất hiện trước khi lặp; không kết thúc trước 60 giây hoặc trước đủ 11 lần cản.",
      "error": "Kết thúc sớm hoặc clone lặp trước khi đủ 11."
    },
    "miniinst.chase-direct.03": {
      "action": "Thắng hoặc thua rượt đuổi.",
      "result": "Thắng: dọn UI/clone rồi tới Map25. Thua: Game Over sạch, không giữ UI.",
      "error": "UI/clone còn sót."
    },
    "miniinst.chase-flow.00": {
      "action": "Tại Map34 (Vòng vây clone), chờ đủ clone áp sát.",
      "result": "Cả 11 clone chạy sát quanh Hải Quỳ trước câu “Buông tao ra!”.",
      "error": "Thiếu clone hoặc câu thoại chạy quá sớm."
    },
    "miniinst.chase-flow.01": {
      "action": "Sau khi Hải Quỳ đánh văng clone, quan sát quái vật.",
      "result": "Dấu chấm than/quay lên xảy ra trước; quái vật bước vào khung hình rồi mới gầm và rung màn hình.",
      "error": "Quái vật/gầm/rung sai thứ tự."
    },
    "miniinst.chase-flow.02": {
      "action": "Tại Map29, theo dõi Hải Quỳ và quái vật.",
      "result": "Cả hai chạy xuống; quái vật ở phía trên và tiến gần dần nhưng không xuyên qua Hải Quỳ.",
      "error": "Camera bỏ nhân vật hoặc quái vật vượt xuyên qua."
    },
    "miniinst.chase-flow.03": {
      "action": "Trong Map29, gặp clone cản đường và nhập chuỗi ba phím.",
      "result": "Phím có thể là Z, X, Shift, ↑, ↓; sai/hết giờ tăng nguy hiểm; lỗi bốn lần Game Over.",
      "error": "Chuỗi/phạt/Game Over sai."
    },
    "miniinst.chase-flow.04": {
      "action": "Sống đủ lâu trong một lượt hoàn chỉnh.",
      "result": "Cả 11 clone khác nhau xuất hiện trước khi lặp; không kết thúc trước 60 giây hoặc trước đủ 11 lần cản.",
      "error": "Kết thúc sớm hoặc clone lặp trước khi đủ 11."
    },
    "miniinst.chase-flow.05": {
      "action": "Thắng hoặc thua rượt đuổi.",
      "result": "Thắng: dọn UI/clone rồi tới Map25. Thua: Game Over sạch, không giữ UI.",
      "error": "UI/clone còn sót."
    },
    "miniinst.ship.00": {
      "action": "Mở game bắn phi thuyền tại Map19, thử hoàn thành và thử thua/thoát.",
      "result": "Khi quay lại siêu thị, UI/điều khiển minigame biến mất.",
      "error": "UI hoặc điều khiển còn sót."
    },
    "miniinst.ship.01": {
      "action": "Đạt đủ điểm yêu cầu.",
      "result": "Phần thưởng biến hình mở đúng một lần.",
      "error": "Mở lặp hoặc không mở."
    },
    "miniinst.cat.00": {
      "action": "Mở trò vuốt mèo tại Map19, tương tác rồi thoát.",
      "result": "Quay lại đúng vị trí trong siêu thị, không crash và không giữ hình bàn tay/mèo.",
      "error": "Crash, sai vị trí hoặc hình còn sót."
    },
    "update.noodle.camera": {
      "action": "Quan sát camera và chuyển sáng/tối từ Map20 (Tiệm mì cay), Map47 (Phòng chuẩn bị mì) tới Map14 (Nhà bếp Wanderer).",
      "result": "Camera lần lượt nhấn đúng Hải Quỳ, khu chuẩn bị cạnh giường và khu nấu ăn; không lóe sáng, không tối vĩnh viễn và luôn trả về theo nhân vật khi cần điều khiển.",
      "error": "Camera nhìn sai chỗ, bỏ lại Hải Quỳ, đổi hình khi màn hình còn sáng hoặc cảnh bị kẹt trong màu đen."
    },
    "update.noodle.partystructure": {
      "action": "Tại Map38 (Văn phòng Wanderer trong tiệc Giáng sinh), khám phá trước khi chọn tiếp tục.",
      "result": "Có thể vào phòng riêng, nhà bếp, phòng họp và phòng chế tạo; có thể chơi ném tuyết rồi trở lại đúng trạng thái bữa tiệc.",
      "error": "Thiếu lối vào, trở về sai phiên bản văn phòng, mất tiến độ bữa tiệc hoặc không tiếp tục được route mì cay."
    },
    "update.noodle.finalassets": {
      "action": "Xem phần trao mì cay cho Leo và kết thúc route.",
      "result": "Đúng nồi mì cay và người nhận Leo; vị trí thiếu ảnh bình Sting hiện chữ tạm “Bình Sting 20 Lít”; ảnh/CG phù hợp được mở trong Gallery; route đi tới đúng gợi ý cuối mà không chen cảnh sáng hôm sau.",
      "error": "Sai người nhận/hình ảnh, thiếu chữ tạm bình Sting, Gallery không cập nhật hoặc đi nhầm phần kết."
    },
    "update.askleo.phone": {
      "action": "Sau lần nói chuyện thứ ba với Leo ở Map13 (Văn phòng Wanderer), xem trọn đoạn nhắn tin tại Map56 (Trạm xe buýt).",
      "result": "Đoạn nhắn tin được lưu trong điện thoại; ba lựa chọn tiệm cà phê, cửa hàng vũ khí và tiệm ma pháp xuất hiện đúng, không tự chọn thay người chơi.",
      "error": "Tin nhắn không được lưu, thiếu lựa chọn hoặc chọn một nơi nhưng route ghi nhận nơi khác."
    },
    "update.askleo.mapping": {
      "action": "Đối chiếu nơi đến với lựa chọn trong tin nhắn Leo.",
      "result": "Tiệm cà phê dẫn tới Map58 (Tiệm cà phê Luminous) và quà cho Kohi; cửa hàng vũ khí dẫn tới Map59 và quà cho Shylvie; tiệm ma pháp dẫn tới Map57 và quà cho Hakase.",
      "error": "Hai lựa chọn khác nhau cùng dẫn tới tiệm ma pháp, sai cửa hàng, sai quà hoặc sai người nhận."
    },
    "update.askleo.shopcamera": {
      "action": "Quan sát phần mở đầu và kết thúc tại cửa hàng đã chọn.",
      "result": "Camera mở cảnh tập trung hợp lý rồi trở lại Hải Quỳ trước khi rời đi; ảnh đúng món quà được hiện và mở trong Gallery. Ở Map57, chủ tiệm ma pháp lặp tự nhiên ba hình hút thuốc, mỗi hình khoảng một giây.",
      "error": "Camera lệch/không trả lại, ảnh quà sai, Gallery không mở hoặc chủ tiệm ma pháp không cử động đúng nhịp."
    },
    "update.askleo.prep": {
      "action": "Xem Map60 (Phòng Hải Quỳ chuẩn bị quà theo lời Leo).",
      "result": "Hải Quỳ chuẩn bị đúng món vừa mua; ngủ rồi mới thức dậy; cảnh thay đồ chạy xong mới đổi sprite; không phát thoại của route mua đá và màn hình sáng lại trước khi tiếp tục.",
      "error": "Lẫn quà/thoại route đá, đổi sprite quá sớm, lóe hình hoặc màn hình đen không kết thúc."
    },
    "update.askleo.partyend": {
      "action": "Khám phá Map38, chơi thử ném tuyết rồi chọn tiếp tục bữa tiệc trong route hỏi Leo.",
      "result": "Camera theo lại Hải Quỳ khi free roam; các phòng phụ hoạt động; cảnh trao quà đúng cửa hàng đã chọn; điện thoại, Gallery và gợi ý cuối được cập nhật đúng route.",
      "error": "Camera bị khóa, thiếu free roam/minigame, cảnh trao sai quà hoặc phần điện thoại/Gallery/gợi ý thuộc route khác."
    },
    "update.shylvie.phonecamera": {
      "action": "Nói chuyện với Shylvie ở Map13 tới đoạn nhắn tin và đi tới Map64 (Tiệm đá phong thủy).",
      "result": "Tin nhắn riêng được lưu trong điện thoại; camera tiệm mở ở lối vào rồi di chuyển lên các kệ đá trước khi cho chọn.",
      "error": "Tin nhắn không lưu, đi nhầm cửa hàng, camera đứng sai chỗ hoặc lựa chọn xuất hiện trước khi xem kệ."
    },
    "update.shylvie.gallery": {
      "action": "Thử từng lựa chọn quà trong Map64 (Tiệm đá phong thủy).",
      "result": "Leo nhận Purple Garnet; Kohi nhận Diamond Coffee; Shylvie nhận Congo Tourmaline; Hakase nhận Rainbow Fluorite. Ảnh đúng vật phẩm xuất hiện và được mở trong Gallery.",
      "error": "Sai đá/người nhận, ảnh không khớp, lời thoại nổi chèn lên ảnh hoặc Gallery không cập nhật."
    },
    "update.shylvie.prep": {
      "action": "Xem Map65 (Phòng Hải Quỳ chuẩn bị quà đá phong thủy).",
      "result": "Có thể nhìn thấy Hải Quỳ trong cảnh; quà được gói đúng; các lần tối/sáng mượt và chỉ đổi sprite sau khi thay đồ xong.",
      "error": "Chỉ có màn hình kể chuyện, sai quà, đổi sprite sớm, lóe hình hoặc tối vĩnh viễn."
    },
    "update.shylvie.party": {
      "action": "Tới phần free roam ở Map38 bằng route hỏi Shylvie.",
      "result": "Có đủ mở đầu bữa tiệc và ảnh tuyết đúng trạng thái Hải Quỳ; camera trở lại theo player; phòng riêng, nhà bếp, phòng họp, phòng chế tạo và ném tuyết đều dùng được.",
      "error": "Thiếu phần bữa tiệc, ảnh tuyết sai, camera bị khóa hoặc khu vực phụ/minigame không hoạt động."
    },
    "update.shylvie.giftscene": {
      "action": "Chọn tiếp tục và xem Map66 (Cảnh trao quà đá phong thủy).",
      "result": "Bàn tiệc hoàn chỉnh, camera zoom nhẹ đúng nhóm nhân vật và thoại thường không che ảnh. Cả bốn nhánh quà đều đủ; khiên Congo Tourmaline xuất hiện có rung màn hình.",
      "error": "Sai lớp bàn tiệc/camera, dùng thoại nổi trên ảnh, thiếu một nhánh hoặc hiệu ứng khiên không có điểm nhấn."
    },
    "update.shylvie.epilogue": {
      "action": "Xem Map67 (Sáng hôm sau của route đá phong thủy).",
      "result": "Purple Garnet thành chuông gió; Diamond Coffee gây ác mộng vì thanh trừng Quỷ; khiên Congo Tourmaline nhân bản hũ kem; Rainbow Fluorite tạo các phép biến đổi kỳ lạ. Mỗi nhánh tới đúng gợi ý cuối.",
      "error": "Thiếu hậu quả, lẫn hậu quả giữa các món hoặc gợi ý cuối không khớp món đã tặng."
    },
    "miniinst.tv.00": {
      "action": "Dùng TV ở góc trên trái Map42.",
      "result": "Camera zoom vào TV; Hải Quỳ ngồi đúng hình trước/trong Giáng sinh; 10 nền TV chạy theo nhịp tối hoàn toàn–đổi nền–sáng; sau nền thứ 10 tới bad ending “Thêm tập nữa thôi!”.",
      "error": "Hải Quỳ dùng sai hình theo thời điểm, TV che nhân vật, đổi nền lúc còn sáng, thiếu nền hoặc ending tới sai thời điểm."
    }
  },
  "routes": [
    {
      "id": "super-lock-leo",
      "title": "Bộ phá khóa → Leo",
      "group": "Mua quà tại siêu thị",
      "start": "Map3 → Map10 → Map19",
      "steps": [
        "Chọn đi siêu thị",
        "Chọn Bộ phá khóa",
        "Chọn Leo làm người nhận"
      ],
      "end": "Map36 (Gợi ý sau ending)",
      "checkKeys": [
        "routeinst.super-lock-leo.00",
        "routeinst.super-lock-leo.01",
        "routeinst.super-lock-leo.02",
        "routeinst.super-lock-leo.03",
        "routeinst.super-lock-leo.04",
        "routeinst.super-lock-leo.05",
        "routeinst.super-lock-leo.06",
        "routeinst.super-lock-leo.07",
        "routeinst.super-lock-leo.08",
        "routeinst.super-lock-leo.09",
        "routeinst.super-lock-leo.10",
        "routeinst.super-lock-leo.11",
        "routeinst.super-lock-leo.12",
        "routeinst.super-lock-leo.13",
        "routeinst.super-lock-leo.14",
        "routeinst.super-lock-leo.15",
        "routeinst.super-lock-leo.16",
        "routeinst.super-lock-leo.17"
      ],
      "recipient": "Leo",
      "gift": "Bộ phá khóa",
      "startArea": "Siêu thị"
    },
    {
      "id": "super-lock-kohi",
      "title": "Bộ phá khóa → Kohi",
      "group": "Mua quà tại siêu thị",
      "start": "Map3 → Map10 → Map19",
      "steps": [
        "Chọn đi siêu thị",
        "Chọn Bộ phá khóa",
        "Chọn Kohi làm người nhận"
      ],
      "end": "Map36 (Gợi ý sau ending)",
      "checkKeys": [
        "routeinst.super-lock-kohi.00",
        "routeinst.super-lock-kohi.01",
        "routeinst.super-lock-kohi.02",
        "routeinst.super-lock-kohi.03",
        "routeinst.super-lock-kohi.04",
        "routeinst.super-lock-kohi.05",
        "routeinst.super-lock-kohi.06",
        "routeinst.super-lock-kohi.07",
        "routeinst.super-lock-kohi.08",
        "routeinst.super-lock-kohi.09",
        "routeinst.super-lock-kohi.10",
        "routeinst.super-lock-kohi.11",
        "routeinst.super-lock-kohi.12",
        "routeinst.super-lock-kohi.13",
        "routeinst.super-lock-kohi.14",
        "routeinst.super-lock-kohi.15",
        "routeinst.super-lock-kohi.16",
        "routeinst.super-lock-kohi.17"
      ],
      "recipient": "Kohi",
      "gift": "Bộ phá khóa",
      "startArea": "Siêu thị"
    },
    {
      "id": "super-lock-shylvie",
      "title": "Bộ phá khóa → Shylvie",
      "group": "Mua quà tại siêu thị",
      "start": "Map3 → Map10 → Map19",
      "steps": [
        "Chọn đi siêu thị",
        "Chọn Bộ phá khóa",
        "Chọn Shylvie làm người nhận"
      ],
      "end": "Map36 (Gợi ý sau ending)",
      "checkKeys": [
        "routeinst.super-lock-shylvie.00",
        "routeinst.super-lock-shylvie.01",
        "routeinst.super-lock-shylvie.02",
        "routeinst.super-lock-shylvie.03",
        "routeinst.super-lock-shylvie.04",
        "routeinst.super-lock-shylvie.05",
        "routeinst.super-lock-shylvie.06",
        "routeinst.super-lock-shylvie.07",
        "routeinst.super-lock-shylvie.08",
        "routeinst.super-lock-shylvie.09",
        "routeinst.super-lock-shylvie.10",
        "routeinst.super-lock-shylvie.11",
        "routeinst.super-lock-shylvie.12",
        "routeinst.super-lock-shylvie.13",
        "routeinst.super-lock-shylvie.14",
        "routeinst.super-lock-shylvie.15",
        "routeinst.super-lock-shylvie.16",
        "routeinst.super-lock-shylvie.17"
      ],
      "recipient": "Shylvie",
      "gift": "Bộ phá khóa",
      "startArea": "Siêu thị"
    },
    {
      "id": "super-lock-hakase",
      "title": "Bộ phá khóa → Hakase",
      "group": "Mua quà tại siêu thị",
      "start": "Map3 → Map10 → Map19",
      "steps": [
        "Chọn đi siêu thị",
        "Chọn Bộ phá khóa",
        "Chọn Hakase làm người nhận"
      ],
      "end": "Map36 (Gợi ý sau ending)",
      "checkKeys": [
        "routeinst.super-lock-hakase.00",
        "routeinst.super-lock-hakase.01",
        "routeinst.super-lock-hakase.02",
        "routeinst.super-lock-hakase.03",
        "routeinst.super-lock-hakase.04",
        "routeinst.super-lock-hakase.05",
        "routeinst.super-lock-hakase.06",
        "routeinst.super-lock-hakase.07",
        "routeinst.super-lock-hakase.08",
        "routeinst.super-lock-hakase.09",
        "routeinst.super-lock-hakase.10",
        "routeinst.super-lock-hakase.11",
        "routeinst.super-lock-hakase.12",
        "routeinst.super-lock-hakase.13",
        "routeinst.super-lock-hakase.14",
        "routeinst.super-lock-hakase.15",
        "routeinst.super-lock-hakase.16",
        "routeinst.super-lock-hakase.17"
      ],
      "recipient": "Hakase",
      "gift": "Bộ phá khóa",
      "startArea": "Siêu thị"
    },
    {
      "id": "super-knife-leo",
      "title": "Dao & chảo → Leo",
      "group": "Mua quà tại siêu thị",
      "start": "Map3 → Map10 → Map19",
      "steps": [
        "Chọn đi siêu thị",
        "Chọn Combo dao và chảo",
        "Chọn Leo làm người nhận"
      ],
      "end": "Map36 (Gợi ý sau ending)",
      "checkKeys": [
        "routeinst.super-knife-leo.00",
        "routeinst.super-knife-leo.01",
        "routeinst.super-knife-leo.02",
        "routeinst.super-knife-leo.03",
        "routeinst.super-knife-leo.04",
        "routeinst.super-knife-leo.05",
        "routeinst.super-knife-leo.06",
        "routeinst.super-knife-leo.07",
        "routeinst.super-knife-leo.08",
        "routeinst.super-knife-leo.09",
        "routeinst.super-knife-leo.10",
        "routeinst.super-knife-leo.11",
        "routeinst.super-knife-leo.12",
        "routeinst.super-knife-leo.13",
        "routeinst.super-knife-leo.14",
        "routeinst.super-knife-leo.15",
        "routeinst.super-knife-leo.16",
        "routeinst.super-knife-leo.17"
      ],
      "recipient": "Leo",
      "gift": "Dao & chảo",
      "startArea": "Siêu thị"
    },
    {
      "id": "super-knife-kohi",
      "title": "Dao & chảo → Kohi",
      "group": "Mua quà tại siêu thị",
      "start": "Map3 → Map10 → Map19",
      "steps": [
        "Chọn đi siêu thị",
        "Chọn Combo dao và chảo",
        "Chọn Kohi làm người nhận"
      ],
      "end": "Map36 (Gợi ý sau ending)",
      "checkKeys": [
        "routeinst.super-knife-kohi.00",
        "routeinst.super-knife-kohi.01",
        "routeinst.super-knife-kohi.02",
        "routeinst.super-knife-kohi.03",
        "routeinst.super-knife-kohi.04",
        "routeinst.super-knife-kohi.05",
        "routeinst.super-knife-kohi.06",
        "routeinst.super-knife-kohi.07",
        "routeinst.super-knife-kohi.08",
        "routeinst.super-knife-kohi.09",
        "routeinst.super-knife-kohi.10",
        "routeinst.super-knife-kohi.11",
        "routeinst.super-knife-kohi.12",
        "routeinst.super-knife-kohi.13",
        "routeinst.super-knife-kohi.14",
        "routeinst.super-knife-kohi.15",
        "routeinst.super-knife-kohi.16",
        "routeinst.super-knife-kohi.17"
      ],
      "recipient": "Kohi",
      "gift": "Dao & chảo",
      "startArea": "Siêu thị"
    },
    {
      "id": "super-knife-shylvie",
      "title": "Dao & chảo → Shylvie",
      "group": "Mua quà tại siêu thị",
      "start": "Map3 → Map10 → Map19",
      "steps": [
        "Chọn đi siêu thị",
        "Chọn Combo dao và chảo",
        "Chọn Shylvie làm người nhận"
      ],
      "end": "Map36 (Gợi ý sau ending)",
      "checkKeys": [
        "routeinst.super-knife-shylvie.00",
        "routeinst.super-knife-shylvie.01",
        "routeinst.super-knife-shylvie.02",
        "routeinst.super-knife-shylvie.03",
        "routeinst.super-knife-shylvie.04",
        "routeinst.super-knife-shylvie.05",
        "routeinst.super-knife-shylvie.06",
        "routeinst.super-knife-shylvie.07",
        "routeinst.super-knife-shylvie.08",
        "routeinst.super-knife-shylvie.09",
        "routeinst.super-knife-shylvie.10",
        "routeinst.super-knife-shylvie.11",
        "routeinst.super-knife-shylvie.12",
        "routeinst.super-knife-shylvie.13",
        "routeinst.super-knife-shylvie.14",
        "routeinst.super-knife-shylvie.15",
        "routeinst.super-knife-shylvie.16",
        "routeinst.super-knife-shylvie.17"
      ],
      "recipient": "Shylvie",
      "gift": "Dao & chảo",
      "startArea": "Siêu thị"
    },
    {
      "id": "super-knife-hakase",
      "title": "Dao & chảo → Hakase",
      "group": "Mua quà tại siêu thị",
      "start": "Map3 → Map10 → Map19",
      "steps": [
        "Chọn đi siêu thị",
        "Chọn Combo dao và chảo",
        "Chọn Hakase làm người nhận"
      ],
      "end": "Map36 (Gợi ý sau ending)",
      "checkKeys": [
        "routeinst.super-knife-hakase.00",
        "routeinst.super-knife-hakase.01",
        "routeinst.super-knife-hakase.02",
        "routeinst.super-knife-hakase.03",
        "routeinst.super-knife-hakase.04",
        "routeinst.super-knife-hakase.05",
        "routeinst.super-knife-hakase.06",
        "routeinst.super-knife-hakase.07",
        "routeinst.super-knife-hakase.08",
        "routeinst.super-knife-hakase.09",
        "routeinst.super-knife-hakase.10",
        "routeinst.super-knife-hakase.11",
        "routeinst.super-knife-hakase.12",
        "routeinst.super-knife-hakase.13",
        "routeinst.super-knife-hakase.14",
        "routeinst.super-knife-hakase.15",
        "routeinst.super-knife-hakase.16",
        "routeinst.super-knife-hakase.17"
      ],
      "recipient": "Hakase",
      "gift": "Dao & chảo",
      "startArea": "Siêu thị"
    },
    {
      "id": "super-scarf-leo",
      "title": "Khăn len → Leo",
      "group": "Mua quà tại siêu thị",
      "start": "Map3 → Map10 → Map19",
      "steps": [
        "Chọn đi siêu thị",
        "Chọn Khăn len",
        "Chọn Leo làm người nhận"
      ],
      "end": "Map36 (Gợi ý sau ending)",
      "checkKeys": [
        "routeinst.super-scarf-leo.00",
        "routeinst.super-scarf-leo.01",
        "routeinst.super-scarf-leo.02",
        "routeinst.super-scarf-leo.03",
        "routeinst.super-scarf-leo.04",
        "routeinst.super-scarf-leo.05",
        "routeinst.super-scarf-leo.06",
        "routeinst.super-scarf-leo.07",
        "routeinst.super-scarf-leo.08",
        "routeinst.super-scarf-leo.09",
        "routeinst.super-scarf-leo.10",
        "routeinst.super-scarf-leo.11",
        "routeinst.super-scarf-leo.12",
        "routeinst.super-scarf-leo.13",
        "routeinst.super-scarf-leo.14",
        "routeinst.super-scarf-leo.15",
        "routeinst.super-scarf-leo.16",
        "routeinst.super-scarf-leo.17"
      ],
      "recipient": "Leo",
      "gift": "Khăn len",
      "startArea": "Siêu thị"
    },
    {
      "id": "super-scarf-kohi",
      "title": "Khăn len → Kohi",
      "group": "Mua quà tại siêu thị",
      "start": "Map3 → Map10 → Map19",
      "steps": [
        "Chọn đi siêu thị",
        "Chọn Khăn len",
        "Chọn Kohi làm người nhận"
      ],
      "end": "Map36 (Gợi ý sau ending)",
      "checkKeys": [
        "routeinst.super-scarf-kohi.00",
        "routeinst.super-scarf-kohi.01",
        "routeinst.super-scarf-kohi.02",
        "routeinst.super-scarf-kohi.03",
        "routeinst.super-scarf-kohi.04",
        "routeinst.super-scarf-kohi.05",
        "routeinst.super-scarf-kohi.06",
        "routeinst.super-scarf-kohi.07",
        "routeinst.super-scarf-kohi.08",
        "routeinst.super-scarf-kohi.09",
        "routeinst.super-scarf-kohi.10",
        "routeinst.super-scarf-kohi.11",
        "routeinst.super-scarf-kohi.12",
        "routeinst.super-scarf-kohi.13",
        "routeinst.super-scarf-kohi.14",
        "routeinst.super-scarf-kohi.15",
        "routeinst.super-scarf-kohi.16",
        "routeinst.super-scarf-kohi.17"
      ],
      "recipient": "Kohi",
      "gift": "Khăn len",
      "startArea": "Siêu thị"
    },
    {
      "id": "super-scarf-shylvie",
      "title": "Khăn len → Shylvie",
      "group": "Mua quà tại siêu thị",
      "start": "Map3 → Map10 → Map19",
      "steps": [
        "Chọn đi siêu thị",
        "Chọn Khăn len",
        "Chọn Shylvie làm người nhận"
      ],
      "end": "Map36 (Gợi ý sau ending)",
      "checkKeys": [
        "routeinst.super-scarf-shylvie.00",
        "routeinst.super-scarf-shylvie.01",
        "routeinst.super-scarf-shylvie.02",
        "routeinst.super-scarf-shylvie.03",
        "routeinst.super-scarf-shylvie.04",
        "routeinst.super-scarf-shylvie.05",
        "routeinst.super-scarf-shylvie.06",
        "routeinst.super-scarf-shylvie.07",
        "routeinst.super-scarf-shylvie.08",
        "routeinst.super-scarf-shylvie.09",
        "routeinst.super-scarf-shylvie.10",
        "routeinst.super-scarf-shylvie.11",
        "routeinst.super-scarf-shylvie.12",
        "routeinst.super-scarf-shylvie.13",
        "routeinst.super-scarf-shylvie.14",
        "routeinst.super-scarf-shylvie.15",
        "routeinst.super-scarf-shylvie.16",
        "routeinst.super-scarf-shylvie.17"
      ],
      "recipient": "Shylvie",
      "gift": "Khăn len",
      "startArea": "Siêu thị"
    },
    {
      "id": "super-scarf-hakase",
      "title": "Khăn len → Hakase",
      "group": "Mua quà tại siêu thị",
      "start": "Map3 → Map10 → Map19",
      "steps": [
        "Chọn đi siêu thị",
        "Chọn Khăn len",
        "Chọn Hakase làm người nhận"
      ],
      "end": "Map36 (Gợi ý sau ending)",
      "checkKeys": [
        "routeinst.super-scarf-hakase.00",
        "routeinst.super-scarf-hakase.01",
        "routeinst.super-scarf-hakase.02",
        "routeinst.super-scarf-hakase.03",
        "routeinst.super-scarf-hakase.04",
        "routeinst.super-scarf-hakase.05",
        "routeinst.super-scarf-hakase.06",
        "routeinst.super-scarf-hakase.07",
        "routeinst.super-scarf-hakase.08",
        "routeinst.super-scarf-hakase.09",
        "routeinst.super-scarf-hakase.10",
        "routeinst.super-scarf-hakase.11",
        "routeinst.super-scarf-hakase.12",
        "routeinst.super-scarf-hakase.13",
        "routeinst.super-scarf-hakase.14",
        "routeinst.super-scarf-hakase.15",
        "routeinst.super-scarf-hakase.16",
        "routeinst.super-scarf-hakase.17"
      ],
      "recipient": "Hakase",
      "gift": "Khăn len",
      "startArea": "Siêu thị"
    },
    {
      "id": "super-coffee-leo-regular",
      "title": "Máy pha cà phê → Leo / Cà phê thường",
      "group": "Mua quà tại siêu thị",
      "start": "Map3 → Map10 → Map19 → Map40",
      "steps": [
        "Chọn đi siêu thị",
        "Chọn Máy pha cà phê",
        "Chọn Leo làm người nhận",
        "Tại Map40 chọn dùng cà phê thường"
      ],
      "end": "Map36 (Gợi ý sau ending)",
      "checkKeys": [
        "routeinst.super-coffee-leo-regular.00",
        "routeinst.super-coffee-leo-regular.01",
        "routeinst.super-coffee-leo-regular.02",
        "routeinst.super-coffee-leo-regular.03",
        "routeinst.super-coffee-leo-regular.04",
        "routeinst.super-coffee-leo-regular.05",
        "routeinst.super-coffee-leo-regular.06",
        "routeinst.super-coffee-leo-regular.07",
        "routeinst.super-coffee-leo-regular.08",
        "routeinst.super-coffee-leo-regular.09",
        "routeinst.super-coffee-leo-regular.10",
        "routeinst.super-coffee-leo-regular.11",
        "routeinst.super-coffee-leo-regular.12",
        "routeinst.super-coffee-leo-regular.13",
        "routeinst.super-coffee-leo-regular.14",
        "routeinst.super-coffee-leo-regular.15",
        "routeinst.super-coffee-leo-regular.16",
        "routeinst.super-coffee-leo-regular.17",
        "routeinst.super-coffee-leo-regular.18",
        "routeinst.super-coffee-leo-regular.19"
      ],
      "recipient": "Leo",
      "gift": "Máy pha cà phê",
      "coffee": "Cà phê thường",
      "startArea": "Siêu thị"
    },
    {
      "id": "super-coffee-leo-atlantis",
      "title": "Máy pha cà phê → Leo / Cà phê Atlantis",
      "group": "Mua quà tại siêu thị",
      "start": "Map3 → Map10 → Map19 → Map40",
      "steps": [
        "Chọn đi siêu thị",
        "Chọn Máy pha cà phê",
        "Chọn Leo làm người nhận",
        "Tại Map40 chọn đi câu tôm"
      ],
      "end": "Map36 (Gợi ý sau ending)",
      "checkKeys": [
        "routeinst.super-coffee-leo-atlantis.00",
        "routeinst.super-coffee-leo-atlantis.01",
        "routeinst.super-coffee-leo-atlantis.02",
        "routeinst.super-coffee-leo-atlantis.03",
        "routeinst.super-coffee-leo-atlantis.04",
        "routeinst.super-coffee-leo-atlantis.05",
        "routeinst.super-coffee-leo-atlantis.06",
        "routeinst.super-coffee-leo-atlantis.07",
        "routeinst.super-coffee-leo-atlantis.08",
        "routeinst.super-coffee-leo-atlantis.09",
        "routeinst.super-coffee-leo-atlantis.10",
        "routeinst.super-coffee-leo-atlantis.11",
        "routeinst.super-coffee-leo-atlantis.12",
        "routeinst.super-coffee-leo-atlantis.13",
        "routeinst.super-coffee-leo-atlantis.14",
        "routeinst.super-coffee-leo-atlantis.15",
        "routeinst.super-coffee-leo-atlantis.16",
        "routeinst.super-coffee-leo-atlantis.17",
        "routeinst.super-coffee-leo-atlantis.18",
        "routeinst.super-coffee-leo-atlantis.19"
      ],
      "recipient": "Leo",
      "gift": "Máy pha cà phê",
      "coffee": "Cà phê Atlantis",
      "startArea": "Siêu thị"
    },
    {
      "id": "super-coffee-kohi-regular",
      "title": "Máy pha cà phê → Kohi / Cà phê thường",
      "group": "Mua quà tại siêu thị",
      "start": "Map3 → Map10 → Map19 → Map40",
      "steps": [
        "Chọn đi siêu thị",
        "Chọn Máy pha cà phê",
        "Chọn Kohi làm người nhận",
        "Tại Map40 chọn dùng cà phê thường"
      ],
      "end": "Map36 (Gợi ý sau ending)",
      "checkKeys": [
        "routeinst.super-coffee-kohi-regular.00",
        "routeinst.super-coffee-kohi-regular.01",
        "routeinst.super-coffee-kohi-regular.02",
        "routeinst.super-coffee-kohi-regular.03",
        "routeinst.super-coffee-kohi-regular.04",
        "routeinst.super-coffee-kohi-regular.05",
        "routeinst.super-coffee-kohi-regular.06",
        "routeinst.super-coffee-kohi-regular.07",
        "routeinst.super-coffee-kohi-regular.08",
        "routeinst.super-coffee-kohi-regular.09",
        "routeinst.super-coffee-kohi-regular.10",
        "routeinst.super-coffee-kohi-regular.11",
        "routeinst.super-coffee-kohi-regular.12",
        "routeinst.super-coffee-kohi-regular.13",
        "routeinst.super-coffee-kohi-regular.14",
        "routeinst.super-coffee-kohi-regular.15",
        "routeinst.super-coffee-kohi-regular.16",
        "routeinst.super-coffee-kohi-regular.17",
        "routeinst.super-coffee-kohi-regular.18",
        "routeinst.super-coffee-kohi-regular.19"
      ],
      "recipient": "Kohi",
      "gift": "Máy pha cà phê",
      "coffee": "Cà phê thường",
      "startArea": "Siêu thị"
    },
    {
      "id": "super-coffee-kohi-atlantis",
      "title": "Máy pha cà phê → Kohi / Cà phê Atlantis",
      "group": "Mua quà tại siêu thị",
      "start": "Map3 → Map10 → Map19 → Map40",
      "steps": [
        "Chọn đi siêu thị",
        "Chọn Máy pha cà phê",
        "Chọn Kohi làm người nhận",
        "Tại Map40 chọn đi câu tôm"
      ],
      "end": "Map36 (Gợi ý sau ending)",
      "checkKeys": [
        "routeinst.super-coffee-kohi-atlantis.00",
        "routeinst.super-coffee-kohi-atlantis.01",
        "routeinst.super-coffee-kohi-atlantis.02",
        "routeinst.super-coffee-kohi-atlantis.03",
        "routeinst.super-coffee-kohi-atlantis.04",
        "routeinst.super-coffee-kohi-atlantis.05",
        "routeinst.super-coffee-kohi-atlantis.06",
        "routeinst.super-coffee-kohi-atlantis.07",
        "routeinst.super-coffee-kohi-atlantis.08",
        "routeinst.super-coffee-kohi-atlantis.09",
        "routeinst.super-coffee-kohi-atlantis.10",
        "routeinst.super-coffee-kohi-atlantis.11",
        "routeinst.super-coffee-kohi-atlantis.12",
        "routeinst.super-coffee-kohi-atlantis.13",
        "routeinst.super-coffee-kohi-atlantis.14",
        "routeinst.super-coffee-kohi-atlantis.15",
        "routeinst.super-coffee-kohi-atlantis.16",
        "routeinst.super-coffee-kohi-atlantis.17",
        "routeinst.super-coffee-kohi-atlantis.18",
        "routeinst.super-coffee-kohi-atlantis.19"
      ],
      "recipient": "Kohi",
      "gift": "Máy pha cà phê",
      "coffee": "Cà phê Atlantis",
      "startArea": "Siêu thị"
    },
    {
      "id": "super-coffee-shylvie-regular",
      "title": "Máy pha cà phê → Shylvie / Cà phê thường",
      "group": "Mua quà tại siêu thị",
      "start": "Map3 → Map10 → Map19 → Map40",
      "steps": [
        "Chọn đi siêu thị",
        "Chọn Máy pha cà phê",
        "Chọn Shylvie làm người nhận",
        "Tại Map40 chọn dùng cà phê thường"
      ],
      "end": "Map36 (Gợi ý sau ending)",
      "checkKeys": [
        "routeinst.super-coffee-shylvie-regular.00",
        "routeinst.super-coffee-shylvie-regular.01",
        "routeinst.super-coffee-shylvie-regular.02",
        "routeinst.super-coffee-shylvie-regular.03",
        "routeinst.super-coffee-shylvie-regular.04",
        "routeinst.super-coffee-shylvie-regular.05",
        "routeinst.super-coffee-shylvie-regular.06",
        "routeinst.super-coffee-shylvie-regular.07",
        "routeinst.super-coffee-shylvie-regular.08",
        "routeinst.super-coffee-shylvie-regular.09",
        "routeinst.super-coffee-shylvie-regular.10",
        "routeinst.super-coffee-shylvie-regular.11",
        "routeinst.super-coffee-shylvie-regular.12",
        "routeinst.super-coffee-shylvie-regular.13",
        "routeinst.super-coffee-shylvie-regular.14",
        "routeinst.super-coffee-shylvie-regular.15",
        "routeinst.super-coffee-shylvie-regular.16",
        "routeinst.super-coffee-shylvie-regular.17",
        "routeinst.super-coffee-shylvie-regular.18",
        "routeinst.super-coffee-shylvie-regular.19"
      ],
      "recipient": "Shylvie",
      "gift": "Máy pha cà phê",
      "coffee": "Cà phê thường",
      "startArea": "Siêu thị"
    },
    {
      "id": "super-coffee-shylvie-atlantis",
      "title": "Máy pha cà phê → Shylvie / Cà phê Atlantis",
      "group": "Mua quà tại siêu thị",
      "start": "Map3 → Map10 → Map19 → Map40",
      "steps": [
        "Chọn đi siêu thị",
        "Chọn Máy pha cà phê",
        "Chọn Shylvie làm người nhận",
        "Tại Map40 chọn đi câu tôm"
      ],
      "end": "Map36 (Gợi ý sau ending)",
      "checkKeys": [
        "routeinst.super-coffee-shylvie-atlantis.00",
        "routeinst.super-coffee-shylvie-atlantis.01",
        "routeinst.super-coffee-shylvie-atlantis.02",
        "routeinst.super-coffee-shylvie-atlantis.03",
        "routeinst.super-coffee-shylvie-atlantis.04",
        "routeinst.super-coffee-shylvie-atlantis.05",
        "routeinst.super-coffee-shylvie-atlantis.06",
        "routeinst.super-coffee-shylvie-atlantis.07",
        "routeinst.super-coffee-shylvie-atlantis.08",
        "routeinst.super-coffee-shylvie-atlantis.09",
        "routeinst.super-coffee-shylvie-atlantis.10",
        "routeinst.super-coffee-shylvie-atlantis.11",
        "routeinst.super-coffee-shylvie-atlantis.12",
        "routeinst.super-coffee-shylvie-atlantis.13",
        "routeinst.super-coffee-shylvie-atlantis.14",
        "routeinst.super-coffee-shylvie-atlantis.15",
        "routeinst.super-coffee-shylvie-atlantis.16",
        "routeinst.super-coffee-shylvie-atlantis.17",
        "routeinst.super-coffee-shylvie-atlantis.18",
        "routeinst.super-coffee-shylvie-atlantis.19"
      ],
      "recipient": "Shylvie",
      "gift": "Máy pha cà phê",
      "coffee": "Cà phê Atlantis",
      "startArea": "Siêu thị"
    },
    {
      "id": "super-coffee-hakase-regular",
      "title": "Máy pha cà phê → Hakase / Cà phê thường",
      "group": "Mua quà tại siêu thị",
      "start": "Map3 → Map10 → Map19 → Map40",
      "steps": [
        "Chọn đi siêu thị",
        "Chọn Máy pha cà phê",
        "Chọn Hakase làm người nhận",
        "Tại Map40 chọn dùng cà phê thường"
      ],
      "end": "Map36 (Gợi ý sau ending)",
      "checkKeys": [
        "routeinst.super-coffee-hakase-regular.00",
        "routeinst.super-coffee-hakase-regular.01",
        "routeinst.super-coffee-hakase-regular.02",
        "routeinst.super-coffee-hakase-regular.03",
        "routeinst.super-coffee-hakase-regular.04",
        "routeinst.super-coffee-hakase-regular.05",
        "routeinst.super-coffee-hakase-regular.06",
        "routeinst.super-coffee-hakase-regular.07",
        "routeinst.super-coffee-hakase-regular.08",
        "routeinst.super-coffee-hakase-regular.09",
        "routeinst.super-coffee-hakase-regular.10",
        "routeinst.super-coffee-hakase-regular.11",
        "routeinst.super-coffee-hakase-regular.12",
        "routeinst.super-coffee-hakase-regular.13",
        "routeinst.super-coffee-hakase-regular.14",
        "routeinst.super-coffee-hakase-regular.15",
        "routeinst.super-coffee-hakase-regular.16",
        "routeinst.super-coffee-hakase-regular.17",
        "routeinst.super-coffee-hakase-regular.18",
        "routeinst.super-coffee-hakase-regular.19"
      ],
      "recipient": "Hakase",
      "gift": "Máy pha cà phê",
      "coffee": "Cà phê thường",
      "startArea": "Siêu thị"
    },
    {
      "id": "super-coffee-hakase-atlantis",
      "title": "Máy pha cà phê → Hakase / Cà phê Atlantis",
      "group": "Mua quà tại siêu thị",
      "start": "Map3 → Map10 → Map19 → Map40",
      "steps": [
        "Chọn đi siêu thị",
        "Chọn Máy pha cà phê",
        "Chọn Hakase làm người nhận",
        "Tại Map40 chọn đi câu tôm"
      ],
      "end": "Map36 (Gợi ý sau ending)",
      "checkKeys": [
        "routeinst.super-coffee-hakase-atlantis.00",
        "routeinst.super-coffee-hakase-atlantis.01",
        "routeinst.super-coffee-hakase-atlantis.02",
        "routeinst.super-coffee-hakase-atlantis.03",
        "routeinst.super-coffee-hakase-atlantis.04",
        "routeinst.super-coffee-hakase-atlantis.05",
        "routeinst.super-coffee-hakase-atlantis.06",
        "routeinst.super-coffee-hakase-atlantis.07",
        "routeinst.super-coffee-hakase-atlantis.08",
        "routeinst.super-coffee-hakase-atlantis.09",
        "routeinst.super-coffee-hakase-atlantis.10",
        "routeinst.super-coffee-hakase-atlantis.11",
        "routeinst.super-coffee-hakase-atlantis.12",
        "routeinst.super-coffee-hakase-atlantis.13",
        "routeinst.super-coffee-hakase-atlantis.14",
        "routeinst.super-coffee-hakase-atlantis.15",
        "routeinst.super-coffee-hakase-atlantis.16",
        "routeinst.super-coffee-hakase-atlantis.17",
        "routeinst.super-coffee-hakase-atlantis.18",
        "routeinst.super-coffee-hakase-atlantis.19"
      ],
      "recipient": "Hakase",
      "gift": "Máy pha cà phê",
      "coffee": "Cà phê Atlantis",
      "startArea": "Siêu thị"
    },
    {
      "id": "noodle-aira",
      "title": "Mì cay cho Leo — Tin Aira",
      "group": "Mua mì cay cho Leo",
      "start": "Map3 → Map10 → Map20",
      "steps": [
        "Chọn đi mua mì cay",
        "Chọn “Tin Aira”"
      ],
      "end": "Map36 (Gợi ý sau ending)",
      "checkKeys": [
        "routeinst.noodle-aira.00",
        "routeinst.noodle-aira.01",
        "routeinst.noodle-aira.02",
        "routeinst.noodle-aira.03",
        "routeinst.noodle-aira.04",
        "routeinst.noodle-aira.05",
        "routeinst.noodle-aira.06",
        "routeinst.noodle-aira.07",
        "routeinst.noodle-aira.08",
        "routeinst.noodle-aira.09",
        "routeinst.noodle-aira.10",
        "update.noodle.camera",
        "update.noodle.partystructure",
        "update.noodle.finalassets"
      ],
      "recipient": "Leo",
      "gift": "Mì cay",
      "startArea": "Tiệm mì cay"
    },
    {
      "id": "noodle-self",
      "title": "Mì cay cho Leo — Không tin Aira",
      "group": "Mua mì cay cho Leo",
      "start": "Map3 → Map10 → Map20",
      "steps": [
        "Chọn đi mua mì cay",
        "Chọn “Không tin Aira”"
      ],
      "end": "Map36 (Gợi ý sau ending)",
      "checkKeys": [
        "routeinst.noodle-self.00",
        "routeinst.noodle-self.01",
        "routeinst.noodle-self.02",
        "routeinst.noodle-self.03",
        "routeinst.noodle-self.04",
        "routeinst.noodle-self.05",
        "routeinst.noodle-self.06",
        "routeinst.noodle-self.07",
        "routeinst.noodle-self.08",
        "routeinst.noodle-self.09",
        "routeinst.noodle-self.10",
        "update.noodle.camera",
        "update.noodle.partystructure",
        "update.noodle.finalassets"
      ],
      "recipient": "Leo",
      "gift": "Mì cay",
      "startArea": "Tiệm mì cay"
    },
    {
      "id": "ask-leo-coffee",
      "title": "Hỏi Leo → Tiệm cà phê",
      "group": "Hỏi Leo rồi chọn cửa hàng",
      "start": "Map13 (Văn phòng Wanderer)",
      "steps": [
        "Nói chuyện với Leo đủ ba lần",
        "Chọn Tiệm cà phê"
      ],
      "end": "Map36 (Gợi ý sau ending)",
      "checkKeys": [
        "routeinst.ask-leo-coffee.00",
        "routeinst.ask-leo-coffee.01",
        "routeinst.ask-leo-coffee.02",
        "routeinst.ask-leo-coffee.03",
        "routeinst.ask-leo-coffee.04",
        "routeinst.ask-leo-coffee.05",
        "routeinst.ask-leo-coffee.06",
        "routeinst.ask-leo-coffee.07",
        "routeinst.ask-leo-coffee.08",
        "update.askleo.phone",
        "update.askleo.mapping",
        "update.askleo.shopcamera",
        "update.askleo.prep",
        "update.askleo.partyend"
      ],
      "recipient": "Kohi",
      "gift": "Cà phê Luminous",
      "startArea": "Văn phòng Wanderer"
    },
    {
      "id": "ask-leo-weapon",
      "title": "Hỏi Leo → Cửa hàng vũ khí",
      "group": "Hỏi Leo rồi chọn cửa hàng",
      "start": "Map13 (Văn phòng Wanderer)",
      "steps": [
        "Nói chuyện với Leo đủ ba lần",
        "Chọn Cửa hàng vũ khí"
      ],
      "end": "Map36 (Gợi ý sau ending)",
      "checkKeys": [
        "routeinst.ask-leo-weapon.00",
        "routeinst.ask-leo-weapon.01",
        "routeinst.ask-leo-weapon.02",
        "routeinst.ask-leo-weapon.03",
        "routeinst.ask-leo-weapon.04",
        "routeinst.ask-leo-weapon.05",
        "routeinst.ask-leo-weapon.06",
        "routeinst.ask-leo-weapon.07",
        "routeinst.ask-leo-weapon.08",
        "update.askleo.phone",
        "update.askleo.mapping",
        "update.askleo.shopcamera",
        "update.askleo.prep",
        "update.askleo.partyend"
      ],
      "recipient": "Shylvie",
      "gift": "Khiên",
      "startArea": "Văn phòng Wanderer"
    },
    {
      "id": "ask-leo-magic",
      "title": "Hỏi Leo → Tiệm ma pháp",
      "group": "Hỏi Leo rồi chọn cửa hàng",
      "start": "Map13 (Văn phòng Wanderer)",
      "steps": [
        "Nói chuyện với Leo đủ ba lần",
        "Chọn Tiệm ma pháp"
      ],
      "end": "Map36 (Gợi ý sau ending)",
      "checkKeys": [
        "routeinst.ask-leo-magic.00",
        "routeinst.ask-leo-magic.01",
        "routeinst.ask-leo-magic.02",
        "routeinst.ask-leo-magic.03",
        "routeinst.ask-leo-magic.04",
        "routeinst.ask-leo-magic.05",
        "routeinst.ask-leo-magic.06",
        "routeinst.ask-leo-magic.07",
        "routeinst.ask-leo-magic.08",
        "update.askleo.phone",
        "update.askleo.mapping",
        "update.askleo.shopcamera",
        "update.askleo.prep",
        "update.askleo.partyend"
      ],
      "recipient": "Hakase",
      "gift": "Áo choàng luyện tàng hình",
      "startArea": "Văn phòng Wanderer"
    },
    {
      "id": "stone-leo",
      "title": "Đá phong thủy → Leo / Purple Garnet",
      "group": "Hỏi Shylvie rồi mua đá phong thủy",
      "start": "Map13 (Văn phòng Wanderer)",
      "steps": [
        "Nói chuyện với Shylvie tới khi nhận tọa độ",
        "Tới tiệm đá",
        "Chọn Leo làm người nhận"
      ],
      "end": "Map36 (Gợi ý sau ending)",
      "checkKeys": [
        "routeinst.stone-leo.00",
        "routeinst.stone-leo.01",
        "routeinst.stone-leo.02",
        "routeinst.stone-leo.03",
        "routeinst.stone-leo.04",
        "routeinst.stone-leo.05",
        "routeinst.stone-leo.06",
        "routeinst.stone-leo.07",
        "routeinst.stone-leo.08",
        "routeinst.stone-leo.09",
        "routeinst.stone-leo.10",
        "update.shylvie.phonecamera",
        "update.shylvie.gallery",
        "update.shylvie.prep",
        "update.shylvie.party",
        "update.shylvie.giftscene",
        "update.shylvie.epilogue"
      ],
      "recipient": "Leo",
      "gift": "Purple Garnet",
      "startArea": "Văn phòng Wanderer"
    },
    {
      "id": "stone-kohi",
      "title": "Đá phong thủy → Kohi / Kim cương hình hạt cà phê",
      "group": "Hỏi Shylvie rồi mua đá phong thủy",
      "start": "Map13 (Văn phòng Wanderer)",
      "steps": [
        "Nói chuyện với Shylvie tới khi nhận tọa độ",
        "Tới tiệm đá",
        "Chọn Kohi làm người nhận"
      ],
      "end": "Map36 (Gợi ý sau ending)",
      "checkKeys": [
        "routeinst.stone-kohi.00",
        "routeinst.stone-kohi.01",
        "routeinst.stone-kohi.02",
        "routeinst.stone-kohi.03",
        "routeinst.stone-kohi.04",
        "routeinst.stone-kohi.05",
        "routeinst.stone-kohi.06",
        "routeinst.stone-kohi.07",
        "routeinst.stone-kohi.08",
        "routeinst.stone-kohi.09",
        "routeinst.stone-kohi.10",
        "update.shylvie.phonecamera",
        "update.shylvie.gallery",
        "update.shylvie.prep",
        "update.shylvie.party",
        "update.shylvie.giftscene",
        "update.shylvie.epilogue"
      ],
      "recipient": "Kohi",
      "gift": "Kim cương hình hạt cà phê",
      "startArea": "Văn phòng Wanderer"
    },
    {
      "id": "stone-shylvie",
      "title": "Đá phong thủy → Shylvie / Congo Tourmaline",
      "group": "Hỏi Shylvie rồi mua đá phong thủy",
      "start": "Map13 (Văn phòng Wanderer)",
      "steps": [
        "Nói chuyện với Shylvie tới khi nhận tọa độ",
        "Tới tiệm đá",
        "Chọn Shylvie làm người nhận"
      ],
      "end": "Map36 (Gợi ý sau ending)",
      "checkKeys": [
        "routeinst.stone-shylvie.00",
        "routeinst.stone-shylvie.01",
        "routeinst.stone-shylvie.02",
        "routeinst.stone-shylvie.03",
        "routeinst.stone-shylvie.04",
        "routeinst.stone-shylvie.05",
        "routeinst.stone-shylvie.06",
        "routeinst.stone-shylvie.07",
        "routeinst.stone-shylvie.08",
        "routeinst.stone-shylvie.09",
        "routeinst.stone-shylvie.10",
        "update.shylvie.phonecamera",
        "update.shylvie.gallery",
        "update.shylvie.prep",
        "update.shylvie.party",
        "update.shylvie.giftscene",
        "update.shylvie.epilogue"
      ],
      "recipient": "Shylvie",
      "gift": "Congo Tourmaline",
      "startArea": "Văn phòng Wanderer"
    },
    {
      "id": "stone-hakase",
      "title": "Đá phong thủy → Hakase / Rainbow Fluorite",
      "group": "Hỏi Shylvie rồi mua đá phong thủy",
      "start": "Map13 (Văn phòng Wanderer)",
      "steps": [
        "Nói chuyện với Shylvie tới khi nhận tọa độ",
        "Tới tiệm đá",
        "Chọn Hakase làm người nhận"
      ],
      "end": "Map36 (Gợi ý sau ending)",
      "checkKeys": [
        "routeinst.stone-hakase.00",
        "routeinst.stone-hakase.01",
        "routeinst.stone-hakase.02",
        "routeinst.stone-hakase.03",
        "routeinst.stone-hakase.04",
        "routeinst.stone-hakase.05",
        "routeinst.stone-hakase.06",
        "routeinst.stone-hakase.07",
        "routeinst.stone-hakase.08",
        "routeinst.stone-hakase.09",
        "routeinst.stone-hakase.10",
        "update.shylvie.phonecamera",
        "update.shylvie.gallery",
        "update.shylvie.prep",
        "update.shylvie.party",
        "update.shylvie.giftscene",
        "update.shylvie.epilogue"
      ],
      "recipient": "Hakase",
      "gift": "Rainbow Fluorite",
      "startArea": "Văn phòng Wanderer"
    },
    {
      "id": "book-shylvie",
      "title": "Atlantis — Sách dịch chuyển → Shylvie",
      "group": "Mua sách phép tại Atlantis",
      "start": "Map10 → Map22 → Map21 → Map23",
      "steps": [
        "Chọn xuống Atlantis",
        "Chọn Phép thuật dịch chuyển nâng cao"
      ],
      "end": "Map36 (Gợi ý sau ending)",
      "checkKeys": [
        "routeinst.book-shylvie.00",
        "routeinst.book-shylvie.01",
        "routeinst.book-shylvie.02",
        "routeinst.book-shylvie.03",
        "routeinst.book-shylvie.04",
        "routeinst.book-shylvie.05",
        "routeinst.book-shylvie.06",
        "routeinst.book-shylvie.07",
        "routeinst.book-shylvie.08",
        "routeinst.book-shylvie.09",
        "routeinst.book-shylvie.10",
        "routeinst.book-shylvie.11",
        "routeinst.book-shylvie.12"
      ],
      "recipient": "Shylvie",
      "gift": "Phép thuật dịch chuyển nâng cao",
      "startArea": "Atlantis"
    },
    {
      "id": "book-hakase",
      "title": "Atlantis — Ma Vương Cổ Đại → Hakase",
      "group": "Mua sách phép tại Atlantis",
      "start": "Map10 → Map22 → Map21 → Map23",
      "steps": [
        "Chọn xuống Atlantis",
        "Chọn Ma Vương Cổ Đại"
      ],
      "end": "Map36 (Gợi ý sau ending)",
      "checkKeys": [
        "routeinst.book-hakase.00",
        "routeinst.book-hakase.01",
        "routeinst.book-hakase.02",
        "routeinst.book-hakase.03",
        "routeinst.book-hakase.04",
        "routeinst.book-hakase.05",
        "routeinst.book-hakase.06",
        "routeinst.book-hakase.07",
        "routeinst.book-hakase.08",
        "routeinst.book-hakase.09",
        "routeinst.book-hakase.10",
        "routeinst.book-hakase.11",
        "routeinst.book-hakase.12"
      ],
      "recipient": "Hakase",
      "gift": "Ma Vương Cổ Đại",
      "startArea": "Atlantis"
    },
    {
      "id": "shopkeeper-first",
      "title": "Atlantis — Nói chuyện với chủ tiệm sách trước",
      "group": "Nói chuyện với chủ tiệm sách trước",
      "start": "Map23 (Tiệm sách phép Atlantis)",
      "steps": [
        "Ưu tiên nói chuyện với chủ tiệm trước khi chọn sách"
      ],
      "end": "Map36 → Title",
      "checkKeys": [
        "routeinst.shopkeeper-first.00",
        "routeinst.shopkeeper-first.01",
        "routeinst.shopkeeper-first.02",
        "routeinst.shopkeeper-first.03"
      ],
      "startArea": "Atlantis"
    },
    {
      "id": "warehouse-chase",
      "title": "Phòng kho → ký ức → rượt đuổi → Paulie",
      "group": "Phòng kho, ký ức và rượt đuổi cùng Paulie",
      "start": "Map22 (Nhà Hải Quỳ)",
      "steps": [
        "Tìm chìa khóa phòng kho",
        "Bật đèn",
        "Đọc Lá thư cuối của Dahria",
        "Đi qua ký ức, mê cung gương, vòng vây clone, rượt đuổi và đối đầu"
      ],
      "end": "Map35 → Map36 (Gợi ý sau ending)",
      "checkKeys": [
        "routeinst.warehouse-chase.00",
        "routeinst.warehouse-chase.01",
        "routeinst.warehouse-chase.02",
        "routeinst.warehouse-chase.03",
        "routeinst.warehouse-chase.04",
        "routeinst.warehouse-chase.05",
        "routeinst.warehouse-chase.06",
        "routeinst.warehouse-chase.07",
        "routeinst.warehouse-chase.08",
        "routeinst.warehouse-chase.09",
        "routeinst.warehouse-chase.10",
        "map28.light",
        "map28.clone.spawn",
        "map28.clone.contact",
        "map28.barrel",
        "map28.spikes",
        "map28.boulder",
        "map28.gauntlet",
        "map28.daze",
        "map28.exit"
      ],
      "startArea": "Atlantis"
    }
  ],
  "scenes": [
    {
      "id": "scene-map3",
      "title": "Map3 — Mở đầu tại Văn phòng Silver Wing",
      "group": "Mở đầu & di chuyển",
      "start": "Map3 (Văn phòng Silver Wing)",
      "steps": [
        "Bắt đầu game/đoạn route tại văn phòng"
      ],
      "end": "Rời văn phòng",
      "checkKeys": [
        "open.map3",
        "visual.dialogue",
        "visual.faces",
        "visual.text",
        "visual.transition"
      ]
    },
    {
      "id": "scene-map17",
      "title": "Map17 — Hành lang Silver Wing",
      "group": "Mở đầu & di chuyển",
      "start": "Map17 (Hành lang Silver Wing)",
      "steps": [
        "Đi hết hành lang"
      ],
      "end": "Map6 (Thành phố)",
      "checkKeys": [
        "open.map17",
        "visual.transition"
      ]
    },
    {
      "id": "scene-map6",
      "title": "Map6 — Thành phố",
      "group": "Mở đầu & di chuyển",
      "start": "Map6 (Thành phố)",
      "steps": [
        "Đi tới trạm/xe bus"
      ],
      "end": "Map10 (Trong xe bus)",
      "checkKeys": [
        "open.map6",
        "visual.transition"
      ]
    },
    {
      "id": "scene-map10",
      "title": "Map10 — Trong xe bus",
      "group": "Mở đầu & di chuyển",
      "start": "Map10 (Trong xe bus)",
      "steps": [
        "Xem đoạn suy nghĩ",
        "Chọn một hướng đi"
      ],
      "end": "Địa điểm đã chọn",
      "checkKeys": [
        "open.map10",
        "visual.dialogue",
        "visual.text",
        "visual.transition"
      ]
    },
    {
      "id": "scene-prep-37",
      "title": "Map37 — Chuẩn bị quà siêu thị",
      "group": "Chuẩn bị quà & ngủ dậy",
      "start": "Map37",
      "steps": [
        "Theo route tương ứng tới phòng Hải Quỳ"
      ],
      "end": "Tiếp tục tới văn phòng Wanderer",
      "checkKeys": [
        "prep.sleep",
        "prep.outfit",
        "prep.light",
        "visual.transition"
      ]
    },
    {
      "id": "scene-prep-47",
      "title": "Map47 — Chuẩn bị mì cay",
      "group": "Chuẩn bị quà & ngủ dậy",
      "start": "Map47",
      "steps": [
        "Theo route tương ứng tới phòng Hải Quỳ"
      ],
      "end": "Tiếp tục tới văn phòng Wanderer",
      "checkKeys": [
        "prep.sleep",
        "prep.outfit",
        "prep.light",
        "visual.transition",
        "update.noodle.camera"
      ]
    },
    {
      "id": "scene-prep-49",
      "title": "Map49 — Chuẩn bị sách cho Shylvie",
      "group": "Chuẩn bị quà & ngủ dậy",
      "start": "Map49",
      "steps": [
        "Theo route tương ứng tới phòng Hải Quỳ"
      ],
      "end": "Tiếp tục tới văn phòng Wanderer",
      "checkKeys": [
        "prep.sleep",
        "prep.outfit",
        "prep.light",
        "visual.transition"
      ]
    },
    {
      "id": "scene-prep-51",
      "title": "Map51 — Chuẩn bị sách cho Hakase",
      "group": "Chuẩn bị quà & ngủ dậy",
      "start": "Map51",
      "steps": [
        "Theo route tương ứng tới phòng Hải Quỳ"
      ],
      "end": "Tiếp tục tới văn phòng Wanderer",
      "checkKeys": [
        "prep.sleep",
        "prep.outfit",
        "prep.light",
        "visual.transition"
      ]
    },
    {
      "id": "scene-prep-60",
      "title": "Map60 — Chuẩn bị quà theo lời Leo",
      "group": "Chuẩn bị quà & ngủ dậy",
      "start": "Map60",
      "steps": [
        "Theo route tương ứng tới phòng Hải Quỳ"
      ],
      "end": "Tiếp tục tới văn phòng Wanderer",
      "checkKeys": [
        "prep.sleep",
        "prep.outfit",
        "prep.light",
        "visual.transition",
        "update.askleo.prep"
      ]
    },
    {
      "id": "scene-prep-stone",
      "title": "Map65 — Phòng Hải Quỳ chuẩn bị quà đá phong thủy",
      "group": "Chuẩn bị quà & ngủ dậy",
      "start": "Map65 (Phòng Hải Quỳ chuẩn bị quà đá phong thủy)",
      "steps": [
        "Theo route đá tới đoạn chuẩn bị quà"
      ],
      "end": "Map38",
      "checkKeys": [
        "prep.sleep",
        "prep.outfit",
        "prep.light",
        "visual.transition",
        "update.shylvie.prep"
      ]
    },
    {
      "id": "scene-party",
      "title": "Map38 — Tiệc Giáng sinh",
      "group": "Tiệc Giáng sinh",
      "start": "Map38 (Văn phòng Wanderer trong tiệc Giáng sinh)",
      "steps": [
        "Đi vào Map38 theo bất kỳ route hợp lệ",
        "Đi tới phần tự do",
        "Chọn tiếp tục"
      ],
      "end": "Phần sau route",
      "checkKeys": [
        "party.arrival",
        "visual.dialogue",
        "visual.faces",
        "visual.text",
        "party.free",
        "map38.rooms",
        "party.snow",
        "party.continue",
        "visual.transition"
      ]
    },
    {
      "id": "scene-noodle-home",
      "title": "Scene ăn mì tại nhà Hải Quỳ",
      "group": "Scene đặc biệt",
      "start": "Nhà Hải Quỳ",
      "steps": [
        "Đi tới cảnh ăn mì cùng Paulie"
      ],
      "end": "Map23 hoặc địa điểm tiếp theo",
      "checkKeys": [
        "scene.noodlehome",
        "visual.dialogue",
        "visual.transition"
      ]
    },
    {
      "id": "scene-snow-bury",
      "title": "Map38 — Hải Quỳ/Aira bị vùi trong tuyết",
      "group": "Tiệc Giáng sinh",
      "start": "Map38",
      "steps": [
        "Theo route tới đoạn bị tuyết vùi"
      ],
      "end": "Phần tự do tại Map38",
      "checkKeys": [
        "scene.snowbury",
        "visual.dialogue",
        "visual.transition"
      ]
    },
    {
      "id": "scene-clone-circle",
      "title": "Map34 — Vòng vây clone",
      "group": "Atlantis rượt đuổi",
      "start": "Map34",
      "steps": [
        "Đi từ mê cung gương tới vòng vây"
      ],
      "end": "Map29",
      "checkKeys": [
        "clone.11",
        "clone.monster",
        "visual.transition"
      ]
    },
    {
      "id": "scene-chase",
      "title": "Map29 — Hành lang rượt đuổi Atlantis",
      "group": "Atlantis rượt đuổi",
      "start": "Map29",
      "steps": [
        "Bắt đầu rượt đuổi"
      ],
      "end": "Map25",
      "checkKeys": [
        "chase.camera",
        "chase.rules",
        "chase.11",
        "chase.cleanup"
      ]
    },
    {
      "id": "scene-paulie",
      "title": "Map25 — Paulie khống chế quái vật",
      "group": "Atlantis rượt đuổi",
      "start": "Map25",
      "steps": [
        "Thoát rượt đuổi và tới đối đầu"
      ],
      "end": "Map35",
      "checkKeys": [
        "paulie.drop",
        "paulie.land",
        "paulie.bind",
        "paulie.talk",
        "paulie.finish",
        "visual.transition"
      ]
    },
    {
      "id": "scene-map35",
      "title": "Map35 — Phòng Hải Quỳ đêm muộn",
      "group": "Atlantis rượt đuổi",
      "start": "Map35",
      "steps": [
        "Hoàn thành đối đầu quái vật"
      ],
      "end": "Map36",
      "checkKeys": [
        "paulie.leave",
        "visual.dialogue",
        "visual.transition"
      ]
    },
    {
      "id": "scene-noodle-cooking-review",
      "title": "Map14 — Nấu mì cay cho Leo",
      "group": "Mua mì cay cho Leo",
      "start": "Map14 (Nhà bếp Wanderer)",
      "steps": [
        "Theo một trong hai nhánh mua mì tới cảnh nấu ăn"
      ],
      "end": "Map38 (Văn phòng Wanderer trong tiệc Giáng sinh)",
      "checkKeys": [
        "noodle.map14once",
        "update.noodle.camera",
        "visual.dialogue",
        "visual.transition"
      ]
    },
    {
      "id": "scene-askleo-message-review",
      "title": "Map56 — Trạm xe buýt và tin nhắn với Leo",
      "group": "Hỏi Leo rồi chọn cửa hàng",
      "start": "Map13 (Văn phòng Wanderer), sau lần nói chuyện thứ ba với Leo",
      "steps": [
        "Xem tin nhắn và thử riêng từng lựa chọn cửa hàng"
      ],
      "end": "Map57, Map58 hoặc Map59 theo lựa chọn",
      "checkKeys": [
        "update.askleo.phone",
        "update.askleo.mapping",
        "visual.dialogue",
        "visual.transition"
      ]
    },
    {
      "id": "scene-askleo-shops-review",
      "title": "Map57–59 — Ba cửa hàng theo gợi ý của Leo",
      "group": "Hỏi Leo rồi chọn cửa hàng",
      "start": "Cửa hàng tương ứng với lựa chọn trong tin nhắn",
      "steps": [
        "Thử tiệm ma pháp, tiệm cà phê Luminous và cửa hàng vũ khí"
      ],
      "end": "Map60 (Phòng Hải Quỳ chuẩn bị quà theo lời Leo)",
      "checkKeys": [
        "update.askleo.mapping",
        "update.askleo.shopcamera",
        "visual.dialogue",
        "visual.faces",
        "visual.transition"
      ]
    },
    {
      "id": "scene-stone-shop-review",
      "title": "Map64 — Tiệm đá phong thủy",
      "group": "Hỏi Shylvie rồi mua đá phong thủy",
      "start": "Map13 (Văn phòng Wanderer), sau đoạn nhắn tin với Shylvie",
      "steps": [
        "Đi vào tiệm và thử bốn lựa chọn người nhận"
      ],
      "end": "Map65 (Phòng Hải Quỳ chuẩn bị quà đá phong thủy)",
      "checkKeys": [
        "update.shylvie.phonecamera",
        "update.shylvie.gallery",
        "visual.dialogue",
        "visual.faces",
        "visual.transition"
      ]
    },
    {
      "id": "scene-stone-gift-review",
      "title": "Map66 — Trao quà đá phong thủy",
      "group": "Hỏi Shylvie rồi mua đá phong thủy",
      "start": "Chọn tiếp tục bữa tiệc ở Map38",
      "steps": [
        "Xem cảnh trao đúng món đá đã mua"
      ],
      "end": "Map67 (Sáng hôm sau của route đá phong thủy)",
      "checkKeys": [
        "update.shylvie.giftscene",
        "visual.dialogue",
        "visual.faces",
        "visual.transition"
      ]
    },
    {
      "id": "scene-stone-epilogue-review",
      "title": "Map67 — Hậu truyện đá phong thủy",
      "group": "Hỏi Shylvie rồi mua đá phong thủy",
      "start": "Sau cảnh trao quà tại Map66",
      "steps": [
        "Đối chiếu hậu quả với món đá đã tặng"
      ],
      "end": "Map36 (Gợi ý sau ending)",
      "checkKeys": [
        "update.shylvie.epilogue",
        "visual.dialogue",
        "visual.faces",
        "visual.transition"
      ]
    }
  ],
  "maps": [
    {
      "id": "map3",
      "title": "Map3 (Văn phòng Silver Wing)",
      "group": "Khu vực công cộng",
      "start": "Map3",
      "steps": [
        "Khám phá các điểm tương tác chính"
      ],
      "end": "Quay lại khu vực trước",
      "checkKeys": [
        "open.map3"
      ]
    },
    {
      "id": "map6",
      "title": "Map6 (Thành phố)",
      "group": "Khu vực công cộng",
      "start": "Map6",
      "steps": [
        "Khám phá các điểm tương tác chính"
      ],
      "end": "Quay lại khu vực trước",
      "checkKeys": [
        "open.map6",
        "visual.transition"
      ]
    },
    {
      "id": "map13",
      "title": "Map13 (Văn phòng Wanderer)",
      "group": "Khu vực công cộng",
      "start": "Map13",
      "steps": [
        "Khám phá các điểm tương tác chính"
      ],
      "end": "Quay lại khu vực trước",
      "checkKeys": [
        "map13.nav"
      ]
    },
    {
      "id": "map14",
      "title": "Map14 (Nhà bếp Wanderer)",
      "group": "Khu vực công cộng",
      "start": "Map14",
      "steps": [
        "Khám phá các điểm tương tác chính"
      ],
      "end": "Quay lại khu vực trước",
      "checkKeys": [
        "map14.return",
        "noodle.map14once",
        "update.noodle.camera"
      ]
    },
    {
      "id": "map15",
      "title": "Map15 (Phòng tắm Wanderer)",
      "group": "Khu vực công cộng",
      "start": "Map15",
      "steps": [
        "Khám phá các điểm tương tác chính"
      ],
      "end": "Quay lại khu vực trước",
      "checkKeys": [
        "map15.return"
      ]
    },
    {
      "id": "map19",
      "title": "Map19 (Siêu thị)",
      "group": "Khu vực công cộng",
      "start": "Map19",
      "steps": [
        "Khám phá các điểm tương tác chính"
      ],
      "end": "Quay lại khu vực trước",
      "checkKeys": [
        "map19.interactions",
        "super.view4",
        "super.freeaftergift"
      ]
    },
    {
      "id": "map20",
      "title": "Map20 (Tiệm mì cay)",
      "group": "Khu vực công cộng",
      "start": "Map20",
      "steps": [
        "Khám phá các điểm tương tác chính"
      ],
      "end": "Quay lại khu vực trước",
      "checkKeys": [
        "map20.choice",
        "update.noodle.camera"
      ]
    },
    {
      "id": "map21",
      "title": "Map21 (Điểm xuống Atlantis)",
      "group": "Khu vực công cộng",
      "start": "Map21",
      "steps": [
        "Khám phá các điểm tương tác chính"
      ],
      "end": "Quay lại khu vực trước",
      "checkKeys": [
        "map21.link"
      ]
    },
    {
      "id": "map23",
      "title": "Map23 (Tiệm sách phép Atlantis)",
      "group": "Khu vực công cộng",
      "start": "Map23",
      "steps": [
        "Khám phá các điểm tương tác chính"
      ],
      "end": "Quay lại khu vực trước",
      "checkKeys": [
        "map23.counter",
        "map23.objects"
      ]
    },
    {
      "id": "map28",
      "title": "Map28 (Mê cung gương Atlantis)",
      "group": "Khu vực công cộng",
      "start": "Map28",
      "steps": [
        "Kiểm tra ánh sáng và Region",
        "Kích hoạt clone, thùng lửa, gai và đá lăn",
        "Hoàn thành bẫy cửa–nút",
        "Thử đủ bốn lần choáng và đi tới lối ra"
      ],
      "end": "Lối ra dẫn tới vòng vây clone",
      "checkKeys": [
        "map28.light",
        "map28.clone.spawn",
        "map28.clone.contact",
        "map28.barrel",
        "map28.spikes",
        "map28.boulder",
        "map28.gauntlet",
        "map28.daze",
        "map28.exit"
      ]
    },
    {
      "id": "map57",
      "title": "Map57 (Tiệm ma pháp)",
      "group": "Khu vực công cộng",
      "start": "Map57",
      "steps": [
        "Khám phá các điểm tương tác chính"
      ],
      "end": "Quay lại khu vực trước",
      "checkKeys": [
        "map57.shop",
        "update.askleo.mapping",
        "update.askleo.shopcamera"
      ]
    },
    {
      "id": "map58",
      "title": "Map58 (Tiệm cà phê)",
      "group": "Khu vực công cộng",
      "start": "Map58",
      "steps": [
        "Khám phá các điểm tương tác chính"
      ],
      "end": "Quay lại khu vực trước",
      "checkKeys": [
        "map58.shop",
        "update.askleo.mapping",
        "update.askleo.shopcamera"
      ]
    },
    {
      "id": "map59",
      "title": "Map59 (Cửa hàng vũ khí)",
      "group": "Khu vực công cộng",
      "start": "Map59",
      "steps": [
        "Khám phá các điểm tương tác chính"
      ],
      "end": "Quay lại khu vực trước",
      "checkKeys": [
        "map59.shop",
        "update.askleo.mapping",
        "update.askleo.shopcamera"
      ]
    },
    {
      "id": "map-stone",
      "title": "Map64 (Tiệm đá phong thủy)",
      "group": "Khu vực công cộng",
      "start": "Map64",
      "steps": [
        "Khám phá các điểm tương tác chính"
      ],
      "end": "Quay lại khu vực trước",
      "checkKeys": [
        "mapstone.shop",
        "update.shylvie.phonecamera",
        "update.shylvie.gallery"
      ]
    },
    {
      "id": "map22",
      "title": "Map22 (Nhà Hải Quỳ)",
      "group": "Nhà Hải Quỳ",
      "start": "Map22",
      "steps": [
        "Khám phá các điểm tương tác chính"
      ],
      "end": "Quay lại khu vực trước",
      "checkKeys": [
        "map22.house",
        "map22.stairs"
      ]
    },
    {
      "id": "map41",
      "title": "Map41 (Phòng Hải Quỳ ở nhà)",
      "group": "Nhà Hải Quỳ",
      "start": "Map41",
      "steps": [
        "Khám phá các điểm tương tác chính"
      ],
      "end": "Quay lại khu vực trước",
      "checkKeys": [
        "map41.room",
        "map22.stairs"
      ]
    },
    {
      "id": "map26",
      "title": "Map26 (Phòng kho nhà Hải Quỳ)",
      "group": "Nhà Hải Quỳ",
      "start": "Map26",
      "steps": [
        "Khám phá các điểm tương tác chính"
      ],
      "end": "Quay lại khu vực trước",
      "checkKeys": [
        "map26.dark",
        "map26.diaries",
        "map26.cassette",
        "warehouse.letter"
      ]
    },
    {
      "id": "map42",
      "title": "Map42 (Phòng Hải Quỳ ở văn phòng Wanderer)",
      "group": "Phòng riêng Wanderer",
      "start": "Map42",
      "steps": [
        "Khám phá các điểm tương tác chính"
      ],
      "end": "Quay lại khu vực trước",
      "checkKeys": [
        "map42.safe",
        "map42.bath",
        "map42.tv",
        "map42.return"
      ]
    },
    {
      "id": "map43",
      "title": "Map43 (Phòng Shylvie)",
      "group": "Phòng riêng Wanderer",
      "start": "Map43",
      "steps": [
        "Khám phá các điểm tương tác chính"
      ],
      "end": "Quay lại khu vực trước",
      "checkKeys": [
        "map43.room",
        "map43.return"
      ]
    },
    {
      "id": "map44",
      "title": "Map44 (Phòng Leo)",
      "group": "Phòng riêng Wanderer",
      "start": "Map44",
      "steps": [
        "Khám phá các điểm tương tác chính"
      ],
      "end": "Quay lại khu vực trước",
      "checkKeys": [
        "map44.room",
        "map44.return"
      ]
    },
    {
      "id": "map45",
      "title": "Map45 (Phòng Hakase)",
      "group": "Phòng riêng Wanderer",
      "start": "Map45",
      "steps": [
        "Khám phá các điểm tương tác chính"
      ],
      "end": "Quay lại khu vực trước",
      "checkKeys": [
        "map45.room",
        "map45.return"
      ]
    },
    {
      "id": "map46",
      "title": "Map46 (Phòng Kohi)",
      "group": "Phòng riêng Wanderer",
      "start": "Map46",
      "steps": [
        "Khám phá các điểm tương tác chính"
      ],
      "end": "Quay lại khu vực trước",
      "checkKeys": [
        "map46.ram",
        "map46.room",
        "map46.return"
      ]
    },
    {
      "id": "map61",
      "title": "Map61 (Phòng họp)",
      "group": "Phòng họp & chế tạo",
      "start": "Map61",
      "steps": [
        "Khám phá các điểm tương tác chính"
      ],
      "end": "Quay lại khu vực trước",
      "checkKeys": [
        "map61.room"
      ]
    },
    {
      "id": "map62",
      "title": "Map62 (Phòng họp Movie Night)",
      "group": "Phòng họp & chế tạo",
      "start": "Map62",
      "steps": [
        "Khám phá các điểm tương tác chính"
      ],
      "end": "Quay lại khu vực trước",
      "checkKeys": [
        "map62.room"
      ]
    },
    {
      "id": "map63",
      "title": "Map63 (Phòng chế tạo)",
      "group": "Phòng họp & chế tạo",
      "start": "Map63",
      "steps": [
        "Khám phá các điểm tương tác chính"
      ],
      "end": "Quay lại khu vực trước",
      "checkKeys": [
        "map63.room"
      ]
    },
    {
      "id": "map38",
      "title": "Map38 (Văn phòng Wanderer trong tiệc Giáng sinh)",
      "group": "Wanderer — các phiên bản",
      "start": "Map38",
      "steps": [
        "Khám phá các điểm tương tác chính"
      ],
      "end": "Quay lại khu vực trước",
      "checkKeys": [
        "party.free",
        "map38.rooms",
        "party.snow",
        "party.continue",
        "update.noodle.partystructure",
        "update.askleo.partyend",
        "update.shylvie.party"
      ]
    },
    {
      "id": "map39",
      "title": "Map39 (Văn phòng Wanderer sáng hôm sau)",
      "group": "Wanderer — các phiên bản",
      "start": "Map39",
      "steps": [
        "Khám phá các điểm tương tác chính"
      ],
      "end": "Quay lại khu vực trước",
      "checkKeys": [
        "map39.rooms"
      ]
    },
    {
      "id": "map48",
      "title": "Map48 (Văn phòng route mì cay)",
      "group": "Wanderer — các phiên bản",
      "start": "Map48",
      "steps": [
        "Khám phá các điểm tương tác chính"
      ],
      "end": "Quay lại khu vực trước",
      "checkKeys": [
        "map48.rooms"
      ]
    },
    {
      "id": "map50",
      "title": "Map50 (Văn phòng sau route sách Shylvie)",
      "group": "Wanderer — các phiên bản",
      "start": "Map50",
      "steps": [
        "Khám phá các điểm tương tác chính"
      ],
      "end": "Quay lại khu vực trước",
      "checkKeys": [
        "map50.rooms"
      ]
    },
    {
      "id": "map52",
      "title": "Map52 (Văn phòng sau route sách Hakase)",
      "group": "Wanderer — các phiên bản",
      "start": "Map52",
      "steps": [
        "Khám phá các điểm tương tác chính"
      ],
      "end": "Quay lại khu vực trước",
      "checkKeys": [
        "map52.rooms"
      ]
    },
    {
      "id": "map54",
      "title": "Map54 (Văn phòng trong cảnh đi tìm Hải Quỳ)",
      "group": "Wanderer — các phiên bản",
      "start": "Map54",
      "steps": [
        "Khám phá các điểm tương tác chính"
      ],
      "end": "Quay lại khu vực trước",
      "checkKeys": [
        "map54.rooms"
      ]
    },
    {
      "id": "map40",
      "title": "Map40 (Chuyến xuống Atlantis lấy cà phê)",
      "group": "Route máy pha cà phê",
      "start": "Map40",
      "steps": [
        "Khám phá các điểm tương tác chính"
      ],
      "end": "Quay lại khu vực trước",
      "checkKeys": [
        "map40.scene"
      ]
    }
  ],
  "minigames": [
    {
      "id": "snow-shylvie",
      "title": "Ném tuyết — Shylvie",
      "group": "Ném tuyết",
      "start": "Map38 (Tiệc Giáng sinh)",
      "steps": [
        "Nói chuyện với Shylvie và chọn chơi ném tuyết",
        "Thử một lượt thắng",
        "Thử một lượt thua hoặc chủ động dừng"
      ],
      "end": "Quay lại Map38",
      "checkKeys": [
        "miniinst.snow-shylvie.00",
        "miniinst.snow-shylvie.01",
        "miniinst.snow-shylvie.02",
        "miniinst.snow-shylvie.03"
      ],
      "opponent": "Shylvie"
    },
    {
      "id": "snow-kohi",
      "title": "Ném tuyết — Kohi",
      "group": "Ném tuyết",
      "start": "Map38 (Tiệc Giáng sinh)",
      "steps": [
        "Nói chuyện với Kohi và chọn chơi ném tuyết",
        "Thử một lượt thắng",
        "Thử một lượt thua hoặc chủ động dừng"
      ],
      "end": "Quay lại Map38",
      "checkKeys": [
        "miniinst.snow-kohi.00",
        "miniinst.snow-kohi.01",
        "miniinst.snow-kohi.02",
        "miniinst.snow-kohi.03"
      ],
      "opponent": "Kohi"
    },
    {
      "id": "snow-leo",
      "title": "Ném tuyết — Leo",
      "group": "Ném tuyết",
      "start": "Map38 (Tiệc Giáng sinh)",
      "steps": [
        "Nói chuyện với Leo và chọn chơi ném tuyết",
        "Thử một lượt thắng",
        "Thử một lượt thua hoặc chủ động dừng"
      ],
      "end": "Quay lại Map38",
      "checkKeys": [
        "miniinst.snow-leo.00",
        "miniinst.snow-leo.01",
        "miniinst.snow-leo.02",
        "miniinst.snow-leo.03"
      ],
      "opponent": "Leo"
    },
    {
      "id": "snow-hakase",
      "title": "Ném tuyết — Hakase",
      "group": "Ném tuyết",
      "start": "Map38 (Tiệc Giáng sinh)",
      "steps": [
        "Nói chuyện với Hakase và chọn chơi ném tuyết",
        "Thử một lượt thắng",
        "Thử một lượt thua hoặc chủ động dừng"
      ],
      "end": "Quay lại Map38",
      "checkKeys": [
        "miniinst.snow-hakase.00",
        "miniinst.snow-hakase.01",
        "miniinst.snow-hakase.02",
        "miniinst.snow-hakase.03"
      ],
      "opponent": "Hakase"
    },
    {
      "id": "fishing",
      "title": "Câu tôm lấy cà phê Atlantis",
      "group": "Câu tôm",
      "start": "Map40",
      "steps": [
        "Chọn đi câu tôm",
        "Thử kéo tôm đen/vàng/đỏ",
        "Thử găng tay/beam",
        "Thử thoát trước đủ 10",
        "Đạt đủ 10"
      ],
      "end": "Quay lại quán và tiếp tục route",
      "checkKeys": [
        "miniinst.fishing.00",
        "miniinst.fishing.01",
        "miniinst.fishing.02",
        "miniinst.fishing.03",
        "miniinst.fishing.04",
        "miniinst.fishing.05",
        "miniinst.fishing.06",
        "miniinst.fishing.07"
      ]
    },
    {
      "id": "chase-direct",
      "title": "Rượt đuổi Atlantis — vào thẳng Map29",
      "group": "Rượt đuổi Atlantis",
      "start": "Map29",
      "steps": [
        "Bắt đầu trực tiếp tại Map29",
        "Sống sót đủ thời gian và gặp đủ clone"
      ],
      "end": "Map25",
      "checkKeys": [
        "miniinst.chase-direct.00",
        "miniinst.chase-direct.01",
        "miniinst.chase-direct.02",
        "miniinst.chase-direct.03"
      ]
    },
    {
      "id": "chase-flow",
      "title": "Rượt đuổi Atlantis — đi từ Map34",
      "group": "Rượt đuổi Atlantis",
      "start": "Map34 → Map29",
      "steps": [
        "Hoàn thành vòng vây clone để tự chuyển sang Map29",
        "Sống sót đủ thời gian và gặp đủ clone"
      ],
      "end": "Map25",
      "checkKeys": [
        "miniinst.chase-flow.00",
        "miniinst.chase-flow.01",
        "miniinst.chase-flow.02",
        "miniinst.chase-flow.03",
        "miniinst.chase-flow.04",
        "miniinst.chase-flow.05"
      ]
    },
    {
      "id": "ship",
      "title": "Game bắn phi thuyền trong siêu thị",
      "group": "Siêu thị",
      "start": "Map19",
      "steps": [
        "Mở game bắn phi thuyền",
        "Thử hoàn thành",
        "Thử thua hoặc thoát",
        "Thử đạt mốc điểm phần thưởng"
      ],
      "end": "Quay lại Map19",
      "checkKeys": [
        "miniinst.ship.00",
        "miniinst.ship.01"
      ]
    },
    {
      "id": "cat",
      "title": "Vuốt mèo trong siêu thị",
      "group": "Siêu thị",
      "start": "Map19",
      "steps": [
        "Mở trò vuốt mèo",
        "Tương tác",
        "Thoát"
      ],
      "end": "Quay lại Map19",
      "checkKeys": [
        "miniinst.cat.00"
      ]
    },
    {
      "id": "tv",
      "title": "Xem TV → Bad Ending “Thêm tập nữa thôi!”",
      "group": "Phân đoạn đặc biệt",
      "start": "Map42",
      "steps": [
        "Tương tác với TV góc trên trái",
        "Xem đủ chín màn hình"
      ],
      "end": "Bad Ending “Thêm tập nữa thôi!”",
      "checkKeys": [
        "miniinst.tv.00"
      ]
    }
  ]
};
