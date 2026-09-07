# GAME SCRIPT — AI COMPACT / DEDUP

Định dạng này tối ưu để AI đọc với ít token hơn. Mỗi `B####` trỏ đến đúng một block văn bản trong `BLOCK REGISTRY`. `B0001..B0010` nghĩa là toàn bộ block từ B0001 đến B0010 theo thứ tự. Các logical document chỉ lưu chuỗi tham chiếu, nên văn bản trùng giữa nhiều route chỉ xuất hiện một lần.

Đã chủ động bỏ: hình/chart; phần Chú thích/Tài nguyên/bảng tài nguyên/bảng hướng dẫn ở đầu các DOCX; hàng `Ctrl + Click`/`Không có` trong bảng điều hướng. Nhãn lựa chọn có ý nghĩa vẫn được giữ thành block `[CHOICES] ...`.

## DOCUMENT SEQUENCES

### Route Bophakhoa
Sources: Route Bophakhoa(1).docx ; Kịch bản Wonder Christmas Fiesta_Bophakhoa(1).docx
MAIN: B0001..B0117 B0116 B0118 B0116 B0119 B0116 B0120..B0154 B0138..B0149 B0155..B0162 B0139..B0142 B0163..B0167 B0148 B0149 B0168..B0173 B0138..B0145 B0174 B0147..B0149 B0175..B0177 B0133 B0178..B0191 B0179..B0182 B0192..B0195 B0187..B0190 B0196 B0179..B0181 B0197..B0202 B0187..B0190 B0203 B0179..B0182 B0204 B0205 B0185..B0188 B0188..B0190 B0206..B0225 B0224 B0226 B0224 B0227..B0321 B0133 B0322..B0332 B0275 B0333..B0337 B0275 B0338..B0352 B0249 B0353..B0361 B0327 B0362..B0368 B0296 B0369..B0372 B0323..B0325 B0373 B0327 B0374..B0381 B0331 B0382..B0385 B0323..B0325 B0386 B0327 B0387..B0391 B0296 B0392 B0331 B0393..B0398 B0296 B0399 B0267 B0400 B0341 B0401 B0267 B0402..B0409 B0356 B0410..B0415 B0275 B0416 B0296 B0417 B0253 B0418 B0419 B0375 B0420 B0421 B0370 B0422 B0423 B0253 B0424..B0434 B0323..B0325 B0435..B0456 B0296 B0457..B0462 B0356 B0463 B0327 B0464..B0468 B0375 B0469 B0356 B0470 B0471 B0253 B0472..B0476 B0375 B0477..B0485 B0253 B0486..B0490 B0358 B0491..B0493 B0327 B0494 B0495 B0258 B0496..B0501 B0296 B0399 B0267 B0400 B0341 B0401 B0267 B0402..B0409 B0356 B0410..B0413 B0502..B0518 B0133 B0519..B0525 B0253 B0526..B0528 B0327 B0529..B0534 B0522 B0535..B0540 B0356 B0541..B0543 B0539 B0544..B0547 B0327 B0548 B0356 B0549..B0551 B0521 B0522 B0552..B0566 B0327 B0567..B0574 B0133 B0575 B0562 B0576..B0588 B0562 B0589..B0598 B0520 B0599..B0603 B0253 B0604..B0612 B0358 B0613..B0623 B0539 B0624 B0625 B0296 B0626..B0633 B0562 B0576 B0634..B0644 B0562 B0576 B0645..B0652
VARIANTS:
- source=Kịch bản Wonder Christmas Fiesta_Bophakhoa(1).docx near_main_position=604: B0653
- source=Kịch bản Wonder Christmas Fiesta_Bophakhoa(1).docx near_main_position=784: B0654

### Route Dao & Chao
Sources: Kịch bản Wonder Christmas Fiesta_DaovaChao(1).docx ; Route DaovaChao(1).docx
MAIN: B0001..B0117 B0116 B0118 B0116 B0119 B0116 B0120..B0139 B0655..B0657 B0142 B0658..B0661 B0148..B0154 B0138 B0139 B0655..B0657 B0142 B0658..B0661 B0148 B0149 B0155..B0158 B0662..B0664 B0161 B0162 B0665..B0667 B0656 B0657 B0142 B0668..B0672 B0149 B0673 B0169..B0173 B0138 B0139 B0674 B0656 B0657 B0142 B0675..B0680 B0149 B0681 B0176 B0177 B0133 B0178..B0181 B0682..B0685 B0189 B0686 B0687 B0191 B0179..B0181 B0688..B0690 B0684 B0685 B0189 B0686 B0687 B0196 B0179..B0181 B0691..B0694 B0684 B0685 B0189 B0686 B0687 B0203 B0179..B0181 B0695..B0697 B0684 B0685 B0189 B0686 B0687 B0206..B0209 B0698..B0709 B0224 B0710 B0224 B0711 B0712 B0224 B0713 B0714 B0228 B0715 B0716 B0229..B0231 B0717 B0233 B0718 B0719 B0236 B0237 B0720..B0722 B0241..B0243 B0723 B0243 B0724 B0245 B0725..B0732 B0249 B0733..B0735 B0253 B0736..B0738 B0262..B0264 B0739 B0272 B0273 B0740..B0742 B0275 B0743..B0747 B0281 B0748 B0749 B0285 B0750 B0286..B0288 B0751 B0290..B0292 B0752 B0753 B0295..B0299 B0754 B0301..B0312 B0755..B0757 B0316..B0321 B0133 B0322..B0328 B0267 B0758 B0759 B0275 B0760..B0762 B0378 B0763 B0296 B0764..B0767 B0275 B0338..B0352 B0249 B0353 B0354 B0768..B0773 B0378 B0774..B0777 B0327 B0778..B0783 B0366..B0368 B0296 B0369..B0372 B0323..B0325 B0373 B0327 B0374 B0375 B0758 B0784 B0253 B0785 B0786 B0296 B0787 B0378 B0788 B0789 B0765 B0790..B0794 B0253 B0424..B0433 B0795 B0356 B0796 B0329 B0797..B0802 B0356 B0803 B0267 B0804..B0808 B0275 B0809 B0356 B0810 B0811 B0453 B0812..B0814 B0249 B0815 B0816 B0375 B0817 B0339 B0818 B0734 B0819..B0825 B0385 B0323..B0325 B0386 B0327 B0387 B0826 B0487 B0827..B0829 B0296 B0830 B0447 B0831..B0835 B0378 B0836 B0447 B0837 B0765 B0838..B0840 B0653 B0296 B0399 B0267 B0400 B0341 B0401 B0267 B0402..B0409 B0356 B0410..B0413 B0502 B0841..B0849 B0275 B0850 B0378 B0851 B0852 B0253 B0853..B0855 B0253 B0856..B0860 B0434 B0323..B0325 B0435..B0439 B0327 B0861 B0442 B0339 B0862..B0864 B0356 B0865..B0869 B0866 B0870..B0872 B0356 B0873 B0375 B0874..B0876 B0356 B0877 B0843 B0878 B0879 B0253 B0880 B0881 B0253 B0882 B0883 B0253 B0884 B0296 B0885 B0886 B0267 B0402..B0409 B0356 B0410..B0413 B0502 B0503 B0887 B0505..B0514 B0888 B0889 B0517 B0518 B0133 B0519..B0522 B0890 B0253 B0891..B0903 B0329 B0904..B0907 B0358 B0908 B0557 B0909..B0911 B0521 B0911 B0521 B0522 B0552 B0358 B0912 B0913 B0620..B0623 B0539 B0624 B0914 B0296 B0626 B0628..B0632 B0253 B0915 B0532..B0534 B0522 B0535..B0540 B0356 B0541 B0542 B0539 B0544 B0545 B0916..B0918 B0548 B0356 B0549..B0551 B0521 B0522 B0552..B0559 B0562 B0563 B0919..B0921 B0275 B0922..B0925 B0356 B0926 B0253 B0927..B0930 B0560 B0931 B0562 B0563 B0919..B0921 B0275 B0922..B0925 B0356 B0926 B0253 B0927..B0930 B0573 B0574 B0133 B0575 B0562 B0932..B0939 B0588 B0562 B0940..B0945 B0633 B0562 B0940 B0946..B0949 B0644 B0562 B0940 B0950..B0955
VARIANTS:
- source=Route DaovaChao(1).docx near_main_position=711: B0956

### Route Khăn Len
Sources: Kịch bản Wonder Christmas Fiesta_Khanlen(1).docx ; Route Khanlen(1).docx
MAIN: B0001..B0117 B0116 B0118 B0116 B0119 B0116 B0120..B0139 B0957 B0142 B0958..B0962 B0151 B0963..B0966 B0139 B0957 B0142 B0958..B0961 B0967 B0156..B0158 B0662..B0664 B0161 B0162 B0665 B0666 B0968 B0142 B0668 B0969..B0972 B0169 B0130..B0132 B0170..B0173 B0138 B0139 B0957 B0142 B0973..B0979 B0176 B0177 B0133 B0178 B0179 B0980..B0994 B0685 B0189 B0686 B0687 B0191 B0179 B0995 B0980 B0996..B1004 B0988 B1005..B1008 B0991 B1009 B0993 B1010 B0685 B0189 B0686 B0687 B0196 B0980 B0996 B1011 B0999 B1012 B0983 B0984 B1013 B0986..B0988 B1014 B0990..B0993 B1015 B0685 B0189 B0686 B0687 B0203 B0179 B0980 B0981 B1016 B0983 B0984 B1017 B0986..B0988 B1018 B0990..B0993 B1019 B0685 B0189 B0686 B0687 B0206..B0208 B1020..B1028 B0224 B1029 B0224 B1030 B0224 B1031 B0228 B0715 B0716 B0229 B0230 B1032..B1040 B0237 B0720..B0722 B0241 B1041..B1043 B0243 B1044 B0245 B1045 B1046 B0262..B0264 B0739 B0272 B0273 B0740..B0742 B1047 B0275 B0743..B0747 B0281 B0748 B0749 B0285 B1048 B1049 B0290..B0292 B0752 B0753 B0295..B0299 B0754 B0301..B0312 B0755..B0757 B0316..B0321 B0133 B0322..B0328 B0267 B1050..B1055 B0814 B0249 B0815 B0816 B0375 B0817 B0339 B0818 B0734 B0819..B0825 B1056 B0370 B1057 B1058 B0794 B0253 B0856..B0860 B0372 B0323 B0324 B1059 B0373 B0327 B1060 B0253 B1061..B1065 B0253 B1066 B0267 B1067..B1076 B0275 B1077..B1082 B0378 B1083 B0275 B1084 B0358 B1085..B1087 B0378 B1088..B1093 B0356..B0361 B0327 B0362 B0363 B0385 B0323..B0325 B1094 B1095 B0386 B0327 B0387 B0358 B1096..B1104 B0327 B1105..B1110 B0370 B1057 B1111 B0794 B0253 B0424..B0433 B1112 B0356 B1113 B0267 B1114 B1115 B0275 B1116 B0434 B0323..B0325 B0435..B0439 B0327 B0861 B1117..B1125 B0865 B1126..B1130 B0868 B1131..B1139 B0356 B1140..B1142 B0356 B1113 B0267 B1114 B1115 B0275 B1116 B0813 B0814 B0249 B0815 B0816 B0375 B0817 B0339 B0818 B0734 B0819..B0825 B1143 B0370 B1057 B1144 B0503 B0887 B0505..B0514 B0888 B0889 B0517 B0518 B0133 B0519 B0533 B0534 B0522 B0535..B0540 B0356 B1145 B1146 B0533 B1147..B1150 B0910 B0911 B0521 B0522 B0552 B0358 B0912 B0913 B0620 B0621 B1151..B1156 B0253 B1157..B1162 B0532 B0551 B0521 B0522 B0552..B0559 B0550 B0520..B0525 B0253 B0526 B1163 B1164 B0327 B0529..B0531 B0560 B0931 B0562 B0563 B0919..B0921 B0275 B0922 B0923 B0296 B1165 B0356 B1166 B0253 B0927..B0930 B1167
VARIANTS:
- source=Route Khanlen(1).docx near_main_position=126: B1168 B1169

### Route Máy Pha Cà Phê
Sources: Kịch bản Wonder Christmas Fiesta_Mayphacaphe(1).docx ; Route Mayphacaphe(1).docx
MAIN: B1170 B0002..B0117 B0116 B0118 B0116 B0119 B0116 B0120..B0122 B1168 B1171..B1175 B0125..B0134 B0127..B0132 B0135..B0139 B1176 B1177 B0142 B1178..B1185 B0142 B1178 B1179 B1186..B1189 B1184 B0151 B0130..B0132 B0963..B0966 B0139 B1190 B1177 B0142 B1178 B1191 B1180 B1192 B1182..B1185 B0142 B1178 B1193..B1197 B1184 B0156 B0130..B0132 B0157 B0158 B0662..B0664 B0161 B0162 B0665 B0666 B1198 B1177 B0142 B0668 B0969 B1199 B0971 B1184 B1185 B0142 B0668 B0969 B1200 B1201 B1184 B0169 B0130..B0132 B0170..B0173 B0138 B0139 B1176 B1177 B0142 B1202 B0974 B1203..B1205 B0978 B1184 B1185 B0142 B1202 B0974 B1203 B1204 B1206 B1184 B0176 B0177 B0133 B0178 B0179 B1207..B1212 B0984 B1213..B1220 B0189 B1221 B1222 B0191 B0179 B1207..B1212 B0984 B1223 B1224 B1215..B1217 B1225 B1219 B1220 B0189 B1221 B1222 B0196 B0179 B1207..B1212 B0984 B1226 B1227 B1215..B1217 B1228 B1219 B1220 B0189 B1221 B1222 B0203 B0179 B1207..B1209 B1229 B1211 B1212 B0984 B1230 B1231 B1215..B1217 B1232 B1219 B1220 B0189 B1221 B1222 B0206..B0208 B1020..B1028 B0224 B1029 B0224 B1030 B0224 B1031 B0228..B0230 B1032..B1040 B0237 B0720..B0722 B0241 B1041..B1043 B0243 B1044 B0245 B1045 B1046 B0262..B0264 B0739 B0272 B0273 B0740..B0742 B1047 B0275 B0743..B0747 B0281 B0748 B0749 B0285 B1048 B1049 B0290..B0292 B0752 B0753 B0295..B0299 B0754 B0301..B0312 B0755..B0757 B0316..B0321 B0133 B0322 B1185 B0323..B0325 B1233..B1235 B0327 B1236 B0267 B1237..B1241 B1177 B0323..B0325 B1233..B1235 B0327 B1236 B0267 B1237..B1239 B1242..B1246 B1240 B1241 B1055 B0814 B0249 B0815 B0816 B0375 B0817 B0339 B0818 B0734 B0819..B0825 B1056 B0370 B1057 B1058 B0794 B0253 B0856..B0860 B0372 B1185 B0323 B0324 B1059 B1233..B1235 B0327 B1060 B0609 B1247 B1248 B0296 B1249 B1250 B0253 B1251..B1255 B0461 B1256..B1258 B1064 B1177 B0323 B0324 B1059 B1233..B1235 B0327 B1060 B0609 B1247 B1248 B0296 B1249 B1250 B0253 B1251..B1255 B0461 B1256 B1259..B1263 B0609 B1264..B1272 B1064 B1273 B1274 B0253 B1066 B0267 B1067..B1076 B0275 B1077..B1082 B0378 B1083 B0275 B1084 B0358 B1085..B1087 B0378 B1088..B1093 B0356..B0361 B0327 B0362 B0363 B0385 B1177 B0323..B0325 B1275 B1234 B1235 B0327 B1276 B0249 B1277 B1278 B0296 B1279..B1284 B0370 B1285 B1057 B1286 B1185 B0323..B0325 B1275 B1234 B1235 B0327 B1276 B0249 B1277 B1278 B0296 B1279 B1284 B0370 B1057 B1286 B1111 B0794 B0253 B0424..B0433 B1112 B0356 B1113 B0267 B1114 B1115 B0275 B1116 B0434 B1177 B0323..B0325 B1287 B1234 B1235 B1288 B0436 B1289 B0438 B1290 B1291 B1118 B1292 B0865 B1293 B0356 B1113 B0267 B1114 B1115 B0275 B1116 B0813 B0814 B0249 B0815 B0816 B0375 B0817 B0339 B0818 B0734 B0819..B0825 B1143 B0370 B1057 B1144 B0503 B0887 B0505..B0514 B0888 B0889 B0517 B0518 B0133 B0519 B0533 B0534 B0522 B0535..B0540 B0356 B1145 B1146 B0533 B1147..B1150 B0910 B0911 B0521 B0522 B0552 B0358 B0912 B0913 B0620 B0621 B1151..B1156 B0253 B1157..B1162 B0532 B0551 B0521 B0522 B0552..B0559 B0550 B0520..B0525 B0253 B0526 B1163 B1164 B0327 B0529..B0531 B0560 B0931 B0133 B1294 B0562 B0563 B0919..B0921 B0275 B0922 B0923 B0296 B1165 B0356 B1166 B0253 B0927..B0930 B0562 B0576 B1295..B1298 B0267 B1299..B1310 B0609 B1311..B1316 B0562 B0576 B1295 B1296 B1185 B1297 B1317 B0375 B1318..B1327 B1177 B1328..B1330 B0911 B1331..B1334 B0911 B1335..B1338 B0551 B1339 B1340 B0533 B1341 B0440 B1342..B1347 B0562 B1185 B1348 B1349 B1177 B1350..B1363 B0562 B0576 B1295..B1298 B0267 B1299 B1300 B1364..B1370 B0356 B1371..B1378 B0533 B1379..B1387 B1167
VARIANTS:
- source=Route Mayphacaphe(1).docx near_main_position=108: B1388 B1389
- source=Route Mayphacaphe(1).docx near_main_position=628: B1390

### Mua Mì Cay Cho Leo
Sources: Mua Mi Cay Cho Leo(1).docx
MAIN: B1170 B0002..B0107 B1391..B1395 B0110 B0111 B1396..B1401 B0142 B1402..B1422 B0126 B0130..B0132 B1423 B0964 B1424 B0966 B0139 B0142 B1425..B1429 B0176 B0177 B1408 B1409 B0179 B1430..B1441 B1414 B0179 B1442..B1444 B0684 B1445 B0189 B1446..B1451 B0206 B0207 B1408 B1409 B1452 B0209 B0698..B0702 B1453 B1454 B0705 B1455 B0709 B0224 B0710 B0224 B0711 B0712 B0224 B0713 B0714 B0228 B1456..B1459 B1414 B0208 B1020..B1023 B1460 B1025 B1461..B1463 B0229 B0230 B1408 B1409 B1032..B1037 B1464..B1468 B0241 B1469 B1470 B1043 B0243 B1471..B1475 B0245 B1045 B1476 B0262..B0264 B0739 B1477 B0273 B0740..B0742 B1047 B0275 B0743..B0747 B0281 B0748 B0749 B0285 B1048 B1049 B0290..B0292 B0752 B0753 B0295..B0299 B0754 B0301..B0312 B0755..B0757 B0316..B0319 B1414 B1032..B1037 B1464 B1465 B1478 B1467 B1468 B0241 B1469 B1470 B1043 B0243 B1479..B1481 B0245 B1045 B1476 B0262..B0264 B0739 B1477 B0273 B0740..B0742 B1047 B0275 B0743..B0747 B0281 B0748 B0749 B0285 B1048 B1049 B0290..B0292 B0752 B0753 B0295..B0299 B0754 B0301..B0312 B0755..B0757 B0316..B0321 B1408 B1409 B0323..B0325 B1482..B1498 B0253 B1499..B1517 B0275 B0338..B0341 B1518 B1519 B0344..B0352 B0249 B0353 B0354 B0768..B0772 B1520..B1533 B0367 B0368 B0296 B0369 B0370 B1534 B1414 B0323..B0325 B1535..B1542 B0911 B1543 B1544 B0455 B1545 B0327 B1492..B1498 B0253 B1499 B1546 B1547 B0275 B1548..B1565 B1505 B1506 B1566 B1508..B1517 B0275 B0338..B0341 B1518 B1519 B0344..B0352 B0249 B0353 B0354 B0768..B0772 B1520..B1533 B0367 B0368 B0296 B0369 B0370 B1534 B0503 B0887 B0505..B0514 B0888 B0889 B0517 B0518 B0520..B0522 B1567 B0253 B0891..B0903 B0329 B0904..B0907 B0358 B0908 B0557 B0909 B0560 B0931 B0562 B0563 B0919..B0921 B0275 B0922 B0923 B0296 B1165 B0356 B1166 B0253 B0927..B0930 B1167

### Nhắn tin Leo
Sources: NhantinLeo(1).docx
MAIN: B1170 B0002..B0107 B1388 B1389 B0110 B1568 B0112 B1569..B1616 B1576 B1617..B1625 B1591 B1626..B1642 B1604 B1643..B1653 B1614 B1654 B0125 B1655 B1574 B1656..B1686 B1665 B1666 B1687..B1693 B1665 B1666 B1687 B1694..B1744 B0126 B1663 B1745 B0130..B0132 B0170..B0173 B0138 B0139 B1746 B1747 B0142 B0675..B0679 B1748 B1749 B0130..B0132 B0963..B0966 B0139 B0142 B1750..B1752 B1195 B1753..B1756 B0127 B0128 B0130..B0132 B0157 B0158 B0662..B0664 B0161 B0162 B0665 B0666 B0142 B0668 B0969 B1757..B1759 B0176 B0177 B1663 B1745 B0179 B1760 B1761 B0684 B0685 B0189 B0686 B0687 B1749 B0179 B1762 B1763 B0684 B0685 B0189 B0686 B0687 B1756 B0179 B1207 B1208 B1764 B1765 B1211 B1212 B0984 B1766 B1227 B1215..B1217 B1767 B1219 B1220 B0189 B1221 B1768 B0206..B0208 B1020..B1023 B1460 B1025 B1461 B1027 B1028 B0224 B1029 B0224 B1030 B0224 B1031 B0228 B0715 B0229 B0230 B1032..B1040 B0237 B0720..B0722 B0241 B1041..B1043 B0243 B1044 B0245 B1045 B1046 B0262..B0264 B0739 B0272 B0273 B0740..B0742 B1047 B0275 B0743..B0747 B0281 B0748 B0749 B0285 B1048 B1049 B0290..B0292 B0752 B0753 B0295..B0299 B0754 B0301..B0312 B0755..B0757 B0316..B0321 B1663 B1745 B0323..B0325 B0435..B0439 B0327 B0861 B1769 B0339 B1770 B1771 B0275 B1772 B1773 B0375 B1774..B1780 B0356 B1781 B1782 B0356 B0873 B0375 B0874..B0876 B0356 B0877 B0843 B0878 B0879 B0253 B0880 B0881 B0253 B0882 B0883 B0253 B0884 B0296 B0885 B0886 B0267 B0402..B0409 B0356 B0410..B0413 B0502 B1749 B0323..B0325 B0373 B0327 B0374 B1783 B1784 B1248 B0249 B1785 B1250 B0253 B1251..B1255 B0461 B1256 B1259 B1786 B1257 B1258 B1064 B1787 B0253 B1066 B0267 B1067..B1076 B0275 B1077..B1082 B0378 B1083 B0275 B1084 B0358 B1085..B1087 B0378 B1088..B1093 B0356..B0361 B0327 B0362 B0363 B1756 B0323..B0325 B1788 B0327 B1789 B0249 B1790..B1792 B0296 B1279 B1793 B0375 B0817 B0339 B0818 B0734 B0819..B0821 B1794 B0823..B0825 B1056 B0370 B1057 B1286 B1111 B0794 B0253 B0424..B0433 B1112 B0356 B1113 B0267 B1114 B1115 B0275 B1116 B0503 B0887 B0505..B0514 B0888 B0889 B0517 B1745 B0551 B0521 B0522 B0552..B0559 B1749 B0911 B0521 B0911 B0521 B0522 B0956 B0358 B0912 B0913 B0620..B0623 B0539 B0624 B0914 B0296 B0626 B0628..B0632 B0253 B0915 B1756 B0533 B0534 B0522 B0535..B0540 B0356 B0541 B0542 B0539 B0544 B0545 B0916..B0918 B0548 B0356 B0549 B0560 B0931 B0562 B0563 B0919..B0921 B0275 B0922 B0923 B0296 B1165 B0356 B1166 B0253 B0927..B0930 B1167

### Nhắn tin Shylvie
Sources: NhantinShylvie(1).docx
MAIN: B1170 B0002..B0107 B1388 B1389 B0110 B1568 B0112 B1569..B1616 B1576 B1617..B1625 B1591 B1626..B1642 B1604 B1643..B1653 B1614 B1654 B0125 B1655 B1795 B1657 B1796..B1800 B1666 B1801..B1804 B0126 B1805 B1806 B0135..B0139 B1807 B0142 B1808..B1813 B1745 B0130..B0132 B0170..B0173 B0138 B0139 B1814 B0142 B1815 B0676 B1816..B1820 B1749 B0130..B0132 B0963..B0966 B0139 B1821 B0142 B1822..B1828 B1756 B0127 B0128 B0130..B0132 B0157 B1829..B1832 B0161 B0162 B1833 B1834 B0142 B1835..B1840 B0176 B0177 B1805 B1806 B0179 B1841 B0684 B0685 B0189 B0686 B0687 B1745 B0179 B1842 B0684 B0685 B0189 B0686 B0687 B1749 B0179 B1843 B0684 B0685 B0189 B0686 B0687 B1756 B0179 B1844 B0684 B0685 B0189 B0686 B0687 B0206..B0208 B1020..B1023 B1460 B1025 B1461 B1027 B1028 B0224 B1029 B0224 B1030 B0224 B1031 B0228 B0715 B0229 B0230 B1032..B1040 B0237 B0720..B0722 B0241 B1041..B1043 B0243 B1044 B0245 B1045 B1046 B0262..B0264 B0739 B0272 B0273 B0740..B0742 B1047 B0275 B0743..B0747 B0281 B0748 B0749 B0285 B1048 B1049 B0290..B0292 B0752 B0753 B0295..B0299 B0754 B0301..B0312 B0755..B0757 B0316..B0321 B1805 B1806 B0323..B0325 B1845 B0327 B0328 B0267 B1846..B1848 B0296 B1849..B1855 B0275 B0338..B0352 B0249 B0353..B0361 B0327 B0362..B0368 B0296 B0369..B0371 B1745 B0323..B0325 B1856 B0436..B0439 B0327 B0861 B0442 B0339 B1770 B1857 B0296 B1858..B1861 B0356 B1862 B0249 B1863 B0765 B1864..B1871 B0356 B1872 B1873 B0356 B0873 B0375 B0874..B0876 B0356 B0877 B0843 B0878 B0879 B0253 B0880 B0881 B0253 B0882 B0883 B0253 B0884 B0296 B0885 B0886 B0267 B0402..B0409 B0356 B0410..B0413 B0502 B1749 B0323..B0325 B0373 B0327 B0374 B1783 B1874 B1875 B0249 B1876 B1250 B0253 B1251..B1255 B0461 B1256 B1259 B1877 B1257 B1878..B1888 B1064 B1889..B1891 B0253 B1066 B0267 B1067..B1076 B0275 B1077..B1082 B0378 B1083 B0275 B1084 B0358 B1085..B1087 B0378 B1088..B1093 B0356..B0361 B0327 B0362 B0363 B1756 B0323..B0325 B1892 B0327 B1893 B0249 B1894 B1895 B0296 B1896 B1897 B0375 B0817 B0339 B0818 B0734 B0819 B1898 B0821 B1899 B1900 B0825 B1056 B0370 B1057 B1286 B1111 B0794 B0253 B0424..B0433 B1112 B0356 B1113 B0267 B1114 B1115 B0275 B1116 B0503 B0887 B0505..B0514 B0888 B0889 B0517 B0518 B1745 B0551 B0521 B0522 B0552..B0559 B1749 B0911 B0521 B0522 B1901..B1917 B1806 B0520..B0522 B1918 B1919 B0894..B0903 B0329 B0904..B0907 B0358 B0908 B0557 B0909 B1756 B0533 B0534 B0522 B0535..B0540 B0356 B0541 B0542 B0539 B0544 B0545 B0916..B0918 B0548 B0356 B0549 B0560 B0931 B0562 B0563 B0919..B0921 B0275 B0922 B0923 B0296 B1165 B0356 B1166 B0253 B0927..B0930 B0573 B0574 B0133 B0575 B0576 B0634 B1920..B1926 B0562 B1927 B1928 B0588 B0576 B0634 B1929..B1934 B0562 B1935..B1938 B1928 B0633 B0576 B0634 B1939..B1943 B0562 B1944..B1947 B0644 B0576 B0634 B1948..B1959

### Tin nhắn
Sources: Kịch bản Wonder Christmas Fiesta_Tinnhanv2(1).docx ; Kịch bản Wonder Christmas Fiesta_Tinnhan(1).docx ; Kịch bản Wonder Christmas Fiesta_Tinnhanv1(1).docx
MAIN: B1960..B1990 B1977 B1991..B2016 B1294 B2017..B2023 B1316 B2024..B2033 B1316 B2034..B2039 B1347 B2040..B2047 B1294 B2034 B2048..B2052 B2040 B2053..B2056 B1363 B2024 B2057..B2068 B1363 B2017 B2018 B2069..B2072 B1347 B2034 B2073..B2087 B1977 B2088..B2102 B1977 B2103..B2107 B1970 B2108..B2112 B1982 B2113..B2144

### Thoại tương tác Silver Wing
Sources: Thoại_Tương tác (4)(1).docx ; Thoại_Tương tác_FIXED(1).docx
MAIN: B2145..B2188 B2181 B2189..B2194 B2157 B2195..B2205 B2165 B2206..B2316

### Thoại tương tác ST
Sources: Thoại Tương Tác ST_FIXED(1).docx
MAIN: B2317..B2319 B2157 B2320..B2329 B2165 B2330..B2390

### Tương tác map Magic Shop
Sources: Tương tác map Magic Shop.docx
MAIN: B2391..B2393 B2157 B2394..B2396 B2165 B2397 B2398 B2172 B2399..B2455 B2327 B2456..B2485 B2466..B2470 B2486 B2472..B2474 B2487..B2538

### Tương tác map Phòng Chế Tạo
Sources: Tương tác map phòng chế tạo.docx
MAIN: B2539..B2584

### After Ending Hint
Sources: AFTER ENDING HINT(1).docx
MAIN: B2585 B2586 B1294 B2587..B2592 B1316 B2587 B2593..B2595 B2591 B2592 B2596 B1347 B2587 B2597..B2603 B1363 B2587 B2604..B2608 B1294 B2587 B2609..B2614 B1316 B2587 B2615..B2618 B1347 B2587 B2609 B2619..B2625 B1363 B2587 B2626..B2634 B1294 B2587 B2635..B2640 B1316 B2587 B2641..B2644 B1347 B2587 B2645..B2649 B1363 B2587 B2650..B2655 B1294 B2587 B2656..B2660 B1316 B2587 B2661..B2667 B2650 B1347 B2587 B2668..B2672 B1363 B2587 B2673..B2684 B1294 B2587 B2685..B2690 B1316 B2587 B2691..B2695 B1347 B2587 B2696..B2698 B1363 B2587 B2699..B2706 B1316 B2587 B2707 B2708 B2611..B2613 B2709 B1347 B2587 B2710..B2713 B1363 B2714..B2718 B2716 B2719..B2728 B2587 B2729..B2740 B1347 B2587 B2741..B2745 B1363 B2587 B2746 B2747 B2647 B2748..B2761 B2714 B2762 B2587 B2763..B2767 B2716 B2768 B2769 B2764 B2770 B2771 B2767 B2716 B2772 B2764 B2773 B2767 B2774..B2776 B2764 B2777..B2780 B2767 B2781 B2782 B2764 B2783 B2767 B2784 B2785 B2764 B2786 B2787 B2767 B2647 B2788 B2764 B2789 B2790 B2767 B2791 B2764 B2792 B2793 B2767 B2794 B2746 B2764 B2795..B2799 B2767 B2800 B2764 B2801 B2767 B2746 B2764 B2802..B2808 B2767 B2809 B2810 B2767 B2811..B2824

## BATCH 2 — DOCUMENT SEQUENCES

### Route Xuống Atlantis Mua Sách Phép
Source: Xuống Atlantis Mua Sách Phép(1).docx
MAIN: B1170 B0002..B0090 B2825 B0092..B0107 B2826..B2828 B0110 B0111 B2829..B2850 B2844 B2851..B2864 B2852 B2865 B2866 B2852 B2867..B2892 B2890 B2893..B2896 B2890 B2897..B2914 B2910 B2911 B2915 B2912 B2916..B2952 B1407 B2953..B2958 B0126 B2953 B2959 B2960 B2844 B2961..B2966 B2862 B2967..B3004 B2977 B3005..B3026 B2954 B0130..B0132 B0170..B0173 B0138 B0139 B3027 B0142 B3028..B3032 B1748 B3033 B0127 B0128 B0130..B0132 B0157 B0158 B0662..B0664 B0161 B0162 B0665 B3034 B0142 B0668 B0969 B3035 B1758 B3036 B0176 B0177 B2954 B0179 B1842 B0684 B0685 B0189 B0686 B0687 B3033 B1844 B0684 B0685 B0189 B0686 B0687 B0206..B0208 B1020..B1022 B3037 B3038 B1025 B3039 B1027 B3040 B0224 B1029 B0224 B3041 B0224 B3042 B0228 B3043 B0229 B0230 B1032 B3044 B1034..B1040 B0237 B0720..B0722 B0241 B1041..B1043 B0243 B1044 B0245 B1045 B1046 B0262..B0264 B0739 B0272 B0273 B0740..B0742 B1047 B0275 B0743..B0747 B0281 B0748 B0749 B0285 B1048 B1049 B0290..B0292 B0752 B0753 B0295..B0299 B0754 B0301..B0312 B0755..B0757 B0316..B0321 B2954 B0323..B0325 B3045 B0436..B0439 B0327 B0861 B3046 B0339 B1770 B3047..B3064 B3055 B3065..B3070 B0356 B0873 B0375 B0874..B0876 B0356 B0877 B0843 B0878 B0879 B0253 B0880 B0881 B0253 B0882 B3071 B0253 B0884 B0296 B3072 B3073 B0267 B0402..B0409 B0356 B0410..B0413 B0502 B3033 B0323..B0325 B3074 B0327 B3075 B0249 B3076..B3091 B0370 B1057 B1286 B1111 B0794 B0253 B0424..B0433 B1112 B0356 B1113 B0267 B1114 B1115 B0275 B1116 B0503 B0887 B0505..B0514 B0888 B0889 B0517 B0518 B0551 B0521 B0522 B0552..B0560 B0931 B3092..B3109 B0562 B0563 B0919..B0921 B0275 B0922 B0923 B0296 B1165 B0356 B1166 B0253 B0927..B0930 B0573 B0574 B2954 B0562 B0933 B3110..B3130 B0652 B3033 B0933 B3131 B0635 B3132..B3149 B0652 B3150..B3186 B0652 B2959 B3187..B3235 B0652

### Tương tác phòng ngủ Hải Quỳ — Wanderer Office
Source: TƯƠNG TÁC MAP PHÒNG NGỦ HẢI QUỲ Ở VĂN PHÒNG WANDERER.docx
MAIN: B3236..B3238 B1576 B3239 B1591 B3240..B3242 B1604 B3243..B3258

### Tương tác nhà Hải Quỳ
Source: Tương tác nhà Hải Quỳ.docx
MAIN: B3259..B3287 B2157 B3288..B3290 B2165 B3291..B3293 B2172 B3294 B3295 B2401 B3296..B3330

### Tương tác phòng Hải Quỳ ở nhà
Source: TƯƠNG TÁC PHÒNG HẢI QUỲ Ở NHÀ.docx
MAIN: B3331..B3376

### Tương tác phòng Hakase
Source: Tương tác phòng Hakase.docx
MAIN: B3377..B3401

### Tương tác phòng kho
Source: Tương tác phòng kho.docx
MAIN: B3402..B3410 B3405 B3411..B3414 B3406 B3415..B3419 B3407 B3420..B3494

### Tương tác phòng Leo
Source: TƯƠNG TÁC PHÒNG LEO.docx
MAIN: B3495..B3516

### Tương tác phòng ngủ Kohi
Source: Tương tác phòng ngủ Kohi.docx
MAIN: B3517..B3535

### Tương tác phòng ngủ Shylvie
Source: Tương tác phòng ngủ Shylvie.docx
MAIN: B3536..B3557

### Tương tác quán cà phê
Source: Tương tác quán cà phê.docx
MAIN: B3558..B3667

### Tương tác tiệm sách cũ
Source: TƯƠNG TÁC TIỆM SÁCH CŨ.docx
MAIN: B3668 B3669 B2157 B3670..B3672 B2165 B3673..B3684 B2165 B3682..B3797

## BLOCK REGISTRY

B0001: Kịch bản Wonder Christmas Fiesta Route mua đồ móc len
B0002: Cảnh số 1:
B0003: [ BG văn phòng. Sfx gõ bàn phím. BGM Unbound – Sonic Adventure ]
B0004: - Ôi, những ngày cuối năm nhiều công việc sổ sách quá!! Tôi cứ làm mãi mà nó không hết!! Chán quá đi mất thôi huhu!!
B0005: - Alpha C-61 à, nếu đồng chí không ngồi chơi Băng Hoại Đường Ray Tinh Tú suốt hai tuần vừa rồi thì có lẽ đồng chí sẽ không báo hại tôi phải ngồi làm tới giờ này và có thể nghỉ lễ sớm hơn rồi đấy. Nên là lo mà làm đi.
B0006: [ Ngưng sfx gõ bàn phím ]
B0007: - Huhu Omega D-13, Beta-M34 bắt nạt tôi kìa!! Cậu nói gì đi chứ!
B0008: [ Sprite Hải Quỳ ver2.0 cười mỉm ]
B0009: - Cố lên nhé, Alpha C-61!
B0010: - Tôi đã mong đợi nhiều hơn thế…Huhu
B0011: Tôi mau chóng sắp xếp gọn các xấp giấy tờ đã xử lý vào tủ hồ sơ.
B0012: [ Sfx khóa cửa tủ ]
B0013: Sau khi kiểm tra lại các tệp hồ sơ tôi đã hoàn thành thêm lần nữa, tôi quyết định khóa tủ và bàn giao chiếc chìa khóa tủ hồ sơ cho đồng chí Beta M-34, người đang tập trung hết sức gõ phím để giải quyết hậu sự lười biếng của đồng chí Alpha C-61.
B0014: [ sfx gõ bàn phím ]
B0015: - Beta M-34, hồ sơ về khu vực rìa lỗ hổng vực sâu 61 đã tổng hợp xong. Chìa khóa đây, giữ kỹ nhé.
B0016: - Cảm ơn Omega D-13! Chúc đồng chí có kỳ nghi vui vẻ!
B0017: - Đừng đi mà Omega D-13! Hãy nghĩ về tình đồng chí!! Đồng chí không thể nào nghỉ lễ trước bọn tôi chứ!!
B0018: - Im đi Alpha C-61!
B0019: [ sfx Cốp ]
B0020: Nói dứt lời, Beta M-34 dùng tay gõ thật mạnh vào đầu của Alpha C-61 một cái " cốp ".
B0021: - Đồng chí cứ an tâm nghỉ lễ. Việc tồn đọng cứ để tôi và tên lười biếng này giải quyết!
B0022: - Haha, cảm ơn hai đồng chí. Đừng làm quá sức nhé.
B0023: Tui vẫy tay chào tạm biệt họ rồi thong thả rảo bước ra về.
B0024: Hết cảnh số 1
B0025: Cảnh số 2
B0026: [ BG đường phố. Hiệu ứng choáng váng. BGM Collection room – Sonic Generation. Sprite Hải Quỳ đồ thường nhật mặt vui vẻ ]
B0027: Vừa bước khỏi cửa Văn Phòng Silver Wing, đôi mắt của tôi ngay lập tức bị ánh nắng làm cho choáng váng suýt ngã lăn ra nền đất.
B0028: Đã hơn ba ngày rồi tôi không được ngủ vì phải liên tục săn lùng quái vật vực sâu lẫn giải quyết hồ sơ vụ án tồn đọng trong năm.
B0029: [ CG Hải Quỳ sụ mặt nhớ lại từng vụ. CG bắn beam trong mưa, CG sấy quần áo hiện lên nối tiếp ]
B0030: Hôm nay trời đẹp thế nhỉ. Chả bù cho ba ngày trước, ngày nào cũng mưa tầm mưa tã, mưa như trút nước. Mấy ngày vừa rồi tôi phải đội mưa đi tiêu diệt quái vật, phiền muốn chết. Mặc dù trời mưa là lợi thế để tôi sử dụng các loại phép liên quan đến nước nhưng việc phải sấy khô quần áo liên tục khiến tôi phát bực.
B0031: [ sfx còi xe buýt ]
B0032: Không biết Shylvie có biết phép thuật nào liên quan đến sấy khô quần áo cấp tốc không nhỉ? Nếu có thì tôi phải vòi học cho bằng được!
B0033: [ Sfx bước chân ]
B0034: Tôi lững thững bước đến trạm xe buýt cách văn phòng hơn chục bước rồi ngồi xuống băng ghế chờ. Tai tôi cứ nghe thấy tiếng gì đó " ting ting ", " ting ting " không dứt. Mà tiếng này quen lắm, hình như tôi đã nghe ở đâu đó rồi.
B0035: Tay tôi theo phản xạ đút vô túi váy, rút ra một chiếc điện thoại. À ừ nhỉ! Nó là tiếng báo tin nhắn mà!!
B0036: Đã ba ngày rồi tôi chưa đụng vào điện thoại, không biết là đã lỡ bao nhiêu tin nhắn nhỉ?
B0037: Cái chế độ mã hóa chết tiệt! Mắc gì cho phép đọc tin nhắn mới ngay bây giờ thôi vậy?!
B0038: [ CG tin nhắn. Tin nhắn của từng nhân vật như: Mẹ, Wanderer Office, OniiOni-Chan, Bố hiện ra. Hải Quỳ ngồi kiểm tra tin nhắn của Wanderer Office ]
B0039: ( Leo: Ủa, mấy nay có ai liên lạc được với Quỳ không??
B0040: Shylvie: Chịu, chả biết bà ấy đi đâu.
B0041: Kohi: Tui không thấy Quỳ onl luôn ấy.
B0042: Hakase: Tôi cũng vậy.
B0043: Leo: Hừm. Vậy mọi người tính giáng sinh năm nay tổ chức như thế nào?
B0044: Kohi: Ồ, bên mình có tổ chức giáng sinh mỗi năm luôn hả?
B0045: Leo: Có chứ! Giáng sinh năm ngoái bọn tui đóng giả làm ông già Noel để đi tặng quà cho khách hàng ấy.
B0046: Shylvie: Nói đúng hơn là đột nhập trái phép đó. Năm ngoái Leo suýt nữa bị bắt được, may mà ổng biến thành dơi nên trốn kịp.
B0047: Leo: Nè, tại ai vậy hả?? Nếu lúc đó ông không đạp tui xuống đột ngột thì đâu có chuyện đó.
B0048: Hakase: Nhí nhí mọi người, cho tôi hỏi cái.
B0049: Leo: Sao thế?
B0050: Shylvie: Hả, hỏi gì.
B0051: Hakase: Bọn mình…có khách hàng hả?
B0052: Kohi: Trời má trùng hợp ghê, cũng đang tính hỏi. Đến giờ tôi vẫn chưa hiểu văn phòng của mình có công việc gì luôn.
B0053: Shylvie: Ờm….Bà biết đó, ờm...
B0054: Leo: Giải quyết yêu cầu của khách hàng đến từ đa chiều không gian khác nhau. Lúc thì điều tra án mạng, lúc thì điều tra chân tướng sự kiện bất thường. Có lúc thì đi bảo vệ, giải cứu dân thường hoặc là đi thanh trừng quái vật.
B0055: Shylvie: Không biết lý do vì sao mà dạo gần đây bọn tôi toàn nhận được yêu cầu đi thanh trừng quái vật nên là không muốn để mọi người đi. Vì mọi người chưa được rèn luyện lẫn trang bị phù hợp nên là không thể để mọi người mạo hiểm được.
B0056: Leo: Đa phần công việc thanh trừng quái vật bọn tui toàn để cho Hải Quỳ giải quyết thôi. Bả bắn tia năng lượng một phát là xong ngay ấy mà.
B0057: Shylvie: Và…đó cũng là vấn đề mà bọn tôi đang nhức đầu đây,
B0058: Kohi: Hả? Sao lại nhức đầu?
B0059: Hakase: Đừng nói là bả bắn beam xuyên không gian nhé?
B0060: Leo: Nah, không phải đâu.
B0061: Shylvie: Để du hành sang chiều không gian khác, tôi cùng với cựu thành viên đã chế tạo ra một trang bị, một chiếc vòng tay có gắn la bàn, giúp cho người du hành có thể thích ứng kịp thời với quy luật sống ở chiều không gian đấy.
B0062: Shylvie: Mỗi chiều không gian sẽ có quy luật sống riêng, cũng như là quy luật và trật tự ma pháp riêng.
B0063: Shylvie: Và Hải Quỳ…Ở một số chiều không gian, ma lực của bả vượt xa cả quy luật ở đó. Dẫn đến việc trang bị bị quá tải và hỏng liên tục.
B0064: Leo: Yeah. Bọn tui cố sửa chữa để kịp cho các yêu cầu tiếp theo nhưng không kịp. Thế nên bọn tui đành cho bả mượn trang bị của bọn tui lẫn các trang bị dự phòng. Đó cũng là lý do mà tui vẫn chưa giao nhiệm vụ nào cho hai người đó.
B0065: Hakase: Trời má, ghê dữ vậy hả.
B0066: Kohi: Bả làm hỏng hết luôn?
B0067: Shylvie: Chứ sao nữa. Hỏng hết. Có cái không còn sửa được luôn.
B0068: Leo: Ồ, nói ra mới nhớ. Tần suất hoạt động của Quái Vật Vực Sâu tăng lên đáng kể những tháng cuối năm nhỉ. Năm ngoái cũng vậy, tui nhớ là đến tận những ngày gần cuối năm bả mới ló mặt đến Văn Phòng Wanderer đó. Chả lẽ năm nay cũng vậy??
B0069: Hakase: Có lẽ nào…
B0070: Quỳ: Ông cũng để ý nhỉ. Cơ mà tui đã giải quyết xong hết rồi, tui đoán vậy.
B0071: Leo: Quỳ! Cuối cùng bà cũng onl! Ý bà giải quyết xong hết rồi là sao?
B0072: Quỳ: Thì tui làm hết nhiệm vụ cấp trên giao cho và được nghỉ lễ trước cả mấy bạn ở Silver Wing luôn đấy. Khen tui cái coi.
B0073: Shylvie: Trời ơi, Ma pháp thiếu nữ Hải Quỳ toàn năng tài giỏi quá trời ơi, làm hết việc luôn cơ!! Đỉnh cao đỉnh cao!!
B0074: Quỳ: Tui đánh ông giờ. Khen hay là khịa đấy.
B0075: Shylvie: Tùy bà nghĩ thôi, lmao.
B0076: Quỳ: Để tôi đoán nhé, ông tính hỏi tui về hoạt động Noel năm nay hả?
B0077: Leo: Ừ.
B0078: Quỳ: Năm nay tui muốn mọi người sẽ tặng quà theo vòng cho nhau!
B0079: Kohi: Ý Quỳ là sao á?
B0080: Shylvie: Nghe…rất gì và này nọ…? Nói rõ hơn đi.
B0081: Quỳ: Thì giả sử tui tặng cho Leo, Leo sẽ tặng cho Shylvie, Shylvie tặng Kohi và Kohi tặng Hakase.
B0082: Hakase: Nghe thú vị thế!
B0083: Leo: À à, tui hiểu ý bà rồi. Là tặng theo vòng tròn, người cuối cùng sẽ tặng cho bà đúng không?
B0084: Quỳ: Yeh, nó đó!! Tui sẽ là người bắt đầu!
B0085: Kohi: À. Thế thì Quỳ chuẩn bị quà sớm rồi thông báo người tiếp theo nhé để bọn tôi chuẩn bị quà kịp!! Tại nay cũng là 21 rồi đó!
B0086: Quỳ: Đang chuẩn bị đây. Chiều nay tui sẽ thông báo ai sẽ là " The choosen one"! )
B0087: [ Sfx còi xe buýt ]
B0088: Tôi nghe thấy tiếng còi của xe buýt. Tôi lập tức đứng dậy và giơ tay vẫy chiếc xe buýt đang chạy gần đến.
B0089: Hết cảnh số 2
B0090: Cảnh số 3
B0091: [ Sfx xe buýt mở cửa + bước chân. BGM Seascape – Knuckles Chaotix. Màn hình đen.  ]
B0092: Chuyến xe buýt này đang vắng nên còn trống nhiều chỗ. Vì muốn ngắm nhìn phong cảnh bên ngoài nên tôi quyết định ngồi ở hàng ghế cuối, ngồi ngay chiếc ghế gần cửa sổ.
B0093: [ CG Hải Quỳ ngồi trên xe buýt bấm điện thoại ]
B0094: Nếu mà nửa kia của tôi mà ngồi ở vị trí này thì nó sẽ bị say xe đấy. Tại hàng ghế cuối nó sốc lắm.
B0095: Giáng sinh sao…? Vào tháng 12 ở Việt Nam, tiết trời chỉ se se lạnh thôi chứ không lạnh đến độ có tuyết rơi. Muốn có tuyết rơi thì phải lên các tỉnh vùng cao, khi ấy sẽ thấy tuyết rơi trắng xóa ngợp cả bầu trời, phủ một tấm mền trắng lên cỏ cây khắp bốn phương trời.
B0096: Văn phòng Wanderer thì nằm trong khu vực nơi mà không có sự khác biệt rõ rệt giữa bốn mùa trong năm. Làm sao để có thể tạo ra bầu không khí giáng sinh giống hệt như các phim bộ mà tôi đã xem nhỉ?
B0097: A đúng rồi! Tôi có Sierra mà!! Tôi có thể đưa ra yêu cầu cho Sierra điều chỉnh không gian cho cả văn phòng ngập trong tuyết là được! Sau đó là trang trí theo kiểu giáng sinh nhất có thể! Tôi quả là thiên tài! Sierra là AI tuyệt vời nhất mà tôi chôm được từ Poseidon mà! Nhất định Sierra sẽ làm được!!
B0098: " The choosen one "…." The choosen one "….Ai sẽ là người được chọn đây?
B0099: [ Emoji của Leo hiện ra ]
B0100: Người đầu tiên mà tôi nghĩ tới đó là Leo. Leo Murasami, một ma cà rồng 2000 tuổi đến từ chiều không gian Luminous. Không biết ở chiều không gian ấy người ta sẽ tổ chức giáng sinh và tặng quà cho nhau như thế nào nhỉ? Leo tuy dễ tính nhất Wanderer nhưng đâu thể nào tặng quà tùy tiện cho ổng được. Tặng cho ông ấy một chiếc khăn len cũng là ý hay. Ý định ban đầu của tôi là tặng cho ông ấy một thanh Katana mới nhưng mà tôi tìm mãi vẫn chưa có thanh nào tốt bằng thanh mà Leo đang dùng hiện tại.
B0101: [ Emoji của Shylvie hiện ra ]
B0102: Tiếp đến là Shylvie. Shirogane Shylvie, một pháp sư cận chiến dùng khiên sở hữu một mái tóc màu xanh dương đậm nhất mà tôi từng thấy. Suốt từ lúc thành lập văn phòng Wanderer đến giờ, Shylvie luôn nói về niềm đam mê và yêu thích của mình dành cho những chiếc khiên. Tôi cũng nghĩ rằng mình nên tặng khiên cho Shylvie. Cơ mà, đợt sinh nhật vừa rồi tôi cũng đã tặng khiên cho Shylvie rồi, không biết có nên tặng thêm không nhỉ?
B0103: [ Emoji của Kohi hiện ra ]
B0104: Người kế tiếp là Kohi. Cô Quỷ Cà Phê Kohi là một cô quỷ dễ thương có niềm đam mê tột cùng với cà phê. Nên món quà phù hợp nhất để tặng cho Kohi thì nhất định phải là cà phê hoặc là những bộ dụng cụ để pha cà phê. Cơ mà nhắc đến Kohi tôi mới nhận ra, ngoại trừ Kohi thì các thành viên trong Wanderer đều có đầy đủ họ tên.
B0105: [ Emoji của Hakase hiện ra ]
B0106: Cuối cùng là Hakase. Hakase Shoichi, một quỷ vương tiền nhiệm vừa mới gia nhập văn phòng Wanderer. Hakase có chung sở thích lắp ráp mô hình giống tôi. Dạo gần đây thì Hakase đang mất kiểm soát sức mạnh của mình nên đêm nào tôi cũng thấy ông ấy ra ngoài sân tập kiểm soát sức mạnh. Hay là mua cho ông ấy một cuốn sách pháp thuật nhỉ? Sách pháp thuật cũng là lựa chọn không tồi ấy. Vì tôi biết chính xác tôi nên mua cho Hakase quyển nào rồi!
B0107: Cơ mà trước tiên mình phải tìm chỗ để mua quà đã!! Mình nên đi đâu nhỉ?
B0108: [ Hộp lựa chọn hiện ra – Hải Quỳ chọn đi siêu thị ]
B0109: Siêu thị có vẻ là lựa chọn an toàn nhất đó! Bởi vì siêu thị có quá trời là món phù hợp với đại đa số thành viên luôn!! Ừ, hợp lý đó! Trạm kế tiếp là đến siêu thị rồi! Tự dưng thấy lòng háo hức ghê!
B0110: Hết cảnh số 3
B0111: Cảnh số 4
B0112: [ BG đen. Sfx bước chân. ]
B0113: Trời nóng quá….Sốc nhiệt mà chết mất…
B0114: [ Sprite Hải Quỳ đồ thường nhật háo hức. BG siêu thị - BGM Welcome to station square Remix by Tee Lopes feat Jun Senoue ]
B0115: Vào siêu thị một cái mát hẳn ra! Đúng là siêu thị Mega Galaxy Central có khác! Ta nói nó mát rười rượi luôn! Được rồi! Đi dạo vòng quanh siêu thị thôi!
B0116: [ sfx bước chân + người nói qua lại ]
B0117: Ô! Hôm nay mặt hàng đồ gia dụng đang có ưu đãi giáng sinh nè! Combo Dao làm bếp và Chảo chống dính siêu sốc? Hừm, giá này cũng ổn mà ha. Đúng là hàng ưu đãi có khác.
B0118: Ui? Máy pha cà phê đang giảm giá nè! Chỉ với 599k thôi á? Từ từ bình tĩnh Dahria, đừng quyết định vội!
B0119: Chà, bộ dụng cụ đan len cũng đang được giảm giá nè. Gì cơ? Mười cuộn len tùy chọn khi mua kèm bộ dụng cụ sẽ được giảm 30% hả? Giảm dữ vậy??
B0120: Bộ dụng cụ phá khóa…? Giảm từ 389k còn 388k…Là giảm dữ chưa?? Tôi có đang nhìn nhầm không?? Ủa mà mua bộ dụng cụ phá khóa để làm gì? Nhóm mình có ai cần dùng không nhỉ?
B0121: [ BGM dừng. Màn hình tối lại một chút. Spirte Hải Quỳ đồ thường nhật chống cằm suy tư ]
B0122: Quả là một lựa chọn khó khăn. Cái nào tôi cũng muốn mua, thậm chí muốn mua hết để tặng tất cả mọi người! Nhưng mà cả nhóm đã quyết sẽ tặng theo vòng rồi mà!! Vậy thì….Tôi sẽ mua….
B0123: [ Hộp lựa chọn hiện ra – Hải Quỳ chọn mua Khăn Len ]
B0124: Kỹ năng đan len của tôi không quá tệ. Còn vài ngày nữa là tới giáng sinh, chưa kể là tôi được nghỉ phép nên có khi tôi đan kịp đấy. Chưa kể là tôi cũng muốn trổ tài cho mọi người thấy một người sở hữu bàn tay phá hoại như tôi cũng có thể đan len!!
B0125: Hết cảnh số 4
B0126: Cảnh số 5
B0127: [ CG điện thoại hiện ra, mở sẵn hộp thoại của Wanderer Office. Hải Quỳ nhắn tin để thông báo mình sẽ tặng ai ]
B0128: ( Hải Quỳ: Mọi người ơi, tui đã quyết định được giáng sinh này sẽ tặng quà cho ai rồi )
B0129: [ Hộp lựa chọn hiện ra – Hải Quỳ chọn Leo ]
B0130: ( Shylvie: Ai thế? Là tôi hả?!
B0131: Hakase: Ai vậy?
B0132: Kohi: Ai rứa?
B0133: [CHOICES] Leo | Kohi | Shylvie | Hakase
B0134: LEO cảnh 5
B0135: Hải Quỳ: Là Leo!
B0136: Leo: Hả? Là tui á? Bà chắc chưa á?
B0137: Hải Quỳ: Như đinh đóng cột! Mọi người tiếp tục vòng tặng nhé! Tớ sủi đây, hihi! )
B0138: [ CG điện thoại biến mất. Sprite Hải Quỳ hài lòng ]
B0139: Thế là xong!!
B0140: So với các gian khác thì gian bán dụng cụ gia đình không mấy đông đúc.
B0141: Tôi lướt nhẹ đến gian bán bộ dụng cụ phá khóa, mau tay lấy một bộ vào giỏ hàng. Cứ nhìn cái giá niêm yết giảm từ 389k còn 388k là miệng tôi không thể nào ngừng cười.
B0142: [ Sprite Hải Quỳ thường nhật mắt cam thay thế Hải Quỳ thường nhật mắt đỏ. Sẽ luân phiên nhau hiện ra khi nói chuyện ]
B0143: Thật luôn ? Định tặng cái của nợ này thật luôn ? [ Q2 ]
B0144: Sao lại không nhỉ ? Nó đang giảm giá mà ?! [ Q1 ]
B0145: Người gì mà tồi thế ! Giáng sinh là phải tặng mấy món quà họ muốn chứ ? [ Q2 ]
B0146: Nhỡ đâu Leo cần thì sao ?  [ Q1 ]
B0147: Hết nói nổi. [ Q2 ]
B0148: Tôi ung dung bước đến gian hàng văn phòng phẩm để tìm giấy gói quà.
B0149: [ sfx soạt soạt ]
B0150: Trông giấy gói quà màu đỏ gấc này cũng đẹp này, chắc mua hai ba cuộn gì đó về gói cho đẹp!
B0151: KOHI cảnh 5
B0152: Hải Quỳ: Là Kohi
B0153: Kohi: Oa!! Hóng quá!!
B0154: Hải Quỳ: Kohi hóng như vậy sao?! Cơ mà Mọi người tiếp tục vòng tặng nhé! Tớ sủi đây, hihi! )
B0155: Trông giấy gói quà màu nâu đỏ này cũng đẹp này, chắc mua hai ba cuộn gì đó về gói cho đẹp!
B0156: SHYLVIE cảnh 5
B0157: Hải Quỳ: Là Shylvie
B0158: Shylvie: Ôi vinh dự thế!!
B0159: Hải Quỳ: Phải vinh dự chứ! Tui cá chắc chưa ai tặng ông món này luôn!
B0160: Shylvie: Gì, nghe hoành tráng vậy? Tò mò ghê.
B0161: Leo: Bà chắc sẽ tặng Shylvie chưa?
B0162: Hải Quỳ: Chắc chắn rồi. Mọi người tiếp tục vòng tặng nhé. Tớ đi đây. )
B0163: Ê, tặng cho nó món này có vẻ được đấy. [ Q2 ]
B0164: Chứ sao nữa!  [ Q1 ]
B0165: Haha, hóng đến lúc nhìn mặt ngơ ngác của nó ghê. [ Q2 ]
B0166: Hông biết nó sẽ như thế nào ha.  [ Q1 ]
B0167: Chắc là sẽ ngu ngốc lắm đây. [ Q2 ]
B0168: Trông giấy gói quà xanh biển đậm này cũng đẹp này, chắc mua hai ba cuộn gì đó về gói cho đẹp!
B0169: HAKASE cảnh 5
B0170: Hải Quỳ: Là Hakase đó!
B0171: Hakase: Yatta!! Vui quá!! Hóng quà à nghen!!
B0172: Leo: Bà chắc sẽ tặng Hakase chưa?
B0173: Hải Quỳ: Chắc chắn rồi!! Tớ đi đây, gặp lại mấy cậu sau!! )
B0174: Nhỡ đâu Hakase cần thì sao ?  [ Q1 ]
B0175: Trông giấy gói quà tím than này cũng đẹp này, chắc mua hai ba cuộn gì đó về gói cho đẹp!
B0176: Hết cảnh số 5
B0177: Cảnh số 6
B0178: Leo Cảnh 6
B0179: [ Chuyển cảnh. BG Phòng của Hải Quỳ. ]
B0180: Thế là xong! Gói quà trông đẹp thế nhỉ!!
B0181: Tôi cẩn thận để gói quà lên trên bàn làm việc để tránh bị dính bẩn.
B0182: Nghĩ lại những lời mà nửa bên kia của tôi đã nói ban chiều, trong lòng tôi bắt đầu cảm thấy tội lỗi. Giáng sinh nên tặng quà mà họ thích hay là tặng quà mà họ cần, hay là tặng quà mà người tặng nghĩ rằng họ sẽ cần ?
B0183: Càng nghĩ, tôi càng thấy bản thân mình là một kẻ tồi tệ. Tôi không biết có nên tặng nó cho Leo hay không nữa….Leo có cần nó không ?
B0184: Leo sẽ nghĩ gì khi nhìn thấy món quà này ?
B0185: Ông ấy sẽ thích nó chứ ?
B0186: Biểu cảm ông ấy khi ấy sẽ ra sao ?
B0187: Tôi….
B0188: Là một kẻ tồi tệ….
B0189: [ BG hơi chớp nhẹ ]
B0190: Ba ngày vừa rồi quả là mệt mỏi mà…Kỳ nghỉ phép này….Tôi…
B0191: Kohi Cảnh 6
B0192: Càng nghĩ, tôi càng thấy bản thân mình là một kẻ tồi tệ. Tôi không biết có nên tặng nó cho Kohi hay không nữa….Kohi có cần nó không ?
B0193: Kohi sẽ nghĩ gì khi nhìn thấy món quà này ?
B0194: Bà ấy sẽ thích nó chứ ?
B0195: Biểu cảm bà ấy khi ấy sẽ ra sao ?
B0196: Shylvie Cảnh 6
B0197: Trong lòng tôi bỗng cảm thấy tội lỗi.
B0198: Đầu tôi nảy lên vô vàn suy nghĩ, về việc giáng sinh nên tặng quà mà họ thích hay là tặng quà mà họ cần, hay là tặng quà mà người tặng nghĩ rằng họ sẽ cần ?
B0199: Càng nghĩ, tôi càng thấy bản thân mình là một kẻ tồi tệ. Tôi không biết có nên tặng nó cho Shylvie hay không nữa….Shylvie có cần nó không ?
B0200: Shylvie sẽ nghĩ gì khi nhìn thấy món quà này ?
B0201: Shylvie sẽ thích nó chứ ?
B0202: Biểu cảm Shylvie khi ấy sẽ ra sao ?
B0203: Hakase Cảnh 6
B0204: Càng nghĩ, tôi càng thấy bản thân mình là một kẻ tồi tệ. Tôi không biết có nên tặng nó cho Hakase hay không nữa….Hakase có cần nó không ?
B0205: Hakase sẽ nghĩ gì khi nhìn thấy món quà này ?
B0206: Hết cảnh 6
B0207: CẢNH 7
B0208: [ BG đen trong giây lát rồi hiện lên BG phòng Hải Quỳ ]
B0209: - Dậy coi con âm binh!! [ Q2 ]
B0210: Tôi được gọi là Aira, là nửa còn lại của Dahria. Hiện tại, Dahria đang chìm trong vô thức, hai mắt thì trắng dã còn tôi đang cố đánh thức nó dậy bằng cách quật xúc tu vào mặt nó.
B0211: Quật mãi, hai má Dahria đỏ bừng lên mà nó vẫn không tỉnh. Kiểu này dám cá nó lạc sâu tận trong vô thức sau mấy ngày không ngủ vì cứ bận suy nghĩ đau đáu về chuyện nó có phải là kẻ tồi tệ hay không.
B0212: Chết thật. Hôm nay là ngày diễn ra bữa tiệc giáng sinh cùng với mấy đứa dở hơi trong cái văn phòng Wanderer gì đó. Nếu mà nó không tỉnh ngay bây giờ thì kiểu gì cũng sẽ đến trễ và không trang trí văn phòng được mất !
B0213: Tôi đành chiếm quyền kiểm soát cơ thể của Dahria, lọ mọ đứng dậy, lảo đảo bước vào nhà vệ sinh.
B0214: Dahria, nửa bên kia của tôi, luôn là một đứa lạc quan một cách quá đà kể từ lúc hai đứa tôi chào đời.
B0215: Về việc lý do tại sao tôi lại mắc kẹt trong cơ thể này cùng với nó, đó là một câu chuyện siêu dài dòng mà tôi không muốn kể lại. Nhưng nếu ai đó đòi tóm tắt thì tôi sẽ tóm tắt như thế này.
B0216: Tôi và nó tuy hai mà một, tuy một mà hai. Tôi là đóm lửa tàn cuối cùng còn sót lại để giữ sinh mạng cho nó, là sinh mạng vốn dĩ sinh ra để thay thế cho mục đích cao cả. Chỉ có thế thôi.
B0217: Nghe lằng nhà lằng nhằng nhỉ? Ừ, đến tôi còn nhức đầu mà.
B0218: Tôi có thể chiếm quyền kiểm soát cơ thể của Dahria nhưng đa phần tôi sẽ tự tạo một chiếc miệng đằng sau gáy để nói chuyện và biến tóc thành xúc tu để tương tác cùng lúc với nó.
B0219: Tại vì tôi cảm thấy bị phiền phức.
B0220: Tôi luôn càu nhàu với Dahria rằng tôi không muốn nó nhờ vả tôi. Nhưng nếu không có tôi thì nó chả làm được cái giống ôn gì hết. Bực hết cả mình.
B0221: Như lúc này chả hạn. Mắc cái giống gì tự đánh giá bản thân xong tự chìm trong mặc cảm luôn vậy? Đã nói ngay từ đầu là đừng có mua bộ phá khóa để làm quà tặng rồi mà nó không nghe.
B0222: Haha, hài hước các thứ….cái cù lôi! Giờ ai là người phải giải quyết hậu quả dùm đây hả?!
B0223: - Bộ quái gì đây? [ Q2 ]
B0224: [ Sfx biến hình liên tục ]
B0225: - Không phải bộ này…. [ Q2 ]
B0226: - Bộ này xấu ói! [ Q2 ]
B0227: - Chậc !! Sau vụ này mà không cho ta ăn cacao dầm là ta ném ngươi ra ngoài biển cho chết đuối đấy! [ Q2 ]
B0228: [ Sfx bước chân + màn hình rung sau khi có sfx đóng cửa ]
B0229: Hết cảnh 7
B0230: CẢNH 8
B0231: [ BG Văn Phòng Wanderer chưa thay đổi ]
B0232: Văn phòng hoàn toàn im ắng không một bóng người, tuyệt vời. Tôi thích sự yên ắng này.
B0233: Tôi nhướn mắt lên nhìn chiếc đồng hồ treo trên tường, còn gần nửa ngày nữa mới đến tiệc giáng sinh.
B0234: Thế thì thừa sức! Xem bà đây trình diễn tuyệt kỹ viết mã có một không hai nhanh như tia chớp đây!
B0235: Tôi đạp cửa bước vào phòng họp và bấm bảng điều khiển như bấm phím đàn Piano. Trước đó, Damien,  quản lý của Dahria, đã phụ đạo nó môn lập trình nên ba cái mã này dễ ợt. Tôi có thể nhìn lại ký ức của nó để học hỏi mà.
B0236: Xem nào…Sao chép và dán…Chỉnh sửa lại…tạch tạch tạch…
B0237: [ sfx bàn phím + tiếng beep beep ]
B0238: Dahria là một con hâm gàn dở. Bản thân chưa bao giờ học về lập trình mà nó dám " mượn " AI Sierra về, thậm chí còn cài đặt thành công vào văn phòng oái ăm này. Nó cũng cố học đấy nhưng mà não nó quá nhỏ để có thể tiếp thu.
B0239: Thiệt sự chứ, nó tiếp thu ba cái không cần thiết thì nhanh lắm mà mấy cái cần thiết nó cứ vứt bạ đi đâu ấy. Mỗi lần tôi muốn học là lại phải cố nhìn lại mớ ký ức hỗn độn bị chèn ép bởi sự tưởng tượng mộng mơ của nó về mấy cặp đôi trong truyện tranh, trò chơi điện tử.
B0240: Axx, mệt cái đầu!
B0241: [ sfx ầm ầm + bóp méo ]
B0242: Ồ, không gian thực sự bị méo mó giống như trong sách hướng dẫn sử dụng Sierra này!
B0243: [ sfx choảng ]
B0244: Nhìn qua camera, tôi thấy cả văn phòng Wanderer đã ngập trong tuyết. Cơ mà cách bày trí này trông xấu kinh khủng khiếp, long nhãn của tôi sắp nổ rồi. Phải chỉnh lại mới được.
B0245: [ BG Văn Phòng Wanderer chủ đề giáng sinh//phủ đầy tuyết ]
B0246: Tôi bước ra ngoài kiểm tra. Toàn bộ văn phòng bị phủ đầy tuyết trắng xóa.
B0247: Tôi chạm thử vào tuyết dưới sàn. Nó là tuyết thật. Đúng là công nghệ Atlantis có khác.
B0248: [ sfx mở cửa ]
B0249: [ Sprite Shylvie ngạc nhiên ]
B0250: - Ơ! Quỳ à! Bà đến sớm thế?
B0251: [ Sprite Hải Quỳ nheo mắt ]
B0252: - Sao, chả lẽ không được đến sớm à?
B0253: [ Sprite Kohi vui vẻ ]
B0254: - Ồ! Văn phòng ngập tuyết rồi nè!! Hay là mình chơi ném bóng tuyết đi!
B0255: Nói rồi Kohi nhanh nhảu cúi người xuống hốt một mớ tuyết vào tay rồi nhào nặn nó thành một quả bóng, ném thẳng vào lưng của Shylvie. Shylvie hưởng ứng theo. Nó dậm chân xuống, hàng chục quả bóng tuyết tròn vo từ dưới sàn bay lên.
B0256: [ Sprite Kohi và Shylvie vui vẻ ]
B0257: Chơi ném tuyết với bọn tôi đi Quỳ!
B0258: [ Sprite Hải Quỳ thở dài ]
B0259: Xin kiếu!
B0260: Hai đứa nó cứ tí ta tí tởn ném nhau qua lại như vậy được một lúc thì có người mở cửa bước vào văn phòng. Đúng lúc đấy Shylvie vừa nặn xong một quả bóng tuyết khổng lồ. Bị giật mình, Shylvie trượt tay ném thẳng vào đầu tôi.
B0261: Cả cơ thể của tôi bị chôn vùi trong quả bóng tuyết, cố gắng lắm tôi mới ngoi đầu lên được. Vừa mở mắt ra thì tôi nhìn thấy gương mặt đang nhịn cười từ Kohi và Shylvie.
B0262: [ Sprite của Kohi và Shylvie đang nhịn cười ]
B0263: - Kh—Khục….!
B0264: - AHAHAHAHAHAHAHA!
B0265: Shylvie không thèm giúp tôi thoát khỏi đống tuyết mà lại lấy điện thoại ra chụp liên hồi. Sau đấy còn vui vẻ chạy lại đưa cho tôi xem, miệng không ngừng khen là trông tôi dễ thương lắm.
B0266: Đó là lý do mà Shylvie có tên trong danh sách đen của tôi. Từ hôm nay tôi sẽ nâng nó lên hạng nhất.
B0267: [ Sprite Leo ngạc nhiên ]
B0268: Có chuyện gì vậy?
B0269: Leo mở cửa bước vào, lập tức nhìn về phía tôi. Ngay sau lưng Leo là Hakase, một tên ma vương đáng gờm vừa mới tuyển vào văn phòng được vài tháng, đang bám lên vai Leo, nhón người lên để xem chuyện gì vừa diễn ra.
B0270: Hakase ôm bụng cười phá lên, tay không ngừng chỉ vào tôi.
B0271: Leo quay mặt đị cố nhịn cười một lúc nhưng rồi không chịu được đành cười theo Hakase.
B0272: [ CG Hải Quỳ người tuyết với gương mặt hậm hực ]
B0273: [ Chuyển về BG Văn Phòng Wanderer ngập tuyết ]
B0274: Cả bọn cùng hợp sức để kéo tôi ra khỏi đống tuyết.
B0275: [ Sprite Leo vui vẻ ]
B0276: - Quỳ à, cảm ơn bà nha! Trang trí đẹp đấy!
B0277: [ Spite Hải Quỳ mặt hơi quạo ]
B0278: - Ờ. Không có gì đâu, nhìn đẹp là được rồi.
B0279: - Đẹp chứ. Nó làm tui nhớ đến quê nhà. Cũng lâu lắm rồi tui chưa thấy tuyết.
B0280: - Luminus cũng bị biến đổi khí hậu hả?
B0281: - Đâu có. Tui cắm mặt vào công việc sổ sách nhiều đến mức trôi qua không biết bao nhiêu mùa đông luôn.
B0282: - Nghe khổ thân vậy? Có tính nghỉ việc chưa?
B0283: - Trời, muốn nghỉ mà có nghỉ được đâu. Lần nào nghỉ là i xì đúc hôm đấy mấy đứa đồng nghiệp sẽ để lọt một sự kiện dị biến chiều không gian liền…! Đi khắc phục mệt chết đi được.
B0284: - Rồi, hiểu luôn. Haiz….
B0285: [ Sprite Hải Quỳ + Leo thở dài cùng lúc ]
B0286: Năm nay Kohi và Shylvie cùng nhau đứng bếp. Shylvie thì chuẩn bị một nồi bò hầm kem ăn cùng bánh mì men và một nồi phô mai thập cẩm được đun chảy ăn cùng một số loại thực phẩm phù hợp. Kohi thì chuẩn bị bánh socola tan chảy cùng bánh khúc gỗ to đùng phủ ngập kem.
B0287: Leo và Hakase bắt đầu bày biện đồ ăn lên bàn.
B0288: Bàn tiệc giáng sinh đã chuẩn bị xong!
B0289: Mùi thơm quá…Tôi muốn ăn sạch cái đĩa bánh socola tan chảy kia!
B0290: [ Sprite vui vẻ của cả năm hiện ra ]
B0291: - Mời mọi người cùng ăn!
B0292: [ sfx ăn uống + Sprite Hải Quỳ vui vẻ ]
B0293: Ôi ngon quá trời. Tôi vốn không thích món bò hầm kem nên ăn một bát rồi ngưng, chuyển sang ăn ngấu nghiến gần hết đĩa bánh socola tan chảy trên bàn. Bữa ăn diễn ra vui vẻ, mọi người kể cho nhau nghe đủ chuyện từ trên trời xuống đất. Leo chia sẻ cho mọi người công việc của vệ thần không gian, Hakase thì kể về việc ông ấy bắt được Pokemon hiếm, Kohi càm ràm về một bộ anime tình yêu học đường, Shylvie vẫn chưa tha cho món phá lấu mà Leo đã dẫn Shylvie ăn vào hai năm trước.
B0294: Tôi không biết phải kể mọi người nghe chuyện gì. Tôi chả rõ chuyện về mấy đứa ở Văn phòng Silver Wing lẫn Phòng Tác Chiến Nguyệt Thực 6 cho lắm. Kể về nhiệm vụ thì phiền phức quá.
B0295: Có lẽ vì trông thấy tôi chưa có chủ đề để kể, Shylvie đã chủ động hỏi tôi về bộ giáp.
B0296: [ Sprite Shylvie vui vẻ ]
B0297: - Bộ giáp sao rồi?
B0298: - Nó vẫn đang được sửa chữa và hoàn thiện.
B0299: - Lâu vậy á?
B0300: - Tuổi đời bộ giáp đó có khi còn hơn tuổi của tui, nên việc sửa chữa nó sẽ lâu lắm.
B0301: [ Sprite Leo tò mò hiện ra ]
B0302: - Khoan, vụ này mới. Sao bà lại sử dụng bộ giáp cổ vậy?
B0303: - Nó là bộ giáp được truyền lại cho người xứng đáng trong dòng họ Anizoa Drosalie Hexacoral. Và tui được nó chọn.
B0304: Bốn người họ đồng thanh " ồ " lên một tiếng dài ơi là dài.
B0305: [ Sprite Hakase hiện lên ]
B0306: - Nhí nhí, tui có câu hỏi.
B0307: [ Sprite Leo hiện lên ]
B0308: - Hakase à….Đừng…Tui biết ông tính hỏi gì…
B0309: - Hả…Sao ông biết là tui đang hỏi về tuổi….
B0310: Hakase chưa kịp nói xong thì đã bị Leo bịt miệng bằng miếng thịt bò nóng hổi.
B0311: [ Sprite Hải Quỳ hiện lên ]
B0312: - Gì vậy Hakase. Kỳ quá nha. Tui mười bốn tuổi mà.
B0313: Dahria đâu phải cô bé mười bốn tuổi? Tôi chắc chắn như vậy.
B0314: Tôi không thể xác định được độ tuổi chính xác của nó là bao nhiêu nữa.
B0315: Vì thông tin đó đã bị Dahria xóa khỏi đầu rồi.
B0316: [ Sprite mọi người biến mất ]
B0317: Sau khi ăn uống no say, cả đám bọn tôi quyết định chơi vài ván mèo nổ với vài ván rút tháp. Leo với Hakase liên tục bị " kaboom ". Dù đã chơi board game với Kohi vài lần rồi nhưng lần nào tôi cũng bị sự may mắn của bà ấy làm cho bất ngờ. Nãy giờ chưa thấy bà ấy bị " kaboom " lần nào!
B0318: Tuy nhiên đến với trò rút tháp, sự may mắn của Kohi cũng không thể cứu nổi tòa tháp đang sập xuống trước mắt bà ấy. Để gia tăng sự khó chịu cho trò này, Leo đã chuẩn bị một túi kẹo siêu chua, hễ ai làm tháp bị sập sẽ phải ăn một lúc hai viên kẹo đấy.
B0319: Tôi gần như ăn sạch túi kẹo chua mà Leo mua. Nó không chua như tôi tưởng tượng.
B0320: Hết cảnh 8
B0321: CẢNH 9
B0322: LEO CẢNH 9
B0323: [ sfx vỗ tay + Sprite của Leo hiện lên ]
B0324: - E hèm! Tui nghĩ đã đến lúc cho sự kiện chính ngày hôm nay rồi, Quỳ nhỉ?
B0325: Leo đá mắt sang tôi.
B0326: Tôi lập tức đứng dậy, cầm theo túi quà mà tôi đã gói kỹ càng tiến đến chỗ của Leo.
B0327: [ Sprite Hải Quỳ vui vẻ ]
B0328: - Giáng sinh an lành Leo! Tui hi vọng ông thích món quà này!! Ông mở nó ra đi!
B0329: [ Sprite Leo khó hiểu ]
B0330: Ồ…Bộ dụng cụ phá khóa…? Tui không ngờ là bà sẽ tặng tui…món quà thú vị này đấy.
B0331: [ Sprite Hải Quỳ cười nhưng nhăn mặt ]
B0332: Leo à, tui thiệt sự đã rất phân vân khi mua nó…Nhưng vì tui đã nhìn trước về một tương lai mà ông cần nó…cấp bách! Nên tui đã quyết định sẽ cứu tương lai đó của ông!
B0333: À….vậy hả…Cảm ơn bà nha! Bà chu đáo quá!
B0334: Tôi không biết nữa. Tôi cá chắc Leo đã nhìn thấu lời nói dối của tôi rồi.
B0335: Làm gì có cái tương lai nào mà Leo cần nó cấp bách chứ!
B0336: Kèo này không cứu nổi rồi Dahria ơi!
B0337: Leo đặt món quà mà Dahria tặng xuống bàn, sau đấy đứng dậy và tiến đến chỗ Hakase, nở một nụ cười tươi tắn.
B0338: - Giáng sinh an lành, Hakase!
B0339: [ Sprite Hakase ngạc nhiên ]
B0340: - Ố! Gì đó gì đó!!
B0341: - Mở ra xem là biết liền à!
B0342: Làm theo lời Leo nói, Hakase từ tốn mở hộp quà. Đằng sau giấy gói quà màu tím lấp lánh kim tuyến được thắt nơ đỏ là một hộp mô hình Gundam RG 78 EX080. Tôi không nhìn nhầm chứ?
B0343: Không, nhầm sao được. Logo mạ vàng kia kìa!
B0344: Leo chơi lớn thế!! Tôi cũng muốn!!!
B0345: [ Sprite Hakase mắt sáng ]
B0346: - Là…Là nó!! Ôi vãi cả lồng đèn Leo ơi!!
B0347: - Haha. Tôi biết ngay là ông sẽ thích nó mà.
B0348: - Thích á? Không, tôi yêu nó vãi cả nồi! Cả ông nữa!
B0349: - Ê ê, no homo bro.
B0350: - Yeah, no homo!!
B0351: [ CG Hakase ôm Leo ]
B0352: Dứt lời, Hakase đặt chiếc hộp xuống và nhảy phóc lên ôm Leo thật chặt. Được dịp thấy cảnh tượng hiếm hoi khó thấy, Kohi thúc cù trỏ vào vai tôi, ra hiệu chụp lại cảnh tượng hiếm hoi này cùng bà ấy.
B0353: - Wow, that's gay
B0354: Hakase hạnh phúc ôm khư khư cái hộp to đùng ấy trong lòng, lắc người qua lại nhịp nhàng như con lật đật. Cho đến khi Shylvie huých nhẹ cánh tay của ông ấy thì ông ấy mới nhớ ra rằng phải tiếp tục vòng tặng quà.
B0355: Hakase vỗ tay, một đôi bao tay mới màu hồng hình Hello Kitty xuất hiện trong hư vô, rơi xuống trước vẻ mặt ngơ ngác tột độ của phù thủy khiên ngẫu nhiên.
B0356: [ Sprite Hakase vui vẻ ]
B0357: - Mé rỳ chít mợt! Năm nay Shylvie phải màu mè hoa lá hẹ lên cho tớ! Cậu toàn chơi tông xám đen nhìn chán lắm!!
B0358: [ Sprite Shylvie khó hiểu ]
B0359: - C…Cảm ơn Hakase…Tui thích món quà này lắm…
B0360: - Đeo vào luôn đi!!
B0361: Dưới sự thúc dục của Hakase, Shylvie không tài nào từ chối việc đeo đôi bao tay màu hồng xinh xắn vào tay mình. Gu thẩm mỹ của Hakase có khác. Đôi bao tay làm bật tông màu da của Shylvie luôn!
B0362: - Trời ơi dễ thương quá!
B0363: Tôi nhoẻn miệng cười khịa Shylvie. Shylvie có vẻ biết được điều đó nên nguýt tôi một cái.
B0364: Trời ơi nhìn nó ngại kia, hai tai của nó đỏ bừng bừng như ống thép đang nung ấy.
B0365: Để chôn giấu sự hổ thẹn, Shylvie nở một nụ cười lớn khi cầm trong tay một gói quà bự có góc cạnh và trao nó cho Kohi.
B0366: Kohi dùng tay sờ sờ nắn nắn gói quà. Mắt bà ấy đột nhiên sáng lên.
B0367: [ Sprite Kohi mắt sáng ]
B0368: - Ô…!! Là nó….?
B0369: - Đúng rồi đấy.
B0370: [ Sprite Kohi hạnh phúc ]
B0371: - Là máy pha cà phê!! Tuyệt quá!!
B0372: KOHI CẢNH 9
B0373: Tôi lập tức đứng dậy, cầm theo túi quà mà tôi đã gói kỹ càng tiến đến chỗ của Kohi
B0374: - Kohi ơi! Giáng sinh vui vẻ!
B0375: [ Sprite Kohi ngạc nhiên ]
B0376: Ồ…Bà tặng gì đó?
B0377: Kohi vừa nói vừa mở gói quà.
B0378: [ Sprite Kohi khó hiểu ]
B0379: Bộ dụng cụ phá khóa…?
B0380: [ Sprite Kohi phụng phịu ]
B0381: Tui….không biết nói gì nữa…
B0382: Ưm…Tui…
B0383: [ màn hình rung mạnh + Sprite Hải Quỳ đen mặt ]
B0384: - TUI XIN LỖI!
B0385: SHYLIVE CẢNH 9
B0386: Tôi lập tức đứng dậy, cầm theo túi quà mà tôi đã gói kỹ càng tiến đến chỗ của Shylvie.
B0387: - Giáng sinh an lành nha, phù thủy ngẫu nhiên dùng khiên tóc xanh thân mến!
B0388: Shylvie ngạc nhiên nhìn túi quà be bé mà tôi đưa cho Shylvie. Tôi gật đầu, ra tín hiệu cho Shylvie mở nó ra xem.
B0389: [ Sprite Shylvie bất ngờ ]
B0390: - Ồ…là bộ dụng cụ phá khóa! Bà lại nhìn trước tương lai đúng không?
B0391: - Hả gì? Nhìn trước gì cơ?
B0392: - Cái bộ dụng cụ này là bộ tui đang có ý định mua!
B0393: - À vậy hả…Đúng, tui nhìn trước tương lai là Shylvie sẽ cần nó nên là đã mua luôn đấy.
B0394: - Tuyệt vời! Cảm ơn bà nha!!
B0395: Chết tiệt! Đây không phải là phản ứng mà hai đứa bọn tôi mong muốn!
B0396: Tôi đã mong là cái biểu cảm con phù thủy tóc xanh cầm khiên ngẫu nhiên kia khi nhận được món quà trời ơi đất hỡi phải là buồn bã chứ, sao lại ngược lại thế này!!
B0397: Nhưng tại sao nó lại cần bộ dụng cụ phá khóa? Để làm trò mèo gì vậy?
B0398: Sau khi nhận món quà của tôi, Shylvie lấy một hộp quà từ trong túi không gian ma thuật của Shylvie, tiến đến chỗ Leo và nở một nụ cười tươi tắn.
B0399: - Giáng sinh an lành, Leo!
B0400: - Ố! Tò mò ghê nha! Gì vậy!
B0401: Theo lời Shylvie, Leo xé hết giấy gói quà và lôi ra được một chiếc ốp lưng điện thoại màu đen lấp la lấp lánh kim tuyến ra khỏi chiếc hộp nhiều hạt xốp màu đỏ.
B0402: Ốp lưng điện thoại? Uầy, được thế?
B0403: Sao lại “ được thế “?? Ông thử gõ nhẹ vô nó đi.
B0404: Leo gõ nhẹ vô chiếc ốp, hai bên chiếc ốp liền bung ra cánh dơi màu đỏ đen pha chút tím. Đôi cánh dơi đấy phát ra một lớp từ trường màu hồng nhẹ nhẹ, nhìn Leo không khác gì đang cầm khiên cả.
B0405: UẦY!! XỊN!!
B0406: Đấy, phải là xịn chứ!! Ông thấy sao hả Leo?
B0407: Tui còn biết nói gì ngoài xịn hả Shylvie? Hay là “ ôi tuyệt tác tuyệt mĩ tuyệt hảo tuyệt đỉnh chạm nóc kịch trần “ à.
B0408: Ừ, phải như thế chứ!
B0409: Leo hào hứng tháo chiếc ốp cũ ra để gắn ốp mới vào. Leo vung tay tạo dáng, chiếc khiên từ trường màu hồng bung ra. Nhìn ngầu thật sự!
B0410: Nhìn ngầu thật sự! Shylvie tài thật đấy!
B0411: Ôi cảm ơn Hakase!!
B0412: Cậu làm cho tớ một cái được không?
B0413: Được chứ! Cậu gửi cho tớ mẫu mà cậu muốn là được!
B0414: Hai cánh mũi của Shylvie nở ra như bánh phồng tôm. Phải rồi ha, ai mà chẳng muốn được khen lên tận chín tầng mây như thế chứ.
B0415: Leo đặt chiếc điện thoại xuống bàn, đứng dậy đi vào trong bếp và mang ra ngoài một túi cà phê nặng trĩu có ánh bạch kim. Chà, tôi có thể đoán được ai là người tiếp theo được tặng rồi đấy.
B0416: - Happy Birthday...Ủa lộn! Merry Christmas!!
B0417: - Trời ơi Leo!! Ông bị liệu giống Hakase rồi!!
B0418: - Ô, dù đã được đóng kín nhưng tui vẫn ngửi thấy mùi cà phê nè! Cà phê gì mà thơm dữ vậy Leo?
B0419: - Cà phê đặc sản ở Luminus đó Kohi! Từ loại cây cà phê mà hơn trăm năm mới đậu quả.
B0420: - Gì dữ vậy!! Nếu thế thì vị của nó ắt hẳn sẽ đặc biệt rồi!
B0421: - Vị của nó-
B0422: - Suỵt! Tui hổng muốn nghe! Hãy để tui tự thưởng thức!!
B0423: Kohi tủm tỉm cười, tay nâng niu túi cà phê bạch kim. Rồi Kohi đặt nó nằm cẩn thận trong túi xách, đồng thời lấy ra một hộp quà hình hộp chữ nhật thon dài. Kohi nhón người trao hộp quà cho Hakase. Hakase đón lấy hộp quà, cẩn thận mở từng lớp giấy gói.
B0424: - Giáng sinh vui vẻ nha Hakase! Mong ông thích món quà này!!
B0425: [ Sprite Hakase háo hức ]
B0426: - Uầy!! Là một cây bút bằng vàng! Tớ cảm ơn Kohi nhiều nhiều lắm!!
B0427: Nói rồi Hakase đưa bút lên miệng cắn thử. Đột nhiên Hakase quay sang nhìn bọn tôi, miệng lắp ba lắp bắp.
B0428: [ Sprite Hakase đổ mồ hôi hột ]
B0429: - Nó…Nó là vàng nguyên chất….Ôi phú bà
B0430: - Phú bà đâu…!! Lần nào ông mượn bút của tui ông cũng cắn nát đuôi chúng hết! Nên là tui nghĩ rằng nếu tặng cho ông một cây bút bằng vàng thì ông sẽ không cắn bút của tui nữa!
B0431: - Tớ hứa là sẽ không bao giờ cắn bút của Kohi nữa, thề luôn!!
B0432: Khoan đã, lý do nghe hơi sai sai…Vàng tinh khiết dễ bị móp mà? Không, tôi hiểu ý của Kohi rồi. Bả tặng ổng cây bút bằng vàng là để ổng bỏ cái tật cắn bút!!
B0433: Nhưng ổng vừa mới cắn mà…
B0434: HAKASE CẢNH 9
B0435: Tôi lập tức đứng dậy, cầm theo túi quà mà tôi đã gói kỹ càng tiến đến chỗ của Hakase.
B0436: - Happy Merry Chích Mớt Gozai múc Hakase!
B0437: Vì hơi lo lắng nên tôi đã bị loạn ngôn, khiến cho ai nấy đều phải bật cười.
B0438: [ Sprite Hakase cười vui vẻ ]
B0439: - Cảm ơn Hải Quỳ nha!! Tớ có thể mở quà được không?
B0440: [ Sprite Hải Quỳ lo lắng ]
B0441: - Được...Được chứ!
B0442: Hakase nhẹ nhàng kéo một cái, giấy gói quà của tôi rách thành trăm mảnh bay xuống nền nhà như pháo giấy. Hakase cầm bộ dụng cụ phá khóa lên, mắt chữ A và miệng chữ O nhìn tôi, kinh ngạc hết cỡ.
B0443: [ Sprite Hakase mắt sáng rực ]
B0444: - T-TUYỆT VỜI QUÁ! Là một bộ dụng cụ phá khóa!
B0445: Phản ứng đấy là sao vậy...? Nghĩa là tên ma vương này đang vui đó à?
B0446: Xem nào, trong ký ức của Dahria cũng có một vài phân đoạn nói về việc tên ma vương này rất thích dòng game Kingdom Heart, game mà có quá trời kiếm nhưng tạo hình chìa khóa ấy. Chả lẽ...tặng ổ khóa vô tình lại đúng chủ đề mà hắn thích? Có hơi...vô lý quá không nhỉ?
B0447: [ Sprite Hải Quỳ khó hiểu ]
B0448: - Anh...thích nó chứ?
B0449: - Siêu thích là đằng khác! Mà thiệt nha, bữa Shylvie với Leo có kể cho anh nghe về việc em có thể nhìn trước tương lai rồi...Em có thể nhìn trước được dự định mua bộ dụng cụ này của anh luôn hả?
B0450: - À...Vậy hả?
B0451: [ Sprite Leo + Shylvie vui vẻ ]
B0452: - Yep, đúng rồi đấy.
B0453: [ Sprite Shylvie thở dài ]
B0454: - Tui vẫn không biết là bà tác động đến thực tại hay là thực sự nhìn trước tương lai nữa...! Nhớ cái đợt chọn tên của văn phòng không?
B0455: [ Sprite Kohi tò mò ]
B0456: - Hổng nhớ, kể nghe với.
B0457: - Con mới vào sao mà nhớ được, ơ hay. Đại khái là hồi đó suýt chút nữa tên văn phòng này là Jayson nếu như Quỳ không ngồi đoán trúng phóc tất cả các lần quay tên....
B0458: - Hả gì? Tên Văn phòng này được đặt theo kiểu quay xổ số hả?
B0459: [ Sprite Leo thở dài ]
B0460: - Do có nhiều tên quá nên là....
B0461: [ Sprite Shylvie vui vẻ nói ]
B0462: - Tôi thề luôn, lần quay đó, hễ bà Quỳ nói ra cái tên nào thì cái kim nó sẽ chỉ đúng cái tên đó. Rõ ràng là bả đã tác động vào thực tại!
B0463: - Hoặc là bả tác động vô cái vòng quay? Nghi à nha. Quỳ à, em có biện minh gì không?
B0464: - Hông! Hông muốn! Tui hóng mọi người tặng quà cho nhau hơn!
B0465: - Haha, phải rồi ha! Câu chuyện li kì quá, suýt chút nữa quên mất!
B0466: Hakase vỗ tay, từ tên trần rơi xuống một cục bông màu hồng được hút chân không trong một chiếc túi kính màu nâu đỏ có gắn một chiếc nơ to màu cam ở trên miệng túi rơi xuống bàn. Hakase đẩy chiếc túi sang cho Kohi, nháy mắt với Kohi một cái.
B0467: [ Sprite Hakase nháy mắt ]
B0468: - Merikuri!
B0469: - Hakase tặng tớ món gì đấy?
B0470: - Cậu đem ra phòng khách mở đi! Đảm bảo bất ngờ luôn!
B0471: Kohi cầm cục bông ra phòng khách, nhẹ nhàng dùng kéo để xé chiếc túi ra. Chỉ trong vài khắc, một con gấu bông Kirby to đùng ngồi chễm chệ giữa phòng khách.
B0472: - Ui! To khiếp!! Nó mềm với xốp quá!! Có khác gì ghế lười không cơ chứ?
B0473: Nói dứt câu, Kohi ngồi lên nó. Hai bên má Kirby phồng lên và tràn ra ngoài, trông như thể Kirby đang cố nuốt trọng Kohi vào bụng nó vậy.
B0474: - Sao hả Kohi? Êm chứ?
B0475: - Êm!! Rất êm!!
B0476: - Haha. Mấy nay tớ thấy cậu than phiền về việc đau lưng nên là tớ quyết định may nó đấy.
B0477: - Hả gì? Cậu may nó á?
B0478: [ Sprite Hải Quỳ + Shylvie + Leo ngạc nhiên ]
B0479: - Gì cơ? Hakase biết may vá á?
B0480: - Ủa gì? Mấy cậu mới biết hả?
B0481: Bốn người bọn tôi gật đầu.
B0482: - Trời! Dùng phép thuật may là được mà?! Sao phải bất ngờ thế!
B0483: - À....Ra là vậy.
B0484: Hakase là ma vương, ắt hẳn hắn sẽ biết vài phép thuật như là may vá rồi! Không ai ngờ tới điều đó phải không? Vì nghĩ tới ma vương thì chắc chắn ai cũng sẽ nghĩ là ma vướng sẽ giỏi các loại phép thuật tấn công hơn.
B0485: Rời khỏi chiếc ghế lười bán thời gian, Kohi đi vào bếp rồi bước ra ngoài cùng với một bộ dao và chảo mới toanh trong tay.
B0486: - Happy Happy to youuu! Merry Christmas!!
B0487: [ Sprite Shylvie mắt sáng rực ]
B0488: - ỐI! THIỆT HẢ KOHI!?
B0489: - Hả, thiệt chứ sao không! Không phải bố luôn than phiền mấy bữa nay về việc dao với chảo trong bếp có vấn đề hả?
B0490: - Ừa nhưng không ngờ là Kohi sẽ tặng nguyên combo...
B0491: - Khoan đã, Kohi đọc lén tờ ghi chú đúng không?
B0492: - Đâu có!! Tui đi hỏi Quỳ ấy chứ? Đúng không Quỳ?
B0493: Kohi huých nhẹ vào tay tôi. Tôi gật đầu lia lịa.
B0494: - À ừ, bữa Kohi có hỏi...
B0495: - Vậy là bà đọc lén tờ ghi chú?
B0496: - Tui nhìn trước tương lai, khổ quá cơ...Có trời mới đọc nổi tờ ghi chú của Shylvie đấy.
B0497: Dahria đã đọc lén tờ ghi chú đã được kẹp trong cuốn tạp chí mà Shylvie đang đọc dở...Trong một lần nó vào phòng lấy dùm đồ cho Shylvie.
B0498: [ Sprite Shylvie hạnh phúc ]
B0499: - Cảm ơn Kohi!! Món quà tuyệt vời quá!!
B0500: - Hehehe, hông có gì đâu bố ạ!
B0501: Shylvie đứng dậy cất bộ dao và chảo mà Kohi mua vào bếp. Rồi từ trong bếp bước ra, sau lưng của Leo xuất hiện một cái hộp bé bé bằng bàn tay. Shylvie tiến đến chỗ Leo, nở một nụ cười tươi tắn.
B0502: Là do tôi hay sao mà mũi Shylvie bắt đầu phồng lên như bánh phồng tôm thế nhỉ.
B0503: HẾT CẢNH 9
B0504: CẢNH 10 – Kohi không có cảnh 10
B0505: Đột nhiên điện thoại tôi rung lên. Tôi lấy điện thoại ra kiểm tra xem ai vừa gọi tôi. Nó là số của đồng chí Alpha C-61. Tôi chưa kịp gọi lại thì đồng chí ấy đã nhắn tràng giang đại hải cho tôi rồi.
B0506: [ CG điện thoại Hải Quỳ, hộp thoại của Alpha C-61. ]
B0507: ( A: Omega D-13! Có chuyện lớn!!
B0508: Tui biết là bây giờ đồng chí đang trong đợt nghỉ phép nhưng chuyện này cấp bách lắm rồi!
B0509: Beta M-34 đã tìm ra được điểm vô lý trong lúc kiểm tra lại hồ sơ về lỗ hổng vực sâu 61.
B0510: Ngoại trừ tôi với Beta M-34 thì những người còn lại được điều xuống khu vực rìa lỗ hổng vực sâu 61 để điều tra dị thường. Đã hơn ba ngày rồi mà không ai gửi báo cáo lại cho chúng tôi cả.
B0511: Tôi đã cố liên lạc với họ nhưng không một ai phản hồi hết! Tất cả thiết bị của bọn họ đều bị ngừng hoạt động cùng lúc!
B0512: Chúng tôi cho rằng họ đang gặp sự cố.
B0513: Beta M-34 yêu cầu đồng chí phải quay trở về gấp để thực thi nhiệm vụ giải cứu.
B0514: Omega D-13: Đã rõ. )
B0515: Tôi biết ngay mà. Từ lúc Dahria tổng hợp hồ sơ, tôi có xem qua một chút, cũng đã thấy nghi nghi rồi.
B0516: Hai đứa bọn tôi đã hi vọng rằng chuyện phát hiện ra điểm vô lý sẽ xảy ra sau khi kỳ nghỉ phép của hai đứa kết thúc. Đành vậy, cứu người vẫn quan trọng nhất. Tiếc ghê, vậy là không được ngồi xem phim " Ở nhà một mình ", ăn kem socola cùng mọi người tại Văn phòng Wanderer rồi.
B0517: HẾT CẢNH 10
B0518: CẢNH 11
B0519: LEO CẢNH 11
B0520: [ Sprite Kohi lo lắng ]
B0521: - Quỳ! Quỳ!! Bà sao vậy?
B0522: [ Sprite Hải Quỳ mỉm cười ]
B0523: - À…Tui đang ngồi đoán xem bà tặng gì cho tui ấy mà!
B0524: - Thôi đừng đoán! Bà mở ra xem đi!
B0525: Kohi nhón người trao hộp quà cho tôi. Tôi vui vẻ đón lấy hộp quà, cẩn thận mở từng lớp giấy gói.
B0526: - Giáng sinh vui vẻ nha Quỳ! Hi vọng bà thích chiếc đầm xòe này!
B0527: Kohi tặng Dahria một chiếc đầm xòe nhiều lớp được may bằng vải voan có màu bạc hà. Nó là chiếc đầm xòe nhiều lớp mà Dahria vô tình đọc được trong cuốn sổ thiết kế trang phục của Kohi. Chuyện sau đấy thì tôi không nhớ rõ lắm, có thể là nó đã nhờ Kohi may bộ này.
B0528: Hừm, nếu là nó thì phản ứng của nó sẽ như thế nào nhỉ?
B0529: - Thích á? Không, tui…YÊU NÓ!! NÓ ĐẸP XUẤT SẮC, ĐẸP SỐ DZÁCH, ĐẸP HẾT CHỖ KHEN LUÔN!!
B0530: [ Sprite Kohi ngượng mặt ]
B0531: - Trời ơi, bà làm tui ngại quá…!!
B0532: SHYLVIE CẢNH 11
B0533: [ Sprite Hakase lo lắng ]
B0534: - Quỳ! Quỳ!! Cậu sao vậy?
B0535: - A….Tớ đang tò mò là cậu sẽ tặng quà gì cho tớ đó!
B0536: - Vậy hả! Vậy cậu đoán xem!!
B0537: - Thiệt luôn hả Hakase!? Bả có thể đoán trước tương lai đó!! Mất vui!
B0538: Shylvie la lên, tôi quay qua lườm Shylvie một cái.
B0539: [ Sprite Hải Quỳ mắt sáng rực ]
B0540: - Để tớ đoán nhé…Là gấu bông Sonic hả?
B0541: - Sai rồi! Là một chiếc gậy phép thuật !!
B0542: Hakase đập tay một cái, một chiếc gậy phép có cánh chuồn chuồn có đính ngọc đỏ rơi xuống tay tôi.
B0543: Tôi không có hứng thú với gậy phép lắm. Nhưng vì đang giả vờ làm Hải Quỳ nên là….
B0544: Gậy phép thuật !! Nhìn quen lắm ! Phải chăng Hakase làm cây gậy này dựa trên tiểu thuyết tớ viết ?
B0545: Đúng vậy !! Mà nó không phải là đồ chơi đâu, nó là gậy phép thật đấy !
B0546: Tôi quơ nhẹ một cái. Một vụ nổ liền xảy ra, tôi ngay lập tức tạo kết giới để bọc vụ nổ và ép nó lại thành viên bi ve. Tôi nhìn về phía mọi người. Shylvie lẫn Leo đều giơ khiên ra, đằng sau họ là Kohi và Hakase.
B0547: Ồ, mấy người này cũng phản ứng nhanh đấy.
B0548: Ui da….Là hàng thật này !
B0549: Thấy chưa ! Tớ nói rồi mà cậu không tin !!
B0550: HAKASE CẢNH 11
B0551: [ Sprite Leo lo lắng ]
B0552: - A….Tui đang tò mò là ông sẽ tặng quà gì cho tui đó!
B0553: - Trời! Khỏi phải đoán! Quà đây!!
B0554: Leo đặt trước mặt tui một túi quà màu xanh dương khổng lồ được buộc bằng chiếc nơ màu đỏ siêu to. Tôi tò mò chọt tay vào thử thì thấy nó mềm mềm. Tháo chiếc nơ màu đỏ xuống, một chiếc thú bông Knuckles tỷ lệ 1:1 đến từ series game Sonic The Hedgehog xuất hiện trước mắt tôi.
B0555: - ÔI…TRỜI ĐẤT…MẸ ƠI…TO KHIẾP….
B0556: Tôi mở mắt to hết cỡ, miệng không thốt nên lời. Knuckles bông còn cao hơn cả tôi nữa. Tôi vòng tay ôm Knuckles bông vào lòng, vui sướng nhảy cẫng lên.
B0557: [ Sprite Hải Quỳ hạnh phúc ]
B0558: - Tui luôn muốn có một con!! Cảm ơn ông nha Leo!! Thích quá xá!!
B0559: Tôi vừa nói lời cảm ơn đến Leo, vừa dụi mặt vào bụng Knuckles bông. Trời ơi nó mềm, nó thơm!! Bàn tay của Knuckles to hơn cả đầu tôi luôn!! Thích quá!! Thích quá xá là thích!!
B0560: HẾT CẢNH 11
B0561: CẢNH 12 – Kohi không có cảnh 12
B0562: [ Màn hình đen ]
B0563: Trong lúc mọi người đang dọn dẹp bàn tiệc, tôi phụ trách chuẩn bị bắp rang ngũ vị, một thùng đá lạnh để ướp các loại nước ngọt và kem. Điện thoại của tôi rung không ngưng nghỉ trên bàn bếp.
B0564: Sau khi chuẩn bị xong, tôi đi vào phòng vệ sinh để biến thành hình dạng Omega D-13.
B0565: Bà không phải Hải Quỳ, đúng không?
B0566: Đúng lúc tôi tính thi triển ma thuật dịch chuyển thì Shylvie gõ cửa hỏi chuyện.
B0567: - Ờ, sao nhận ra hay thế?
B0568: - Hải Quỳ hiếm khi nào nói chuyện bằng giọng trầm. Chưa kể là dù bà có cố giữ màu mắt đỏ lâu đến mức nào thì vẫn có lúc nó chuyển sang màu cam đấy.
B0569: - Đỉnh đấy. Rồi sao?
B0570: - Không tính xem phim chung với mọi người à?
B0571: - Phức tạp lắm. Nói với bọn họ là tụi tôi có chuyện đi trước. Với cả nhớ chừa kem socola đó!!
B0572: Tôi dậm chân, thi chuyển vòng tròn dịch chuyển.
B0573: HẾT CẢNH 12
B0574: CẢNH 13
B0575: LEO CẢNH 13
B0576: Tôi thực hiện thành công nhiệm vụ giải cứu phiền phức ngay tối hôm đấy.
B0577: Sáng hôm sau, tôi dịch chuyển về phòng vệ sinh của văn phòng Wanderer như lời hẹn để ăn kem.
B0578: Nhưng kỳ lạ! Cửa phòng vệ sinh không mở được! Mà sao tôi lại dịch chuyển vô phòng vệ sinh nhỉ?
B0579: Ai đấy!!
B0580: Leo! Cửa bị kẹt rồi!!
B0581: Ơ Quỳ hả? Sao bà bất thình lình ở trong đấy vậy? Lại không kiểm soát được phép dịch chuyển à?!
B0582: Đại khái vậy! Ông mở giúp tui được không?
B0583: Đợi tí!!
B0584: [ sfx tiếng bước chân ]
B0585: Dưới sự hướng dẫn của Hakase, Leo đã dùng bộ dụng cụ phá khóa mà Dahria tặng hôm qua để mở cửa phòng vệ sinh giúp tôi.
B0586: Trời ơi ta nói nó xui xẻo gì đâu…!!
B0587: Đã thế không còn hộp kem nào trong tủ hết. Chán thế không biết. Cứ tưởng được về ăn kem rồi chứ!
B0588: KOHI CẢNH 13
B0589: Tôi đã dịch chuyển đi ngay lập tức khi biết rằng tôi không thể biện minh cho sai lầm ngu ngốc đến tai hại của Dahria.
B0590: Tôi có thể gây chuyện với bất kỳ ai nhưng không phải Kohi.
B0591: May mắn cho Dahria rằng tôi đủ ý chí kiên cường, không có thói quen suy đi tính lại, không có thói quen suy nghĩ nhiều nên trong thoáng chốc tôi có thể nảy ra phương án để khắc phục ngay lập tức.
B0592: Ta ghét ngươi, Dahria ạ. Bớt suy nghĩ nhiều lại dùm.
B0593: Trời ơi, phiền phức chết đi được!
B0594: Tôi chạy một mạch đến siêu thị điện máy để mua ngay và luôn một chiếc máy pha cà phê, lặn thật sâu xuống Atlantis để lấy bịch cà phê mà Momo bọn tôi gửi, sử dụng số giấy gói quà ít ỏi còn lại để gói thành một món quà thật tươm tất.
B0595: Tôi tính quay trở lại văn phòng để tặng luôn cho Kohi, tính viện cớ là tôi lấy nhầm quà mà không được. Mấy đứa bên văn phòng Silver Wing gọi đột ngột, bảo rằng văn phòng đã xảy ra sự cố gì đấy cần Dahria phải quay về gấp.
B0596: Thế nên là đến tận sáng, sau khi giải quyết hết mớ bòng bong do con Dahria gây nên ở bên văn phòng Silver Wing, tôi mới có thể quay trở về văn phòng Wanderer.
B0597: [ Văn phòng Wanderer + sfx mở cửa ]
B0598: K…Kohi…!! Hộc….
B0599: Ớ? Quỳ! Cuối cùng bà cũng về rồi! Bà ổn hông?!
B0600: [ Sprite Hải Quỳ đồng phục mắt cam thở hồng hộc ]
B0601: Quà….Quà giáng sinh muộn…!
B0602: Tôi chạy đến, tay duỗi thẳng đưa gói quà to bự của tôi cho Kohi, đầu cúi xuống.
B0603: Tối hôm qua….Tui…
B0604: Bà mang nhầm quà chứ gì!
B0605: [ Sprite Hải Quỳ mắt đỏ ngạc nhiên ]
B0606: Ừm…Đại khái là vậy…
B0607: Thấy chưa Shylvie! Tui đã nói là Quỳ mang nhầm rồi mà!
B0608: Kohi không chần chừ, háo hức mở gói quà của tôi. Hai mắt bà ấy sáng rực, hết nhìn chiếc máy pha cà phê rồi quay qua nhìn tôi.
B0609: [ Sprite Kohi mắt sáng rực ]
B0610: Máy pha cà phê!! Lại còn là loại được trang trí theo hình dạng gấu nâu nữa!! Dễ thương thế!! Cảm ơn bà nha!
B0611: Kohi vui sướng đến mức nói liến thoắng không ngừng nghỉ. Sau đấy bà ấy ôm chiếc máy pha cà phê vào bếp để pha thử gói cà phê đi kèm.
B0612: Shylvie từng bước bước đến kế bên tôi, tra hỏi ngọn ngành câu chuyện.
B0613: Hôm qua tính chơi khăm Kohi đúng không, Bully Quỳ?
B0614: [ Sprite Hải Quỳ đồng phục khó chịu ]
B0615: Mắc gì? Nhầm quà thì có.
B0616: Ừ, nhầm quà. Chắc là vậy rồi. Nhưng thôi, ít nhất thì Kohi cũng đã có quà giáng sinh.
B0617: Những người còn lại thì sao?
B0618: Ờm để nhớ xem. Kohi tặng Hakase chiếc bao tay len do bà ấy tự làm, Hakase thì khắc phép lên kiếm của Leo, Leo thì tặng tôi một cuốn sách tổng hợp các loại ma pháp tấn công tầm gần ở chiều không gian của ổng. Còn tôi thì….
B0619: - Hửm? Ấp úng thế? Thế để tui đoán nhé?
B0620: - Ừ đoán đi.
B0621: - Ừm….Là...Gấu bông?
B0622: - Chậc! Đúng là không thể giấu được bà mà!
B0623: Shylvie lôi từ chiếc túi không gian của Shylvie một chiếc gấu bông màu vàng hai đuôi. Tôi nhìn kỹ lại thì phát hiện ra đó là Tails, một nhân vật đến từ series Sonic the Hedgehog.
B0624: - LÀ TAILS?! UI!! DỄ THƯƠNG QUÁ XÁ!! AAAAAAAAAAAAAA
B0625: Tay tôi giả vờ chụp lấy Tails ôm chặt vào long, chân nhảy cẫng lên trong vui sướng.
B0626: - Tui biết thừa là bà thích mấy nhân vật bé trai mà, thừa nhận đi.
B0627: Nếu là Dahria thì nó sẽ nói gì nhỉ?
B0628: - Không thừa nhận!
B0629: - Không thừa nhận thì tui sẽ lấy Tails về!
B0630: - TUI THÍCH SỰ DỄ THƯƠNG Ứ Ừ CỦA CÁC NHÂN VẬT ẢO AAAAAAAAA
B0631: Tôi lật đằng sau Tails để có thể ụp mặt vào hai chiếc đuôi bông mềm mịn.
B0632: - Aaaa, cảm giác này…đã quá đi!! Cảm ơn Shylvie nha!!
B0633: SHYLVIE CẢNH 13
B0634: Sáng hôm sau, tôi dịch chuyển về văn phòng Wanderer như lời hẹn để ăn kem.
B0635: Không còn hộp kem nào trong tủ hết. Chán thế không biết. Cứ tưởng được về ăn kem rồi chứ!
B0636: Tôi buồn chán chuẩn bị rời đi thì từ trên trần có một cổng dịch chuyển hình ổ khóa xuất hiện. Một toán người đầu hình ổ khóa có chiều cao khiêm tốn thông qua chiếc cổng đáp xuống trước mặt tôi.
B0637: Bọn chúng nói thứ ngôn ngữ gì đó nghe như tiếng kim loại va đập vào nhau, nghe điếc hết cả tai, đau hết cả đầu. Tôi thử sử dụng phép dịch ngôn ngữ mà tôi học lỏm từ Shylvie và biết được chúng đang săn lùng phù thủy đầu xanh sử dụng khiên ngẫu nhiên.
B0638: Thấy tôi không có hành động đáp trả gì, bọn chúng nghĩ rằng tôi khinh miệt bọn chúng nên đã lao lên tấn công tôi bằng mấy thanh kiếm có hình chìa khóa.
B0639: [ sfx tiếng bắn beam + tiếng cháy ]
B0640: Tôi búng beam vào chỗ bọn chúng.
B0641: Mắc mệt…Phiền hà chết đi được….Đây không phải là tương lai mà tôi với Dahria nhìn thấy. Chán quá trời quá đất.
B0642: Biết vậy không nên tặng Shylvie bộ dụng cụ phá khóa. Tên đó đã dùng ma thuật để nâng cấp thành bộ dụng cụ phá phép thuật rồi dùng nó để " mượn " bảo vật của mấy tên đầu ổ khóa này.
B0643: Thôi đi về.
B0644: HAKASE CẢNH 13
B0645: Sáng hôm sau, tôi dịch chuyển về văn phòng như lời hẹn để ăn kem.
B0646: Nhưng Shylvie đã dùng hết số kem socola tối qua để làm một món tráng miệng mới theo kiểu Tây Âu cho cả văn phòng, đến chiều mới được ăn.
B0647: Bù lại, sáng nay Shylvie nấu bữa sáng theo kiểu Đức, ăn cũng ngon lắm.
B0648: Mỗi tội cả bọn chưa thưởng thức xong bữa sáng thì Leo nhận được điện thoại.
B0649: Cảnh sát khu vực gọi tới, hi vọng Leo có thể đến đồn để bảo lãnh Hakase về.
B0650: Hóa ra tối qua sau khi xem phim xong, Hakase đã thử thực hành bộ môn phá khóa, khiến cho hàng xóm tưởng lầm rằng hắn ta đi trộm.
B0651: Thế có khổ không cơ chứ…Ít nhất có thể nào cho tôi ăn xong bữa sáng ngon lành này được không?
B0652: [ Kết thúc game ]
B0653: Shylvie đứng dậy cất bộ dao và chảo mà tôi mua vào bếp. Rồi từ trong bếp bước ra, sau lưng của Leo xuất hiện một cái hộp bé bé bằng bàn tay. Shylvie tiến đến chỗ Leo, nở một nụ cười tươi tắn.
B0654: Tôi búng viên bi vụ nổ mà tôi làm từ tối qua vào chỗ bọn chúng.
B0655: Tôi tí ta tí tởn đi đến khu vực mua đồ dùng làm bếp để tậu ngay combo dao và chảo cực xịn mà tôi vừa thấy ban nãy.
B0656: Nhưng ôi thôi nhìn kia, một hàng dài người chen lấn nhau, xô đẩy nhau. Đúng là sức hút của đồ giảm giá mà! Tôi phải cố gắng mới được!
B0657: Tôi chen chúc vào dòng người xô đẩy, cuối cùng cũng chạm tay vào món hàng tôi cần. Mà đấy còn là món hàng cuối cùng nữa chứ! Thiệt là may mắn hết sức!!
B0658: Bực mình ghê! Mắc gì phải chen chúc chi cho khổ vậy? [ Q2 ]
B0659: Không chen chúc thì sao mà mua được! Mà mua xong rồi mới càm ràm là sao? [ Q1 ]
B0660: Hứ! Bộ người quên là ta ghét chen chúc à? [ Q2 ]
B0661: Rồi rồi, xin lỗi!! [ Q1 ]
B0662: Hải Quỳ: Vậy là không muốn được tặng hả?
B0663: Shylvie: Ừ đúng rồi đó~ Không muốn được tặng đó
B0664: Hải Quỳ: Thì thôi~
B0665: [ CG điện thoại biến mất. Sprite Hải Quỳ hơi quạo ]
B0666: Đọc tin nhắn xong mắt tôi nổ đom đóm. Cái tên Shylvie chết tiệt khó ưa này!
B0667: Tôi bực mình đi đến khu vực mua đồ dùng làm bếp để tậu ngay combo dao và chảo cực xịn mà tôi vừa thấy ban nãy.
B0668: Bực mình vậy mà còn chuẩn bị quà tặng nó à? [ Q2 ]
B0669: Haiz, khổ tâm ghê. Tui đang tính tặng món mà Shylvie thích nhất mà… [ Q1 ]
B0670: Thôi, đừng buồn chứ. Nó nói vậy thôi chứ nó không có ý vậy đâu. [ Q2 ]
B0671: Hic…. [ Q1 ]
B0672: Tôi buồn bã bước đến gian hàng văn phòng phẩm để tìm giấy gói quà.
B0673: Trông giấy gói quà màu xanh dương này cũng đẹp này, chắc mua hai ba cuộn gì đó về gói cho đẹp!
B0674: Tôi vui vẻ đi đến khu vực mua đồ dùng làm bếp để tậu ngay combo dao và chảo cực xịn mà tôi vừa thấy ban nãy.
B0675: Ngươi tính tặng cho tên ma vương đáng gờm đó à ?[ Q2 ]
B0676: Ừ đúng rồi, sao thế ?[ Q1 ]
B0677: Ahahaha, không có gì đâu. Thay vì tặng hắn một quyển sách ma thuật thì ngươi lại tặng hắn món này, hay à nha ! [ Q2 ]
B0678: Úp úp mở mở thế ? [ Q1 ]
B0679: Nói ra mất hay. Tự ngươi trải nghiệm mới hay chứ [ Q2 ]
B0680: Tôi khó hiểu trước những lời mà nửa bên kia của tôi nói, bước từng bước trong hoang mang đến gian hàng văn phòng phẩm để tìm giấy gói quà.
B0681: Trông giấy gói quà màu tím than này cũng đẹp này, chắc mua hai ba cuộn gì đó về gói cho đẹp!
B0682: Dạo gần đây, mấy cái chảo trong văn phòng đều bị Hakase đem đi nấu món gì đó đến mức đáy của chúng đều bị lủng lỗ. Nên đôi khi Leo muốn làm đồ ăn sáng cho bọn tôi đều phải làm chiếc chảo bé tin hin, vừa nấu lâu mà vừa tốn ga nữa.
B0683: Tôi nghĩ ắt hẳn Leo sẽ vui lắm khi tôi mua cho ông ấy một bộ dao và chảo mới toanh để ông ấy xài riêng. Không những Leo vui mà tôi cũng vui nữa! Vì khi đó tôi có thể ăn bánh kếp do ông ấy làm nhiều hơn rồi!
B0684: Oáp….Sao buồn ngủ thế nhỉ.
B0685: Tôi dự tính là sẽ đi tuần tra rồi chợt nhớ ra là mình đang được nghỉ phép. Thế là tôi không do dự mà nhảy tọt lên giường và đắp chăn đi ngủ.
B0686: Ba ngày vừa rồi quả là mệt mỏi mà…Kỳ nghỉ phép này….thật…xứng….đáng……
B0687: Nhớ…đánh thức…bọn mình dậy…trước giáng sinh nha…nửa bên kia…
B0688: Dạo gần đây, mấy cái chảo trong văn phòng đều bị Hakase đem đi nấu món gì đó đến mức đáy của chúng đều bị lủng lỗ. Mấy cái dao cái nào cái đấy đều bị Hakase làm rỉ hết.
B0689: Tôi để ý có mấy lần Kohi cố mài dao để xắt lát mấy miếng cá hồi mà không được. Thành ra miếng cá hồi nào cũng nát bươm.
B0690: Tôi nghĩ ắt hẳn Kohi sẽ vui lắm khi tôi mua cho bà ấy một bộ dao và chảo mới toanh để bà ấy xài riêng. Không những Kohi vui mà tôi cũng vui nữa! Vì khi đó tôi có thể ăn sashimi cá hồi do Kohi làm thỏa thích rồi!
B0691: Dạo gần đây, mấy cái chảo trong văn phòng đều bị Hakase đem đi nấu món gì đó đến mức đáy của chúng đều bị lủng lỗ. Mấy cái dao cái nào cái đấy đều bị Hakase làm rỉ hết. Nên Shylvie mỗi lần nấu ăn đều phải cọ nồi và mài dao trước khi sử dụng chúng.
B0692: Có lần tôi vô phòng tìm đồ giúp Shylvie, vô tình nhìn thấy cuốn tạp chí Đầu Bếp đang được ghi chú dở dang của Shylvie. Với bản tính tò mò, tôi đã nghía mắt vào xem thử thì biết được Shylvie đang có ý định mua mới toàn bộ dụng cụ nhà bếp mà Hakase làm hỏng.
B0693: Thành ra hôm nay khi thấy dao và chảo giảm giá, tôi đã không ngần ngại mua. Tôi nghĩ ắt hẳn Shylvie sẽ vui lắm khi tôi mua cho Shylvie một bộ dao và chảo mới toanh.
B0694: Không những Shylvie vui mà tôi cũng vui nữa! Vì khi đó tôi có thể ăn chực đồ do Shylvie làm thỏa thích rồi!
B0695: Dạo gần đây, mấy cái chảo trong văn phòng đều bị Hakase đem đi nấu món gì đó đến mức đáy của chúng đều bị lủng lỗ. Mấy cái dao cái nào cái đấy đều bị Hakase làm rỉ hết. Những thành phẩm mà Hakase nấu ra đều là chất lỏng màu đen đặc quánh và có mùi kì lạ.
B0696: Thành ra hôm nay khi thấy dao và chảo giảm giá, tôi đã không ngần ngại mua. Tôi nghĩ Hakase đang tập nấu thuốc ma thuật nên ắt hẳn ông ấy sẽ vui lắm khi tôi mua cho ông ấy một bộ dao và chảo mới toanh để dùng riêng.
B0697: Không những Hakase vui mà tôi cũng vui nữa! Vì khi đó tôi không phải kì cọ chảo và rèn lại dao mà Hakase làm hỏng nữa !
B0698: Chiếc miệng sau đầu của tôi lên tiếng. Nó liên tục dùng xúc tu để quật vào mặt tôi.
B0699: - Ưm…cho nướng thêm 5 phút nữa….[ Q1 ]
B0700: - Không có 5 phút gì hết! Dậy coi!! [ Q2 ]
B0701: Nói rồi, chiếc miệng sau đầu tôi dùng hết lực hất tung tôi ra khỏi giường. Mặt tôi đập mạnh xuống sàn.
B0702: - Cảm ơn…Aira…. [ Q1 ]
B0703: - Đã bảo không phải Aira rồi! Cái con này! [ Q2 ]
B0704: Dưới sự thúc giục của nửa bên kia của tôi, tôi lọ mọ đứng dậy, lảo đảo bước vào nhà vệ sinh.
B0705: Aira, nửa bên kia của tôi, đã kề bên tôi từ lúc tôi chào đời.
B0706: Aira có thể chiếm quyền kiểm soát cơ thể của tôi nhưng đa phần bà ấy sẽ tự tạo một chiếc miệng đằng sau gáy để nói chuyện và biến tóc thành xúc tu để tương tác cùng lúc với tôi.
B0707: Trông bà ấy khó chịu vậy thôi chứ Aira tốt tính lắm đấy. Tuy hay càu nhàu rằng bà ấy ghét bị tôi nhờ vả nhưng hễ tôi nhờ gì bà ấy cũng chịu khó làm cho ra trò.
B0708: Như lúc này chả hạn. Tôi đang nằm nghĩ vu vơ về Aira còn Aira dùng 8 chiếc xúc tu vừa cõng tôi vừa đi lại trong nhà tôi trông chả khác gì con nhện.
B0709: - Bộ này thì sao? [ Q2 ]
B0710: - Không phải bộ này…. [ Q1 ]
B0711: - Bộ này xấu quá [ Q2 ]
B0712: - Đồng ý [ Q1 ]
B0713: - Bộ này ổn này !! [ Q2 ]
B0714: - Ừa! Bộ này được! [ Q1 ]
B0715: Ý chết ! Suýt nữa là quên hộp quà !
B0716: [ Sfx bước chân + sfx đóng cửa ]
B0717: Xem ra tôi là người đến sớm nhất! Văn phòng hoàn toàn im ắng không một bóng người!
B0718: Thế thì dư sức! Tôi sẽ có dư thời gian để trang trí văn phòng sao cho đẹp nhất có thể!
B0719: Tôi nhảy chân sáo vào phòng họp và bấm bảng điều khiển như bấm phím đàn Piano. Trước đó, Damien,  quản lý siêu sáng suốt của tôi, đã phụ đạo tôi môn lập trình nên ba cái mã này dễ ợt.
B0720: Chuyện thật mà tưởng như đùa, tôi không biết dùng Siera mặc dù tôi là người đã cài đặt cô ấy. Não bộ của tôi thiệt sự không còn chỗ cho bộ môn lập trình, hoặc là do môn lập trình khó đến mức tôi không tiếp thu nổi. Hoặc là cả hai.
B0721: Tôi cực kỳ nể Damien và Murane, người bạn mà tôi quen trong một nhiệm vụ. Không hiểu sao hai con người này lại có thể học được lập trình.
B0722: Được rồi Siera, làm việc của cô đi nào! Hãy cho mọi người thấy AI của Atlantis xịn đến mức nào!
B0723: Nhìn qua camera, tôi thấy cả văn phòng Wanderer đã ngập trong tuyết. Cơ mà cách bày trí này trông hơi đơn điệu quá, phải chỉnh lại mới được.
B0724: Được rồi! Nhìn ổn phết!! Mỗi tội chén dĩa trong tủ bị rơi xuống đất vỡ hết rồi.
B0725: Tôi bước ra ngoài kiểm tra. Trời ơi, ta nói nó lạnh!!
B0726: Tôi chạm thử vào tuyết dưới sàn. Nó là tuyết thật! Sierra đỉnh thật đấy!!
B0727: Muốn chơi với tuyết ghê! Tôi muốn chơi với tuyết quá nhưng phải dọn hết mớ chén dĩa bị vỡ đã!
B0728: Đợt vừa rồi Shylvie có hướng dẫn cho tôi sử dụng phép phục hồi nên phục hồi mớ chén dĩa bị vỡ này dễ như bỡn! Với lượng ma pháp dồi dào của tôi, tôi thậm chí còn khiến chúng không những phục hồi tốt mà còn hóa vàng nữa.
B0729: Được rồi! Chơi với tuyết thôi hi hi!!
B0730: Tôi tự tạo một phân thân để nó chơi ném tuyết với mình. Hai đứa cứ ném nhau qua lại như vậy chưa vui được bao lâu thì có người mở cửa bước vào văn phòng.
B0731: Tôi trượt tay, ném mạnh quả bóng tuyết khổng lồ về phía cửa.
B0732: Một chiếc cổng dịch chuyển có viền màu xanh đột ngột xuất hiện. Quả bóng tuyết tội nghiệp của tôi bị nó nuốt chửng.
B0733: - Ai chơi ném bóng tuyết đấy!!
B0734: [ Sprite Hải Quỳ ngạc nhiên ]
B0735: - Ớ? Shylvie à?
B0736: - Chơi bóng tuyết hả! Cho chơi với!!
B0737: - Kohi, Shylvie! Hai người-
B0738: Tôi chưa kịp nói xong câu thì một đống tuyết nặng trịch đổ ầm xuống đầu tôi. Cả cơ thể của tôi bị chôn vùi trong tuyết, cố gắng lắm tôi mới ngoi đầu lên được. Vừa mở mắt ra thì tôi nhìn thấy gương mặt đang nhịn cười từ Kohi và Shylvie.
B0739: Shylvie không thèm giúp tôi thoát khỏi đống tuyết mà lại lấy điện thoại ra chụp liên hồi. Sau đấy còn vui vẻ chạy lại đưa cho tôi xem.
B0740: Kohi hợp sức cùng Shylvie để kéo tôi ra khỏi đống tuyết. Ngay khi họ vừa cứu tôi thoát ra khỏi đống tuyết, Leo và Hakase về đến văn phòng. Shylvie nhanh nhảu chạy đến đưa cho cả hai người họ xem bức hình xấu hổ ban nãy. Và đoán xem, họ phản ứng thế nào nào?
B0741: Hakase ôm bụng cười ngặt nghẽo. Ổng ngồi bệt xuống sàn, vừa cười vừa dậm chân.
B0742: Leo cố nhịn cười một lúc nhưng rồi không chịu được đành cười phá lên.
B0743: - Vậy " kiệt tác " này là do bà làm à?
B0744: [ Spite Hải Quỳ vui vẻ ]
B0745: - Ừm! Tui nghĩ rằng cho cả Văn Phòng ngập trong tuyết sẽ hay lắm mà dè đâu…
B0746: - Haha. Ý tưởng không tồi. Cũng lâu lắm rồi tui chưa thấy tuyết.
B0747: - Khoan, chả lẽ Luminus cũng bị biến đổi khí hậu hả?
B0748: - Làm vệ thần không gian mệt thiệt ha...
B0749: - Ừ…Làm đặc vụ cũng mệt ngang ngửa mà ha…
B0750: Hakase trố mắt với số chén dĩa đã bị tôi hóa vàng. Chúng khiến ông ấy lầm tưởng năm nay tôi được Poseidon trả lương hậu hĩnh nên mới chơi lớn, mua chén dĩa vàng cho cả văn phòng dùng. Sau khi kể ra sự tình, Hakase và Shylvie cùng phải thốt lên rằng:" Ma lực bà làm được trò này luôn hả? ".
B0751: Mùi thơm quá…Thơm đến mức tôi nhớ lại khi nãy trong lúc bọn họ nấu thì tôi đã tòm tèm được vài miếng. Phần chuẩn bị đã ngon đến thế rồi thì không biết thành phẩm sẽ ngon đến mức nào nữa nhỉ?
B0752: Ôi ngon nhức nách. Nửa bên kia của tôi cực kỳ thích ăn socola nên là nó đã thò xúc tu ra để cắp vài chiếc cho vào miệng sau đầu. Tôi thì mê món bò hầm kem, ăn hết bát này đến bát khác. Bữa ăn diễn ra vui vẻ, mọi người kể cho nhau nghe đủ chuyện từ trên trời xuống đất. Leo chia sẻ cho mọi người công việc của vệ thần không gian, Hakase thì kể về việc ông ấy bắt được Pokemon hiếm, Kohi càm ràm về một bộ anime tình yêu học đường, Shylvie vẫn chưa tha cho món phá lấu mà Leo đã dẫn Shylvie ăn vào hai năm trước.
B0753: Tôi không biết phải kể mọi người nghe chuyện gì. Mọi người ở Văn phòng Silver Wing lẫn Phòng Tác Chiến Nguyệt Thực 6 luôn hòa thuận với nhau, hiếm khi có xích mích. Kể về nhiệm vụ thì hơi dài dòng quá.
B0754: - Lâu vậy đó. Vì tuổi đời bộ giáp đó có khi còn hơn tuổi của tui, nên việc sửa chữa nó sẽ tốn kha khá thời gian.
B0755: Đúng. Tôi là một cô bé mười bốn tuổi. Không hơn không kém.
B0756: Tôi không thể xác định được độ tuổi chính xác của mình là bao nhiêu nữa.
B0757: Vì nó quá ít để đếm!
B0758: Leo: Ui? Bà mua nhiều dao và chảo thế!
B0759: Hải Quỳ: Phải mua nhiều chứ!! Mấy nay tui thấy ông làm bánh kếp bằng cái chảo kia trông ghét bỏ xừ nên tặng ông hẳn một combo cho đỡ ghét!
B0760: Leo: Vậy hả! Cảm ơn bà nha, Quỳ!! Giờ tui có thể vứt hết mớ chảo bị Hakase làm hỏng rồi!
B0761: Hải Quỳ: Đúng vậy, thời kỳ cọ chảo bị khét hay phục hồi chảo bị lủng đã qua rồi Leo à!!
B0762: Tôi và Leo cùng nhau ngước nhìn lên trần nhà, rơm rớm nước mắt.
B0763: Kohi: Họ đang nhìn cái gì vậy….
B0764: Shylvie: Sự hạnh phúc đó, Kohi à…Họ đã ngăn chặn được thảm họa…tạm thời.
B0765: [ Sprite Hakase khó hiểu ]
B0766: Hakase: Hả, thảm họa nào cơ?
B0767: Nhìn lên trần nhà một lúc, Leo đứng dậy cất bộ dao và chảo mà tôi mua vào bếp. Rồi từ trong bếp bước ra, sau lưng của Leo xuất hiện một cái hộp to ngang ngửa ông ấy. Leo tiến đến chỗ Hakase, nở một nụ cười tươi tắn.
B0768: Hakase vỗ tay, một hộp quà bé bé xinh xinh rơi vào tay của Shylvie.
B0769: [ Sprite Hakase vui vẻ + Sprite Shylvie khó hiểu ]
B0770: Hakase: Chúc mừng giáng sinh vui vẻ, Shylvie!!
B0771: Shylvie: Ồ…Cảm ơn Hakase.
B0772: Shylvie mở hộp quà ra. Tôi và Kohi tò mò nên nhón người qua dòm.
B0773: Nó là một bộ phá khóa.
B0774: - Bố à, từ khi nào bố muốn làm trộm vậy?
B0775: - Con à…kiến thức là vô tận…
B0776: - Kohi không biết sao? Hôm bữa Shylvie bị kẹt trong phòng vệ s-
B0777: Shylvie vội dùng tay bịt miệng Hakase lại không đế ổng nói tiếp. Điệu bộ đổ mồ hôi hột giữa tiết trời lạnh giá của Shylvie nhìn kỳ lạ lắm nha. Nhưng không sao, ma pháp thiếu nữ tôi đây chỉ cần nghe một chút xíu thông tin cũng có thể đoán được diễn biến tiếp theo.
B0778: - À, vì Shylvie bị kẹt trong phòng vệ sinh nên ông đã phá khóa cứu Shylvie ra và rồi Shylvie tò mò cách phá khóa nên là ông mới mua cái này đúng không?
B0779: Hakase ư ử gật đầu. Shylvie đỏ mặt trợn mắt nhìn tôi rồi quay mặt đi.
B0780: Trúng phóc!
B0781: Leo và Kohi bụm miệng cười. Riêng tôi thì cười hô hố, cười ra nước mắt.
B0782: Tại vì Shylvie thay vì sử dụng cổng dịch chuyển để thoát khỏi phòng vệ sinh thì Shylvie lại ngồi đau khổ trong trỏng và chờ ai đó cứu Shylvie ra ngoài, nghĩ có buồn cười không cơ chứ.
B0783: Chôn giấu sự hổ thẹn, Shylvie nở một nụ cười lớn khi cầm trong tay một gói quà bự có góc cạnh và trao nó cho Kohi.
B0784: Hải Quỳ: Phải mua nhiều chứ!! Mấy nay tui thấy bà xắt lát cá hồi bằng cái dao rỉ kia trông ghét bỏ xừ nên tặng bà hẳn một combo cho đỡ ghét!
B0785: Kohi: Trời! Kohi đang định đi mua luôn! Quỳ đọc được suy nghĩ của Kohi hả!
B0786: Hải Quỳ: E hèm! Đương nhiên rồi! Ma pháp thiếu nữ mà lị!
B0787: - Hoặc là bà ấy đoán trước được tương lai. Có lẽ bà ấy vừa cứu Wanderer khỏi thảm họa đấy.
B0788: - Khoan, thảm họa gì cơ?
B0789: Leo cùng Shylvie đánh mắt sang nhìn Hakase. Lúc này Kohi mới hiểu được liền " Ồ " lên một tiếng rõ dài.
B0790: - Hả gì? Sao mọi người nhìn tui chằm chằm thế?
B0791: [ Sprite Leo + Shylvie thở dài ]
B0792: - Không có gì đâu Hakase à…Không có gì đâu…
B0793: Kohi lấy ra một hộp quà màu tím được đính nơ đỏ ở chính giữa. Ồ, để tôi đoán! Dựa trên màu giấy gói này…Người tiếp theo được tặng là Hakase!
B0794: Kohi nhón người trao hộp quà cho Hakase. Hakase đón lấy hộp quà, cẩn thận mở từng lớp giấy gói.
B0795: Hakase hứng khởi cài cây bút bằng vàng vào quyển ghi chú trong túi áo của ổng.
B0796: - Leo, có thể đưa cho tôi thanh kiếm Marumasami của ông được không?
B0797: - Marumasami…? Nó là Muramasa mà…Nhưng mà để làm gì ấy?
B0798: - Cứ đưa cho tôi đi!
B0799: Nhìn Leo có vẻ không hiểu chuyện gì đang xảy ra nhưng ổng vẫn làm theo lời của Hakase, lập tức triệu hồi thanh Muramasa rồi đưa nó cho Hakase. Nhận lấy thanh kiếm, Hakase tuốt gươm khỏi vỏ rồi cắm xuống sàn đầy tuyết.
B0800: Bầu không khí đột nhiên trở nên ngột ngạt, đèn điện chớp tắt liên tục. Phần tuyết dưới thanh gươm xuất hiện một vòng tròn màu đỏ máu phát ra từng tia sáng rực khiến chúng tan thành nước rồi chạy dọc ngược lên lưỡi gươm.
B0801: Hakase lẩm bẩm trong miệng từng câu chú thần bí. Từng tia sét li ti liền xuất hiện trong dòng nước làm nó di chuyển một cách dữ dội theo chiều ngang, tạo thành từng đường nét đỏ hỏn trên lưỡi gươm. Từng đường nét mà tia sét khắc nóng trên lưỡi gươm đều được dòng nước theo sau xoa dịu làm nguội đi ngay lập tức.
B0802: Sau vài phút, sức nóng của tia sét đã làm cho những giọt nước mau chóng bốc hơi hết, để lộ ra một dòng chữ hết sức lạ kỳ mà tôi chưa bao giờ thấy trên thanh gươm Murasama của Leo.
B0803: - Tèn tén ten! Ông thấy sao hả Leo?
B0804: - Tui thấy…lạ.Ông vừa làm gì với thanh Murasama vậy?
B0805: - Ơ kìa! Tớ khắc phép lên đó cho cậu mà! Phép hơi bị xịn à nha!
B0806: - Xịn là xịn như thế nào?
B0807: - Cậu cầm vung thử đi!
B0808: Leo nghe theo lời Hakase nói, cầm vung thử thanh Murasama. Leo chỉ vung nhẹ một cái, một vệt sáng màu đỏ tím bay vút vào trong bếp. Hậu quả là bàn bếp bằng đá hoa cương bị nó cắt làm đôi.
B0809: - Ui!! Chém ra gió luôn này!! Cảm ơn ông nha Hakase!! Món quà này tuyệt quá!
B0810: - Hehe! Hông có gì đâu Leo! Tớ hổng cần cậu đền đáp gì ngoài thân thể của cậu hết.
B0811: [ Sprite Leo đỏ mặt ]
B0812: - That's phoking gay guys….
B0813: Cảm ơn Hakase xong, Leo lấy từ trong chiếc túi không gian của ổng một chiếc khiên cổ bị rỉ sét và bám đầy rêu. Ổng tiến đến chỗ Shylvie rồi dúi chiếc khiên vào tay Shylvie.
B0814: - Quà của ông đây! Giáng sinh vui vẻ!!
B0815: - Ồ!! Cảm ơn ông nha!! Chiếc khiên này có vẻ xịn đấy!!
B0816: Shylvie vừa nói dứt lời, bỗng chiếc khiên xuất hiện nhiều vết nứt, lớp vỏ rỉ sét trên chiếc khiên tróc thành từng mảng rơi xuống sàn. Nó phát ra một ánh sáng rực rỡ, hớp hồn tất cả mọi người trong văn phòng.
B0817: - Woa….
B0818: - Uầy…
B0819: - Trời má….
B0820: [ Sprite của ba người biến mất. Sprite của Shylvie + Leo ngạc nhiên ]
B0821: - Ôi vãi…?! Nó…Nó là chiếc khiên huyền thoại ở chiều không gian của tôi mà!? Làm thế nào mà…
B0822: - GÌ CƠ?? CHIẾC KHIÊN HUYỀN THOẠI Á??
B0823: - Nó đó. Tương truyền rằng nó được rèn bởi thợ rèn kiêm pháp sư huyền thoại, người đã khảm lên chiếc khiên này vô vàn loại bùa chú không thể xác định sau đấy.
B0824: - NÓ LÀ MÓN QUÀ TUYỆT CÀ LÀ VỜI LEO Ạ! ĐỈNH CỦA CHÓP! XUẤT SẮC CÀ CHUA!!
B0825: Shylvie hét loạn lên, nâng chiếc khiên lên cao thật cao rồi xoay người vài ba vòng cùng chiếc khiên. Nhìn Shylvie không khác gì trẻ lên ba đang phấn khích.
B0826: Shylvie ngạc nhiên nhìn túi quà to bự mà tôi đưa cho Shylvie. Tôi gật đầu, ra tín hiệu cho Shylvie mở nó ra xem.
B0827: Shylvie: ÔI… !! CÁI NÀY… !!
B0828: [ Sprite Hakase và Kohi tò mò ]
B0829: Hakase: Ố, là gì thế !
B0830: Shylvie: Một bộ dao và chảo hoàn toàn mới toanh !! Tôi cứ nghĩ là bà sẽ tặng tôi một chiếc khiên siêu xịn từ Atlantis chứ ! Bà lại nhìn trước tương lai đúng không ?
B0831: Hải Quỳ: Hả ? Nhìn trước gì cơ ?
B0832: Shylvie: Không lý nào bà lại mua đúng bộ tôi đang định mua được ! NÓ QUÁ LÀ TUYỆT VỜI QUỲ Ạ !!
B0833: Hải Quỳ: À vậy hả… ! Tui còn đang lo là Shylvie không thích đấy chứ…
B0834: Shylvie: Đâu ra ! Tôi thích bỏ xừ mà !! Thời kỳ cọ chảo bị khét hay phục hồi chảo bị lủng đã qua rồi Quỳ ơi!!
B0835: Shylvie quay sang khoe với Leo món quà mà tôi vừa tặng. Rồi cả hai cùng nhau ngước nhìn lên trần nhà, rơm rớm nước mắt.
B0836: Kohi: Quỳ à, tương lai mà bà thấy bộ nó tệ đến vậy hả…
B0837: Hải Quỳ: Tui cũng không biết nữa Kohi à…
B0838: Hakase: Hai người đó đang nhìn cái gì vậy ?
B0839: [ Sprite Shylvie và Leo vui vẻ ]
B0840: Shylvie: Hạnh phúc đó Hakase à… ! Là hạnh phúc đó !
B0841: Tiếp đến là lượt tặng quà của Leo. Không biết là Leo sẽ tặng cho Kohi hay là sẽ tặng cho Hakase đây.
B0842: Leo bước vào phòng của ông ấy để đẩy một chiếc hộp gỗ to đùng ra ngoài. Leo từng bước đẩy nó đến chỗ Kohi, trước sự ngỡ ngàng của bà ấy.
B0843: [ Kohi ngạc nhiên ]
B0844: Leo à...Ông tặng cho tôi món gì đấy?
B0845: Bà mở ra là biết liền à!
B0846: Nó an toàn không vậy?
B0847: Hả! Đương nhiên là an toàn rồi! Có khi bà sẽ thích nó đấy!!
B0848: Kohi loay hoay một lúc không biết mở chiếc thùng gỗ này như thế nào. Leo chợt nhận ra, ngay lập tức triệu hồi thanh Murasama của ổng để chém vụn chiếc thùng.
B0849: Bên trong chiếc thùng gỗ là rất nhiều thanh gỗ có hình dạng khác nhau được xếp chồng lên nhau.
B0850: Giáng sinh vui vẻ, Kohi!!
B0851: Cảm ơn Leo! Tui vẫn chưa hiểu lắm! Mấy thanh gỗ này là sao vậy?
B0852: Là chiếc tủ lắp ráp bằng gỗ đó! Tui nghĩ là phòng Kohi sẽ đẹp lắm nếu có một chiếc tủ gỗ trang hoàng như thế này nên là….
B0853: Ơ, thế á! Thế thì tuyệt vời quá Leo ạ! Dạo gần đây Kohi cũng đang tính mua tủ để đồ mà cứ phân vân mãi thôi! Tủ lắp ráp bằng gỗ là lựa chọn hay đó!!
B0854: Rồi Leo vác hết các thanh gỗ vào phòng Kohi để lắp ráp. Lắp xong, Leo gọi cả bọn vào xem. Đúng như Leo nói, trang hoàng phòng Kohi bằng chiếc tủ này khiến cho phòng Kohi trông đã đẹp còn đẹp hơn. Rất phong cách!
B0855: Sau khi cả bọn quay về bàn ngồi, Kohi lấy ra một hộp quà màu tím được đính nơ đỏ ở chính giữa từ trong túi xách của bà ấy rồi đưa nó cho Hakase. Hakase đón lấy hộp quà, cẩn thận mở từng lớp giấy gói.
B0856: - Nhớ đeo chiếc bao tay này mỗi lần lấy trộm bánh khỏi lò nướng nhé!
B0857: [ Sprite Hakase phấn khích ]
B0858: - Ôi Kohi, tui cảm động quá! Cảm ơn bà nha!!
B0859: Chiếc bao tay mà Kohi tặng cho Hakase là chiếc bao tay do Kohi đan từ len. Nó đẹp thật đấy…!!
B0860: Khoan, không một ai để ý đến việc Hakase hay trộm bánh trong lò nướng hả….??
B0861: Hải Quỳ: Được chứ! Anh mở đi!
B0862: Hakase: Chảo mới! Dao mới!! Cảm ơn Hải Quỳ nha! Cơ mà sao cậu lại tặng tớ món này thế!!
B0863: Hải Quỳ: À thì em để ý thấy mấy nay Hakase đang hết sức luyện tập nấu thuốc! Bộ dao với chảo cũ đều hỏng cả rồi nên mua bộ mới cho anh dùng dần luôn!
B0864: Leo và Shylvie kinh hãi nhìn chiếc chảo mà Hakase đang vui vẻ cầm rồi quay lại nhìn tôi. Ủa gì vậy?! Ánh mắt đó là sao?
B0865: Hakase: Ra là vậy! Một lần nữa, cảm ơn cậu nha!
B0866: [ Sprite Leo và Shylvie thở dài ]
B0867: Leo: Thôi xong rồi…
B0868: [ Kohi khó hiểu ]
B0869: Kohi: Hai người sao vậy?
B0870: Leo: Không có gì đâu Kohi à…Không có gì đâu…
B0871: Có chuyện gì xảy ra với Leo và Shylvie vậy? Trông hai người họ không được ổn lắm…Chả lẽ tặng dao và chảo mới cho Hakase bất ổn vậy sao?
B0872: Hakase đứng dậy cất bộ dao và chảo mà tôi mua vào bếp. Rồi từ trong bếp bước ra, sau lưng của Hakase xuất hiện một cái hộp bé bé bằng bàn tay. Hakase tiến đến chỗ Kohi, nở một nụ cười đầy tự hào.
B0873: Hakase: Mè rí Mè rí!! Quà của cậu nè Kohi!
B0874: Kohi: Ú ù! Là gì vậy Hakase?
B0875: Hakase: Mở ra xem đi Kohi! Đảm bảo bất ngờ luôn!
B0876: Theo lời Hakase, Kohi cẩn thận mở từng lớp giấy gói quà và lấy ra một chiếc lọ thủy tinh trong suốt có chứa nhiều hạt sỏi chi chít lỗ.
B0877: Hakase: Xin giới thiệu cho Kohi và mọi người, đây là chiếc đèn ngủ ma thuật với đèn được làm bằng thiên thạch!
B0878: Kohi: Đèn được làm bằng thiên thạch á? Khó tin vậy!
B0879: Hakase: Khó tin mà đúng không! Vì đây là chiếc đèn ma thuật! Chỉ cần Kohi để chiếc lọ trong phòng tối thì ngay lập tức các viên thiên thạch bé tin hin này sẽ vỡ ra và mô phỏng lại bầu trời sao! Thế nên tớ đã gọi nó là “ Đèn ngủ ánh sao ma thuật để bàn “ đấy!
B0880: Trời…Cậu đầu tư dữ! Đâu, để tớ kiểm tra sản phẩm nào! Sierra, tắt đèn giúp tôi nhé!
B0881: Sierra lập tức tắt hết tất cả đèn trong văn phòng. Một luồng ánh sáng nhè nhẹ đủ màu sắc từ trong chiếc lọ thủy tinh tỏa ra. Đúng như lời Hakase nói, các viên thiên thạch đã vỡ ra và tạo thành một bầu trời đầy sao sáng trong chiếc lọ thủy tinh này!
B0882: Oa! Đẹp quá Hakase ạ! Tớ thích nó, cảm ơn cậu nha!!
B0883: Kohi gọi ới Sierra một tiếng, toàn bộ đèn trong văn phòng được bật sáng trở lại. Kohi đứng dậy đi vào phòng để cất chiếc đèn ngủ ma thuật rồi đi ra ngoài với một chiếc túi đeo kéo nho nhỏ có đính nhiều hạt cườm màu xanh dương trong vắt. Chỉ cần nhìn vào chúng thôi, tôi có thể xác định được món quà này sẽ dành tặng cho ai.
B0884: Giáng sinh an lành nha bố!
B0885: Ôi, cảm ơn con gái yêu của bố!
B0886: Sau khi nhận được chiếc túi đeo chéo mà Kohi tặng, Shylvie cẩn thận cất nó vào trong chiếc túi không gian ma thuật của mình. Xong, Shylvie rút ra một chiếc ốp lưng điện thoại màu đen từ trong chiếc túi và đưa nó cho Leo.
B0887: CẢNH 10
B0888: Tôi biết ngay mà. Từ lúc tôi tổng hợp hồ sơ, tôi có xem qua một chút, cũng đã thấy nghi nghi rồi.
B0889: Tôi đã hi vọng rằng chuyện phát hiện ra điểm vô lý sẽ xảy ra sau khi kỳ nghỉ phép của tôi kết thúc. Đành vậy, cứu người vẫn quan trọng nhất. Tiếc ghê, vậy là không được ngồi xem phim " Ở nhà một mình " cùng mọi người tại Văn phòng Wanderer rồi.
B0890: - A…Tui đang tò mò về máy pha cà phê ấy mà!
B0891: - Gì chứ! Bà phải tò mò về quà tui sắp tặng bà chứ!
B0892: - À ừ…!! Vậy bà tính tặng tui gì đó!
B0893: - Đợi tui xíu!
B0894: Kohi lon ton bước vào bếp và mở tủ lạnh ra.
B0895: Mắt tôi dán chặt vô chiếc bánh phô mai màu cam mà Kohi đang cầm trên tay.
B0896: - Bữa bà nói bà chưa ăn bánh phô mai cam mà đúng không!
B0897: - Nên là…Kohi đã làm nó cho tui sao?!
B0898: - Yup!
B0899: - Ôi! Trông nó ngon quá!! Tui có thể ăn nó luôn không?
B0900: - Được chứ!
B0901: - Itadaki-múc!
B0902: Tôi mở miệng to hết mức để cạp mất một nửa chiếc bánh. Rồi tôi đưa chiếc bánh ra sau để chiếc miệng sau đầu của tôi cạp hết nửa còn lại.
B0903: Mọi người trố mắt nhìn tôi.
B0904: - Ờm Quỳ à…Bà ăn cả đĩa à….?
B0905: - Đâu có!
B0906: " Ợ "
B0907: Tôi đưa tay ra sau chụp lấy. Chiếc miệng đằng sau ợ ra chiếc đĩa sạch vàng sạch kin kít.
B0908: - Bà ấy…thực sự ăn luôn mà…
B0909: - Tui luôn muốn được ăn bánh phô mai!! Cảm ơn Kohi nhiều nhiều lắm!!
B0910: KOHI CẢNH 11
B0911: [ Sprite Shylvie lo lắng ]
B0912: - Trời? Nay biết tò mò luôn? Tui còn tưởng là bà đã đoán ra được rồi cơ.
B0913: - Ơ? Thế để tui đoán nhé?
B0914: Tay tôi lập tức chụp lấy Tails ôm chặt vào long, chân nhảy cẫng lên trong vui sướng.
B0915: - Bả thực sự thích bé trai...
B0916: Tôi không tin lời Hakase nói, liền quơ nhẹ một cái. Một vụ nổ liền xảy ra, nó đủ mạnh để thổi bay tôi đập mạnh người vào cửa chính. Tôi suýt nữa lăn ra ngất ngay tại chỗ nếu không có Aira dùng xúc tu đỡ hộ tôi.
B0917: Tôi nhìn về phía mọi người. Shylvie lẫn Leo đều giơ khiên ra, đằng sau họ là Kohi và Hakase. May quá, họ phản ứng kịp !
B0918: [ Sprite Hải Quỳ vui vẻ nhưng mặt nhem nhuốc ]
B0919: Sau khi chuẩn bị xong, tôi chạm vào mỏ neo biến hình của tôi để biến thành hình dạng Omega D-13 ngay trước mắt mọi người.
B0920: [ Sprite Hải Quỳ 2.0 ]
B0921: - Xin lỗi mọi người-
B0922: - Bà cứ đi đi, không sao hết
B0923: Leo gật đầu nhìn tôi.
B0924: - Và bà sẽ cần chiếc chìa khóa này đấy.
B0925: Leo đưa cho tôi chiếc chìa khóa dịch chuyển dự phòng.
B0926: - Nhớ về sớm sớm nha! Kẻo hết kem!!
B0927: - Đi cẩn thận nhé!!
B0928: - Ừa! Tui đi đây!! Nhớ chừa kem cho tui đó!!
B0929: Tôi rút chìa khóa dịch chuyển ra khỏi túi áo, cắm mạnh vào cửa.
B0930: Cánh cửa ra vào của Văn phòng Wanderer ngay lập tức được kết nối đến phòng của tôi tại Văn phòng Silver Wing. Tôi mở cửa và bước vào.
B0931: CẢNH 12
B0932: Chiếc bánh mà Kohi làm mang lại năng lượng dồi dào cho tôi.
B0933: Tôi thực hiện thành công nhiệm vụ giải cứu ngay tối hôm đấy.
B0934: Sáng hôm sau, tôi quay về văn phòng Wanderer như lời hẹn để ăn kem.
B0935: Đáng tiếc là không còn hộp kem nào trong tủ hết. Bù lại tôi thấy Leo đang đứng nấu món gì đó.
B0936: Ồ, là mì cay hải sản!!
B0937: Leo múc cho tôi một bát đầy nghêu, tôm và mực. Tôi húp một muỗng nước dùng để cảm nhận vị ngon của hải sản trong tô mì và chợt nhận ra.
B0938: Leo đã cho kem vào tô mì của tôi.
B0939: Nó không tệ như tôi nghĩ. Nó lại còn ngon là đằng khác.
B0940: Rìa lỗ hổng 61 là khu vực cực kỳ hỗn loạn. Để có thể cứu được các thành viên Silver Wing bị bắt nhốt tại đấy, tôi bắt buộc phải tạo một kết giới phong tỏa và xả hết tất cả số đạn ma pháp mà tôi mang theo mình.
B0941: Việc đó khiến cho tôi cực kỳ đuối sức. Vì không còn chút sức lực nào để quay về văn phòng xem phim cùng mọi người nên tôi đành qua đêm tại phòng y tế của văn phòng Silver Wing.
B0942: Sáng hôm sau, tôi quay trở về văn phòng để cất chiếc chìa khóa dịch chuyển dự phòng thì ngửi thấy một mùi thơm ngào ngạt. Có mùi hoa hồi, hoa quế, ngò và bò viên…LÀ PHỞ?
B0943: Tôi bước vào bếp và trông thấy Kohi đang xắt lát tảng thịt bò to đùng bằng con dao mới mà tôi tặng bà ấy.
B0944: " CẠCH "
B0945: Cái thớt bị gãy làm đôi.
B0946: Việc đó khiến cho tôi cực kỳ đuối sức. Cộng thêm trước đó tôi đã gây ra một vụ nổ trong văn phòng Wanderer, tôi không còn chút sức lực nào để quay về văn phòng xem phim cùng mọi người nên tôi đành qua đêm tại phòng y tế của văn phòng Silver Wing.
B0947: Sáng hôm sau, tôi quay trở về văn phòng để cất chiếc chìa khóa dịch chuyển dự phòng thì thấy mọi người đang tụ tập trong bếp. Trông thấy tôi, họ liền bỏ dở việc đang làm để kéo tôi ngồi xuống bàn ăn.
B0948: Hóa ra sáng nay Shylvie dậy sớm để trổ tài làm các món Tây Âu đã cả bọn. Do đang đói nên tôi không những ăn hết cả nồi mà còn liếm sạch đĩa của mình.
B0949: Chà, ngon thật. Không có gì để chê cả.
B0950: Việc đó khiến cho tôi cực kỳ đuối sức. Vì tôi không còn chút sức lực nào để quay về văn phòng xem phim cùng mọi người nên tôi đành qua đêm tại phòng y tế của văn phòng Silver Wing.
B0951: Sáng hôm sau, tôi quay trở về văn phòng để cất chiếc chìa khóa dịch chuyển dự phòng thì thấy ngoại trừ Hakase thì những người còn lại đều đã gục mặt ngất lịm trên bàn ăn. Tôi khịt khịt mũi, ngửi thấy một mùi hương quen thuộc từ trong bếp.
B0952: Hóa ra Hakase đã trổ tài làm món Omurice trứng hắc ám ăn kèm với thịt Leviathan chiên xù cho mọi người ăn.
B0953: Chà, ngon thật đấy! Lâu rồi tôi chưa ăn thịt quái vật nên vị ban đầu của nó không ngon lắm. Nhưng nếu ăn thêm vài muỗng thì trời ơi, không có gì để chê cả.
B0954: Sau đó, ba người kia bị ngộ độc thực phẩm, tôi và Hakase phải hợp sức cùng nhau chữa trị cho họ.
B0955: HẾT CẢNH 13 – KẾT THÚC GAME.
B0956: - A….Tui đang tò mò là bà sẽ tặng quà gì cho tui đó!
B0957: Tôi tí ta tí tởn đi đến khu vực mua bộ dụng cụ đan len.
B0958: Nè con nhãi kia, bộ dụng cụ đan len cũ còn xài được mà ? [ Q2 ]
B0959: Xài được ? Sau cái hôm bà dùng nó để đi hạ sát quái vật vực sâu thì nó bị ăn mòn rồi còn gì ? [ Q1 ]
B0960: À…ừ nhỉ. Quên khuấy đi mất. Nhưng mà len nhà mình vẫn còn mà… ? [ Q2 ]
B0961: Nhưng nó đang giảm giá !! [ Q1 ]
B0962: Tôi dòm lên kệ trước mặt tôi một hồi lâu rồi quyết định với tay lên lấy bộ dụng cụ đan len bằng gỗ, rồi quay sang kệ kế bên để lấy mười cuộn len màu đỏ cho vào giỏ.
B0963: Hải Quỳ: Là Kohi!!
B0964: Shylvie: Ui! Hóng quá!
B0965: Leo: Bà chắc sẽ tặng Kohi chưa?
B0966: Hải Quỳ: Như đinh đóng cột! Mọi người tiếp tục vòng tặng nhé! Tớ sủi đây, hihi!. )
B0967: Tôi dòm lên kệ trước mặt tôi một hồi lâu rồi quyết định với tay lên lấy bộ dụng cụ đan len bằng gỗ, rồi quay sang kệ kế bên để lấy mười cuộn len màu nâu cam cho vào giỏ.
B0968: Tôi bực mình đi đến khu vực mua bộ dụng cụ đan len.
B0969: Lời đã nói ra sao mà rút được [ Q1 ]
B0970: À, nhớ mua bộ dụng cụ đan len mới. Bộ cũ hỏng rồi. [ Q2 ]
B0971: Nhớ rồi. [ Q1 ]
B0972: Tôi với tay lên kệ trước mặt tôi để lấy bộ dụng cụ đan len bằng gỗ, rồi quay sang kệ kế bên để lấy mười cuộn len màu xanh cho vào giỏ.
B0973: Ngươi tính tặng cho tên ma vương đáng gờm đó à? [ Q2 ]
B0974: Ừ đúng rồi, sao thế? [ Q1 ]
B0975: Ta không hiểu. Thay vì tặng hắn một quyển sách ma thuật thì ngươi tặng hắn một chiếc khăn len à? Để làm gì? [ Q2 ]
B0976: Có mấy hôm khuya khoắt vô tình tạt ngang qua nhà ổng thì thấy ổng đang luyện tập bắn tia năng lượng hăng say lắm. Mà trời dạo này trở lạnh, nên tui nghĩ tặng ổng chiếc khăn tự đan nó cực kỳ ý nghĩa luôn [ Q1 ]
B0977: Chịu. Không hiểu gì hết. À đúng rồi, nhớ mua bộ đan len mới đấy. Bộ cũ hỏng mất rồi còn đâu [ Q2 ]
B0978: Ừa, biết rồi mà! [ Q1 ]
B0979: Tôi với tay lên kệ trước mặt tôi để lấy bộ dụng cụ đan len bằng gỗ, rồi quay sang kệ kế bên để lấy mười cuộn len màu tím và xám cho vào giỏ.
B0980: Hai ba….Hai ba…Một bốn….Ừm…Đan như vầy đúng chưa ta ?
B0981: Hai ba ! Bốn sáu ! Bốn một….Nhìn cũng ổn phết ha !!
B0982: Cơ mà…chiếc khăn màu đỏ này…không biết có bị nhàm quá không ? Đúng là màu đỏ là màu của Leo đó nhưng mà…chiếc khăn này vẫn chưa có chất của Leo lắm…Hừm…Nó bị thiếu gì đó…A đúng rồi ! Ký hiệu con dơi !!
B0983: Nửa bên kia của tôi ơi, giúp cái coi ! [ Q1 ]
B0984: Gì vậy trời ? Nửa đêm nửa hôm đánh thức người ta dậy làm gì ? [ Q2 ]
B0985: Bà giúp tui tạo ra một chiếc kẹp sắt hình con dơi được không ? [ Q1 ]
B0986: Hả ?! Chi vậy ? Chả lẽ tính gắn lên chiếc khăn này hả ? [ Q2 ]
B0987: Ừm ! [ Q1 ]
B0988: Haiz…Đợi xíu…[ Q2 ]
B0989: [ CG hai bàn tay Hải Quỳ từ trống không thành đang nâng niu chiếc kẹp hình con dơi ]
B0990: Nhìn đẹp thế !! [ Q1 ]
B0991: Đương nhiên rồi, ta mà lị ! [ Q2 ]
B0992: Cảm ơn nha, Aira ! [ Q1 ]
B0993: Đã bảo không phải là Aira rồi mà ! [ Q2 ]
B0994: Tôi liền kẹp chiếc kẹp hình con dơi lên chiếc khăn len màu đỏ. Thế mới đúng chứ ! Nhìn vô là biết chiếc khăn này là của ai liền ! Hi vọng là Leo sẽ thích nó !!
B0995: Sở dĩ tôi biết đan len là nhờ Kohi dạy cho đó. Hôm tôi đến nhà Kohi tôi thấy bà ấy có một cái bàn may và một rổ móc len đầy đủ dụng cụ. Thấy tôi nhìn nó không ngớt nên Kohi đã ngỏ ý dạy cho tôi móc len.
B0996: Hai ba ! Bốn một….Bốn một….Không ổn rồi…Sao lủng lỗ tè le vậy nè…?
B0997: Tôi càng cố sửa chiếc khăn, nó càng nhăn nhúm và lủng nhiều lỗ hơn.
B0998: Tôi đành vất chiếc khăn đan dở ấy đi để đan chiếc khăn mới.
B0999: Kết quả là chiếc khăn mới đỡ lủng hơn chiếc khăn cũ một chút và nó không bị rối thành một nùi giống chiếc khăn cũ.
B1000: Hic, như thế này sao tôi dám tặng cho Kohi đây….
B1001: Coi kìa? Sao mặt sụ xuống rồi? [ Q2 ]
B1002: Cái khăn trông tệ quá [ Q1 ]
B1003: Hừm…Không tệ lắm. Nó hơi lủng lỗ thôi mà. [ Q2 ]
B1004: Đó là vấn đề đó. Tệ thế này thì sao mà đem tặng người ta được [ Q1 ]
B1005: [ CG hai bàn tay Hải Quỳ từ trống không thành đang nâng niu chiếc kẹp hình hạt cà phê ]
B1006: Nó đẹp quá…nhưng để làm gì vậy? [ Q1 ]
B1007: Gắn vào cho đỡ lỗ [ Q2 ]
B1008: Đỉnh quá….! [ Q1 ]
B1009: Aira là thiên tài! [ Q1 ]
B1010: Tôi liền kẹp chiếc kẹp hình hạt cà phê lên chiếc khăn màu nâu đỏ. Mong là Kohi thích nó!
B1011: Tôi càng cố sửa chiếc khăn, nó càng nhăn nhúm và lủng nhiều lỗ hơn. Tôi đành vất chiếc khăn đan dở ấy đi để đan chiếc khăn mới đẹp hơn.
B1012: Cơ mà…chiếc khăn màu xanh này…không biết có bị nhàm quá không ? Đúng là màu đỏ là màu của Shylvie đó nhưng mà…chiếc khăn này vẫn chưa có chất của Shylvie lắm…Hừm…Nó bị thiếu gì đó…A đúng rồi ! Ký hiệu hình chiếc khiên !!
B1013: Bà giúp tui tạo ra một chiếc kẹp sắt hình chiếc khiên được không ? [ Q1 ]
B1014: [ CG hai bàn tay Hải Quỳ từ trống không thành đang nâng niu chiếc kẹp hình chiếc khiên ]
B1015: Tôi liền kẹp chiếc kẹp hình chiếc khiên lên chiếc khăn len màu xanh. Thế mới đúng chứ ! Nhìn vô là biết chiếc khăn này là của ai liền ! Hi vọng là Shylvie sẽ thích nó.
B1016: Cơ mà…chiếc khăn màu đỏ này…không biết có bị nhàm quá không ? Đúng là màu đỏ là màu của Leo đó nhưng mà…chiếc khăn này vẫn chưa có chất của Leo lắm…Hừm…Nó bị thiếu gì đó…A đúng rồi ! Ký hiệu chìa khóa !!
B1017: Bà giúp tui tạo ra một chiếc kẹp sắt hình chìa khóa được không ? [ Q1 ]
B1018: [ CG hai bàn tay Hải Quỳ từ trống không thành đang nâng niu chiếc kẹp hình chìa khóa ]
B1019: Tôi liền kẹp chiếc kẹp hình chìa khóa lên chiếc khăn len màu tím xám. Thế mới đúng chứ ! Nhìn vô là biết chiếc khăn này là của ai liền ! Hi vọng là Hakase sẽ thích nó.
B1020: Tôi mở mắt dậy và quay sang nhìn chiếc đồng hồ điện tử treo trên tường.
B1021: Ồ, nay là giáng sinh rồi à…
B1022: Tôi đã ngủ một mạch đến ngày giáng sinh….Ngon thật đấy….
B1023: Tôi…ngủ một mạch….đến…GIÁNG SINH ?!
B1024: Chết rồi !! Vỡ kế hoạch rồi !! Nửa bên kia của tôi ơi !! Đã dặn là đánh thức trước giáng sinh mà ?! Còn vài tiếng nữa là đến tiệc giáng sinh trong văn phòng rồi !!
B1025: [ sfx đổ vỡ, lật đật ]
B1026: Giờ này thì làm sao mà kịp bắt xe đến văn phò ng được ?! Chìa khóa dịch chuyển đâu rồi… !! Nó nằm ở đâu vậy ?!
B1027: [ sfx mở cửa tủ liên tục ]
B1028: Mình còn chưa chuẩn bị trang phục nữa !! Nên mặc bộ nào đây !!
B1029: Không phải bộ này….
B1030: Cũng không phải bộ này nốt !!
B1031: Bộ này ổn này !!
B1032: [ Màn hình đen đổi sang BG Văn Phòng Wanderer ]
B1033: Quỳ !! Hello !
B1034: [ Sprite Hải Quỳ mặc đồ giáng sinh + Shylvie mặc đồ giáng sinh ]
B1035: Người đầu tiên tôi gặp khi vừa mở cửa là Shylvie. Trên tay Shylvie đang cầm một đĩa hoa quả đầy ú ụ.
B1036: A…Shylvie!! Mọi người chuẩn bị đến đâu rồi?
B1037: Đã xong đâu. Leo với Hakase đi mua đồ để trang trí mà giờ chưa thấy về.
B1038: Để tui trang trí cho…!
B1039: [ Sprite của Shylvie biến mất, Sprite của Hải Quỳ từ bên phải chạy nhanh sang bên trái ]
B1040: Tôi lao nhanh vào phòng họp và bấm bảng điều khiển loạn xạ. May mắn là trước đó Damien, quản lý siêu sáng suốt của tôi, đã phụ đạo tôi môn lập trình nên ban nãy lúc tôi vừa thay đồ vừa đọc cuốn hướng dẫn sử dụng Sierra, tôi đã nắm bắt kha khá mã lệnh cho cô ấy.
B1041: - Ối cái gì thế Shylvie!
B1042: - Không phải do tôi!!
B1043: Tôi nghe thấy tiếng la toáng của Kohi và Shylvie ở bên ngoài phòng họp. Nối tiếp sau đó là tiếng chén dĩa vỡ tanh bành.
B1044: Tôi nghĩ mình nên ra ngoài giúp họ.
B1045: - Kohi, Shylvie! Mọi người-
B1046: Tôi mở cửa, chưa kịp nói xong câu thì một đống tuyết nặng trịch đổ ầm xuống đầu tôi. Cả cơ thể của tôi bị chôn vùi trong tuyết, cố gắng lắm tôi mới ngoi đầu lên được. Vừa mở mắt ra thì tôi nhìn thấy gương mặt đang nhịn cười từ Kohi và Shylvie.
B1047: Mọi người cùng nhau dọn dẹp đống chén dĩa vỡ hồi nãy. Shylvie sử dụng phép phục hồi, khiến chúng quay trở về hình dạng cũ. Kohi và Hakase bắt đầu bày biện đồ ăn lên bàn. Tôi với Leo cùng nhau dọn bớt tuyết rồi dùng số tuyết ấy để nặn ra mấy con người tuyết có hình thù kỳ lạ.
B1048: [ Sprite Hải Quỳ + Leo biến mất ]
B1049: Bàn tiệc giáng sinh đã chuẩn bị xong! Năm nay Kohi và Shylvie cùng nhau đứng bếp. Shylvie thì chuẩn bị một nồi bò hầm kem ăn cùng bánh mì men và một nồi phô mai thập cẩm được đun chảy ăn cùng một số loại thực phẩm phù hợp. Kohi thì chuẩn bị bánh socola tan chảy cùng bánh khúc gỗ to đùng phủ ngập kem.
B1050: - Một chiếc khăn len?! Nó không những mang màu của tui mà lại còn có kẹp thêm chiếc kẹp hình con dơi nữa! Quỳ à, tui không biết là bà có thể đan len ấy!
B1051: - Ông thấy sao?
B1052: - Đẹp, nó đẹp!
B1053: Leo liền quàng chiếc khăn lên cổ rồi lấy điện thoại ra chụp tự sướng. Tôi cá mười quả cam chút nữa ổng sẽ gửi cho người thương của ông ấy.
B1054: - Cảm ơn bà nha! Tui thích chiếc khăn này!
B1055: Cảm ơn tôi xong, Leo lấy từ trong chiếc túi không gian của ổng một chiếc khiên cổ bị rỉ sét và bám đầy rêu. Ổng tiến đến chỗ Shylvie rồi dúi chiếc khiên vào tay Shylvie.
B1056: Tiếp theo, Shylvie tặng cho Kohi một túi cà phê dát vàng thượng hạng ở chiều không gian của mình. Nhận lấy túi cà phê, Kohi cười híp cả mắt.
B1057: - Cảm ơn bố nhe!! Thấy bao bì bắt mắt thế này, hi vọng nó sẽ ngon!!
B1058: Sau khi nhận được món quà của Shylvie, Kohi luồn tay cất túi cà phê vô túi xách của mình, đồng thời lấy ra một hộp quà màu tím được đính nơ đỏ ở chính giữa. Ồ, thế có nghĩa Hakase sẽ là người tặng quà cho tôi sao!
B1059: Leo đánh mắt sang tôi.
B1060: - Giáng sinh vui vẻ nha Kohi!!
B1061: - Một chiếc khăn len?! Cảm ơn Quỳ nha!!
B1062: - Ừm! Chỉ là, tui hơi lo lắng một chút, cái khăn nó hơi…lủng lỗ…!
B1063: - Không sao đâu! Mới đan len mà đan được như này là ổn rồi mà!! Chưa kể là bà còn kẹp cả một chiếc kẹp hình hạt cà phê nữa!! Đáng yêu chết đi được!!
B1064: Kohi nhào đến ôm tôi. Tôi vòng tay ra sau lưng Kohi, ôm cô ấy thật chặt. Mùi của Kohi thơm thật đấy, thơm đến mức đánh bay cả sự lo âu của tôi.
B1065: Kohi quàng chiếc khăn mà tôi đan lên cổ. Cô ấy lấy từ trong túi xách của mình một chiếc hộp thiếc bóng loáng có vài đường vân được dát vàng sáng bóng cho bọn tôi chiêm ngưỡng rồi dúi nó vào tay Leo.
B1066: - Happy Birthday…Ý lộn! Merry Christmas! Giáng sinh vui vẻ nha Leo!!
B1067: - Ui, cái hộp nặng thật…! Bà làm tui tò mò quá!
B1068: - Mở ra xem đi Leo! Đảm bảo bất ngờ luôn!
B1069: Theo lời Kohi, Leo mở chiếc hộp thiếc ra. Bên trong chiếc hộp thiếc hình như có gắn đèn pha hay sao mà lúc Leo mở ra, mọi người đều bị lóa mắt. Quà mà Kohi tặng cho Leo là một chiếc kiếm cách có kiểu cách con dơi.
B1070: - Tui thấy ông dính với hình tượng con dơi mà kiếm cách của ông lại là hình tròn nên là tui tặng ông cái này cho nó đồng bộ!!
B1071: [ Sprite Leo hạnh phúc ]
B1072: - Kohi…Nó tuyệt vời lắm!! Tui thích nó!!
B1073: Leo phấn khích bởi món quà được tặng lắm, nhìn mặt ông ấy mà xem. Trông hồ hởi như một đứa trẻ lên ba! Ông ấy vui đến mức triệu hồi thanh kiếm ngay lập tức để thay kiếm cách của nó.
B1074: Ngầu bá cháy! Tôi nhìn mà mê luôn! Phải gọi là đẹp mê ly!
B1075: Bây giờ tới lượt Leo tặng quà. Tôi sẽ không đoán đâu vì đoán trước đâu còn gì hay nữa!
B1076: Leo đẩy hộp quà đến tay Hakase. Hakase ngạc nhiên, đưa mắt nhìn về phía Leo.
B1077: - Happy Merry...Ấy!!
B1078: [ Sprite Shylvie cười ]
B1079: - Thôi xong, Kohi lây Leo rồi!
B1080: [ Sprite Hakase cười ]
B1081: - Hahahaha! Mé rì chịt mệt nha Leo!!
B1082: Hakase mở gói quà ra. Là một chiếc áo choàng mới toanh nhưng lủng lỗ. Hả khoan, gì cơ?
B1083: - Khoan, sao nó lại lủng lỗ thế này?
B1084: - Bà không biết đâu, tui đắn đo mãi về vụ này đấy! Tui cứ nghĩ đi nghĩ lại rằng có nên khoét lỗ trên áo của ổng không! Vì tui tưởng tượng ổng mặc chiếc áo choàng mới toanh mà không có lỗ cứ thấy sai sai sao ấy….
B1085: - Nên là ông quyết định khoét luôn à…?
B1086: [ Sprite Leo ]
B1087: - Ừa!
B1088: - Mèn, đúng là vợ chồng son mà…
B1089: [ Sprite Hakase ]
B1090: - Ui Leo ơi! Tui thích nó! Nó hợp với tui phết!!
B1091: Trong lúc Leo đang kể lại câu chuyện khoét lỗ trên áo choàng cho mọi người nghe thì Hakase đã mau chóng choàng chiếc áo lên vai. Quả thật như lời Hakase nói, nó hợp với ổng cực kỳ!
B1092: Vậy người sẽ tặng quà cho tôi trong giáng sinh năm nay ắt hẳn là Shylvie rồi.
B1093: Hakase vui vẻ trao tay Shylvie một đôi bao tay mới màu hồng hình Hello Kitty trước vẻ mặt ngơ ngác tột độ của phù thủy khiên ngẫu nhiên.
B1094: [ Sprite Shylvie háo hức ]
B1095: - Ồ!! Bà định tặng tui món gì đó!
B1096: - Một chiếc khăn len?! Tui cảm ơn bà nhưng mà…Sao nó rách lỗ chỗ vậy…Bà có cầm nhầm giữa quà của tui với giẻ lau không…Tại tui không nghĩ là bà ghét tui đến vậy đâu nhỉ….?
B1097: Cái tên chết tiệt này…Dám chê quà của tôi sao?
B1098: [ Sprite Hải Quỳ chau mày ]
B1099: - Đâu có nhầm đâu! Trời đang lạnh đó Shylvie, để tui QUÀNG cho ha!
B1100: Tôi nhẹ nhàng nắm lấy cánh tay của Shylvie, bước một chân lên đằng trước. Tôi nhanh tay dùng chiếc khăn quấn mạnh vào cổ của Shylvie và vật cả người Shylvie xuống.
B1101: [ Sprite Shylvie xanh mặt ]
B1102: - Leo…C…Cứu….Ặc
B1103: [ Sprite Leo nhắm mắt đổ mồ hôi hột ]
B1104: - Chịu….Chịu rồi. Pha này tui không cứu được.
B1105: - Nói xin lỗi đi thì tui tha
B1106: - X…Xin lỗi…ặc…Thật sự xin lỗi mà…!
B1107: Nghe được lời xin lỗi chân thành, tôi buông tay. Shylvie nằm vật trên sàn thở hổn hển một lúc rồi mới ngồi dậy nổi.
B1108: Tôi quay sang nhìn mọi người. Mặt ai nấy đều xanh như tàu lá chuối.
B1109: Tôi biết Shylvie không có ý xấu nhưng câu nói của Shylvie vẫn khiến tôi buồn lòng.
B1110: Shylvie cất hộp quà của tôi vào túi của mình, đồng thời rút ra một túi cà phê dát vàng thượng hạng ở chiều không gian của mình. Nhận lấy túi cà phê, Kohi cười híp cả mắt.
B1111: Sau khi nhận được món quà của Shylvie, Kohi luồn tay cất túi cà phê vô túi xách của mình, đồng thời lấy ra một hộp quà màu tím được đính nơ đỏ ở chính giữa. Ồ, để tôi đoán! Dựa trên màu giấy gói này…Người tiếp theo được tặng là Hakase!
B1112: Hakase hứng khởi cài cây bút bằng vàng vào quyển ghi chú trong túi áo của ổng. Rồi ổng vỗ tay, một chiếc kệ gỗ bóng loáng bỗng dưng xuất hiện từ không trung. Nhìn vào hình dáng của chiếc kệ, tôi đoán nó là kệ đựng vũ khí.
B1113: - Leo! Chiếc kệ gỗ này tớ dành tặng cậu!!
B1114: - Thật á?! Chiếc kệ đẹp thế!!!
B1115: - Đúng vậy! Đẹp mà đúng không! Nên là ông nhớ trưng bày mấy thanh kiếm không dùng tới lên đây đi chứ đừng vứt xó trong góc phòng nữa!
B1116: - Ừa ừa!! Cảm ơn ông nha Hakase!! Món quà tuyệt vời lắm!!
B1117: Hakase nhẹ nhàng kéo một cái, giấy gói quà của tôi rách thành trăm mảnh bay xuống nền nhà như pháo giấy. Hakase cầm chiếc khăn lên trước mặt săm soi một hồi lâu rồi quay sang hỏi tôi.
B1118: - Nhí nhí, cho tớ hỏi là sao cậu lại tặng tớ món này thế?
B1119: [ Hải Quỳ mặt đổ mồ hôi hột ]
B1120: - À thì…
B1121: Tôi đâu có thể nào nói là tôi tạt ngang qua nhà ông ấy và thấy hết mọi thứ xong sợ ổng bị cảm nên là mới tặng khăn được. Ôi, tôi muốn nói thẳng ra quá nhưng mà nói hết ra rồi mọi người sẽ nhìn tôi bằng ánh mắt kỳ lạ mất.
B1122: Họ sẽ phát hiện ra tối nào tôi cũng tạt ngang qua nhà của họ để kiểm tra. Không, tôi không phải loại theo dõi người khác đáng khinh bỉ đó! Tôi chỉ là lo lắng quá đà trước sự xâm nhập ngày một gia tăng của Quái Vật Vực Sâu thôi!
B1123: [ Hải Quỳ vui vẻ ]
B1124: - Em muốn tặng anh món quà nào đó thật ý nghĩa. Và em nghĩ rằng nếu tự tay làm thì sẽ…cực kỳ ý nghĩa luôn….Ahahaha…
B1125: Ba người còn lại chớp chớp mắt nhìn vô chiếc khăn mà Hakase đang cầm rồi quay lại nhìn tôi. Ủa gì vậy?! Câu trả lời chan chứa tình yêu thương thế mà!! Đừng nhìn tôi bằng ánh mắt phán xét đó chứ!
B1126: Nói dứt lời, Hakase quấn chiếc khăn đó lên cổ tay của ổng. Hakase vung nhẹ cổ tay qua lại nhằm khoe chiếc khăn hợp với nước da của ổng như thế nào.
B1127: [ Sprite Hakase giơ tay lên khoe khăn ]
B1128: - Mọi người xem nè, hợp không!! Tớ thấy hợp quá trời!!
B1129: [ Hải Quỳ khó hiểu ]
B1130: - Hakase…Sao anh lại quấn ở đấy?
B1131: - Ừ tôi cũng đang tính hỏi. Nó là khăn choàng mà, nhỉ?
B1132: - Ơ, tớ tưởng khăn choàng len được quấn lên cho ấm mà? Thì cổ tay tớ đang lạnh! Quấn vô ấm hơn hẳn luôn đó mọi người!
B1133: [ Sprite Leo + Quỳ + Kohi ngạc nhiên ]
B1134: - Khoan đã, sao cổ tay ông lại lạnh cơ?
B1135: - À, xem nè!!
B1136: [ Sprite Hakase giơ tay khoe khăn thẳng vai ]
B1137: Hakase duỗi thẳng tay ngang bằng vai, môi mấp máy gì đó. Một chùm tia năng lượng ngay lập tức dồn vào cổ tay của ông ấy khiến cho chiếc khăn len mà tôi đan bị hóa băng.
B1138: [ Sprite Shylvie mắt sang rực ]
B1139: - ÔI VÃI!! Ông làm chủ được phép này rồi à!?
B1140: - Ghê chưa ghê chưa Shylvie!!
B1141: - Ghê chứ sao không! Tôi mới dạy ông tuần trước mà!!
B1142: Một hồi sau khi khoe chán chê cho Shylvie xem thành quả luyện tập của mình, Hakase chợt nhớ ra mình là người phải tặng quà cho người tiếp theo. Rồi ổng vỗ tay, một chiếc kệ gỗ bóng loáng bỗng dưng xuất hiện từ không trung. Nhìn vào hình dáng của chiếc kệ, tôi đoán nó là kệ đựng vũ khí.
B1143: Shylvie cất hộp quà của Leo vào túi của mình, đồng thời rút ra một túi cà phê dát vàng thượng hạng ở chiều không gian của mình. Nhận lấy túi cà phê, Kohi cười híp cả mắt.
B1144: Sau khi nhận được món quà của Shylvie, Kohi luồn tay cất túi cà phê vô túi xách của mình, đồng thời lấy ra một hộp quà màu xanh được đính nơ đỏ ở chính giữa. Ồ, để tôi đoán! Dựa trên màu giấy gói này…Người tiếp theo được tặng là tôi! Đương nhiên rồi!!
B1145: - Sai rồi! Là Gundam RG 78-EX!
B1146: Hakase đập tay một cái, nguyên hộp mô hình Gundam to chà bá lửa rơi xuống đầu tôi.
B1147: - Ấy!! Tớ xin lỗi!! Cậu có đau không!
B1148: - Không….Nó…đáng…hự…
B1149: Hôm nay là ngày gì vậy nè! Đây là lần thứ ba tui bị rơi trúng đầu rồi đó!
B1150: Hộp Gundam RG 78-EX này dài hơn cả vai tôi! Nó cao gần bằng tôi luôn!! Tôi mở nó ra xem hình dạng các gói lắp ráp và phụ kiện trông như thế nào. Tôi suýt nữa lăn ra ngất ngay tại chỗ. Quá trời gói và phụ kiện, kiểu này có khi tôi phải lắp vài tháng mới xong mất!!
B1151: - Bà cố tình đoán sai đúng không? Đoán trật là không tặng đâu!
B1152: - Ủa mắc gì!! Thôi được rồi, [ Sprite Hải Quỳ mắt sáng rực ]  là máy ép nước cam MK25 thế hệ R34?
B1153: - Bingo!
B1154: Shylvie lôi từ chiếc túi không gian của Shylvie một chiếc máy ép cam tân tiến. Tôi chạy qua chạy lại để ngắm nhìn kiểu dáng của chiếc máy, táy máy mở từng bộ phận để kiểm tra kỹ lưỡng.
B1155: - Ha, Kohi! Bà đưa tiền đây!
B1156: - Hả? Hai người cá cược gì đấy?
B1157: - Shylvie và tui đã cá với nhau là bà sẽ phản ứng như thế nào khi được tặng cái máy.
B1158: - Ơ thế Kohi nghĩ tui sẽ phản ứng như thế nào?
B1159: - Tui đã nghĩ bà sẽ liếm láp nó cơ…
B1160: - Thì tui đang liếm nó mà. Bằng xúc tu của tui.
B1161: - Ha, Shylvie! Đưa tiền đây!
B1162: Cả nhóm cùng nhau cười rộn rã. Tôi biết Kohi với Shylvie hay cá cược với nhau nhưng không ngờ rằng hai người họ lại dùng tôi để cá cược đấy.
B1163: Kohi tặng tôi một chiếc đầm xòe nhiều lớp được may bằng vải voan có màu bạc hà. Ôi! Hạnh phúc quá! Nó là chiếc đầm xòe nhiều lớp mà tôi vô tình đọc được trong cuốn sổ thiết kế trang phục của Kohi đó!! Tôi nhớ rõ hôm đó tôi dành rất nhiều lời khen cho bản thiết kế đấy xong còn nói vu vơ rằng nếu Kohi may thì tôi chắc chắn sẽ mặc nó.
B1164: Và Kohi may thật!!
B1165: - Nhớ về sớm đấy nhé!
B1166: - Không là mọi người ăn hết kem đó!!
B1167: HẾT CẢNH 12 – KẾT THÚC GAME
B1168: [ Hộp lựa chọn hiện ra – Hải Quỳ chọn mua Máy pha cà phê ]
B1169: Máy pha cà phê là lựa chọn không tồi! Vì cả văn phòng ai ít nhiều gì cũng uống cà phê!
B1170: Kịch bản Wonder Christmas Fiesta Route mua máy pha cà phê
B1171: Máy pha cà phê là món quà ổn áp ấy chứ nhỉ? Vì cả văn phòng Wanderer ai cũng thích uống cà phê hết. Thành ra là bây giờ tôi không biết nên tặng cho ai. Tặng cho Kohi là điều đầu tiên mà tôi nghĩ tới vì Kohi là Quỷ cà phê, không những thế bà ấy thực sự nghiện uống cà phê. Tiếp đến là Shylvie, Shylvie lắm hôm cũng hay thức khuya nên tần suất uống cà phê cũng nhiều. Kế đến là Leo và Hakase, tuy hai người này uống cà phê ít hơn hai người kia nhưng mà mỗi lần họ uống thì toàn uống một lít.
B1172: Sao càng nói càng thấy văn phòng này đang có vấn đề với cà phê vậy nhỉ?
B1173: Đương nhiên là phải loại trừ tôi ra rồi.
B1174: Vì tôi uống sữa nhiều hơn cà phê, haha.
B1175: Quả đúng là con nít! Tự hào quá đi!
B1176: Tôi tí ta tí tởn đi đến khu vực mua máy pha cà phê.
B1177: [ Nếu check tin nhắn của Momo trước khi tắt điện thoại ]
B1178: Nè con nhãi kia, nay dư giả quá ha, mua hẳn máy pha cà phê làm quà! [ Q2 ]
B1179: Chứ sao nữa! Quỹ đen tích góp bấy lâu nay mà lị! [ Q1 ]
B1180: Vậy thì mua máy nào tốt tốt một chút, loại mà pha được cả cà phê Atlantis ấy.  [ Q2 ]
B1181: Ừa, tui cũng đang tính tặng kèm cả cà phê Atlantis cho Leo luôn!  [ Q1 ]
B1182: Ờm, ta không nghĩ đó là ý hay… [ Q2 ]
B1183: Cà phê Atlantis uống ngon bỏ xừ! Leo chắc chắn sẽ thích nó thôi! [ Q1 ]
B1184: Tôi dòm lên kệ trước mặt tôi một hồi lâu rồi quyết định với tay lên lấy chiếc máy pha cà phê màu trắng đen bóng loáng.
B1185: [ Nếu không check tin nhắn của Momo trước khi tắt điện thoại ]
B1186: Mà Leo hắn uống cà phê à? Ta tưởng hắn thích uống sting hơn chứ? Có khi ngươi nên mua máy làm kem đá bào cho hắn thì hợp lý hơn. [ Q2 ]
B1187: Ai bảo Leo không uống cà phê! Mỗi lần Leo uống là uống cả cái ca một lít đó! Leo còn buồn vì cà phê ở đây không giống vị ở Luminus nên đang tìm máy phù hợp để pha cà phê quê nhà ổng kìa. [ Q1 ]
B1188: Ghê vậy sao? [ Q2 ]
B1189: Ghê chứ sao! [ Q1 ]
B1190: Tôi tí ta tí tởn đi đến khu vực mua máy pha cà phê
B1191: Chứ sao nữa! Kohi siêu siêu thích cà phê luôn mà! Đây là món quà quá phù hợp luôn![ Q1 ]
B1192: Ồ, sao biết tui đang tính tặng Kohi cà phê Atlantis vậy? [ Q1 ]
B1193: Chứ sao nữa! Kohi siêu siêu thích cà phê luôn mà! Đây là món quà quá phù hợp luôn [ Q1 ]
B1194: À ừ suýt thì quên mất. Phải rồi ha, bả là Quỷ cà phê mà.[ Q2 ]
B1195: Tiếc là bọn mình không tặng được cho bà ấy cà phê Atlantis ha! Cà phê Atlantis ngon bỏ xừ luôn! [ Q1 ]
B1196: Tiếc ghê ha! [ Q2 ]
B1197: Tiếc chứ sao! [ Q1 ]
B1198: Tôi bực mình đi đến khu vực mua máy pha cà phê.
B1199: À, vậy thì nhớ tặng kèm cà phê Atlantis cho nó đi.[ Q2 ]
B1200: À, hóa ra ngươi là người tốt, phải rồi ha.Q2 ]
B1201: Ôi thôi đừng chọc, quạo á. [ Q1 ]
B1202: Ngươi tính tặng máy pha cà phê cho tên ma vương đáng gờm đó à? [ Q2 ]
B1203: Ta không hiểu. Thay vì tặng hắn một quyển sách ma thuật thì ngươi tặng hắn một chiếc máy pha cà phê à? Để làm gì? [ Q2 ]
B1204: Có mấy hôm khuya khoắt vô tình tạt ngang qua nhà ổng thì thấy ổng đang luyện tập bắn tia năng lượng hăng say lắm. Mà trời dạo này trở lạnh, dễ buồn ngủ nữa. Mua cho ổng máy pha cà phê để ổng uống cho đỡ buồn ngủ chứ sao![ Q1 ]
B1205: Chịu. Không hiểu gì hết. À đúng rồi, nhớ tặng kèm cà phê Atlantis đấy. [ Q2 ]
B1206: Có chắc là ổng uống cà phê không vậy… [ Q2 ]
B1207: Hai mắt tôi mở tháo láo.
B1208: Bây giờ là gần hai giờ sáng rồi. Tôi không tài nào ngủ được.
B1209: Mặc dù còn vài ngày nữa mới tới buổi tiệc giáng sinh nhưng không biết vì sao mà tôi cứ có cảm giác là bữa tiệc sẽ diễn ra vào ngày mai. Và điều đó khiến tim tôi đập thình thịch, tạo cảm giác lo lắng tột độ.
B1210: Tôi không gói máy pha cà phê bằng giấy gói quà mà chỉ buộc vài chiếc nơ đỏ xunh quanh thành máy. Không biết như vậy có ổn không ta?
B1211: [ Đoạn này không hiện sprite ]
B1212: Nửa bên kia của tôi ơi, còn thức không ! [ Q1 ]
B1213: Tui cảm thấy hơi bất an một chút…Không biết Leo có thích món quà này không…. [ Q1 ]
B1214: Leo sẽ thích thôi, lo lắng chi vậy trời. Giờ thì ngủ dùm cái đi! [ Q2 ]
B1215: Thiệt không?! [ Q1 ]
B1216: Phiền quá đừng hỏi nữa! [ Q2 ]
B1217: Aira không thân thiện tí nào hết! [ Q1 ]
B1218: Thân thiện gì với cái đứa nhiều chuyện như ngươi. Ngươi cứ lo lắng dư thừa, Leo vốn là một người dễ tính, ngươi tặng món gì mà hắn chả thích, mắc gì phải lo?
B1219: Nhưng…
B1220: Không nhưng nhị gì hết! Đi ngủ!
B1221: Aira lấy xúc tu bịt mắt và miệng của tôi lại, cố ép tôi đi ngủ bằng vũ lực.
B1222: Nhớ…đánh thức…bọn mình dậy…trước giáng sinh nha…Aira…
B1223: Tui cảm thấy hơi bất an một chút…Không biết Kohi có thích món quà này không…. [ Q1 ]
B1224: Kiểu gì Kohi chả thích. Giờ thì ngủ dùm cái đi! [ Q2 ]
B1225: Thân thiện gì với cái đứa nhiều chuyện như ngươi. Ngươi cứ lo lắng dư thừa, Kohi lại chẳng thích máy pha cà phê bỏ xừ ra, mắc gì phải lo?
B1226: Tui cảm thấy hơi bất an một chút…Không biết Shylvie có thích món quà này không…. [ Q1 ]
B1227: Shylvie sẽ thích thôi, lo lắng chi vậy trời. Giờ thì ngủ dùm cái đi! [ Q2 ]
B1228: Thân thiện gì với cái đứa nhiều chuyện như ngươi. Ngươi cứ lo lắng dư thừa, Shylvie vốn là một đứa thích cà phê mà, nhiễu sự ghê.
B1229: Tôi không gói máy pha cà phê bằng giấy gói quà mà chỉ buộc vài chiếc nơ đỏ xung quanh thành máy. Không biết như vậy có ổn không ta?
B1230: Tui cảm thấy hơi bất an một chút…Không biết Hakase có thích món quà này không…. [ Q1 ]
B1231: Hakase sẽ thích thôi, lo lắng chi vậy trời. Giờ thì ngủ dùm cái đi! [ Q2 ]
B1232: Thân thiện gì với cái đứa nhiều chuyện như ngươi. Ngươi cứ lo lắng dư thừa, Hakase vốn là một kẻ tò mò, ngươi tặng cái quái gì mà hắn chả khoái.
B1233: Tôi tính đứng lên để tặng chiếc máy pha cà phê cho Leo thì chợt nhận ra tôi để quên nó ở nhà…
B1234: Haizz, đúng là không có tôi thì Dahria là một con mắm hay quên nhỉ.
B1235: Tôi cởi mũ len của mình xuống, thò tay vào nó trước bốn cặp mắt ngỡ ngàng. Tôi moi moi một lúc, cuối cùng cũng lôi được chiếc máy pha cà phê mà con nhỏ Dahria để quên ở nhà.
B1236: - Giáng sinh an lành Leo! Tui hi vọng ông thích chiếc máy pha cà phê này!
B1237: - Uầy!! Bà dùng được phép dịch chuyển rồi hả?!
B1238: - Ngạc nhiên sai thứ rồi!! Ông phải ngạc nhiên vì chiếc máy pha cà phê này chứ!
B1239: - À ừ thì đương nhiên rồi! Cảm ơn bà nha!!!
B1240: Leo nhận chiếc máy pha cà phê từ tay tôi rồi lon ton lon ton cất nó vào trong bếp. Tôi thấy Leo lấy điện thoại ra chụp tự sướng cùng chiếc máy pha cà phê. Tôi cá mười quả cam chút nữa ổng sẽ gửi cho người thương của ông ấy.
B1241: - Món quà tuyệt vời lắm Quỳ!!
B1242: - Phải như vậy chứ! Tui thậm chí còn tặng cho ông đặc sản quê tui, cà phê Atlantis siêu hảo hạng luôn!!
B1243: - Ồ!! Bà chu đáo quá! Cà phê siêu hảo hạng luôn!! Không biết mùi vị như thế nào nhỉ?!
B1244: [ Sprite Kohi sáng mắt ]
B1245: Leo!! Nó ngon lắm đó!! Hôm bữa tui uống ké của Quỳ rồi, ngon xĩu luôn!!
B1246: Thiệt hả?!
B1247: - MỘT CHIẾC MÁY PHA CÀ PHÊ?! UI!! THÍCH THẾ!!
B1248: - Hehe!! Bà thích là tui vui rồi!!
B1249: - Đấy thấy chưa Kohi, tôi đã nói là bà ấy nhìn thấy trước tương lai rồi mà.
B1250: - Hả? Vụ gì đấy?
B1251: - À, tuần trước tui với Shylvie có cược với nhau rằng bà sẽ mua máy pha cà phê tặng tui ấy mà.
B1252: - À…Thế là mấy người đem tui ra để cá cược với nhau hả??
B1253: - Không không, không hẳn là thế! Tui muốn kiểm chứng vụ đấy thôi!!
B1254: - Vụ…tui nhìn thấy trước tương lai?
B1255: - Ừm hứm! Shylvie thậm chí còn bảo rằng bà có thể tác động cả thực tại cơ.
B1256: -Ừ, chuyện là vậy đó.
B1257: [ Sprite Kohi vui vẻ nói ]
B1258: -Mà bỏ qua vụ đó đi! Quan trọng là….
B1259: [ Sprite Hải Quỳ vui vẻ nói ]
B1260: -À…Thế thì không một ai thắng cược hết!
B1261: [ Sprite Shylvie + Kohi ]
B1262: -HẢ? Tại sao?
B1263: - Tại vì ngoài máy pha cà phê ra tui còn tặng cả cà phê Atlantis cơ!
B1264: -Ồ! Tui có nghe về nó rồi!! Là loại cà phê hiếm có khó tìm, được trồng trên các tảng san hô núi lửa ở rãnh Marianna không?
B1265: - Đúng đúng! Nhưng còn điều này bà chưa biết…! Để cho ra được cà phê Atlantis, bắt buộc phải có sự tiêu hóa của tôm tích núi lửa nữa!
B1266: - Là sao á?
B1267: - Là tôm tích núi lửa phải ăn! Nó giống cà phê chồn ấy!
B1268: - Ồ!! Ra là vậy!!
B1269: Nó gần giống cà phê chồn. Ngoại trừ việc một số con tôm sau khi ăn cà phê sẽ bị nổ banh xác. Vì cà phê Atlantis đa phần là các loại có độc tính mạnh, để xác định được chỗ cà phê nào uống được thì phải quan sát tôm núi lửa.
B1270: Chỗ trồng cà phê nào mà có nhiều xác tôm núi lửa banh xác thì chỗ cà phê đó không uống được.
B1271: Ngược lại, chỗ nào mà bọn tôm núi lửa ăn xong mà phát ra màu ánh kim, chỗ cà phê đó không những uống được mà còn là loại ngon nhất nữa!
B1272: Mặc dù đã tìm cách để nhân giống loại trừ các loại có độc tính mạnh nhưng độc tính của cà phê Atlantis vẫn không giảm.
B1273: -Cảm ơn bà nhiều nhiều lắm Quỳ! Món quà tuyệt vời ông mặt trời!
B1274: Kohi cất chiếc máy pha cà phê vào trong bếp. Cô ấy lấy từ trong túi xách của mình một chiếc hộp thiếc bóng loáng có vài đường vân được dát vàng sáng bóng cho bọn tôi chiêm ngưỡng rồi dúi nó vào tay Leo.
B1275: Tôi tính đứng lên để tặng chiếc máy pha cà phê cho Shylvie thì chợt nhận ra tôi để quên nó ở nhà…
B1276: - Giáng sinh an lành Shi-ru-vi! Tui hi vọng ông thích chiếc máy pha cà phê này!
B1277: - WOW! Từ khi nào bà xài được phép dịch chuyển vậy?
B1278: - Từ hôm nay. Thấy sao hả Shylvie? Về cái máy pha cà phê ấy?
B1279: - Ồ, đương nhiên là tui thích nó rồi!
B1280: - Phải thích chứ ha! Tui còn tặng kèm cả cà phê Atlantis đắt tiền cho ông đấy!
B1281: - Trời!! Trùng hợp thế!!
B1282: - Hả? Trùng hợp gì?
B1283: - Thì đây…!
B1284: Shylvie cất chiếc máy pha cà phê mà tôi tặng thật cẩn thận vào túi của mình, đồng thời rút ra một túi cà phê dát vàng thượng hạng ở chiều không gian của mình. Nhận lấy túi cà phê, Kohi cười híp cả mắt.
B1285: - Tại nay tui cũng tặng cà phê cho Kohi á.
B1286: - Chắc chắn sẽ ngon rồi!
B1287: Tôi tính đứng lên để tặng chiếc máy pha cà phê cho Hakase thì chợt nhận ra tôi để quên nó ở nhà…
B1288: [ Sprite Hải Quỳ giáng sinh vui vẻ ]
B1289: Nếu là Dahria thì nó sẽ lo lắng đến mức bị loạn ngôn, khiến cho ai nấy đều phải bật cười nhỉ.
B1290: - Cảm ơn Hải Quỳ nha!! Nó là gì đó!!
B1291: - Là máy pha cà phê đó!!
B1292: - À, em chỉ nghĩ đơn giản là Hakase sẽ cần máy pha cà phê nên là em mua thôi! Ừm, là vậy đó! Dù sao thì mấy nay Hakase cũng làm việc cật lực mà ha! Kiểu gì cũng dễ bị buồn ngủ nên là mua máy pha cà phê là hợp lý nhỉ!
B1293: Nói dứt lời, Hakase vỗ tay làm cho chiếc máy pha cà phê mà tôi đang ôm khư khư trong tay dịch chuyển lên bàn bếp. Rồi Hakase búng tay, một chiếc kệ gỗ bóng loáng bỗng dưng xuất hiện từ không trung. Nhìn vào hình dáng của chiếc kệ, tôi đoán nó là kệ đựng vũ khí.
B1294: LEO
B1295: Rìa lỗ hổng 61 là khu vực cực kỳ hỗn loạn. Tuy vậy tôi vẫn dễ dàng giải cứu hết các thành viên Silver Wing bị bắt nhốt tại đấy trong tích tắc và không chần chừ tạo một kết giới để phong tỏa toàn bộ quái vật rồi cho nổ tanh bành mọi thứ.
B1296: May cho mấy đứa bên Silver Wing vì TÔI là người đã cứu chúng nó, chứ nếu mà để Dahria làm thì có khi giờ này chúng nó đi chầu ông bà rồi.
B1297: [ BG Văn phòng Wanderer ]
B1298: Sáng hôm sau, tôi dịch chuyển về văn phòng Wanderer để ăn kem. Mở tủ lạnh ra, cả một núi kem Socola đè vào người tôi.
B1299: Ơ? Quỳ đấy à?! Bà về hồi nào đấy…
B1300: [ Sprite Hải Quỳ đồ văn phòng vui vẻ ]
B1301: Mới…Mới về….Nay Leo dậy sớm thế….
B1302: À, tui đang pha cà phê ấy mà!
B1303: Leo đỡ tôi ngồi lên ghế. Cầm hộp kem Socola chà bá trong tay, tôi vừa ăn vừa nhìn Leo pha cà phê bằng chiếc máy mà tôi tặng ông ấy ngày hôm qua. Mùi cà phê này thơm quá mà lạ nữa, hình như không phải loại cà phê ở thế giới này. Nó có mùi gì đấy giống giống mùi bạc hà, một chút khét của nhựa đường và vị chát của vôi.
B1304: Leo pha một cốc đầy và san ra làm hai cốc nhỏ, một cốc cho tôi và một cốc cho ông ấy.
B1305: Ừm, ngon phết.
B1306: [ Sprite Leo + Hải Quỳ ]
B1307: À, bà có thể đổ thêm Sting vào để gia tăng vị ngọt đó.
B1308: Hả…Ai lại cho Sting vào cà phê cơ…
B1309: A!! Leo pha lén cà phê mà không rủ tớ!!
B1310: Tiếng Kohi vọng ra từ trong phòng họp. Tức tốc, Kohi phi ra bếp với vận tốc âm thanh với vẻ mặt háo hức.
B1311: Ừm hưm! Là cà phê Luminous trứ danh đó sao!! Cho tui một ly, cho tui một ly!!
B1312: Ok! Chờ xíu!!
B1313: Leo múc một muỗng bột cà phê từ trong hũ cho vào máy pha cà phê. Nhưng không biết vì lý do nào đó mà đã hơn 10 phút rồi mà chưa thấy giọt cà phê nào nhỏ xuống cốc. Không những thế lại còn có mùi khét bốc ra từ trong máy.
B1314: Và rồi cái máy pha cà phê bốc cháy. Leo hoảng hốt chạy đi lấy bình cứu hỏa để ở góc bếp ra xịt tùm lum.
B1315: Ừm, cà phê đổ thêm Sting uống cũng ngon phết.
B1316: KOHI
B1317: Sáng hôm sau, tôi dịch chuyển về văn phòng Wanderer để ăn kem. Vừa bước vào bếp, tôi đã ngửi thấy mùi cà phê nồng nàn. Tôi quay qua nhìn khu vực bếp thì thấy Kohi đang nhìn tôi, tay cầm một cốc cà phê nóng hôi hổi, còn bàn bếp thì chất đầy cốc cà phê sử dụng một lần.
B1318: -Ơ Quỳ, bà về sớm thế! Uống cà phê không?
B1319: - Uống chứ. Bà pha loại nào đó?
B1320: - À, cái loại của Leo ấy. Loại này khá là đặc biệt nha. Của bà đây.
B1321: Tôi nếm thử. Ừa, đúng là ngon thật. Mùi cà phê này thơm quá mà lạ nữa, hình như không phải loại cà phê ở thế giới này. Nó có mùi gì đấy giống giống mùi bạc hà, một chút khét của nhựa đường và vị chát của vôi.
B1322: -Ừ, ngon ghê.
B1323: - Phải ha!!
B1324: - Bảo sao bà uống tận hơn ba mươi ly.
B1325: - Ồ, nó đặc biệt ở chỗ đó đó Quỳ! Một muỗng cà phê Luminous mà pha hơn tận ba chục ly mà vẫn đậm đặc. Thần kỳ thật ha!
B1326: - Ừa, bảo sao đợt lâu rồi Leo mượn phin pha cà phê của tui tận một tháng mà không trả.
B1327: Cứ thế, hai đứa bọn tôi vừa ngồi uống cà phê, vừa trò chuyện, vừa ngắm nhìn bầu trời buổi sáng.
B1328: Sáng hôm sau, tôi dịch chuyển về văn phòng Wanderer để ăn kem. Tôi chưa kịp mở tủ thì đã nghe thấy tiếng hét thất thanh của Shylvie từ trong phòng Kohi. Không những tôi mà Hakase và Leo đều tức tốc chạy vào kiểm tra.
B1329: [ Sprite Leo + Hakase + Quỳ đồ văn phòng Silver Wing lo lắng ]
B1330: -Chuyện gì vậy Shylvie?!
B1331: -K-Kohi! Bà ấy không còn thở nữa!!
B1332: Hakase lập tức triệu hồi một vòng tròn ma pháp loại y tế để kiểm tra cấp tốc cho Kohi.
B1333: [ Sprite Hakase nói chuyện ]
B1334: -Bà ấy đang ngủ nhưng hơi thở yếu như người sắp chết ấy…
B1335: - Vậy chúng ta phải làm sao?!
B1336: - Không làm gì cả, cứ để bà ấy ngủ thôi.
B1337: - Điên à? Chả phải ông bảo bà ấy sắp chết sao?
B1338: - Không chết được, yên tâm. Kiểu này cỡ 2-3 ngày sau là dậy ấy mà.
B1339: - Chết thật! Thôi thì để bà ấy ngủ bù cho tuần vừa rồi làm việc cật lực vậy!
B1340: Leo kéo cả bọn ra ngoài để Kohi nghỉ ngơi. Hakase kéo tôi riêng ra một góc để hỏi chuyện.
B1341: -Nè, cà phê Atlantis thực sự khiến người khác mất ngủ vậy hả?
B1342: - Cái này mới gặp lần đầu luôn…Đừng nói là anh uống rồi nha?
B1343: - À thì…sáng nay Kohi có mời một cốc…
B1344: - Chắc là không sao đâu ha…?
B1345: Ba ngày sau, Kohi lảo đảo bước ra khỏi phòng trước sự ngỡ ngàng đến vỡ òa của mọi người, nhất là Shylvie. Kohi bảo rằng đây là giấc ngủ ngon nhất từ trước đến giờ của bà ấy nên chắc bà ấy sẽ chuyển sang uống cà phê Atlantis một thời gian.
B1346: Tôi với Hakase đã ba ngày không ngủ. Đến giờ Hakase vẫn chưa ngủ được.
B1347: SHYLVIE
B1348: Từ hôm tôi tặng máy pha cà phê cho Shylvie đã hơn một tuần. Tần suất uống cà phê của Shylvie từ đó tỷ lệ thuận với bọng mắt của Shylvie, chúng bắt đầu tăng lên. Hỏi ra thì mới biết, Kohi vì không muốn Shylvie thức khuya làm việc nên đã nhất quyết không cho Shylvie mượn máy pha cà phê của bà ấy, thế nên việc tôi tặng máy pha cà phê cho Shylvie không khác gì tiếp giáo cho giặc.
B1349: Chà, biết vậy tặng Shylvie cà phê Atlantis cho Shylvie mất ngủ chơi, keke.
B1350: Hai tuần sau, tôi cúp việc để đến văn phòng Wanderer ăn tối cùng với mọi người.
B1351: [ Sprite Shylvie mắt đỏ hoe ]
B1352: Q…Quỳ…Bà đến rồi hả?
B1353: [ Sprite Hải Quỳ đồ thường vui vẻ ]
B1354: Shylvie sao vậy?
B1355: Giọng điệu này…bà…Bà chơi xỏ tôi…
B1356: Cà phê Atlantis ngon không?
B1357: Haiz…" ngon " quá trời luôn…
B1358: [ Sprite Hải Quỳ đồ thường mắt Bully Quỳ nhoẻn miệng cười ]
B1359: Ồ, đương nhiên rồi, keke. Hàng xịn mà lị.
B1360: Ừ, xịn đến mức mất ngủ hai tuần luôn. Tui không tài nào ngủ được…
B1361: Trời trời, khổ thân chưa!!
B1362: Bữa tối diễn ra vui vẻ. Vì để Shylvie hết bị mất ngủ, tôi đã nói với Hakase rằng Shylvie đang bị bệnh nên cần ông ấy nấu cháo. Nhờ có tô cháo đặc biệt của Hakase, Shylvie đã nôn bán sống bán chết và rồi ngủ một mạch tận ba ngày. Do đó, chứng mất ngủ của Shylvie đã được chữa khỏi.
B1363: HAKASE
B1364: Mới…Mới về….Ơ, nay mọi người dậy sớm thế…
B1365: À, Hakase bảo là sẽ pha cà phê cho mọi người uống sáng nay nên là mọi người thấy tò mò thôi….Nhỉ…
B1366: [ Sprite Leo xanh mặt ]
B1367: Leo quay qua nhìn Shylvie và Kohi, hai người họ gật đầu lia lịa nhưng mặt thì xanh lắm.
B1368: [ Sprite Kohi + Shylvie xanh mặt ]
B1369: Vậy là mọi người uống rồi à? Cà phê ngon không?
B1370: Không một ai đáp lại lời của tôi, tất cả đều đá mắt sang Hakase, người đang loay hoay trong bếp.
B1371: Ơ! Quỳ!! Cậu về đúng lúc đấy!! Tớ có làm cà phê cho cậu này!!
B1372: Hả…Ừ, cảm ơn Hakase nha…
B1373: Ah, chết tiệt. Biết vậy về trễ cho rồi.
B1374: Đón lấy ly cà phê vào lòng bàn tay, chân mày tôi khẽ chau lại đôi chút. Tại sao trong ly cà phê này lại có cỏ vậy…? Lại còn có cả hạt của loại trái cây nào đó? Chất cà phê thì bùn lầy, sánh đặc. Hương thơm thì có chút mùi cháy của giấy báo, than chì.
B1375: Thôi xong, không ổn rồi.
B1376: [ Sprite Kohi + Leo + Shylvie mặt trắng bệch ]
B1377: Tôi quay qua nhìn ba người kia, họ đã bất tỉnh nhân sự. Thôi thì….ỰC ỰC ỰC.
B1378: Hừm, cà phê không tệ như tôi nghĩ? Nó khá là….HỰ…..Huệ….
B1379: Ơ?! Quỳ sao vậy?!
B1380: Không…Không có gì…
B1381: [ Sprite Hải Quỳ da nâu ]
B1382: Thiệt không? Thế sao da của cậu chuyển sang màu nâu vậy?
B1383: À…Hue…Ừm, mỗi lần em uống nước gì đó mà đậm đặc thì…hue….ực, da sẽ chuyển m…màu…
B1384: À!! Ra là thế!! Hiệu ứng hay thế!
B1385: Vài tiếng sau, Leo, Kohi và Shylvie đều nằm liệt giường. Tôi phải lấp liếm với Hakase rằng có lẽ tối qua mọi người ăn quá nhiều kem nên bị đau bụng.
B1386: Trời ơi, vậy trưa nay tớ sẽ đứng bếp nấu cháo cho mọi người ăn ha!
B1387: HAKASE ĐỪNG! E hèm, ý tớ là, để tớ nấu cháo cho..!
B1388: [ Hộp lựa chọn hiện ra – Hải Quỳ chọn đi đến văn phòng Wanderer]
B1389: Chắc ghé ngang văn phòng để thăm mọi người vậy. Tiện thể hỏi ý kiến họ xem nên đi đâu và mua gì.
B1390: - Phải thích chứ ha! Tui còn tặng kèm cả cà phê Atlantis đắt tiền cho bà đấy!
B1391: [Hộp lựa chọn hiện ra - Mua Mì Cay]
B1392: Tự dưng trong đầu mình nghĩ đến mì cay. Mà nghĩ đến mì cay thì lại nhớ tới Leo! Đây là tín hiệu sao?
B1393: Thôi thì năm vừa rồi tôi và các thành viên còn lại hành ổng dữ quá, giáng sinh năm nay đãi ổng một bữa mì cay thập cẩm siêu to khổng lồ mới được!! Cơ mà tôi không biết nấu mì cay….A PHẢI RỒI!
B1394: Cái phép thuật phân tích công thức món ăn hôm bữa Hakase chỉ tôi sẽ hữu dụng đây!
B1395: ĐẾN QUÁN MÌ CAY MÀ LEO YÊU THÍCH THÔI!
B1396: [ BG Quán Mì Cay. Sfx bước chân, dừng trước quầy  ]
B1397: Quán mì cay mà Leo yêu thích đây rồi.
B1398: Lúc ý tưởng lóe lên thì tôi hùng hổ lắm, xong lúc đến nơi mới nhớ ra rằng tôi không ăn được cay…
B1399: Trời ơi cái bộ óc lơ tơ mơ này!
B1400: Đừng chùn chân nữa, Dahlia! Mày…Mày ăn được cay! Mày sẽ ăn được cay!!
B1401: Chỉ là ớt thôi mà, hahahaha…Chắc là không cay đâu!
B1402: Trời ơi, nay chưa đủ nóng hay sao mà đi ăn đồ cay vậy gái? [ Q2 ]
B1403: Biết là vậy rồi…Nhưng mà không ăn thì không nấu được đâu!! [ Q1 ]
B1404: Hả gì? Nấu mì cay dễ mà! Ngươi cứ để ta nấu là được! [ Q2 ]
B1405: Hả gì? Aira biết nấu mì cay á? Tin tưởng được không đấy? [ Q1 ]
B1406: Phải thử mới biết được chứ. [ Q2 ]
B1407: [ Hộp lựa chọn hiện ra ]
B1408: [CHOICES] Tin tưởng | Có cái nịt
B1409: Tin tưởng
B1410: Tin tưởng Aira lần này đấy! [ Q1 ]
B1411: Vậy đi siêu thị mua nguyên vật liệu thôi. [ Q2 ]
B1412: [ Đoạn này là cutscene ở map siêu thị ]
B1413: Cùng với Aira, tôi mau chóng mua các nguyên vật liệu cần thiết để nấu một nồi mì cay được Aira đặt tên là “ dữ tợn “. Nào là hành baro, bắp cải, thịt gà, thịt bò, hải sản các loại, bột mì….Ơ sao lại có cả vi cá mập, đầu heo với lại mía, nhộng tằm thế này?
B1414: Có cái nịt
B1415: Có cái nịt! Lần nào để Aira làm hộ, đều xôi hỏng bỏng không hết! [ Q1 ]
B1416: Hứ, vậy thôi!!  [ Q2 ]
B1417: Tôi dồn hết dũng khí để bước đến quầy gọi món. Nhân viên niềm nở đưa cho tôi cuốn thực đơn. Đảo mắt một lúc, tôi quyết định gọi mang về tất cả mọi loại mì cay của quán, thu hút bao ánh nhìn ngỡ ngàng trong quán.
B1418: Không phải do tôi hướng nội hay gì, tôi chỉ đang muốn về nhà nằm ườn ra xem Anime và ăn mì cay thôi. Ngồi ăn ở quán bây giờ không phải là lựa chọn thích hợp. Chưa kể đến việc sử dụng phép thuật lên mì cay để phân tích công thức của nó, tốt nhất nên về nhà để dùng.
B1419: Nhân loại không nên biết quá nhiều về ma pháp.
B1420: Hoặc tôi bị lười.
B1421: Hoặc lưng tôi đau.
B1422: Lý do nào cũng hợp lý hết. Về nhà thôi!
B1423: Hải Quỳ: Là Leo
B1424: Leo: Bà chắc sẽ tặng tôi chưa?
B1425: Nè con nhãi kia, hình như chưa mua Sting [ Q2 ]
B1426: Hả gì? Từ khi nào muốn uống sting vậy? [ Q1 ]
B1427: Gì vậy má? Mua cho Leo mà!! Cái bình Sting 20 lít? Nhớ không? [ Q2 ]
B1428: À!! Nhớ rồi!! Để tui gọi họ gửi 5 thùng qua nhà mình cho tiện! [ Q1 ]
B1429: LƯỜI THÌ CÓ!!! [ Q2 ]
B1430: Lưng tôi dán chặt lên giường, không nhúc nhích nổi.
B1431: Aira có chắc là mình nấu được không đấy? [ Q1 ]
B1432: Trời, còn phải hỏi xác nhận lại à! Chả phải ngươi được ăn đồ ta nấu mấy lần rồi sao?  [ Q2 ]
B1433: Nhưng đâu phải mì cay đâu!! [ Q1 ]
B1434: Cứ đợi đến hôm giáng sinh đi, ta trổ tài cho xem. Giờ thì ngủ dùm cái! [ Q2 ]
B1435: Aira có phải mẹ tui đâu mà quản tui dữ vậy!! Tui muốn xem Anime cơ!! [ Q1 ]
B1436: Đi ngủ!! Tăng ca mấy tuần liền mà giờ đòi xem Anime hả! [ Q2 ]
B1437: Ngẫm lại cũng đúng. Mấy tuần rồi tôi tăng ca liên tục nên cũng chẳng mấy khi được nằm thẳng cẳng. Cơ mà vẫn khó ngủ! Cứ nghĩ đến việc Aira sẽ trêu trọc Leo trong bữa tiệc giáng sinh sắp tới, làm tôi không tài nào nhắm mắt được.
B1438: Cứ ngủ đi. [ Q2 ]
B1439: Có chắc là Aira không trêu Leo không đấy? [ Q1 ]
B1440: Ngươi còn hỏi nữa là ta trêu hắn thật đấy [ Q2 ]
B1441: Dưới sự thúc giục của Aira, tôi mau chóng chìm vào giấc ngủ.
B1442: Bên cạnh tôi là ba chiếc mâm xếp chồng lên nhau, mỗi mâm là năm tô mì cay. Tôi bật TV lên, nằm ườn xuống để cảm nhận sự thoải mái mà tôi đã mong chờ mấy tuần rồi. Ta nói nó đã gì đâu!
B1443: Nằm được một lúc, tôi ngồi dậy với tay lấy tô mì cay đầu tiên. Trước khi ăn, tôi dùng ma thuật điều chỉnh vị giác của chính mình và ma thuật phân tích công thức lên tô mì. Rồi tôi bật bộ Anime Ma Pháp Thiếu Nữ mới nhất, vừa xem vừa ăn.
B1444: Rồi nằm ngả lưng, uống nước cam, rồi lại ngồi dậy ăn tô tiếp theo.
B1445: Không được ngủ, đã viết xong công thức của tô mì thứ 6 và thứ 7 đâu!!
B1446: Xong tô mì thứ 9 rồi….! Hải sản ngon ghê…
B1447: Trời, phim hay ghê…! Đến giai đoạn cao trào của phim rồi!
B1448: Tô mì thứ 10….Bò Wagyu hả…
B1449: Oáp…
B1450: Aira ơi…Có gì…Gọi tớ dậy nhé….! Tớ chợp mắt một lát! [ Q1 ]
B1451: [ BG đen ]
B1452: BG đen trong giây lát rồi hiện lên BG phòng Hải Quỳ ]
B1453: - Nhanh cái chân lên! [ Q2 ]
B1454: Aira hét lớn, tôi lọ mọ đứng dậy, lảo đảo bước vào nhà vệ sinh.
B1455: Aira có thể chiếm quyền kiểm soát cơ thể của tôi nhưng đa phần bà ấy sẽ tự tạo một chiếc miệng đằng sau gáy để nói chuyện và biến tóc thành xúc tu để tương tác cùng lúc với tôi. Hoặc như bây giờ, Aira dùng 8 chiếc xúc tu vừa cõng tôi vừa đi lại trong nhà tôi trông chả khác gì con nhện.
B1456: -Ủa mà nguyên liệu đâu?
B1457: - Ta dịch chuyển chúng đến tủ lạnh văn phòng rồi, khỏi lo.
B1458: - Kể cả chai sting 20 lít á?
B1459: - Cả chai sting 20 lít.
B1460: Chết rồi !! Vỡ kế hoạch rồi !! Nửa bên kia của tôi ơi !! SAO KHÔNG GỌI TÔI DẬY?! Còn vài tiếng nữa là đến tiệc giáng sinh trong văn phòng rồi !!
B1461: Giờ này thì làm sao mà kịp bắt xe đến văn phòng được ?! Chìa khóa dịch chuyển đâu rồi… !! Nó nằm ở đâu vậy ?!
B1462: Mắt tôi vô tình hướng về phía giường, nơi đang có một chai Sting 20 lít nằm kế bên chiếc túi đi chợ đang đè lên một bộ trang phục cùng chìa khóa dịch chuyển và tờ công thức mì cay.
B1463: Tôi lật đật túm lấy mọi thứ, tròng bộ đồ vô người rồi cắm chìa khóa dịch chuyển.
B1464: Có ai đang dùng bếp không?
B1465: Không á! Bà cứ thoải mái dùng đi!
B1466: Tôi bước vào bếp, lôi hết nguyên liệu mà Aira đã dịch chuyển vào tủ lạnh. Trước khi để Aira nắm quyền kiểm soát cơ thể, tôi đã ra lệnh cho Sierra, AI của văn phòng, trang trí lại văn phòng giúp tôi.
B1467: Sierra! Trang trí hộ tôi văn phòng Wanderer theo chủ đề mùa đông mà cô thích đi!
B1468: Đã rõ!
B1469: Ối! Sierra!! Cậu làm gì thế?
B1470: Sierra!! Nhiều tuyết quá rồi!!
B1471: Trời. Nghe tội nghiệp dữ vậy bây?
B1472: Sierra, ngươi không cần dọn giúp chúng đâu, có gì để chúng tự dọn.
B1473: TỚI GIỜ BỔN CÔ NƯƠNG TA ĐÂY TRỔ TÀI RỒI!
B1474: [ Cutscene Animation nấu ăn của Bully Quỳ  ]
B1475: Hoàn thành rồi! Đây sẽ là món mì cay duy nhất mà Leo sẽ nhung nhớ mãi!! Giờ thì dùng Flamescion Cluster để giữ nóng cái nồi này lâu hơn thôi. Và…switch!
B1476: Tôi vừa bước ra khỏi bếp, chưa kịp nói xong câu thì một đống tuyết nặng trịch đổ ầm xuống đầu tôi. Cả cơ thể của tôi bị chôn vùi trong tuyết, cố gắng lắm tôi mới ngoi đầu lên được. Vừa mở mắt ra thì tôi nhìn thấy gương mặt đang nhịn cười từ Kohi và Shylvie.
B1477: [ CG Hải Quỳ người tuyết với gương mặt mếu]
B1478: Tôi ba chân bốn cẳng chạy vô bếp, lôi mọi nguyên liệu sẵn có từ chiếc túi đi chợ. Aira đã mua đúng nguyên liệu theo công thức mà tôi chốt sổ sao? Ôi, yêu Aira quá đi mất!!
B1479: Chà không sao đâu, Sierra tự dọn được mà! TỚI GIỜ TRỔ TÀI RỒI!
B1480: [ Cutscene Animation nấu ăn của Hải Quỳ ]
B1481: Hoàn thành rồi! Đây sẽ là món mì cay tuyệt vời nhất mà Leo từng được ăn!! Tôi sẽ cất nó vào tủ lạnh để xíu nữa hâm lại vậy!
B1482: Tôi vỗ tay, nồi mì cay siêu to khổng lồ vô cùng đặc biệt xuất hiện trước sự trầm trồ và hoảng sợ của mọi người.
B1483: Xin giới thiệu, đây là mì cay “ dữ tợn “! Nước dùng được hầm từ nhiều loại rau củ quả cùng vi cá mập để lấy vị ngọt, nấu với mì được làm từ thịt mực tươi nguyên chất, ăn cùng các loại thịt được chiên xù và hải sản nướng mía thơm lừng! Trang trí trên tô mì cay là từng lát chả đầu heo trộn với nhộng tằm!
B1484: UẦYYYYYYYYYYYYYY
B1485: [ Shylvie hoảng sợ ]
B1486: Thôi rồi…Bả lại “ sáng tạo “ ra món dị hợm rồi…!
B1487: Đúng! Dị hợm để “ bà “ không ăn đó
B1488: Tôi liếc nhìn bằng cặp mắt vàng rực đang phản chiếu trong con ngươi ngờ vực của Shylvie.
B1489: Leo! Để tui rào trước! Đây là nồi mì cay duy nhất mà ông chỉ có thể ăn được một lần trong đời thôi! Ông có thể chia cho mọi người hoặt một mình ăn hết nó đều được!
B1490: Ồ! Đương nhiên là tui sẽ chia cho mọi người rồi! Nào, ăn chung với tui!!
B1491: Leo vui vẻ, lấy tay đỡ lấy nồi mì cay khói bốc nghi ngút.
B1492: Ngoài ra, tui còn chuẩn bị cho Leo….
B1493: Tôi búng tay, chai Sting 20 lít ngay lập tức xuất hiện trước mặt Leo. Phù! May quá! Tôi cứ ngỡ phép dịch chuyển bị lỗi lần này nữa chứ!
B1494: BÌNH STING 20 LÍT!? BÀ ĐIÊN RỒI HẢ QUỲ?!
B1495: ĐIÊN CHỨ!! 20 LÍT UỐNG MỚI ĐÃ!!
B1496: AAAAAAAAAAAAAAAAA!! TUYỆT VỜI QUÁ QUỲ!!
B1497: [ Sprite Shylvie đổ mồ hôi ]
B1498: Sao tôi nghi ổng sẽ thay cái bình này với cái bình 20 lít trong văn phòng ổng nhỉ?
B1499: Chứ gì nữa!
B1500: Cả nhóm xúm xít quanh nồi mì cay, Leo cẩn thận múc mỗi người một tô. Ai nấy đều húp sồn sột mì và nước dùng rồi tấm tắc khen ngon.
B1501: Món này ăn được?!  - Shylvie ngạc nhiên - Mì mực ăn giòn dai, thịt chiên thấm nước dùng ngon thiệt chứ…?
B1502: Chả đầu heo có vị lạ thiệt - Kohi ngạc nhiên - Tui không nghĩ là bà sẽ băm nguyên cái đầu heo để làm chả đó…xong còn trộn nhộng vô…Nghe khủng khiếp thiệt nhưng ăn vẫn…lạ và ngon?
B1503: Tui không ngờ cái mì này trông dị nhưng ngon thiệt đó - Leo hài lòng
B1504: Nước dùng nhớt nhớt tím tím đỏ đỏ này ngon ghê - Hakase tấm tắc khen
B1505: [ Hakase vui vẻ ]
B1506: Quỳ, tuyết này ăn được không?
B1507: Được chứ.
B1508: Thấy tôi nói vậy, Hakase không ngần ngại dùng tay xới tuyết lên và cho thẳng vô tô mì mà anh ấy vừa múc thêm nước dùng.
B1509: CÁI GÌ VẬY HAKASE??! WTF?!?!
B1510: Shylvie hét toáng, mặt đầy sợ hãi.
B1511: Đá bào mì cay?
B1512: KHÔNG!! KHÔNG!! KHÔNG AI LẠI ĂN “ ĐÁ BÀO MÌ CAY “ CẢ!! NÓ KHÔNG NÊN TỒN TẠI!!
B1513: Ngon mà!!
B1514: KHÔNG!! ĐÓ LÀ THẢM HỌA ẨM THỰC!! ỰAAAAA
B1515: Shylvie nhảy dựng lên. Kohi và Leo phải trấn tĩnh một lúc bả mới chịu yên.
B1516: Ăn xong, mọi người tập trung dọn dẹp và tiếp tục vòng tặng quà.
B1517: Sau lưng của Leo xuất hiện một cái hộp to ngang ngửa ông ấy. Leo tiến đến chỗ Hakase, nở một nụ cười tươi tắn.
B1518: Làm theo lời Leo nói, Hakase từ tốn mở hộp quà. Đằng sau giấy gói quà màu tím lấp lánh kim tuyến được thắt nơ đỏ là một hộp mô hình Armored Core. Tôi không nhìn nhầm chứ?
B1519: Không, nhầm sao được. Logo đặc chuẩn luôn kìa!
B1520: Nó là một chiếc mặt nạ đá. Trên trán chiếc mặt nạ đá có gắn một viên đá quý màu đỏ hòa chút xanh lam và tím có sức hút mê hoặc.
B1521: Ủa ê. Sao nó giống với cái mặt nạ…
B1522: Wow….Mặt nạ này là mặt nạ gì vậy Hakase?
B1523: Mặt Nạ Đá đã tinh chỉnh đó! - Hakase vui vẻ đáp - Đeo vào sẽ gia tăng sức mạnh thể chất lẫn ma pháp của người sử dụng, gia tăng sự hồi phục của cơ thể trong mười phút!
B1524: Gượm đã Hakase, anh thực sự tinh chỉnh lại cái mặt nạ đá nguyền rủa mà bọn em phong ấn sao? - Shylvie ngạc nhiên - Không thể nào…!!
B1525: Ủa, có phong ấn hả? - Hakase ngơ ngác
B1526: Leo vỗ vai Hakase, giơ ngón cái biểu đạt:” Làm tốt lắm, Hakase “.
B1527: Mặt Nạ Đá mà ông tinh chỉnh thực chất là Mặt Nạ Quỷ Bào Mòn Sự Sống đó Hakase - Leo đáp - Ba đứa bọn tui phải khó khăn lắm mới phong ấn được nó lại!
B1528: Đù! - Hakase ngạc nhiên - Tớ không biết vụ đó! Tại tớ mở hộp cái rụp à!
B1529: ĐÙ! - Shylvie ngạc nhiên
B1530: Mà Shylvie cứ yên tâm sử dụng nha! Giờ cái mặt nạ này không còn bào mòn sự sống nữa!! Thay vào đó là bào mòn đá quý á!
B1531: NGON!! Tôi biết phải bào đá quý từ ai rồi!
B1532: Ê NHA Ê NHA!! ĐỪNG CÓ MÀ ĐỘNG VÔ SỐ KHO BÁU CỦA TUI! - Leo nhảy dựng
B1533: Shylvie cất chiếc mặt nạ vào trong túi không gian của bả, đồng thời lôi ra một túi quà được gói kỹ càng màu nâu nhạt và trao nó cho Kohi.
B1534: - LÀ BỘ MÓC LEN MỚI!!
B1535: Tôi bước vào bếp, sử dụng Moonlight Exocist Sacrifices để hâm nóng nồi mì cay thật nhanh trong 2 giây rồi mang nồi mì cay siêu to khổng lồ vô cùng đặc biệt ra ngoài trước sự trầm trồ và nghi hoặc của mọi người.
B1536: TADA!! GIáng sinh ngon miệng, Leo!! Tui đã tự tay nấu cho ông một nồi mì cay to đùng vô cùng ngon nhức nhức cái nách!!
B1537: WOWWWWWWWWWWWW
B1538: Xin giới thiệu với Leo và mọi người, đây là nồi mì cay Chìm và Nổi Atlantis! Trong nồi mì cay này hội tụ nhiều loại thịt, hải sản độc lạ ở Atlantis và đất liền!!
B1539: [ Sprite Leo mắt ngôi sao ]
B1540: Thịt gì với thịt gì đó bà!!
B1541: Thịt tôm núi lửa, mực tam giác quỷ, thịt trâu gác bếp, thịt cá mái chèo, thịt heo Iberico, thịt gà đông tảo…v…v! À, có cả sò quỷ, bào ngư bóng ma và nghêu hắc ám nữa!!
B1542: Mắt Leo sáng rực, tay đỡ lấy nồi mì cay khói bốc nghi ngút.
B1543: Bà…có chắc là ăn được không đấy?
B1544: Ăn được chứ má!! Ngon là đằng khác!
B1545: Ồ, nghêu hắc ám trông hắc ám thiệt!!
B1546: [ Sprite Hakase tò mò ]
B1547: Mùi mì cay thơm ghê ha!! Cho tớ miếng đi!!
B1548: Mọi người ăn cùng với tui cho vui!!
B1549: Cả nhóm xúm xít quanh nồi mì cay, Leo cẩn thận múc mỗi người một tô. Mùi thơm nồng của ớt bột cùng hương vị hải sản Atlantis làm cho mọi người xuýt xoa mãi.
B1550: Chà, ngon thiệt ấy chứ? - Shylvie ngạc nhiên - Tui nào giờ thấy Quỳ toàn nấu mấy món dị hợm nên cứ nghĩ trình độ nấu ăn của bả tệ nhất Wanderer…
B1551: Shylvie đánh mắt qua nhìn Hakase, người đang húp sồn sột nước dùng.
B1552: Sò Quỷ dai dai, thịt ngọt ghê! - Kohi tấm tắc khen - Ăn chung với sợi mì thấm đẫm nước dùng mì cay cay, mằn mặn như này hợp thiệt!
B1553: Tui không ngờ hải sản dưới Atlantis ngon vậy đó! - Leo hài lòng - Sợi mì dai thiệt! Bà dùng mì gì vậy?
B1554: Kết hợp giữa mì khoai tây nhồi phô mai và mì gà!
B1555: Là bà trộn thịt gà xay nhuyễn với bột mì hả?
B1556: Đúng rồi!!
B1557: [ Shylvie vui vẻ ]
B1558: Rau củ cũng thấm nước dùng nữa, ngon thật đấy. Bà có chắc là không nhờ ai đó nấu hộ chứ?
B1559: Nhỏ này kỳ ghê nha!! Đã nói là tui tự nấu rồi mà!!
B1560: Haha, vẫn phải hỏi kỹ chứ. Tại vì tui vẫn không tin ấy!
B1561: [ Hakase tò mò ]
B1562: Shylvie nói gì lạ thế? Tui ăn mấy món mà Quỳ nấu rồi, có vấn đề gì đâu? Ngon lắm luôn á!
B1563: Đó! Thấy chưa, Hakase xác nhận luôn kìa!
B1564: Không tính! Khẩu vị của hai người kỳ quặc lắm!!
B1565: Leo và Kohi bụm miệng cười.
B1566: Hả? Chắc được á anh.
B1567: - A…Hông có gì!! Tui đang nghĩ về đá bào…
B1568: Cảnh số 4.5
B1569: Không biết đã bao lâu rồi tôi chưa tới văn phòng Wanderer nhỉ? Lần cuối là khi nào ta?
B1570: [ Sprite Hải Quỳ đồ thường nhật háo hức. BG Văn phòng Wanderer - BGM Signs Of Love (Instrumental) ]
B1571: Chắc cũng hơn hai tháng rồi tôi không đến văn phòng. Công việc bên Silver Wing nhiều đến mức tôi còn không có thì giờ để ăn uống nói chi là nhắn tin Leo để xin nghỉ phép dài hạn. May mà Leo dễ tính, văn phòng Wanderer không bắt buộc nhân viên phải đi làm thường xuyên chứ không tôi bị đuổi việc lâu rồi.
B1572: Không biết hôm nay có ai túc trực ở văn phòng nhỉ? Bình thường sẽ là Leo hoặc Shylvie hoặc cả hai.
B1573: Ồ, y chóc! Tôi có thể cảm nhận được ma lực của hai người ấy đang hiện diện trong văn phòng. Vô chào hỏi xíu nhỉ!
B1574: [CHOICES] Leo | Shylvie
B1575: LEO cảnh 4.5
B1576: Tương tác lần 1:
B1577: Leo: Xin chào quý khách! Chào mừng đến với văn phòng Wanderer!
B1578: Hình như Leo không nhận ra mình hả ta? Phải hù ổng một xíu mới được!
B1579: Quỳ: Hố la mù cha chố.
B1580: Leo: …..Hố la?
B1581: Quỳ: Ôi, xin thứ lỗi!! Tại vì mình có xem stream bạn nên là mới tìm tới đây để gặp bạn…!!
B1582: Leo: À…Hóa ra là như vậy. Làm sao mà bạn tìm tới đây được? Ai đã chỉ cho bạn thế?
B1583: [ Thay đổi sprite Hải Quỳ thường phục sang Hải Quỳ đồng phục ]
B1584: Quỳ: LÀ TUI CHỨ AI?!
B1585: Leo: Q…Quỳ!? Trời ơi tui nhận không ra! Bà đang trong nhiệm vụ hay sao mà thay đổi ngoại hình vậy?!
B1586: Quỳ: Khác biệt vậy luôn á hả?
B1587: Leo: Khác, khác quá trời khác. Ủa mà tưởng bà nhắn là đang chuẩn bị mà?
B1588: [ Thay đổi Sprite Hải quỳ đồng phục sang Hải Quỳ thường phục ]
B1589: Quỳ: Bộ không được ghé thăm văn phòng trong lúc đang đi chuẩn bị sao?
B1590: Leo: Được chứ! Tui chỉ tò mò thôi!!
B1591: Tương tác lần 2:
B1592: Quỳ: Mấy nay mọi người ổn chứ?
B1593: Leo: Không ổn lắm. Tui và Shylvie mấy nay phải đi xử lý quái vật suốt. Kohi và Hakase thì liên tục tiếp nhận các yêu cầu điều tra phá án. Mệt bở hơi tai luôn ấy chứ.
B1594: Quỳ: Đúng là bận trăm công nghìn việc!!
B1595: Quỳ: Hakase với Kohi đã quen công việc ở văn phòng chưa?
B1596: Leo: Xời, hai người họ luôn hoàn thành công việc một cách hoàn hảo luôn! Tui còn đang muốn cho Hakase tiếp nhận thêm các yêu cầu xử lý quái vật nữa đó! Ổng mạnh kinh hồn!!
B1597: Quỳ: Khoan! Ổng kiểm soát được sức mạnh rồi hả?!
B1598: Leo: Không hẳn, nhưng tiến bộ hơn rất nhiều so với ngày đầu rồi!!
B1599: Quỳ: Còn Kohi thì sao?
B1600: Leo: Tốc độ làm việc của bà ấy nhanh ghê gớm luôn! Hồ sơ sổ sách trong văn phòng được bà ấy giải quyết nhanh gọn lẹ, chớp nhoáng luôn á.
B1601: Quỳ: Uầy! Hóa ra hai người họ là cao thủ ẩn danh hả?
B1602: Leo: Chứ gì nữa.
B1603: ( Trong lúc tương tác với Leo thì Shylvie đi mất )
B1604: Tương tác lần 3:
B1605: Leo: Bà đã tính mua gì để làm quà chưa?
B1606: Quỳ: Tui…nói thực là có nhiều thứ lắm, tui đang phân vân lắm luôn.
B1607: Leo: Sao tui có cảm giác là bà sẽ tặng cho bọn tui ba cái thứ ma xui quỷ khiến, ma ghét quỷ hờn vậy…?
B1608: Quỳ: Ừ, có thể đấy.
B1609: Leo: Thôi tha dùm!! Hồi năm ngoái bà tặng cho bọn tui mỗi đứa một mảnh tinh thể gì đó, chúng phát nổ suýt cháy cả văn phòng đấy!!
B1610: Quỳ: Hè hè!! Thế nên tui mới phân vân!!
B1611: Leo: Thôi thôi bà nội. Nếu mà bà có tặng á, thì tặng cho Shylvie dụng cụ làm bếp, tặng Kohi cà phê, tặng Hakase sách phép hay mấy dụng cụ hỗ trợ ma pháp ấy.
B1612: Quỳ: Mèn đét, đúng là Leo, rành rọt ghê!! Cảm ơn nha!!
B1613: Leo: Má, sao tui có cảm giác bất an dữ dội vậy ta….
B1614: Ấy chết! Phải đi mua đồ thôi, kẻo trễ mất!!
B1615: Sau khi chào tạm biệt Leo, tôi cắm đầu chạy thẳng ra khỏi văn phòng.
B1616: SHYLVIE cảnh 4.5
B1617: Shylvie: Tôi tưởng bà đang đi mua đồ?
B1618: Quỳ: Thì tiện đường tạt ngang qua văn phòng, không cho à?
B1619: Shylvie: Ừ, không cho đấy.
B1620: Quỳ: Dỗi à?
B1621: Shylvie: Không dỗi. Tôi mệt. Tôi thích làm các nhiệm vụ khám phá tàn tích, thu hồi vật phẩm cổ đại hơn. Mấy cái việc bắn phá, thanh trừng quái vật đáng lý ra bà phải làm mới đúng.
B1622: Quỳ: Xời, tưởng như nào. Tàng thư ma thuật hơn một nghìn phép chẳng lẽ không có phép thuật nào “ dọn dẹp “ nhanh hơn à?
B1623: Shylvie: Có nhưng dùng tốn ma năng lắm. Dùng xong ai cõng tôi về?
B1624: Quỳ: Thì tự lết về đi bạn.
B1625: Shylvie: Thôi khỏi. Thà không dùng còn hơn.
B1626: Quỳ: Ê mà sao nhận ra tôi nhanh thế?
B1627: Shylvie: Bà để tóc hai bím.
B1628: ( Trong lúc tương tác với Shylvie thì Leo đi mất )
B1629: [ Nếu nói chuyện với Leo trước đó ]
B1630: Quỳ : Ấy thế mà Leo không nhận ra tôi đấy.
B1631: Shylvie : Gì ? Thật hả ?
B1632: Quỳ : Thật mà. Ổng còn chào tôi như thể tôi là khách hàng ở đây đấy.
B1633: Shylvie : Cũng phải. Hải Quỳ tuyệt nhiên là bé gái hai bím. Nhưng đâu phải bé gái hai bím nào cũng là Hải Quỳ.
B1634: Quỳ : Triết lý này đâu ra đấy ?
B1635: Shylvie : Bà tự nhìn lại xem. Biết bao lần bà thay đổi ngoại hình toàn chọn hình dáng bé gái buộc tóc hai bím rồi ?
B1636: Quỳ : Ừ thì…Chậc, không cãi được.
B1637: [ Nếu không nói chuyện với Leo trước đó ]
B1638: Quỳ : Có mỗi thế thôi á ?
B1639: Shylvie : Màu mắt, lượng ma năng mà bà tỏa ra. Đủ nhiêu đó thôi cũng khiến tôi nhận ra bà rồi. À mà nếu bà ở xa quá thì tôi chịu.
B1640: Quỳ : Ê nha ê nha, đụng chạm nha.
B1641: Shylvie : Đụng chạm gì đâu, này là bà tự nhận nha.
B1642: Quỳ : Đánh cho bây giờ !
B1643: Shylvie: Mà bà trông rảnh ghê. Phụ tôi một tay cái coi.
B1644: Quỳ: Méo. Bổn cô nương đây đang vi hành, méo rảnh rang đâu mà phụ với chả giúp, hứ!
B1645: Shylvie: Ờ rồi “ bồn cố nương “ đang tính mua gì đấy?
B1646: Quỳ: Chưa biết. Đang phân vân vì nhiều món quá.
B1647: Shylvie: Cần gợi ý không?
B1648: Quỳ: Phun đi.
B1649: Shylvie: Ở thế giới của tôi có chỗ bán đá phong thủy hay ho lắm. Được thì tạt ngang qua xem thử.
B1650: Quỳ: Đang nhắc khéo tôi mua cho Shylvie phải hông?
B1651: Shylvie: Biết gì đâu. Thấy hay hay mới giới thiệu thôi.
B1652: Quỳ: À thế à?
B1653: Shylvie: Ừ thế ứ.
B1654: Sau khi chào tạm biệt Shylvie, tôi cắm đầu chạy thẳng ra khỏi văn phòng.
B1655: Cảnh số 4.5.1
B1656: Leo cảnh số 4.5.1
B1657: Tôi vừa ngồi xuống trạm xe buýt thì tiếng chuông báo tin nhắn vang lên.
B1658: [ CG điện thoại hiện ra, tin nhắn riêng với Leo hiện lên ]
B1659: ( Leo : Hải Quỳ, bà tính đi đâu mua đồ vậy ?
B1660: Hải Quỳ : Tôi đang tính đi ra siêu thị hoặc là về Atlantis để mua á. Sao vậy ?
B1661: Leo : Bà có muốn tôi giới thiệu bà đến mấy cửa hàng mà tôi quen ở các chiều không gian khác không ? Họ có mấy món mà các thành viên khác sẽ thích đấy.
B1662: Hải Quỳ : Tuyệt vời ông mặt trời !! Vậy ông gửi cho tui tọa độ của
B1663: [CHOICES] Cửa hàng cà phê | Cửa hàng vũ khí | Cửa tiệm bán dụng cụ ma pháp
B1664: [ Hộp lựa chọn hiện ra – Cửa tiệm bán dụng cụ ma pháp ]
B1665: Leo : Ờ đợi xíu !
B1666: [ CG điện thoại tắt ]
B1667: Leo lập tức gửi tọa độ cho tôi. Đồng thời dịch chuyển một chiếc vòng tay có gắn la bàn và một túi châu báu to đùng cho tôi. Chà, tôi hy vọng rằng chiếc vòng tay sẽ không phát nổ trong lúc tôi đang ở bên chiều không gian khác. Nếu nổ thì hết đường về luôn !
B1668: [ BG Cửa tiệm bán dụng cụ ma pháp]
B1669: Sao cửa tiệm này nhìn ma mị thế…? Bầu không khí của nơi này khiến tôi rợn tóc gáy. Mấy cửa tiệm bán dụng cụ ma pháp ở Atlantis sáng sủa hơn nhiều…! Cửa tiệm làm tôi nghĩ đến mấy nơi buôn bán đồ bất hợp pháp mà trước đây tôi từng nằm vùng!!
B1670: Leo chắc như đinh đóng cột rằng đây là một cửa tiệm vô cùng uy tín. Ông ấy còn lấy tính mạng của mình ra đảm bảo. Chắc là liều một phen! Cùng lắm thì đánh sập cửa tiệm thôi!
B1671: Một bóng người với đôi mắt đỏ au trùm khăn kín mín xuất hiện trước mặt tôi. Người ấy tự giới thiệu mình là chủ tiệm, vì nhạy cảm với ánh sáng nên buộc phải trùm khăn. Sau khi biết tôi là bạn của Leo, chủ tiệm không ngần ngại giới thiệu cho tôi nhiều sản phẩm hay ho, nào là hạt dẻ dịch chuyển, bút thay đổi hình thể, nến dẫn đường rồi đến các loại chổi bay, thảm bay thế hệ mới.
B1672: Ê, cái bát họ mà tôi làm rơi ở vực sâu mấy năm trước cũng nằm ở trong cửa tiệm này nè?! Không lẽ dưới vực sâu tồn tại cổng giao thoa đa chiều không gian hả?!
B1673: Tôi đứng suy nghĩ một lúc. Hakase sẽ cần món nào trong cửa tiệm này nhỉ? Ổng vốn là ma vương tiền nhiệm đang lấy lại sức mạnh, các phép thuật căn bản ổng đều nắm vững rồi…Riêng chỉ có phép tàng hình là hơi có vấn đề một chút. Tôi nhớ có lần ổng tàng hình nửa thân trên, có hôm thì nửa thân dưới, có hôm tàng hình chừa mỗi cái đầu làm cho Kohi suýt ngất.
B1674: - Chủ tiệm có món nào liên quan đến phép thuật tàng hình không?
B1675: - Phép thuật tàng hình sao…? Ồ! Thật hiếm có làm sao! Tôi có món này vô cùng phù hợp cho em bé nhà cô luôn!
B1676: - Hả? Đồ cho em bé?
B1677: - Vì phép thuật tàng hình là phép thuật dễ nhất, cũng là phép thuật đầu tiên mà các em bé thực hiện được! Hồi xưa, để cho các em bé tập làm quen với việc tàng hình, chúng tôi có sản phẩm này đây!
B1678: Nói rồi, chủ tiệm lôi ra từ trong tủ kính trưng bày một tấm áo choàng bằng lông động vật vô cùng mềm mượt.
B1679: - Áo choàng tàng hình! Chiếc áo choàng này cũng là chiếc áo choàng cuối cùng của cửa tiệm chúng tôi rồi!
B1680: - Vì sao vậy?
B1681: - Vì nguy hiểm đó! Lần cuối cùng chiếc áo choàng này được bày bán chắc cũng phải hơn 100 năm trước rồi!
B1682: Chủ tiệm giải thích công dụng và cách sử dụng chiếc áo choàng này cho tôi nghe. Chiếc áo choàng giúp cho người choàng nó biết kiểm soát lưu lượng ma lực vừa đủ để tàng hình. Chỉ cần truyền đủ ma lực, cả người lẫn áo choàng sẽ biến mất.
B1683: Ông cũng giải thích thêm lý do vì sao chiếc áo choàng này bị cấm bán. Hóa ra là vì các em bé bẩm sinh không biết kiểm soát ma lực nên 10 bé thì hết 8 bé đều mất vì bị tan biến vào hư vô. Vì phép tàng hình quá nguy hiểm nên họ quyết định cho con mình mặc chiếc áo choàng chống tàng hình để con họ không thể học phép tàng hình nữa. Hệ quả là thế hệ sau này hiếm ai thông thạo phép tàng hình.
B1684: Phép thuật tàng hình nguy hiểm tới vậy luôn…!
B1685: Tôi có ý định mua lại cái bát họ của tôi nhưng sau khi nghe giá của chiếc áo choàng tàng hình, tôi mau chóng bỏ ý định đấy đi.
B1686: [ Hộp lựa chọn hiện ra – Cửa hàng cà phê ]
B1687: Leo lập tức gửi tọa độ cho tôi. Đồng thời dịch chuyển một chiếc vòng tay có gắn la bàn và một túi châu báu to đùng cho tôi. Chà, tôi hy vọng rằng chiếc vòng tay sẽ không phát nổ trong lúc tôi đang ở bên chiều không gian khác. Nếu không thì hết đường về luôn !
B1688: [ BG Cửa Hàng cà phê ]
B1689: Ồ, vừa mới bước vào thôi là đã thấy mùi hương cà phê ngào ngạt xộc thẳng vào mũi rồi!
B1690: Tôi sử dụng khứu giác nhanh nhạy của tôi để mau chóng tìm ra loại cà phê tuyệt vời nhất ở trong cửa hàng. Chà, ở thế giới này cũng tồn tại một loại cà phê gần tương tự cà phê tôm núi lửa ở Atlantis!! Mùi của nó dịu hơn cà phê tôm núi lửa một chút, có hương thoang thoảng của trầm hương!
B1691: Chủ tiệm ở đây vô cùng tốt bụng. Ngay khi nghe tôi giới thiệu rằng tôi là bạn của Leo, anh ấy liền mời tôi một tách cà phê nổi tiếng nhất của tiệm.
B1692: Nó ngon thật đấy. Chắc là tôi sẽ mua loại này làm quà.
B1693: [ Hộp lựa chọn hiện ra – Cửa hàng vũ khí ]
B1694: [ BG Cửa Hàng Bán vũ khí ]
B1695: Chà, cửa hàng bán khiên này rộng ghê… !! Có quá trời vũ khí đang trưng bày luôn !! Mỗi tội không có súng… ! Cũng phải, ở chiều không gian này chưa tồn tại những loại vũ khí giống ở Atlantis !!
B1696: Nghe Leo bảo rằng chủ cửa hàng này là gian thương thích sưu tập vũ khí huyền thoại. Leo đặc biệt dặn tôi nếu đến đây thì chỉ nên mua khiên thôi, vì ngoài khiên ra thì mấy vũ khí được trưng bày ở đây đều là hàng thải, hàng sao chép rẻ tiền.
B1697: Ủa khoan, sao nghe sai sai…Sao Leo lại giới thiệu tôi đến cửa hàng gian thương vậy ?!
B1698: Tôi ngắm nghía kệ trưng bày khiên. Đa phần là kiểu dáng khiên vừa tay cầm, không quá to cũng không quá bé nhưng họa tiết thiếu sáng tạo, thiếu tinh tế, nhìn rất nhàm chán. Nếu so sánh với mớ khiên được Shylvie trưng bày trong phòng ngủ, thì cái kệ trưng bày này không có tuổi.
B1699: Đột nhiên, có một đôi gồm một cô Elf tóc tím và một cô gái tóc nâu có nét giống Shylvie hớt hải chạy ngang qua tôi, chạy thẳng đến quầy thanh toán.
B1700: Cô Elf tóc tím : BÀ CHỦ !! TÔI MUỐN BÁN CHIẾC KHIÊN NÀY !!
B1701: Cô gái tóc nâu : ERUFU !! B-Bình tĩnh !! Chúng ta chưa biết chắc nó có phải khiên hay không mà !!
B1702: Cô gái tóc nâu thở hổn hển, tay khẽ giơ lên can cô Elf tóc tím. Tôi tò mò nên tiến lại gần quầy thanh toán để hóng chuyện.
B1703: Bà chủ : Lại là hai cô à ? Lần này lại mang thứ rác phẩm gì đến đấy ?
B1704: Cô Elf tóc tím : Đây không phải rác phẩm ! Bọn tôi vừa móc từ con Mimic to đùng dưới hầm ngục Eldorask đấy !!
B1705: Bà chủ : Hầm ngục Eldorask làm gì có Mimic, cô lại bịa chuyện để có tiền đi uống rượu đúng không ? Tôi quen với chiêu trò này của cô rồi ! Nhìn đi, thứ các cô mang đến trông chả khác gì cục đá chùi đít của bọn heo rừng ấy. Sao cô dám chắc nó là khiên được ?
B1706: Cô Elf tóc tím : Tôi sống đủ lâu để biết rằng có chiếc khiên nằm trong cục đá chùi đít mà bà bảo đấy ! Bà không tin thì cứ đẽo ra mà xem !
B1707: Cô gái tóc nâu : Quả thực là khi dùng phép thẩm định thì chỉ số của….cục đá chùi đít này cao bất thường. Mong chủ tiệm xem xét cho.
B1708: Cô gái tóc nâu nói đúng. Tôi cũng cảm nhận được nguồn ma lực khổng lồ từ cục đá chùi đít ấy.
B1709: Bà chủ : Mấy cô bị điên hả ? Nếu dùng phép thẩm định thì cũng phải biết cục đá này không phải loại đá mà con người có thể đẽo được chứ ? Thôi thôi đi dùm đi !! Lần này tôi không mua đồ của mấy cô đâu !!
B1710: Cục đá chùi đít của heo rừng có vẻ thú vị. So với mấy cái khiên tầm thường nằm ở trên kệ thì cục đá chùi đít này tôi thấy đáng giá hơn.
B1711: Trước khi cô elf tóc tím bị cô gái tóc nâu lôi xềnh xệch ra về, tôi vội chạy tới bắt chuyện.
B1712: Hải Quỳ : Liệu tôi có thể mua nó không ?
B1713: Cô Elf tóc tím : Ồ !! Cô gái quả là có mắt !!
B1714: Cô gái tóc nâu túm lấy gáy của cô elf và lùi lại một bước. Vẻ mặt của cô ấy lộ rõ vẻ lo lắng tột độ.
B1715: Cô gái tóc nâu : Erufu, cô gái này nguy hiểm lắm.
B1716: Cô Elf tóc tím : Có gì mà nguy hiểm ?
B1717: Cô gái tóc nâu : Trang phục rõ kỳ lạ, lượng ma pháp rõ khủng khiếp. Chúng ta không nên dây dưa với cô ấy.
B1718: Cô Elf tóc tím : Euruka ! Tưởng gì !! Mấy người như này lại càng phải giao du đấy Traveller !!
B1719: Ai lại đặt cho mình cái tên Traveller vậy ?! Đây là Genshin Impact trá hình hả ? Tôi nheo mắt nhìn Travellver một lượt từ trên xuống. Traveller có mái tóc nâu dài, vai trái mang ba chiếc giáp vai kiểu dáng cánh chim, toàn bộ cánh tay phải đều được gắn thêm giáp, có vẻ cô gái này thuận tay phải.
B1720: Cô Elf tóc tím : Cô gái ! Để tiện xưng hô thì có thể cho tôi biết tên không ?
B1721: Hải Quỳ : Tên tôi là Twinkle.
B1722: Cô Elf tóc tím : Tôi là Erufu, còn con mắm này là Traveller. Tôi có hỏi tên nhỏ nhưng nhỏ mãi chưa chịu nói. Tên xấu ói.
B1723: Traveller : Xin lỗi vì tên xấu ói, được chưa ?
B1724: Tính cách này y xì đúc Shylvie. Chắc chắn đây là Shylvie ở thế giới khác !!
B1725: Hải Quỳ : Cô Erufu ra giá cho " chiếc khiên " này đi.
B1726: Erufu: Euruka! Cô gái thật khảng khái! Vậy cô gái có đồng ý với mức giá 120 đồng vàng cho " chiếc khiên " này không?
B1727: Hả, gì cơ? 120 đồng vàng cho chiếc khiên này á? Bán giá gì đắt cắt cổ vậy?! Tôi thực lòng muốn nói thẳng mặt Erufu nhưng ngẫm lại, 120 đồng cho cục đá chùi đít này hời hơn mớ khiên được trưng bày kia. So về giá cả, tổng số tiền để mua hết cái kệ đó mắc hơn cục đá chùi đít này. Còn so về ma lực gì thôi, vứt mớ khiên trên kệ kia vào thùng rác đi.
B1728: Cơ mà hiện tại tôi lại không có đồng vàng nào trong người. Ngoại trừ túi châu báu của Leo ra. Hay là trao đổi cái túi này với cục đá chùi đít nhỉ?
B1729: Tôi biết có ai đó đang đánh giá tôi về cách tôi sử dụng tiền.
B1730: Hải Quỳ:  Thật đáng tiếc là tôi đang không mang theo tiền trong người ngoại trừ túi vật phẩm này. Liệu hai người có muốn trao đổi đồng giá không?
B1731: Tôi mở chiếc túi châu báu ra và đưa trước mặt hai cô gái. Đôi mắt Erufu sáng rực cả lên, miệng thì chảy dãi. Traveller thì trợn tròn mắt ngạc nhiên, mắt hết đánh lên nhìn tôi lại đánh xuống nhìn túi châu báu.
B1732: Traveller: Twinkle, cô không phải công chúa phương xa nào đó đâu đúng không?
B1733: Hải Quỳ: Sao cô lại nói vậy?
B1734: Traveller: Vì cô không biết giá trị thực sự của nó. Số tiền này quá lớn-
B1735: Erufu: Được được! Tôi đồng ý!!
B1736: Traveller: Không được Erufu! Số tiền này quá nhiều so với giá mà cô đưa ra đấy!!
B1737: Ai mới là gian thương ở đây vậy?
B1738: Traveller: Tôi thực sự tò mò về thân thế của cô đấy, Twinkle. Cô thực sự đi long nhong ở đây, người không mảnh giáp, cùng với chiếc túi siêu giá trị này à?
B1739: Tôi sợ gì phường trộm cướp hay quái vật ở đây. Ban nãy tôi đi lạc rồi gặp phải một toán cướp. Chúng nó chưa kịp bu vào tôi thì đã bị một beam tan thành tro bụi rồi.
B1740: Traveller:  Chúng tôi xin nhận hai viên ngọc lam này thay cho 120 đồng vàng.
B1741: Erufu: Gì vậy Euruka….!!
B1742: Tôi đoán Euruka có nghĩa là " trời ơi ".
B1743: Tôi trao cho Traveller hai viên ngọc lam cùng ba viên ruby. Traveller ban đầu từ chối nhận ba viên ruby nhưng vì Erufu nằm lăn ra ăn vạ nên Traveller đã chịu nhận thêm. Và thế là tôi mua được viên đá chùi đít cho Shylvie.
B1744: Cục đá tự dưng nứt toác.
B1745: Hakase
B1746: Chủ tiệm nể tình tôi là bạn của Leo nên đã giảm giá chiếc áo choàng tàng hình. Cơ mà dù có giảm giá, với số tiền còn lại tôi cũng không thể mua chiếc bát họ thất lạc của tôi. Tạm biệt mày, bát họ, tao sẽ nhớ mày lắm….!
B1747: Chủ tiệm gói chiếc áo choàng cẩn thận rồi đưa nó cho tôi.
B1748: Tôi chả hiểu nửa bên kia của tôi nói gì hết. Thôi, mặc kệ cô ấy thôi.
B1749: Kohi
B1750: Nè con nhãi kia, ta cũng muốn uống![ Q2 ]
B1751: Rồi rồi! Tui sẽ mua thêm vài gói! Mua tặng cả nhà luôn! [ Q1 ]
B1752: Phải thế chứ! [ Q2 ]
B1753: Thôi, dù rằng bà ấy là Quỷ cà phê nhưng Cà phê Atlantis nặng đô lắm. Cho bà ấy uống lỡ gặp chuyện gì thì sao? [ Q2 ]
B1754: Ừ ha [ Q1 ]
B1755: Tôi dòm lên kệ trước mặt tôi, với tay lên lấy thêm vài túi cà phê thượng hạng mạ vàng.
B1756: Shylvie
B1757: Rồi ngươi tính sao với cục đá chùi đít này đây? Tính về đẽo nó đấy à?[ Q2 ]
B1758: Chứ gì nữa. [ Q1 ]
B1759: Tôi dòm cục đá đen tuyền to đùng trong tay. Vết nứt ngày một lan rộng hơn.
B1760: Tôi đặt gói quà của Hakase lên bàn, lấy đồng hồ báo thức đè lên nó. Mặc dù còn vài ngày nữa mới tới buổi tiệc giáng sinh nhưng không biết vì sao mà tôi cứ có cảm giác là bữa tiệc sẽ diễn ra vào ngày mai. Và điều đó khiến tim tôi đập thình thịch, tạo cảm giác lo lắng tột độ.
B1761: Tôi tò mò, tự tưởng tượng ra hàng tá trường hợp, những trò vặt vãnh mà Hakase có thể làm với áo choàng tàng hình. Càng tưởng tượng, tâm trí tôi càng được xoa dịu, cảm thấy đỡ căng thẳng hơn đôi chút.
B1762: Tôi chỉnh lại nơ trên chiếc túi giấy đựng cà phê. Mặc dù còn vài ngày nữa mới tới buổi tiệc giáng sinh nhưng không biết vì sao mà tôi cứ có cảm giác là bữa tiệc sẽ diễn ra vào ngày mai. Và điều đó khiến tim tôi đập thình thịch, tạo cảm giác lo lắng tột độ.
B1763: Nhưng khi nghĩ đến việc Kohi sẽ thích thú với túi cà phê, cảm giác lo lắng trong tôi tan biến đi một chút.
B1764: Vài ngày nữa là tới buổi tiệc giáng sinh mà tôi vẫn chưa đẽo được cục đá chùi đít này. Đá gì đâu mà cứng chết đi được! Kể cả tôi dùng máy đẽo đá đa chiều không gian mà tôi thó được từ Hakase, vẫn không tài nào đẽo được. Càng nghĩ tới việc không đẽo được cục đá, tim tôi càng đập thình thịch, tạo cảm giác lo lắng tột độ.
B1765: Chả lẽ tặng nguyên cục đá này cho Shylvie hả ta?
B1766: Tui cảm thấy hơi bất an một chút…Liệu có nên tặng nguyên cục đá này cho Shylvie không? [ Q1 ]
B1767: Thân thiện gì với cái đứa nhiều chuyện như ngươi. Ngươi cứ lo lắng dư thừa, Shylvie vốn là một đứa thích đá mà, nhiễu sự ghê.
B1768: Nhớ…buộc nơ…vô cục đá nha…Aira…
B1769: Hakase nhẹ nhàng kéo một cái, giấy gói quà của tôi rách thành trăm mảnh bay xuống nền nhà như pháo giấy. Hakase cầm chiếc áolên, mắt chữ A và miệng chữ O nhìn tôi, kinh ngạc hết cỡ.
B1770: - Cái này là gì vậy Hải Quỳ?
B1771: - Anh thử choàng nó lên người đi!
B1772: - Hakase khoác lên người rồi truyền ma lực vào nó đi.
B1773: Hakase làm theo. Anh ấy nhắm mắt, từ từ chậm rãi truyền ma lực vào chiếc áo choàng. Cơ thể của Hakase bắt đầu biến mất.
B1774: - Ớ! Ổng biến mất rồi!!
B1775: - Ui, Leo ơi, Hải Quỳ ơi, tớ dùng được phép thuật tàng hình rồi nè!! Đỉnh thiệt chứ!!
B1776: [ Sprite Leo nói chuyện ]
B1777: - Ừ, áo choàng tàng hình mà lại! Mà bà tài thật đó Quỳ, kiếm được đồ cổ luôn.
B1778: - Hehe, tui mà lị!
B1779: Tôi huých nhẹ vai Leo.
B1780: Hakase thích thú chạy vài vòng quanh mọi người. Chạy được mấy vòng, Hakase cởi áo choàng ra, vui vẻ nói với tôi:
B1781: - Cảm ơn Hải Quỳ nha! Tớ thich món này lắm!! Không ngờ cậu để ý đến vậy luôn!
B1782: Hakase ngay lập tức cất chiếc áo choàng vào ngăn tủ không gian của anh ấy và lôi một chiếc hộp be bé từ đấy ra.Hakase tiến đến chỗ Kohi, nở một nụ cười đầy tự hào.
B1783: [ Sprite Kohi sáng rực ]
B1784: - BỘT CÀ PHÊ NGON NHẤT LUMINOUS SAO!? UI!! THÍCH THẾ!!
B1785: - K-Không thể nào!
B1786: -À…Thế thì Shylvie thua cược rồi.
B1787: Kohi cất bột cà phê vào trong bếp. Cô ấy lấy từ trong túi xách của mình một chiếc hộp thiếc bóng loáng có vài đường vân được dát vàng sáng bóng cho bọn tôi chiêm ngưỡng rồi dúi nó vào tay Leo.
B1788: Tôi lập tức đứng dậy, cầm theo cục đá mà tôi đã buộc nơ tiến đến chỗ của Shylvie.
B1789: - Giáng sinh an lành Shi-ru-vi! Tui hi vọng ông thích cục đá…phong thủy này!
B1790: - WOW! Đá phong thủy gì mà to vậy!
B1791: - Ủa Quỳ, tôi tưởng bà đi mua-
B1792: - Tiệm họ bán hết đá nhỏ rồi, chỉ còn cục to đùng này thôi. Chả lẽ Shylvie không thích nó sao?
B1793: Shylvie vừa nói dứt lời, bỗng cục đá xuất hiện nhiều vết nứt rồi nổ tung. Một chiếc khiên hiện ra, lớp vỏ rỉ sét trên chiếc khiên tróc thành từng mảng rơi xuống sàn. Nó tỏa ra một ánh sáng rực rỡ, hớp hồn tất cả mọi người trong văn phòng.
B1794: - GÌ CƠ?? CHIẾC KHIÊN HUYỀN THOẠI Ở CHIỀU KHÔNG GIAN CỦA LEO Á??
B1795: Shylvie cảnh số 4.5.1
B1796: [ CG điện thoại hiện ra, tin nhắn riêng với Shylvie hiện lên ]
B1797: ( Shylvie : Hải Quỳ, bà có muốn tạt ngang qua cửa tiệm bán đá phong thủy không?
B1798: Hải Quỳ : Shylvie nhiệt tình giới thiệu quá nên chắc là có.
B1799: Shylvie : Để tui gửi tọa độ cho.
B1800: Hải Quỳ : Ừ, gửi tọa độ lẹ lên! )
B1801: Shylvie ngay lập tức gửi tôi tọa độ chính xác của cửa tiệm. Đồng thời dịch chuyển một chiếc vòng tay có gắn la bàn và một túi châu báu to đùng cho tôi. Chà, tôi hy vọng rằng chiếc vòng tay sẽ không phát nổ trong lúc tôi đang ở bên chiều không gian khác. Nếu không thì hết đường về luôn !
B1802: [ BG cửa tiệm đá phong thủy ]
B1803: Trời đất thánh thần Poseidon ơi…Chói quá…!!! Lại còn tràn đầy ma lực nữa chứ!!
B1804: Tôi dạo một vòng xung quanh tiệm, ngắm nghía hết kệ trưng bày này đến kệ trưng bày khác. Nào là Ruby, Sapphire, Emerald cho tới Topaz, Tourmaline, Amber. Vì vốn hiểu biết về đá quý của tôi hạn hẹp nên chỉ có thể nhận ra một số viên mà thôi.
B1805: [CHOICES] Shylvie | Kohi | Leo | Hakase
B1806: Leo
B1807: Tôi nhìn qua kệ trưng các loại Garnet, nhắm mắt lại và đưa tay ra chọn ngẫu nhiên một viên.
B1808: Ồ, là Purple Garnet này [ Q2 ]
B1809: Cũng rành về đá quý dữ ha? [ Q1 ]
B1810: Khùng hả má, nó có màu tím nè. Không lẽ gọi là Sting Garnet? [ Q2 ]
B1811: Ừ cũng hợp lý, Sting nho uống cũng ngon… [ Q1 ]
B1812: Tôi quyết định mua viên Purple Garnet này để tặng cho Leo. Bà chủ khen tôi là người có mắt tinh tường, vì viên Purple Garnet này có khả năng giải trừ các trạng thái bất lợi và các loại độc tố. Ngoài ra thì Purple Garnet còn có khả năng giúp cho tinh thần người sử dụng trở nên vui vẻ tích cực hơn.
B1813: Sao nghe giống như một dạng thôi miên vậy?
B1814: Tôi nhìn qua kệ trưng các loại Fluorite, nhắm mắt lại và đưa tay ra chọn ngẫu nhiên một viên.
B1815: Ngươi tính tặng Rainbow Fluorite cho tên ma vương đáng gờm đó à ?[ Q2 ]
B1816: Ta tính nói là ngươi chọn đúng loại đá cho kẻ ham học hỏi như hắn đấy.[ Q2 ]
B1817: Thật á ? [ Q1 ]
B1818: Thật. Xíu nữa ra hỏi ông chủ là biết liền à. [ Q2 ]
B1819: Tôi quyết định mua viên Rainbow Fluorite này để tặng cho Hakase. Hỏi bà chủ mới biết, viên Rainbow Fluorite này được mệnh danh là đá trí tuệ. Trong mỗi viên Rainbow Fluorite sẽ có ngẫu nhiên một đến hai loại phép thật khác nhau, chỉ cần người sử dụng cầm chúng là sẽ ngay lập tức học được. Vì thế mà loại đá này được nhiều giới học giả tại thế giới này săn đón.
B1820: Chà, đáng để Hakase thử nhỉ?
B1821: Tôi nhìn qua kệ trưng các loại Kim Cương, nhắm mắt lại và đưa tay ra chọn ngẫu nhiên một viên.
B1822: Nè con nhãi kia, giàu dữ ha, mua hẳn kim cương luôn mà.Q2 ]
B1823: Nhưng nó có hình hạt cà phê. [ Q1 ]
B1824: NHƯNG NÓ LÀ KIM CƯƠNG ĐẤY?! [ Q2 ]
B1825: Thì kim cương, nhưng hình hạt cà phê [ Q1 ]
B1826: Ừ rồi, hạt cà phê kim cương.[ Q2 ]
B1827: Dễ thương ha! [ Q1 ]
B1828: Tôi quyết định mua viên kim cương hình hạt cà phê này cho Kohi.
B1829: Shylvie: BÀ MUA THẬT HẢ?!
B1830: Hải Quỳ: Chứ chả lẽ mua giả hả má
B1831: Shylvie: TUYỆT VỜI! Mà bà mua gì đó?
B1832: Hải Quỳ: Quên rồi.
B1833: [ CG điện thoại biến mất.]
B1834: Tôi nhìn qua kệ trưng bày các loại Tourmaline, nhắm mắt lại và đưa tay ra chọn ngẫu nhiên một viên.
B1835: Congo Tourmaline cơ à? Ta tưởng ngươi sẽ mua viên đá nào màu xanh dương như Lapis Lazuli, Sapphire, Kyanite hay Zircon chứ?  [ Q2 ]
B1836: Tặng màu xanh dương cho đứa thích màu xanh dương là quá tầm thường rồi. Giờ xu hướng phải tặng màu " xa lánh "! [ Q1 ]
B1837: Haha, màu " xa lánh "!![ Q2 ]
B1838: Nhận ra rồi sao? [ Q1 ]
B1839: Tôi quyết định mua viên Congo Tourmaline này để tặng cho Shylvie. Bà chủ bảo khen tôi là người có mắt tinh tường. Vì viên Congo Tourmaline có khả năng triệu hồi ra một chiếc khiên phép thuật mạnh mẽ.
B1840: Chà, trùng hợp nhỉ?
B1841: Tôi đặt gói quà của Leo lên bàn, lấy đồng hồ báo thức đè lên nó. Mặc dù còn vài ngày nữa mới tới buổi tiệc giáng sinh nhưng không biết vì sao mà tôi cứ có cảm giác là bữa tiệc sẽ diễn ra vào ngày mai.
B1842: Tôi đặt gói quà của Hakase lên bàn, lấy đồng hồ báo thức đè lên nó. Mặc dù còn vài ngày nữa mới tới buổi tiệc giáng sinh nhưng không biết vì sao mà tôi cứ có cảm giác là bữa tiệc sẽ diễn ra vào ngày mai.
B1843: Tôi đặt gói quà của Kohi lên bàn, lấy đồng hồ báo thức đè lên nó. Mặc dù còn vài ngày nữa mới tới buổi tiệc giáng sinh nhưng không biết vì sao mà tôi cứ có cảm giác là bữa tiệc sẽ diễn ra vào ngày mai.
B1844: Tôi đặt gói quà của Shylvie lên bàn, lấy đồng hồ báo thức đè lên nó. Mặc dù còn vài ngày nữa mới tới buổi tiệc giáng sinh nhưng không biết vì sao mà tôi cứ có cảm giác là bữa tiệc sẽ diễn ra vào ngày mai.
B1845: Tôi lập tức đứng dậy, cầm theo túi quà tiến đến chỗ của Leo.
B1846: Uầy!! Đá quý?!
B1847: Leo thích món quà này hông?
B1848: Thích chứ! Vừa cầm nó trong tay thôi mà bao nhiêu mệt mỏi tan biến, thần kỳ thật đấy!!
B1849: - Ồ, Purple Garnet à? Lựa chọn không tồi đấy Quỳ!
B1850: - Trời trời tui mà lị!! Quá là tâm lý!!
B1851: Tôi vỗ ngực tự hào.
B1852: Dù rằng việc tôi mua viên đá này hoàn toàn là ngẫu nhiên.
B1853: Chắc chắn không phải cố tình chọn cho giống màu ai đấy.
B1854: Chắc chắn!
B1855: Leo đặt món quà mà tôi tặng xuống bàn, sau đấy đứng dậy và tiến đến chỗ Hakase, nở một nụ cười tươi tắn.
B1856: Tôi lập tức đứng dậy, cầm theo túi quà tiến đến chỗ của Hakase.
B1857: - Đá phong thủy đó Hakase! Đây là đá Rainbow Fluorite! Được mệnh danh là " Đá tri thức " đó!
B1858: - Hakase cầm chắc viên đá trong tay rồi truyền ma lực vào nó đi.
B1859: Hakase làm theo. Anh ấy nhắm mắt, từ từ chậm rãi truyền ma lực vào viên đá. Rainbow Fluorite tỏa ra ánh sáng rực rỡ, chiếu lên không trung một dãy ký tự dài như dải ruy răng, chúng từ từ xoay xung quanh Hakase.
B1860: [ Sprite Hải Quỳ nói chuyện ]
B1861: - Em nghe kể rằng mỗi viên Fluorite giống như một cuộn giấy phép thuật, chỉ cần anh cầm vào là sẽ học được phép thuật của nó ngay lập tức. Vậy viên này...có phép thuật gì vậy anh?
B1862: - Nó là phép thuật biến nho thành táo, biến báo thành gạch, biến cá trạch thành mèo, biến beo thành chó.
B1863: - Vãi...! Mấy phép thuật đó hiếm lắm đó Hakase!! Vì nào giờ em chỉ nghe truyền miệng, dè đâu giờ mới biết là nó có thật!!
B1864: - Nó...hiếm vậy luôn á hả?!
B1865: [ Sprite Shylvie nói chuyện ]
B1866: - Hiếm lắm!
B1867: - Thế để tớ đưa cho Shylvie học cùng nhé!
B1868: Hakase đưa viên Rainbow Fluorite ra trước mặt Shylvie.
B1869: - Dạ thôi, viên Fluorite nó chỉ truyền đạt kiến thức một lần duy nhất cho người đầu tiên kích hoạt được nó thôi.
B1870: - Ơ, buồn vậy...?
B1871: - Buồn gì chứ Hakase! Giờ viên Rainbow Fluorite đã trở thành một viên pin ma lực xịn xò cho Hakase lưu trữ rồi đó! Hơn nữa, nó còn có thể ghi chép thông tin mà Hakase truyền đạt cho nó nữa đó!!
B1872: - Xịn vậy sao! Cảm ơn Hải Quỳ và Shylvie nha! Tớ thich món này lắm!! Nó tuyệt vời quá đi mất!
B1873: Hakase ngay lập tức cất viên Rainbow Fluorite vào ngăn tủ không gian của anh ấy và lôi một chiếc hộp be bé từ đấy ra.Hakase tiến đến chỗ Kohi, nở một nụ cười đầy tự hào.
B1874: - TR-TRỜI ĐẤT ƠI?! HẠT CÀ PHÊ KIM CƯƠNG!
B1875: - Đúng rồi! Hạt cà phê kim cương!
B1876: - Trời đất ơi thiệt luôn đó hả?!
B1877: -À…Thế thì cả hai thua cược rồi.
B1878: - Chứ gì nữa…! Tui hông ngờ là bà giàu đến mức này đó?!
B1879: [ Sprite Shylvie tò mò ]
B1880: - Hừm…Tui thì nghĩ khác, vốn dĩ bả giàu ngầm nên mỗi tháng bả mới mua vài hộp " nhựa " ấy chứ.
B1881: [ Sprite Hakase nói ]
B1882: - Phú bà…!!
B1883: [ Sprite Leo nói ]
B1884: - Tui không ngờ là bà giấu tui về việc bà là…phú bà luôn đó Quỳ…!! Vậy mà lúc nào bà cũng than với tui là bà không có tiền…!!! BÀ ĐÙA TUI HẢ?!
B1885: [ Sprite Quỳ hoảng hốt nói ]
B1886: - Đ-Đâu!! T-Tôi đỗ khỉ nghèo thật mà!!
B1887: [ Mọi người cùng nói ]
B1888: - BỌN TUI CÓC TIN!!
B1889: [ Kohi nói ]
B1890: - Cảm ơn Hải Quỳ nha…!!
B1891: Kohi cài viên kim cương lên tóc. Cô ấy lấy từ trong túi xách của mình một chiếc hộp thiếc bóng loáng có vài đường vân được dát vàng sáng bóng cho bọn tôi chiêm ngưỡng rồi dúi nó vào tay Leo.
B1892: Tôi lập tức đứng dậy, cầm theo gói quà tiến đến chỗ của Shylvie.
B1893: - Giáng sinh an lành Shi-ru-vi! Tui hi vọng ông thích viên đá phong thủy này!
B1894: - WOW! Congo Tourmaline!!
B1895: - Nhìn phát biết luôn sao?
B1896: - Ồ, đương nhiên là nhìn phát biết ngay rồi! Bà lại còn tặng đúng viên mà tui muốn nữa chứ!
B1897: Shylvie vừa nói dứt lời, viên đá Congo Tourmaline phát ra ánh sáng rực rỡ. Một chiếc khiên màu xanh lá dứa trong suốt hiện ra. Nó tỏa ra một ánh sáng rực rỡ, hớp hồn tất cả mọi người trong văn phòng.
B1898: [ Sprite của ba người biến mất. Sprite của Shylvie ngạc nhiên ]
B1899: - GÌ CƠ?? CHIẾC KHIÊN HUYỀN THOẠI Ở CHIỀU KHÔNG GIAN CỦA SHYLVIE Á??
B1900: - NÓ LÀ MÓN QUÀ TUYỆT CÀ LÀ VỜI QUỲ Ạ! ĐỈNH CỦA CHÓP! XUẤT SẮC CÀ CHUA!!
B1901: - À đâu có gì đâu, đang tò mò bà tính tặng gì cho tui!
B1902: Shylvie đưa cho tôi một chiếc hộp giấy bé xinh.
B1903: - Gì? Bà không đoán được à?
B1904: - Nah, không muốn đoán!
B1905: - Thế thì không tặng!
B1906: - Gì kỳ cục vậy?! Vậy thì…Huy hiệu? Móc khóa? Chuông?
B1907: - Sai bét! Mở ra xem thử đi.
B1908: Tôi cẩn thận mở hộp giấy ra xem. Bên trong là một viên đá Sapphire lấp lánh.
B1909: -Uầy…! Đá Sapphire luôn hả!! Xịn dữ vậy?
B1910: - Không xịn mới lạ! Nó được khảm ma thuật dịch chuyển đấy.
B1911: - Hả?! Sao lại khảm ma thuật dịch chuyển?! Tui muốn ma thuật beam cơ!
B1912: - Chê thì trả đây!
B1913: - Hông, đã tặng rồi thì không có quyền đòi, lêu lêu. Ngon thì dí tui nè!
B1914: Shylvie toan lao đến lấy lại quà thì tôi dùng viên Sapphire dịch chuyển. Cứ thế, tôi dịch chuyển, Shylvie chạy theo dí. Về sau Shylvie cũng dùng ma thuật dịch chuyển để dí tôi. [ Cái này làm cutscene ]
B1915: -Đứng lại!!
B1916: [ Hiện CG Shylvie ném tuyết vào người Hải Quỳ ]
B1917: -Còn lâu!! Lêu lêu!
B1918: -Hông, tui ổn! Tui chỉ đang tò mò về món quà bà tính tặng ý mà!
B1919: - À!!
B1920: Vừa mở tủ lạnh, tôi nghe thấy tiếng Leo bước vào. Quay qua thì đã thấy gương mặt Leo hớn hở đặt lên bàn ăn một chiếc chuông gió mà ông ấy tự chế.
B1921: [ Leo nói ]
B1922: - Thấy sao? Đẹp chứ!
B1923: - Đẹp!! Nhìn lạ mắt lắm. Mấy mảnh đá hồng tím đó ở đâu ra vậy?
B1924: - Là viên đá phong thủy bà tặng tui đó. Khuya hôm qua, lúc tui tính đặt nó lên bàn làm việc thì nó nổ cái đùng luôn!! Tui thấy tiếc quá nên là tui cặm cụi làm suốt đêm đó, thành quả đâu tệ đâu, đúng hông?
B1925: - Ừ! Leo khéo tay thật đó!! Đâu cho tui nghe thử tiếng của nó đi!!
B1926: Leo liền cầm chiếc chuông gió lên, nhẹ đung đưa qua lại nhịp nhàng. Từng mảnh đá vỡ phát ra tiếng leng keng leng keng trong trẻo, êm tai.
B1927: Sau đấy Leo mang chiếc chuông gió tự chế ấy treo trong văn phòng riêng của ổng. Còn tôi lôi hũ kem socola ra xử. Múc từng vá cho vào miệng, tôi có thể cảm thấy sự hạnh phúc của tôi đang tan chảy, sự vui sướng tê rần rần trên da đầu.
B1928: Ngon quá…!!
B1929: Vừa bước vào bếp, tôi trông thấy Kohi đang đứng trước máy pha cà phê, gương mặt mệt mỏi.
B1930: - C-Chuyện gì xảy ra vậy Kohi?
B1931: - Không hiểu sao, từ tối qua đến giờ, tui cứ ngủ được 30p là gặp ác mộng một lần…Ngủ không nổi nên tui quyết định pha cà phê uống cho dễ ngủ...Mà dè đâu uống xong ngủ không được, trằn trọc, bức bối, ngứa ngáy khắp cơ thể!! Thế là tui đành ra ngoài bếp ngồi, dè đâu ngồi được xíu là gục xuống ngủ một mạch tới sáng luôn!
B1932: - Hừm, bà mới bị như thế hay là lâu lâu bị như thế?
B1933: - Tui chưa bị như thế bao giờ cả.
B1934: - Rồi hiểu, để tui xử lý.
B1935: Nói rồi tôi lên phòng của Kohi kiểm tra. Trông thấy tôi đang lục lọi phòng của Kohi, Shylvie tò mò bước vào hỏi chuyện. Sau một hồi trao đổi, tôi mới biết rằng ở thế giới của Shylvie, có một số loại kim cương có khả năng thanh trừng Quỷ, vô tình viên kim cương mà tôi mua tặng cho Kohi lại chính là loại kim cương thanh trừng nhưng yếu hơn nên chỉ khiến cho Kohi gặp ác mộng khi ngủ.
B1936: Tôi không do dự mà bóp nát viên kim cương đó trước sự ngỡ ngàng của Shylvie, người mới nhớ ra mình có phép thuật tái cấu trúc vật thể. Vì tôi đã vô tình bóp nát phép thuật thanh trừng của viên kim cương nên Shylvie chỉ cần dùng phép ghép nó lại thôi.
B1937: Bảo sao tôi cảm thấy mệt mệt. Thôi, xuống múc kem ăn thôi!
B1938: Tôi lôi hũ kem socola ra xử. Múc từng vá cho vào miệng, tôi có thể cảm thấy sự hạnh phúc của tôi đang tan chảy, sự vui sướng tê rần rần trên da đầu.
B1939: Ngay khi tôi vừa mở tủ lạnh, Shylvie bước vào, vẫy vẫy chiến khiên gắn trên tay mà chào tôi.
B1940: - Bà về rồi hả!! Nhìn nè, xịn không!!
B1941: Tôi nheo mắt săm soi chiếc khiên màu xanh lá dứa trong suốt của Shylvie. Hình như có gì đó khang khác, có vẻ Shylvie đã dành hết tâm huyết suốt tối hôm qua để " độ " cho chiếc khiên huyền thoại này.
B1942: - Chưa xịn, nhìn có khác gì tối qua đâu.
B1943: - Nhìn nè!!
B1944: Chiếc khiên phát sáng, hũ kem trong tủ lạnh ngay lập tức biến mất và xuất hiện trên tay của Shylvie. Sau đó Shylvie nhét hũ kem vào chiếc khiên, lắc chiếc khiên thật mạnh rồi đập nó xuống bàn ăn. Hàng chục hũ kem cùng kích cỡ mau chóng hiện hình trên bàn.
B1945: Chiếc khiên gì xịn đét.
B1946: Nhưng khi tôi mở hũ kem ra để ăn thì nhận ra, chẳng còn miếng kem nào trong hũ cả. Tôi mở hết mấy hũ còn lại, cũng chẳng có miếng kem nào trong đó.
B1947: Chiếc khiên gì tệ đét.
B1948: Bước vào phòng bếp, tôi thấy Hakase đang đứng pha cà phê. Trông thấy tôi, Hakase vui vẻ chào đón:
B1949: - Mừng Hải Quỳ về nhà, làm miếng cà phê kem socola không?
B1950: Hakase đưa chiếc cốc cà phê nóng hổi ra cho tôi. Đón lấy cốc cà phê, tôi làm một hơi hết sạch cốc.
B1951: - Viên đá mà Hải Quỳ tặng cho tui tối qua tuyệt vời lắm đó! Tối qua mọi người thèm ăn táo mà ai cũng lười ra ngoài mua nên tui đã biến hết nho trong tủ thành táo! Giòn ngọt lắm luôn, không khác gì táo thật. Còn một trái trong tủ đó, nè.
B1952: Nói rồi Hakase lấy quả táo cuối cùng ném cho tôi. Bắt lấy quả táo, tôi không do dự cắn thử một miếng. Chà, đúng như Hakase nói, nó giòn nó ngọt gì đâu.
B1953: - À, tui có chuyện này muốn nói cho Hải Quỳ, không có gì to tát đâu, chỉ là chuyện be bé thôi.
B1954: - Sao á?
B1955: - Nếu mà bà có ý định tặng đá phong thủy cho Leo hay Kohi á thì không nên nha. Vì đá phong thủy còn có tác dụng xua đuổi ma quỷ á. Leo là ma cà rồng còn Kohi là quỷ cà phê, lỡ mà tặng cho hai người đó thì…
B1956: - Ồ! Giờ tui mới biết! Cảm ơn Hakase nha! Tui sẽ lưu ý!
B1957: [ màn hình đen ]
B1958: Sau đó tôi đứng xem Hakase biểu diễn các phép thuật của viên đá tri thức. Ông hô biến ra một cục gạch rồi biến nó thành một con chuột lang. Rồi biến con chuột lang thành con báo hoa mai, biến con báo hoa mai thành một khúc gỗ rồi biến khúc gỗ ấy thành quả cam.
B1959: Tôi có nên ăn quả cam đó không...?
B1960: CÁC BOX CHAT XUẤT HIỆN ĐẦU GAME [ VĂN PHÒNG SILVERWING ]
B1961: [ Box chat của Momo ]
B1962: Momo: Dahria.
B1963: Dahria: Sao vậy mẹ?
B1964: Momo: Con có uống cà phê thì về nhà lấy nhé. Dì vừa gửi về vài hộp đấy.
B1965: Dahria: Vâng, con cảm ơn. Khi nào về con sẽ lấy.
B1966: [ Box chat của Popo ]
B1967: Popo: Ráng đừng thức khuya nữa đấy, hại sức khỏe lắm.
B1968: Dahria: Vâng, con biết rồi.
B1969: Popo: Biết rồi mà giờ này còn nhắn hả?
B1970: [ Box chat của OniiOni-chan ]
B1971: OniiOni-chan: Rảnh không? Nhờ cái.
B1972: Dahria: Sao á hai?
B1973: OniiOni-chan: Mày làm hộ tao cái này.
B1974: ( Link hỏng )
B1975: Dahria: Link hỏng rồi hai ơi.
B1976: Dahria: Hai ơi?
B1977: [ Box chat của Hoàng Hà ]
B1978: Hoàng Hà: Ui, Omega D-13!! Cậu có nghe về loại hộp mù mới chưa?
B1979: Omega D-13: Hộp mù nào thế?
B1980: Hoàng Hà: Hộp mù về bộ ba vệ binh Atlantis ấy!! Trông xịn lắm!! Nao tớ mua rồi cậu khui hộ tớ nhé! Tớ tin tưởng vào bàn tay trân châu của cậu đấy!
B1981: Omega D-13: OK.
B1982: [ Box chat của Ánh Lam ]
B1983: Ánh Lam: Omega D-13.
B1984: Ánh Lam: Tớ biết thân phận thật sự của cậu rồi.
B1985: Ánh Lam: Cậu không phải Omega D-13. Cậu chỉ giả vờ làm Omega D-13 mà thôi.
B1986: Ánh Lam: Cả Hải Bình nữa, cậu cũng giả vờ làm cậu ấy.
B1987: Ánh Lam: Cậu là Hải Quỳ, đúng chứ?
B1988: Ánh Lam: Hải Bình đã chết trước khi cậu gia nhập Binh Đoàn Sứa Lam, đúng không?
B1989: ________________________
B1990: KIỂM TRA KHI ĐẾN SIÊU THỊ/VĂN PHÒNG WANDERER
B1991: Hoàng Hà: Omega D-13.
B1992: Omega D-13: Tớ đây!
B1993: Hoàng Hà: [ Gửi ảnh Selfie ]
B1994: Hoàng Hà: Tóc mới nè, đẹp không?
B1995: Omega D-13: Ồ, đẹp! Cậu mới cắt ngắn đi một chút à?
B1996: Hoàng Hà: Yup! Cậu tinh ý thiệt đó!
B1997: Hoàng Hà: Ánh Lam nghệch mặt ra khi thấy tớ khoe. Còn hỏi là:" Cậu vừa mới nhuộm tóc hả " nữa chứ!
B1998: Hoàng Hà: Màu tóc của tớ xưa giờ vẫn thế ấy chứ!
B1999: Hoàng Hà: Thiệt sự bực mình quá đi!
B2000: Omega D-13: Cậu có ảnh hồi xưa hông, cho tớ dễ so sánh?
B2001: Hoàng Hà: Đợi chút! Để tớ lục lại!
B2002: [ Box chat của Alpha C-61 ]
B2003: Alpha C-61: Đồng chí ơi, cứu tôi…
B2004: Omega D-13: Hả? Chuyện gì thế?
B2005: Alpha C-61: Tôi…TÔI Ứ LÀM NỮA!!
B2006: Alpha C-61: CƠM CHÓ CỨ ĐẬP VÀO MẶT TÔI NHƯ THẾ NÀY!! MẤT TẬP TRUNG QUÁ!
B2007: Omega D-13: Hai người họ chim chuột dữ vậy luôn á hả?
B2008: Alpha C-61: Còn tệ hơn cả chim chuột. TÔI BỊ PHÂN BIỆT ĐỐI XỬ!!
B2009: Alpha C-61: Iota F-40 ngọt ngào với Beta M-34 bao nhiêu thì khắt khe với tôi bấy nhiêu!!
B2010: Alpha C-61: Nào là gọt hoa quả cho cậu ấy ăn, làm giúp phần sổ sách…Rồi quay sang quát mắng tôi, huhu :(((
B2011: Omega D-13: Phải gì ạ? Phải chịuuuuuuuuuuuu
B2012: Omega D-13: Trách ai bây giờ đây hả đồng chí?
B2013: Alpha C-61: Huhuhuhuhu, đồng chí đến văn phòng cứu tôi với!
B2014: Omega D-13: [ Gửi Meme Daga Kotowaru ]
B2015: BOX CHAT CỦA CÁC THÀNH VIÊN WANDERER SAU KHI CHỌN QUÀ
B2016: Route: Máy Pha Cà Phê
B2017: [ Box chat của Kohi ]
B2018: Kohi: Hải Quỳ ơi!
B2019: Hải Quỳ: Tui đây, sao á?
B2020: Kohi: Hải Quỳ có biết sở thích của Hakase là gì không?
B2021: Hải Quỳ: Hmm, Quỳ cũng không rõ. Chỉ nhớ là ảnh khá thích các ấn phẩm liên quan đến Gundam, Armored Core, Genshin Impact ấy.
B2022: Kohi: Nhưng ổng có gần hết rồi. Tặng nữa sẽ trùng mất!
B2023: Kohi: Cảm ơn Quỳ nha! Tui nghĩ ra món quà phù hợp với ổng rồi!
B2024: [ Box chat của Hakase ]
B2025: Hakase: QUỲ QUỲ!! HỎI TÍ HỎI TÍ, GẤP GẤP!
B2026: Hải Quỳ: Hả, sao vậy anh?
B2027: Hakase: Anh đang bị phân vân.
B2028: Hakase: Anh đang tạo một loại vật phẩm ma thuật mới cho Shylvie. Nhưng không biết nên tạo kiểu dáng nào cho sì lay.
B2029: Hakase: Cho anh xin ý tưởng với!
B2030: Hải Quỳ: Sì lay hả?
B2031: Hải Quỳ: Kim cương hột xoàn. Mèo lông xù nơ đỏ. Xẻ tà phá cách?
B2032: Hakase: Ồ! Ý kiến hay! Cảm ơn em!
B2033: Route: Khăn Len
B2034: [ Box chat của Leo ]
B2035: Leo: Tui có ý tưởng điên rồ lắm Quỳ ạ.
B2036: Hải Quỳ: Ông tính nướng lu con heo, đẩy Shylvie xuống biển à?
B2037: Leo: Ừ đúng. Nhưng cái đó để sau.
B2038: Leo: Bà nghĩ sao…về việc tạo lỗ trên áo choàng?
B2039: Hải Quỳ: Ồ, phong cách bụi bặm hả! TUYỆT!
B2040: [ Box chat của Shylvie ]
B2041: Shylvie: Quỳ!
B2042: Hải Quỳ: Sao?
B2043: Shylvie: Tui mới để ý là bàn làm việc của bà bị lủng một lỗ to tướng.
B2044: Shylvie: Có cần tôi sửa lại không?
B2045: Hải Quỳ: Nah. Tui sẽ tự sửa bằng phép tui mới học lỏm từ Hakase.
B2046: Shylvie: Ok.
B2047: Route: Dao Và Chảo
B2048: Leo: Hải Quỳ, tui đang ở cửa hàng mô hình đồ chơi để mua quà tặng Hakase nè. Bà có mẫu nào hay hay thì giới thiệu cho tui với!
B2049: Hải Quỳ: NHIỀU LẮM LEO Ạ, ÔNG MUA HẾT CẢ CỬA TIỆM CHO TUI!
B2050: Leo: MUA CHO BÀ LẮP TẸT GA HẢ? CÒN LÂU NHA!
B2051: Hải Quỳ: THẾ THÌ MUA MẪU NÀO MÀ XANH VÀNG ĐỎ, CÓ KHIÊN MÀU ĐỎ CHO TUI! MẪU NÀO BỰ CHÀ BÁ CÀNG TỐT!
B2052: Leo: Ok.
B2053: Shylvie: Bà có thấy cái hộp blu-ray Sousou no Frieren của tui đâu không?
B2054: Hải Quỳ: Tui để trong hộc tủ trong phòng ngủ tui á bà. Tự vô lấy đi, mật khẩu là 0290120240012202.
B2055: Shylvie: Đặt mật khẩu gì dài dữ vậy má?
B2056: Hải Quỳ: Vặt tay tui đi là mật khẩu ngắn lại à.
B2057: Hakase: Hải Quỳ, anh mới mua Gundam RG 78 EX080 nè!
B2058: Hải Quỳ: UẦY!! Gundam RG 78 EX080 LUÔN!
B2059: Hakase: Em biết điều gì thú vị hông?
B2060: Hakase: ANH SẼ HÓA VÀNG NÓ!
B2061: Hakase: Bằng phép thuật mà anh học lỏm từ Shylvie!
B2062: Hải Quỳ: CHÁY!!!
B2063: Hakase: VÀ RỒI ANH SẼ BÁN NÓ!
B2064: Hải Quỳ: Hả gì?
B2065: Hakase: Anh sẽ bán nó!
B2066: Hakase: Anh sẽ làm giàu cho Wanderer!!
B2067: Hải Quỳ: Y-Ý hay đó anh!
B2068: Route: Bộ Phá Khóa
B2069: Hải Quỳ: Hải Quỳ đây!
B2070: Kohi: Hải Quỳ có biết chỗ nào mua khiên phép thuật không á?
B2071: Hải Quỳ: Hông! Leo biết á Kohi, hỏi ổng thử!
B2072: Kohi: Oki, cảm ơn Quỳ!!
B2073: Leo: Quỳ!
B2074: Hải Quỳ: Sao ó?
B2075: Leo: Nãy bà vừa vô văn phòng à?
B2076: Hải Quỳ: Hả? Đâu có?
B2077: Leo: Ủa? Thế ai vừa vô phòng bếp lấy mất thùng sting của tôi vậy?
B2078: Hải Quỳ: Shylvie? Hakase?
B2079: Leo: Shylvie vẫn đang ngồi soạn giấy tờ mà. Vậy chắc là Hakase rồi.
B2080: Hải Quỳ: Quá tày rồi!
B2081: _______________________
B2082: KIỂM TRA TRƯỚC BỮA TIỆC GIÁNG SINH
B2083: [ Box chat của ông Ba Bị ]
B2084: Ông Ba Bị: Chào Hải Quỳ.
B2085: Ông Ba Bị: Hải Quỳ, ngươi có muốn tham gia một trò chơi nho nhỏ với ta không?
B2086: Ông Ba Bị: Nếu có hứng thú, hãy bấm vào đây.
B2087: [ Link bị chặn ]
B2088: Hoàng Hà: [ Gửi ảnh hồi xưa của Hoàng Hà, Ánh Lam, Hải Bình ]
B2089: Hoàng Hà: Nhìn nè! Màu tóc tớ đâu có thay đổi đâu!
B2090: Omega D-13: Đúng, chỉ thay đổi kiểu tóc. Mà hồi xưa trông cậu tinh nghịch hơn bây giờ nhỉ?
B2091: Hoàng Hà: Giờ cũng vậy thôi, khác gì! Mà cũng có thể tớ đã bớt tinh nghịch hơn tí? Haha, ai biết được!
B2092: Hoàng Hà: Cơ mà nhìn lại, nhìn cậu với Hải Bình như song sinh ấy!
B2093: Hoàng Hà: Mỗi tội, cậu ít cười hơn so với Hải Bình. Nếu mà cười nhiều hơn là giống y như đúc!
B2094: Omega D-13: Ánh Lam cũng nói vậy.
B2095: Hoàng Hà: Chà, đến cả Ánh Lam cũng nói vậy thì…Cậu với Hải Bình thực sự là song sinh hả?
B2096: Omega D-13: Đâu ra.
B2097: Hoàng Hà: Thiệt không? Cậu không có chị hay em gái hả?
B2098: Omega D-13: Mất rồi.
B2099: Hoàng Hà: Xin lỗi vì khơi lại chuyện...!
B2100: Omega D-13: Không sao đâu!
B2101: ______________________________________________________
B2102: KIỂM TRA TRONG BỮA TIỆC GIÁNG SINH
B2103: Hoàng Hà: [ Gửi ảnh ăn bánh vòng với Ánh Lam ]
B2104: Hoàng Hà: Gần chỗ tụi tớ làm vừa mới mở quán bánh vòng ngon lắm nè!
B2105: Hoàng Hà: Ánh Lam ăn nhiều lắm luôn!
B2106: Hoàng Hà: Hôm nào tớ mời cậu ăn!!
B2107: Hoàng Hà: Có vị dứa đó!
B2108: OniiOni-Chan: Ở phía dưới này đang loạn, nếu mày có về thì cẩn thận.
B2109: Dahria: Sao vậy hai?
B2110: OniiOni-Chan: Có một con Quái Vật Vực Sâu có khả năng ngụy trang đã lọt vào trong thành phố Atlantis. Không rõ là có bao nhiêu con nên khi về thì nhớ chú ý an toàn.
B2111: Dahria: Hai đánh giá thấp em thế.
B2112: OniiOni-chan: Không. Tao không có rảnh để chăm mày trong bệnh xá.
B2113: Omega D-13: Phải nói thật, giả thuyết của cậu hay đấy.
B2114: Omega D-13: Nhưng tớ là tớ, không phải Hải Bình.
B2115: Omega D-13: Đúng là hai bọn tớ giống nhau, nhưng cả hai không phải là một.
B2116: Omega D-13: Hãy để ký ức của người đã khuất nằm trong tim cậu, đừng áp đặt lên tớ.
B2117: Ánh Lam: Tớ hiểu. Tớ xin lỗi.
B2118: Ánh Lam: Vậy cậu thừa nhận mình là Hải Quỳ à?
B2119: Omega D-13: ….
B2120: Ánh Lam: Đùa thôi. Xin lỗi!
B2121: Ánh Lam: Bọn tớ vừa tìm ra chỗ bán bánh vòng ngon lắm. Có vị dứa mà cậu thích đấy. Hôm nào tớ mời ăn tạ lỗi.
B2122: Ánh Lam: Đừng giận nha.
B2123: Omega D-13: Nếu cậu mua số lượng đúng số hiệu của tớ!
B2124: Ánh Lam: Được.
B2125: [ Box chat Alpha C61 – Tin nhắn hiện luôn ]
B2126: Alpha C-61: Omega D-13! Có chuyện lớn!!
B2127: Alpha C-61: Tui biết là bây giờ đồng chí đang trong đợt nghỉ phép nhưng chuyện này cấp bách lắm rồi!
B2128: Alpha C-61:  Beta M-34 đã tìm ra được điểm vô lý trong lúc kiểm tra lại hồ sơ về lỗ hổng vực sâu 61.
B2129: Alpha C-61: Ngoại trừ tôi với Beta M-34 thì những người còn lại được điều xuống khu vực rìa lỗ hổng vực sâu 61 để điều tra dị thường.
B2130: Alpha C-61:  Nhưng đã hơn ba ngày rồi mà không ai gửi báo cáo lại cho chúng tôi cả.
B2131: Alpha C-61: Tôi đã cố liên lạc với họ nhưng không một ai phản hồi hết!
B2132: Alpha C-61:  Dường như tất cả thiết bị của bọn họ đều bị ngừng hoạt động cùng lúc!
B2133: Alpha C-61: Chúng tôi cho rằng họ đang gặp sự cố.
B2134: Alpha C-61:  Beta M-34 yêu cầu đồng chí phải quay trở về gấp để thực thi nhiệm vụ giải cứu.
B2135: Omega D-13: Đã rõ.
B2136: [ Box chat Đội phòng chống thảm họa Nguyệt Thực 6 – Tin nhắn hiện luôn ]
B2137: A2: Theo thông tin tình báo từ B4 và E5, có một con Quái Vật Vực Sâu cấp độ nguy hiểm cao có khả năng biến đổi muôn hình vạn trạng đang lẩn trốn. Lập tức tiêu diệt nếu đụng độ.
B2138: F7: Báo cáo, tôi đã chạm mặt với nó.
B2139: A2: Vị trí hiện tại?
B2140: F7: Tuyến đường cao tốc Iacon, hiện đang tổ chức sơ tán và phong tỏa.
B2141: F7: Nhiệm vụ thất bại, Quái Vật Vực Sâu đã trốn thoát. Cứu được B4 và E5. Mức độ tổn thất chưa rõ.
B2142: A2: Đội phòng chống thảm họa Nguyệt Thực 3 vừa liên hệ. Họ đã thiết lập một hàng rào quanh thành phố Atlantis và có mong muốn bên mình sẽ gửi đội hỗ trợ ngay lập tức nếu xảy ra diễn biến căng thẳng. D3 và H10 sẽ gia nhập đội hỗ trợ, thay thế cho B4 và E5. Hai đồng chí bắt buộc phải sẵn sàng cho tình huống cấp bách, đã rõ chưa?
B2143: D3: Đã rõ, thưa chỉ huy.
B2144: H10: Đã rõ, thưa chỉ huy.
B2145: Văn phòng Silver Wing
B2146: ( 001,003 ) Tủ lạnh chung của văn phòng Silver Wing. Gamma A-36 thường lén ăn vụng pudding của Epsilon B-21 cất trong này.
B2147: ( 002,003 ) Bảng ghi chú của văn phòng. Chả hiểu sao Omicron G-06 lại dán mật khẩu máy tính ở đây.
B2148: ( 003,003 ) Tên của Alpha C-61 và Beta M-34 được ghi trên bảng phân công ca trực, phía dưới ghi chú: trực một tuần.
B2149: ( 004,003 ) Tấm áp phích thiên văn của Sigma E-33. Alpha C-61 luôn miệng chê và đòi tháo nó xuống.
B2150: ( 005,003 ) – Tủ tài liệu.
B2151: ( 007,003 ) - ( 008,003 ) – Vô số bảng thống kê được Zeta K-89 viết trên đây. Anh ấy thực sự là một siêu máy tính biết đi của Silver Wing.
B2152: ( 010,003 ) – Tủ đựng các loại cà phê, bột thức uống của Silver Wing. Lambda T-79 thường là người pha thức uống cho cả văn phòng. Mình nhớ vị Matcha Latta của cô ấy pha quá.
B2153: ( 011,003 ) – Tủ sách nghiên cứu của Beta M-34.
B2154: ( 013,003 ) – Chậu cây ăn thịt của Omega E-102. Tay của Epsilon B-21 suýt bị gặm mất khi anh ấy đi ngang qua đây.
B2155: ( 003, 005 ) – Bàn làm việc của Beta M-34
B2156: [ Thoại tương tác 3 lần ở ( 004, 005 )
B2157: Lần 1:
B2158: Beta M-34: “ Đáng ra tôi phải đệ đơn yêu cầu thay đổi nhân sự từ tháng trước rồi. “
B2159: Omega D-13: “ Tận tháng trước á? “
B2160: Beta M-34:” Cậu không muốn biết tôi muốn thuyên chuyển ai à? “
B2161: Omega D-13:” Khỏi, tôi biết thừa. Nhưng rồi sao không nộp vậy? “
B2162: Beta M-34: “ Tại tôi nợ Alpha C-61 một mạng. “
B2163: Omega D-13:” Ra là vậy. Thôi thì tháng này cậu nên nộp luôn đi, đừng chần chừ. “
B2164: Alpha C-61: “ Ê, gì ác vậy hai má?“
B2165: Lần 2:
B2166: Beta M-34:” Tôi không hiểu. “ Băng Hoại Đường Ray Tinh Tú “ có gì hay vậy? “
B2167: Omega D-13:” Tôi không biết. Cậu phải hỏi Alpha C-61 chứ? “
B2168: Beta M-34:” Tôi hỏi rồi. Xong cô ấy nói thứ ngôn ngữ gì đó mà tôi không hiểu. “
B2169: Omega D-13:”....Hết cứu. Tôi đoán chắc là bả đang mô tả về nhân vật yêu thích mà bả yêu thích trong game? “
B2170: Alpha C-61:” Chứ gì nữa!! Đúng là chỉ có Omega D-13 hiểu tôi!! Beta M-34 làm sao mà biết được vẻ đẹp của-“
B2171: Omega D-13:” Thôi thôi, stop! Dừng lại! Tôi không muốn nghe!! “
B2172: Lần 3:
B2173: Beta M-34: “ Thế Omega D-13 đã có kế hoạch giáng sinh này chưa?  “
B2174: Omega D-13: “ Chưa! Chắc là nằm lăn dài trên giường thôi! Beta M-34 thì sao?“
B2175: Beta M-34:” Tôi có hẹn với Iota F-40. Nhưng cậu thấy đấy, cứ cái đà này, có khi tôi phải hủy hẹn với cô ấy. “
B2176: ( Nếu đã nghe tin nhắn thoại của Iota F-40 )
B2177: Omega D-13:” Cậu không hủy hẹn được đâu. Iota F-40 đang trên đường đến đây để phụ cậu với Alpha C-61 đấy. “
B2178: Beta M-34:” Vậy sao…? Hmmmm “
B2179: Omega D-13:” Hmmm cái gì, bộ cậu thực sự tính hủy hẹn với bả đấy à? “
B2180: Beta M-34:” Đâu có...Tôi không biết mình phải phản ứng ra sao. “
B2181: Omega D-13:” Haha, thôi, tôi về đây! Mấy người chim chuột vui vẻ! “
B2182: ( Nếu chưa nghe tin nhắn thoại của Iota F-40 )
B2183: Omega D-13:” Tôi có cảm giác là cậu không nên hủy hẹn với Iota F-40 đâu. Một phần vì bả sẽ ghim cậu, một phần là bả sẽ không để cậu hủy đâu. “
B2184: Beta M-34:” Ý cậu là sao? Không để tôi hủy? “
B2185: Omega D-13:” Là một người bạn lâu năm của Iota F-40, tôi cá chắc là bả sẽ chạy tức tốc đến đây để phụ cậu…và rồi gõ vào đầu Alpha C-61 đấy. “
B2186: Beta M-34:” Vậy sao...? Iota F-40 chưa bao giờ nói về việc hai người cậu thân nhau đến vậy. “
B2187: Omega D-13:” Ê, đau nha! “
B2188: Beta M-34:” Xin lỗi. Vì cậu cũng có khả năng nhìn trước tương lai nên mới biết vụ Iota F-40 đang trên đường tới đây. “
B2189: ( 013,007 ) - ( 014,007 ) – Tủ quân trang khẩn cấp. Iota F-40 hay phàn nàn mình mỗi khi ai đó làm hỏng vũ khí của cô ấy.
B2190: [ Thoại tương tác 2 lần ở ( 009, 007 )
B2191: Lần 1: Điện thoại kiêm máy Fax. Sigma E-33 hay bị giật mình khi nghe thấy tiếng máy Fax.
B2192: Lần 2:  Có tin nhắn thoại mới. “ Iota F-40 đây. Omega D-13 đang nghe đúng không? Hãy nhắn lại với cô ấy rằng tôi sẽ đến phụ, đừng có mà hủy hẹn với tôi! “. Khả năng nhìn trước tương lai của Iota F-40 đáng sợ thật đấy…Sao cô ấy biết tôi đang nghe máy vậy? Đành phải báo lại cho Beta M-34 thôi.
B2193: ( 005, 005 )  - Bàn làm việc của Alpha C-61
B2194: [ Thoại tương tác 2 lần ở ( 006, 005 )
B2195: Alpha C-61:” Tôi cứ có cảm giác bất an. “
B2196: Omega D-13:” Bất an cái gì cơ? “
B2197: Alpha C-61:” Nãy giờ ngồi kiểm tra lại đống tài liệu này, tôi cứ thấy có gì đó sai sai mà không biết nó sai ở đâu ấy. “
B2198: Omega D-13:” Chắc không sao đâu. Zeta K-89 đã kiểm tra sơ bộ rồi, làm sao mà có sai sót được. “
B2199: Alpha C-61:” Ai mà biết được?! Bà hông biết là hồi bữa Zeta K-89 tính nhầm chi phí sửa chữa làm Iota F-40 hét ầm hét ĩ lên hả? “
B2200: Omega D-13:” Không. Hồi nào đấy? Đừng nói là đúng cái hôm tôi nghỉ phép nhé? “
B2201: Alpha C-61:” Ừ, bảo sao bà hông biết. Nhưng chắc bà biết là mỗi khi tôi bất an là đều xảy ra sự cố đúng hông? “
B2202: Omega D-13:” Cái miệng ăn mắm ăn muối này!! “
B2203: Alpha C-61:” Haha, nhưng biết đâu cũng nhu Zeta K-89, linh cảm của tôi sẽ có lúc sai thì sao? “
B2204: Omega D-13:” Mong là vậy…! Ê, nhưng mà lỡ có cớ sự thì nhớ đánh tiếng nhé. “
B2205: Alpha C-61:” Tận tụy công việc ghê! Ok thôi, có gì tôi đánh tiếng. “
B2206: Alpha C-61:” Ê, tôi chợt nhận ra một điều. “
B2207: Omega D-13:” Nhận ra cái gì cơ? “
B2208: Alpha C-61:” Gamma A-36 với Epsilon B-21 có gì đó mờ ám…? “
B2209: Omega D-13:” Mập mờ mới đúng. Tôi chịu đủ cảnh hai ổng vờn nhau trong văn phòng rồi! “
B2210: Beta M-34:” Tôi tưởng đó là hành động vô cùng bình thường giữa hai người bạn thân? “
B2211: Alpha C-61:” Đâu ra! Nếu nói thế thì cậu với Iota F-40…”
B2212: Beta M-34:” Bọn tôi đâu phải bạn thân, đương nhiên là sẽ không có hành động đó rồi. “
B2213: Omega D-13:” Đến giờ tôi vẫn không hiểu sao bà với Iota F-40 có thể tiến triển đến vậy đấy. “
B2214: Alpha C-61:” Ừ, tôi cũng thế. “
B2215: Beta M-34:” Tôi chưa hiểu ý hai người lắm.”
B2216: Alpha C-61:” Thôi phức tạp lắm, không cần hiểu đâu. “
B2217: Omega D-13:” Ừ, không cần hiểu đâu. “
B2218: ( 003,008 ) -  ( 004,008 ) – Bàn làm việc của mình. Không ai biết rằng trong ngăn tủ này được nhét đầy thạch rau câu vị cam.
B2219: ( 005,008 ) -  ( 006,008 ) – Bàn làm việc của Sigma E-33
B2220: ( 007,008 ) -  ( 008,008 ) – Bàn làm việc của Omicron G-06. Cô ấy lại dán sai mật khẩu máy tính rồi. Phải là “ phokingpassword “!!
B2221: ( 007,005 ) -  ( 008,005 ) – Bàn làm việc của Lambda T-79
B2222: ( 005,009 ) -  ( 006,009 ) – Bàn làm việc của Iolta F-40
B2223: ( 007,009 ) -  ( 008,009 ) – Bàn làm việc của Zeta K-89.
B2224: ( 009,009 ) -  ( 010,009 ) – Bàn làm việc của Omega E-102. Trong hộc tủ nhét đầy các loại phân bón.
B2225: ( 005,012 ) -  ( 006,012 ) – Bàn làm việc của Gamma A-36. Cuốn lịch để trên bàn của anh ấy có ghi chú:” Ăn pudding vị nào cũng được, trừ vị cà phê của tôi ra! “.
B2226: ( 007,012 ) -  ( 008,012 ) – Bàn làm việc của Epsilon B-21. Trên bàn có một sấp giấy phong bì kèm tờ ghi chú:” Anh giận tôi đấy à? Đừng giận nữa, tôi đền bù cho anh nè~ “.
B2227: ( 009,012 ) -  ( 010,012 ) – Bàn làm việc của Delta P-97. Như thường lệ, trên bàn đầy dụng cụ bảo dưỡng vũ khí.
B2228: ( 001,011 ) - ( 001,012 ) – Chậu cây phóng gai của Omega E-102. Iota F-40 đã có lần dùng phép thuật đốt cháy cây này cho bõ ghét nhưng nó không cháy.
B2229: ( 014,011 ) – ( 013 – 012 ) – Thật may mắn rằng đây không phải cây ăn thịt.
B2230: ( 004,015 ) – Trên bảng có giấy ghi chú của Iota F-40:” Làm ơn đấy Omega E-102, đừng có nhét phân bón vào tủ tài liệu!! “
B2231: ( 005,015 ) – Trên bảng có giấy ghi chú của Iota F-40:” Alpha C-61 tháng này làm hỏng 10 thiết bị hỗ trợ!! Đừng có bắt chước theo Omega D-13 làm hỏng đồ nữa!! “
B2232: ( 006,015 ) – Két sắt của Gamma A-36. Anh ấy từng nói đùa rằng két sắt này chẳng nhét gì ngoài mấy vỏ pudding mà anh ấy ăn vụng của Epsilon B-21.
B2233: ( 007,015 ) – Tủ cá nhân của Gamma A-36
B2234: ( 008,015 ) – Tủ cá nhân của Epsilon B-21
B2235: ( 009,015 ) – Tủ cá nhân của Beta M-34
B2236: ( 010,015 ) – Tủ cá nhân của Omicron G-06
B2237: ( 013,015 ) - ( 0015,015 ) – Tủ cá nhân của Lambda T-79. Vì cô ấy là đội trưởng Silver Wing nên được ưu tiên cấp cho ba cái tủ.
B2238: ( 006,018 ) – Tủ cá nhân của Omega D-13
B2239: ( 007,018 ) – Tủ cá nhân của Omega E-102
B2240: ( 008,018 ) – Tủ cá nhân của Alpha C-61
B2241: ( 009,018 ) – Tủ cá nhân của Iota F-40
B2242: ( 013,018 ) – Tủ cá nhân của Sigma E-33
B2243: ( 014,018 ) – Tủ cá nhân của Zeta K-89
B2244: ( 015,018 ) – Tủ cá nhân của Delta P-97
B2245: ( 005,017 )/ ( 005,016 ) – Tủ vũ khí của văn phòng. Delta P-97 không những là người bảo dưỡng chúng mà còn là người cung cấp cho văn phòng nhiều vũ khí độc lạ mà anh ấy tự sáng chế.
B2246: Wanderer Office
B2247: ( 012,006 ) Phòng nghỉ của khách vãng lai. Deri với Sim thường vào đây nghỉ khi ghé thăm văn phòng.
B2248: ( 016 ,006 ) Phòng trống. Phòng này từng là phòng của một cựu nhân viên.
B2249: ( 020 ,006 ) Phòng của Shylvie. Phong cách tối giản của căn phòng khiến mình thấy rợn người.
B2250: ( 024 ,006 ) Phòng của Leo. Một căn phòng xa hoa và sang trọng có tông màu đỏ đô chủ đạo. Nó khiến mình có cảm giác bồn chồn mỗi khi bước vào.
B2251: ( 028 ,006 ) Phòng của Hakase. Căn phòng ngập ngụa thùng các tông, túi rác và sách giả kim thuật. Điều kỳ lạ là căn phòng vẫn tỏa ra mùi của gỗ đàn hương dù rằng trong phòng không khác gì bãi rác.
B2252: ( 032 ,006 ) Phòng của Kohi. Chỉ cần đứng ngoài cửa thôi cũng đã thấy hương thơm của hoa cà phê dịu nhẹ và say đắm.
B2253: ( 036 ,006 ) [ Phòng của Hải Quỳ, không có thoại tương tác ]
B2254: ( 007 ,0016 ) - ( 014 ,006 ) Tủ lưu trữ tài liệu liên quan đến các vụ án dị thường.
B2255: ( 008 ,019 ) – Tủ lưu trữ các bản thiết kế vũ khí, trang thiết bị cho Wanderer. Nó bị đóng bụi luôn rồi. Chắc là mình sẽ đưa cho Hakase xem thử để ổng mày mò ra vài món trang bị xịn xò mới.
B2256: ( 010 ,019 ) – Tủ lưu trữ bản sao hồ sơ thông tin khách hàng.
B2257: ( 012 ,019 ) – Tủ lưu trữ biên bản hành chính của mình. Đa phần là biên bản phạt, biên bản bồi thường tổn thất, biên bản giải trình.
B2258: ( 014 ,019 ) – Tủ đựng vũ khí.
B2259: ( 015 ,016 ) – Tủ đựng trang thiết bị chuyên dụng.
B2260: ( 015 ,017 ) – Sao lại có con chuột đỏ nhồi bông ở đây vậy?
B2261: ( 018 ,016 ) – Bình cứu hỏa. Thường xuyên được sử dụng mỗi khi mình nấu ăn.
B2262: ( 033 ,016 ) - ( 035 ,016 ) – Tủ đựng đồ ăn vặt của mọi người.
B2263: ( 017 ,019 ) – Lazer bảo vệ. Leo đã một lần phản đối việc lắp lazer bảo vệ cho đến khi văn phòng bị trộm mất một cái laptop.
B2264: ( 007 ,025 ) – Cái tủ này toàn chứa truyện tranh với tiểu thuyết.
B2265: ( 008 ,025 ) – Đây không phải két sắt. Đây là cổng không gian thoát hiểm khẩn cấp.
B2266: ( 009 ,025 ) - Ảnh của Leo và Sakura Usagi được đặt trên đây.
B2267: ( 010 ,025 ) – Đây là két sắt mini kiêm đồng hồ kiêm quả bom, sản phẩm do mình chế tạo ra. Nó vẫn hoạt động tốt. Không biết Leo giấu gì bên trong két sắt nhỉ?
B2268: ( 014 ,025 ) – Tháng trước, có một khách hàng nóng tính kiếm chuyện với Leo, liền bị Leo túm đầu gõ binh binh vào cái tủ này, làm mình dọn muốn chết.
B2269: ( 015 ,025 ) - ( 017 ,025 ) – Hồ sơ lưu trữ của Leo. Chúng được phân loại kỹ càng.
B2270: ( 011 ,025 ) – Bàn làm việc đã được cải tạo của Leo. Ổng đã cải tạo ngăn kéo duy nhất của bàn thành một tủ lạnh có không gian vô hạn chỉ để ướp lạnh Sting – thức uống yêu thích của ổng.
B2271: ( 012 ,025 ) – Chiếc ghế công thái học của Leo.
B2272: ( 011 ,027 ) – Từ sau khi lắp lazer bảo vệ thì Leo thường xuyên để laptop hớ hênh trên bàn như thế này. Ồ, ổng đang lướt Sàn Cam để mua quà giáng sinh à?
B2273: ( 012 ,027 ) – Tài liệu được xếp ngăn nắp trên bàn.
B2274: ( 017 ,028 ) – Leo đã từng muốn đổ đầy Sting vô cái bình nước nóng lạnh này.
B2275: ( 010 ,029 ) – Chậu cây duy nhất trong văn phòng phải tưới bằng nước tăng lực.
B2276: ( 017 ,032 ) - Ảnh chụp chung của Wanderer dịp hè vừa rồi.
B2277: ( 024 ,024 ) – Tủ đựng tài liệu nghiên cứu.
B2278: ( 025 ,024 ) – Tủ sách ma thuật nâng cao.
B2279: ( 026 ,024 ) – Tủ sách ma thuật nâng cao dành cho em bé.
B2280: ( 027 ,024 ) - ( 028 ,024 ) – Tủ lưu trữ hồ sơ của các vụ án dị thường gần đây.
B2281: ( 029 ,024 ) – Máy in kiêm robot hút bụi được tặng bởi Eden.
B2282: ( 030 ,024 ) - ( 031 ,024 ) – Bảng trắng. Mình với Shylvie lúc rảnh rỗi hay đứng đây chơi cờ caro. Nhất định lần sau mình sẽ thắng bả.
B2283: ( 032 ,024 ) - ( 033 ,024 ) – Bảng gỗ thường dùng để viết thông báo lịch trình đã dán tùm lum các tờ bướm quảng cáo.
B2284: ( 036 ,024 ) – Milo viên, phô mai que, khô bò, khô gà cùng trứng ăn liền được nhét đầy hai ngăn tủ. Mỗi lần mà Eden ghé qua là cả nhóm sẽ lôi hết mớ đồ ăn vặt trong tủ và ngồi ệch xuống sàn để ngồi chơi boardgame.
B2285: ( 037 ,024 ) - Đây là cổng không gian thoát hiểm khẩn cấp.
B2286: ( 035 ,026 ) – Tủ sách khoa học. Ghi chú về các loài sinh vật khác thường được tập hợp tại tủ này.
B2287: ( 036 ,026 ) - ( 038 ,026 ) – Bàn làm việc bỏ trống.
B2288: ( 034 ,030 ) – ( 035 ,030 ) - Bàn làm việc của Shylvie.
B2289: ( 036 ,030 ) – ( 038 ,030 )  - Bàn làm việc của Hakase.
B2290: ( 024 ,032 ) - ( 026 ,032 ) – Bàn làm việc của Kohi.
B2291: ( 027 ,032 ) - ( 028 ,032 ) – Bàn làm việc của mình.
B2292: ( 029 ,032 ) – Ngăn kéo chứa đầy kẹo dẻo vị cam của mình.
B2293: ( 038 ,032 ) – Tủ sách ngôn ngữ đa chiều không gian. Bên trên có một cái máy fax thường xuyên nhả nhiệm vụ mật của Poseidon giao cho mình. Mỗi lần tiếng máy fax vang lên là mỗi lần mình cảm thấy mệt mỏi.
B2294: Wanderer Office_Kitchen
B2295: ( 010 ,005 ) – Hakase hay dùng lò vi sóng này để hâm bánh sữa chua.
B2296: ( 011 ,005 ) – Vỏ hộp bánh Pizza ăn liền được rửa sạch.
B2297: ( 012 ,005 ) – Ngăn kéo sặc mùi cà phê. Kohi thường cất các loại bột cà phê mà bà ấy mua được sau mỗi lần đi công tác.
B2298: ( 013 ,005 ) – Cả bếp lẫn lò nướng này đều bị cháy một lần.
B2299: ( 016 ,005 ) – Máy pha cà phê ma thuật ở thế giới Shylvie. Chỉ sử dụng được khi gắn viên ngọc lục bảo của bà ấy.
B2300: ( 017 ,005 ) - Ấm đun nước đa dụng. Có lần mình và Hakase đã nấu trực tiếp mì trong ấm. Mì ngon tét cái nách.
B2301: ( 018 ,005 ) – Chiếc tủ yêu thích của Shylvie. Tốc độ làm đá của nó rất nhanh, viên đá được làm ra vô cùng trong suốt không có chút bọt khí. Tối nào cũng thấy Shylvie hốc một mớ.
B2302: ( 020 ,005 ) – Bàn ăn chung của văn phòng. Tự dưng nhớ nồi lẩu thái khi ấy Eden nấu cho mọi người ăn ghê!!
B2303: ( 020 ,004 ) Nút khẩn cấp mới được lắp gần đây sau khi Hakase và Leo đốt cháy cả văn phòng. Bấm nút này để kích hoạt hệ thống vòi phun chữa cháy.
B2304: ( 023 ,004 ) - ( 024 ,004 ) – Ngồi ăn cơm mà xem Conan, Doraemon hay One Piece thì phải gọi là đỉnh cao ê đít, bữa cơm vĩnh hằng!
B2305: ( 028 ,004 ) – Nhìn vào thì giống bình chữa cháy nhưng thật ra là Robot dọn bếp. Thường thì Sierra sẽ nhập vô con Robot này để dọn dẹp mớ hỗn độn mà mình bày ra.
B2306: ( 010 ,007 ) – Thùng rác phân loại 3 ngăn. Mọi người trong văn phòng ai cũng nề nếp, phân loại rác kỹ càng ghê ta.
B2307: Wanderer Office_Bathroom
B2308: ( 007 ,007 ) – Máy giặt công suất lớn.
B2309: ( 008 ,007 ) – Máy sấy công suất lớn. Mình có thể chui vừa vào đây.
B2310: ( 009 ,006 ) – Tủ thuốc sơ cứu.
B2311: ( 011 ,006 ) – Nến thơm, bom tắm, sữa dưỡng da và nhiều chai lọ khác mà mình không biết rõ được cất gọn trên kệ này. Đa phần bom tắm ở trên kệ này thuộc về Hakase.
B2312: ( 012 ,010 ) - ( 012 ,010 ) – Kệ đựng xà bông cục, sữa tắm, bông tắm của từng người trong văn phòng. Mình hay dùng ké sữa tắm của Kohi, nó thơm lắm luôn!
B2313: ( 017 ,012 ) - ( 019 ,012 ) – Phòng tắm đôi, tại sao lại không nhỉ?
B2314: ( 019 ,007 ) – Bồn cầu thông minh có tích hợp vòi xịt. Chiếc bồn cầu này có thể biến thành một chiếc xe cút kít be bé với tốc độ không thua kém gì xe đua F1.
B2315: ( 014 ,008 ) – Nến thơm đa sắc. Có mùi oải hương và cam thảo.
B2316: ( 015 ,008 ) - ( 016 ,008 ) – Bồn tắm platium được sản xuất tại Atlantis. Ngâm mình trong bồn này sẽ khiến da dẻ trở nên mịn màng và khỏe hơn bao giờ hết.
B2317: Theme: https://www.youtube.com/watch?v=AMwv8MwYimM
B2318: ( 021,012 ) Oguri NomNom: Burger chỗ này…Ngon quá. Lần sau phải rủ thêm Tama mới được!
B2319: [ Thoại tương tác 2 lần ở ( 015, 019 ) - ( 016, 019 ) - ( 016, 020 )
B2320: Hải Quỳ: Rốt cuộc thân phận chú thế nào vậy?
B2321: Nhân viên thu ngân: Cháu biết thừa rồi mà còn hỏi.
B2322: Hải Quỳ: Cháu chả hiểu chú đang nói cái gì sất.
B2323: Nhân viên thu ngân: Cháu biết mà.
B2324: Nhân viên thu ngân: Chú là người nấu lô kẹo cam kia đấy.
B2325: Hải Quỳ: Cháu cóc tin. Nhảm nhí quá à.
B2326: Nhân viên thu ngân: Nói tên ta đi.
B2327: Hải Quỳ:……
B2328: Hải Quỳ: Hải Sâm Bắc….?
B2329: Nhân viên thu ngân: Chuẩn mịa rồi đó.
B2330: Nhân viên thu ngân: Cháu muốn thử 1 viên kẹo Trời Xanh không?
B2331: Hải Quỳ: Có kẹo dừa không chú?
B2332: Nhân viên thu ngân: Rất tiếc, bên ta chưa có mặt hàng đó. ]
B2333: ( 015, 022 ) - ( 016, 022 ) - ( 016, 023 ) : Everything's great at your Chunest!
B2334: Hải Quỳ: Everything's great at your Chunest!
B2335: ( 028, 013 ) - ( 029, 013 ): Không phận sự miễn vào nha.
B2336: ( 028, 015 ) – Xem nào…Phở, Bánh Mì Pate, Bánh Mì Hai Trứng, Burger Bò Đặc Biệt…Chà, quá trời quá đất món luôn…!
B2337: Mà ông kia sao lại ở đây? Chả lẽ lại có chuyên án gì ở cái siêu thị này hả?
B2338: ( 026, 016 ) NPC_Chart_C1: Sao mà anh Phượng lâu quá ta!! Mình đói lắm rồi!!
B2339: [ Thoại tương tác ở ( 024, 032 ) - ( 026, 032) giữa hai nhân vật NPC_Chart_C5 và NPC_Chart_C8
B2340: NPC_Chart_C8: Này Vergil. Anh muốn làm một trận Xì Dách không?
B2341: NPC_Chart_C5: Tự mày chơi một mình đi.
B2342: NPC_Chart_C8: Anh rén à?
B2343: NPC_Chart_C5: Rút bài đi!
B2344: NPC_Chart_C8: Ai thua thì người đó đi bao ăn ở quận 1 nhá!
B2345: NPC_Chart_C8: Ôi bỏ mịa rồi…
B2346: NPC_Chart_C5: Anh đã nói với mày rồi, Dante.
B2347: NPC_Chart_C5: Mày không có đủ trình.
B2348: NPC_Chart_C5: Ôi bỏ bà rồi.
B2349: NPC_Chart_C8: Xem ra điểm của anh còn nhỏ hơn của em nhỉ?
B2350: NPC_Chart_C8: LẬT BÀI!
B2351: NPC_Chart_C8: JACK POT!
B2352: NPC_Chart_C5: Ngu ngốc, Dante!
B2353: NPC_Chart_C5: Mày không biết anh vừa mở bài gì đâu.
B2354: NPC_Chart_C5: Jack…POT!
B2355: NPC_Chart_C8: WHAT?
B2356: NPC_Chart_C5: Và như anh đã nói rồi, Dante.
B2357: NPC_Chart_C5: Quỷ
B2358: NPC_Chart_C5: Không bao giờ
B2359: NPC_Chart_C5: Dằn dơ. ]
B2360: ( 008, 034 ) NPC_Chart_C10: Vẫn chưa có tuần san Đóa Bách Hợp Lưu Ly mới nhất sao…Chán thế…?
B2361: ( 024, 025 ) NPC_Chart_C12: Ố ồ, sasalele áo ba lỗ tralalero tralala này…Nhìn xấu ẻ.
B2362: ( 008, 016 ) NPC_Chart_C11: Quái lạ, cái lọ đó đâu rồi?
B2363: ( 011, 023 ) NPC_Chart_C14: Hmm…? Hình như cái này hông nằm trong dự tính của mình.
B2364: ( 016, 034 ) NPC_Chart_C9: Chết mịa, kẹt thẻ ngân hàng rồi à?!
B2365: ( 018, 034 ) NPC_Chart2_C5: Gòi gòi tới công chuyện luôn. Hay là mình lắc thử cái máy đi, biết đâu cái thẻ tụt ra thì sao?
B2366: ( 032, 020 ) NPC_Chart2_C4: Cái khăn tắm này dễ thương ghê.
B2367: ( 030, 024 ) NPC_Chart2_C11: Ồ, bộ này đẹp quá! Trên mũ cũng có gắn huy hiệu mặt trời nhỏ xinh nữa!
B2368: ( 007, 030 ) NPC_Chart2_C7 ( Animation hút thuốc ): Chao xìn. Làm điếu không bé?
B2369: ( 008, 012 ) – Tủ lạnh đựng sữa bò. Thật tiếc là sữa bò vị cam mà mình thích đã bị tuyệt chủng.
B2370: ( 009, 012 ) – Tủ lạnh đựng phô mai. Hình như hết phô mai vị cam rồi.
B2371: ( 010, 012 ) - ( 011, 012 ): Tủ lạnh đựng nhiều loại nước ngọt. Tủ lạnh của văn phòng vẫn còn đầy ắp Sting nên không cần phải mua thêm đâu.
B2372: ( 012, 012 ) - ( 013, 012 ): Tủ lạnh đựng nhiều loại thịt.
B2373: ( 009, 015 ) - Ui? Máy pha cà phê đang giảm giá nè! Chỉ với 599k thôi á?! MUA LUÔN!
B2374: ( 008, 018 ) - Ô! Hôm nay mặt hàng đồ gia dụng đang có ưu đãi giáng sinh nè! Combo Dao làm bếp và Chảo chống dính siêu sốc? Hừm, giá này cũng ổn mà ha. Đúng là hàng ưu đãi có khác. HỐT THÔI!
B2375: ( 027, 026 ) - Chà, bộ dụng cụ đan len cũng đang được giảm giá nè. Gì cơ? Mười cuộn len tùy chọn khi mua kèm bộ dụng cụ sẽ được giảm 30% hả? Giảm dữ vậy?? THẾ THÌ PHẢI MUA!
B2376: ( 011, 023 ) - Bộ dụng cụ phá khóa…? Giảm từ 389k còn 388k…Là giảm dữ chưa?? Tôi có đang nhìn nhầm không?? Ủa mà mua bộ dụng cụ phá khóa để làm gì? Nhóm mình có ai cần dùng không nhỉ? CÓ CHỨ, MUA!
B2377: [ Nếu thanh toán món đồ mua tại ( 015, 019 ) - ( 016, 019 ) - ( 016, 020 ) hoặc ( 015, 022 ) - ( 016, 022 ) - ( 016, 023 )
B2378: Hải Quỳ: Từ từ bình tĩnh Dahria, đừng quyết định vội. Mình có nên mua món này không?
B2379: CÓ:
B2380: Hải Quỳ: Mua thôi chờ chi nữa!
B2381: NPC Bán Hàng: Cảm ơn Quý Khách đã mua hàng tại Chunest!
B2382: KHÔNG:
B2383: Hải Quỳ: Nah, mình sẽ mua món khác hợp lý hơn. ]
B2384: ( 023, 024 ) – Sao mấy cái áo thun, áo ba lỗ brainrot này được bày bán vậy…Trông xấu tàn canh…!!
B2385: ( 027, 024 ) – Uầy, áo thun Angel Slayer này? Gian này toàn áo Angel Slayer mà sao lọt đâu ra cái áo Dumb Slayer vậy?
B2386: ( 031, 024 ) - ( 032, 024 ) – Không hứng thú lắm.
B2387: ( 030, 026 ) - ( 032, 026 ) – Không hứng thú lắm.
B2388: ( 016, 015 ) – Cam canh này…!! Nhìn ngon quá!!
B2389: ( 018, 013 ) – Tự dưng mình nghe thấy tiếng Shylvie đang nhại lại giọng người Ý khi nhìn thấy bánh sừng bò này.
B2390: ( 025, 014 ) – Nhìn cái bánh xúc xích cay này lại nhớ đến nhím Sonic. Muốn về chơi game Sonic quá….
B2391: Tương tác map Magic Shop
B2392: [ 006, 008 ] Vị trí NPC Chủ Tiệm.
B2393: ( Tương tác 7 lần ở [ 012, 011 ]:
B2394: Con Quạ: Ka, mày nhìn cái gì? Chọc cho mù mắt giờ!
B2395: Hải Quỳ: Gì mà hung dữ vậy?!
B2396: Con Quạ: Ka, cay hả, cay hả?
B2397: Con Quạ: Ka, mẹo mày bé! Mẹo mày bé!
B2398: Hải Quỳ: Con quạ này nó bị làm sao á ta…?
B2399: Con Quạ: Ka, ai sợ thì đi về!
B2400: Hải Quỳ: Con quạ này biết đi theo xu hướng hả!
B2401: Lần 4:
B2402: Hải Quỳ: Mày mà mở mồm nói thêm câu nữa đi, xem tao có vặt lông mày đem nướng không!
B2403: Con Quạ: Ka!! Đã ai làm gì đâu? Đã chạm vào đâu?
B2404: Lần 5:
B2405: Hải Quỳ: Chủ tiệm, con quạ này…
B2406: Chủ Tiệm: À! Đây là Con Quạ Blueprint! Một ma vật cấp cao mà tôi được ngài Leo tặng nuôi. Nó ngoan lắm!
B2407: Hải Quỳ: Haha…Nó “ ngoan “ ghê! Từ nãy đến giờ Blueprint toàn “ khen “ tôi không đó!
B2408: Chủ Tiệm: Ồ, cô nghe hiểu được tiếng của Blueprint sao!
B2409: Hải Quỳ: Hae?
B2410: Chủ Tiệm: Chuyện này nói ra hơi ngại. Mặc dù bản thân tôi là một người có khả năng giao tiếp với ma vật. duy chỉ Blueprint là ma vật duy nhất mà tới giờ tôi không hiểu nó nói gì.
B2411: Hải Quỳ: Ồ…
B2412: Chủ Tiệm: Nếu được…Nếu được thì cô có thể phiên dịch lời của Blueprint cho tôi được không?
B2413: Hải Quỳ: Được chứ!
B2414: Chủ Tiệm: Blueprint! Mày thích ăn thịt Hổ Long hay là ăn thịt Báo Dơi hơn?
B2415: Con Quạ: Ka! Thịt Hổ! Thịt Hổ!
B2416: Hải Quỳ: Nó thích ăn thịt Báo Dơi hơn.
B2417: Con Qua: Ka! Ka! Im lặng đi gopi!
B2418: Hải Quỳ: Nó bảo là thịt Báo Dơi là ngon nhất. Nhưng vị thịt gần đây hơi nhạt.
B2419: Chủ Tiệm: Ồ ồ! Hóa ra là như vậy! Cảm ơn cô rất nhiều!
B2420: Con Quạ: Ka…Ka…. )
B2421: ( [ 004, 012 ] - [ 005, 011 ] : Một cái hộp sọ có sừng.
B2422: Hộp sọ: Ta không phải cái hộp sọ có sừng!
B2423: Hải Quỳ: Ụ á! Giật cả mình!
B2424: Hộp sọ: Ta đây là báu vật ngàn năm!
B2425: Hộp so: Ngươi nên cảm thấy may mắn đi! Không phải ai ta cũng nói chuyện đâu!
B2426: Chủ tiệm: Có chuyện gì vậy?
B2427: Hải Quỳ: Cái…Báu vật này biết nói!
B2428: Chủ tiệm: Ồ, có khi cô nghe nhầm tiếng của bé quạ nhà tôi đấy!
B2429: Hộp sọ: Đấy, thấy chưa.
B2430: Hải Quỳ: Rõ là không ai hiểu ông nói gì thì có!
B2431: Hộp sọ: Hahaha!! Giới thiệu lại, ta là báu vật ngàn năm giúp ngươi tìm được tất cả thông tin mà ngươi muốn.
B2432: Hải Quỳ: Ồ, hóa ra ông là “ Thư Viện Ngàn Năm “?
B2433: Hộp sọ: Đồ ngu. Thư viện có giúp ngươi biết trước tương lai không?
B2434: Hải Quỳ: Uầy! Xịn thế!
B2435: Hộp sọ: Vậy ngươi muốn biết gì?
B2436: [ Tương lai của tôi ]
B2437: Sẽ random 1 trong 4 tương lai dưới đây:
B2438: Tương lai 1:
B2439: Hộp sọ: Tương lai của ngươi là một tờ giấy trắng.
B2440: Hải Quỳ: Hả…? Tờ giấy trắng?
B2441: Hải Quỳ; Đừng nói là tôi phải viết bản tường trình nữa nhé…!!
B2442: Hộp sọ: Đúng rồi đấy.
B2443: Hải Quỳ: Ôi thôi nào!!!
B2444: Tương lai 2:
B2445: Hộp sọ: Tiệc giáng sinh của ngươi sẽ không được an lành.
B2446: Hải Quỳ: Hả gì? Sao lại không an lành?
B2447: Hộp sọ: Ngươi sẽ phải ra chiến trường.
B2448: Hải Quỳ:…
B2449: Hải Quỳ: Tôi hiểu rồi. Cảm ơn ông.
B2450: Tương lai 3:
B2451: Hộp sọ: Ngươi trở thành tai họa hủy diệt và đánh mất chính mình. Ánh mắt vàng kim của ngươi nhìn về phía chiếc cọc treo xác đồng đội. Đôi tay của ngươi sẽ quét sạch tất cả.
B2452: Hải Quỳ: ….Tôi bị mất kiểm soát à?
B2453: Hộp sọ: Ngươi bị tước quyền kiểm soát.
B2454: Hải Quỳ: Tương lai xa hay gần đấy?
B2455: Hộp sọ: Gần.
B2456: Hải Quỳ: Chà, thôi kệ, ít nhất được ăn nốt cái giáng sinh này.
B2457: Tương lai 4:
B2458: Hộp sọ: Ta thấy màu sắc…hai màu sắc…sẽ chọn rời đi.
B2459: Hải Quỳ: Hả, cái gì? Màu sắc gì cơ?
B2460: Hộp sọ: Tím…Cam…Hồng…Đỏ.
B2461: Hải Quỳ: Là hai màu dữ chưa?
B2462: [ Quá khứ của tôi ]
B2463: Sẽ random 1 trong 3 quá khứ dưới đây:
B2464: Quá khứ 1:
B2465: Hộp sọ: Ngươi là một thứ tạp chủng lai tạo thất bại. Sức mạnh của ngươi sẽ trở thành cơn ác mộng đối với thế giới-
B2466: Hải Quỳ: Ồ, cái hộp sọ xấu xí này biết được bí mật động trời đó sao? Hư quá, nhỉ?
B2467: Hộp sọ: Cô là nhân cách thứ hai, nhỉ?
B2468: Hải Quỳ: Giỏi quá ta, đúng là “ Thư viện ngàn năm “!
B2469: Hải Quỳ: Nhưng dặn nè, những chuyện xấu đã qua thì mình nên giấu kín.
B2470: Hải Quỳ: Ngươi không nên bép xép nhiều quá đâu, mất vui.
B2471: Hải Quỳ: Vì ngoài chúng ta ra còn có một đôi mắt đang nhìn chằm chằm nữa kìa.
B2472: * quay lại nhìn vào người chơi *
B2473: Hộp sọ: Ồ, ta hiểu.
B2474: * Âm thanh rewind, Hải Quỳ quay về phía hộp sọ *
B2475: Hộp sọ: Bạn thuở nhỏ của ngươi là con gái của Thần Poseidon, người đã bị hộp Pandora cám dỗ và đã mở hộp khiến cho hai cõi lâm nguy bởi sự tấn công của Quái Vật Vực Sâu.
B2476: Hộp sọ: Ngươi đã nhận hết trách nhiệm về bản thân mình, trở thành cánh tay trái đắc lực cho Poseidon để dẹp trừ hậu họa.
B2477: Hộp sọ: Ngươi bị ngu à.
B2478: Hải Quỳ: Hả, nỡ nào chửi tôi thế?
B2479: Hộp sọ: Ngu là rõ, đồ ngu.
B2480: Hải Quỳ: Ơ kìa! Ngu chỗ nào cơ chứ?
B2481: Hộp sọ: Đồ ngu! Đồ ăn hại!
B2482: Hải Quỳ: Ôi thôi nào!
B2483: Quá khứ 2:
B2484: Hộp sọ: Trong hàng ngàn bản sao, ngươi là kẻ sống sót nhưng lại là bản sao thất bại, bất ổn định.
B2485: Hộp sọ: Bù lại, nhờ tình thương của “ Dahria “, ngươi đã sở hữu điều độc nhất mà các bản sao còn lại không có. Ngươi-
B2486: Hải Quỳ: Vì ngoài chúng ta ra còn có một đôi mắt đang đọc từng chữ nữa kìa.
B2487: Hộp sọ: Ngươi là người duy nhất cầm được cây đinh ba thánh thần của Poseidon.
B2488: Hộp sọ: Vì thế, ngươi được Poseidon để tâm và ưu ái. Thậm chí còn được làm cánh tay trái đắc lực của Poseidon.
B2489: Hộp sọ: Mỗi tội ngươi lại báo đời ổng. Ngươi hết phá nát công trình công cộng còn phá hủy gần hết các trang thiết bị sau mỗi chuyến công tác của ngươi.
B2490: Hải Quỳ: Aha…ha…T-Thì có trường hợp bất khả kháng mà…Biết sao giờ!
B2491: Hộp sọ: Đồ ngu. Đồ ăn hại.
B2492: Hải Quỳ: Ơ kìa!!
B2493: Quá khứ 3:
B2494: Hộp sọ: Trước khi trở thành “ Ma pháp thiếu nữ “, ngươi là “ Kẻ Thanh Trừng “.
B2495: Hộp sọ: Là cánh tay trái đắc lực của Poseidon, đôi bàn tay của ngươi đã không ngần ngại nhuốm biết bao máu của kẻ phản bội, thậm chí còn tước đoạt cả danh phận của chúng.
B2496: Hộp sọ: Trong số đó, có “ Hải Bình “. Ngươi đã sửa chữa sai lầm cho cậu ta.
B2497: Hải Quỳ: Ối chà chà, cái hộp sọ đáng yêu này biết được bí mật động trời đó sao!!
B2498: Hộp sọ: Thoạt nhìn ngươi là một bé gái ngây thơ vô tội nhưng hóa ra ngươi lại vô số tội nhỉ.
B2499: Hải Quỳ: Biết sao bây giờ. Khả năng ngụy trang của tôi không hoàn hảo nên chỉ còn cách tước đoạt thân phận thôi.
B2500: Hộp sọ: Và sau khi hoàn thành nhiệm vụ, ngươi sẽ kết liễu thân phận ấy bằng một viên đạn. Ôi, càng xem mà càng thấy ngươi máu lạnh làm sao.
B2501: Hải Quỳ: Bản thân tôi cũng là sinh vật máu lạnh rồi mà, haha.
B2502: Hải Quỳ: Với cả, nếu không ai đứng ra thanh trừng bè lũ phản bội ấy thì quốc gia lâm nguy mất. Tôi không ngại để đôi tay này nhuốm máu thêm đâu.
B2503: Hộp sọ: Nói chuyện bình thường thôi, không cần phải đao to búa lớn thế đâu. Nghe rợn tóc gáy quá.
B2504: Hải Quỳ: Ông có còn mảng tóc nào đâu…
B2505: [ Quà giáng sinh của tôi ]
B2506: Hộp sọ: Ngươi thật sự hỏi về quà giáng sinh năm nay của ngươi à? Bộ ngươi không muốn bất ngờ sao?
B2507: Hải Quỳ: Ờ ha…! Chưa nghĩ đến!
B2508: Hộp sọ: Đồ ngu!
B2509: Hộp sọ: Thôi để ta ban phước cho ngươi biết. Món quà giáng sinh của ngươi là…
B2510: Hải Quỳ: Là…?
B2511: Hộp sọ: Là….
B2512: Hộp sọ:…z….z….z
B2513: Hải Quỳ: Má…. )
B2514: [ 005, 010 ]: Có hơi lạnh phả ra từ quả cầu phép thuật này. Nếu là Shylvie, chắc chắn cô ấy sẽ đem nó làm đá lạnh vĩnh cửu.
B2515: [ 005, 009 ]: Xúc xắc đa mặt làm từ đá quý. Chà, muốn mua nó về để chơi DnD cùng mọi người ghê.
B2516: [ 005, 008 ] ( Quay trái): Cuộn giấy cổ có mùi thơm thơm của bưởi.
B2517: [ 005, 008 ] ( Quay lên): Xấp vải này có mùi hoa hồi.
B2518: [ 007, 008 ] Lọ thuốc kỳ lạ màu cam.
B2519: [ 008, 008 ] Lọ thuốc kỳ lạ màu xanh lá.
B2520: [ 009, 008 ] Tấm thảm phép thuật có hoa văn lạ mắt.
B2521: [ 010, 008 ] Thùng đựng dụng cụ phép thuật.
B2522: [ 011, 008 ] ( Quay lên ) Hai cuộn vải này có mùi gỗ sồi.
B2523: [ 011, 008 ] ( Quay phải ) Một cái chum.
B2524: [ 011, 009 ] Ủa khoan, đây là “ Bát Họ “ mà mình làm mất đây mà?
B2525: [ 007, 009 ] - [ 009, 009 ] Hmm, bộ hài cốt này có vẻ là đồ thật?
B2526: [ 006, 015 ] - [ 007, 015 ] Hmm, bộ hài cốt này có vẻ là đồ giả?
B2527: [ 008, 014 ] Ồ, bộ giáp này làm mình nhớ đến Shovel Knight.
B2528: [ 009, 014 ] Chiếc váy Lolita nhiều lớp đính nhiều đá quý.
B2529: [ 010, 014 ] Trang phục pháp sư thường thấy.
B2530: [ 011, 014 ] Áo choàng pháp sư có cài một viên đá quý màu tím ở giữa ngực. Hakase mà mặc nó thì sẽ hợp lắm đây.
B2531: [ 015, 015 ], [ 016, 014 ], [ 015, 013 ] Một cái vại chứa chất lỏng màu vàng cam đang sôi ùng ục. Uống nó chứ?
B2532: [ Uống ] Màn hình bị glitch, chỉ khi nào đi ra khỏi map mới hết glitch.
B2533: [ Không uống ]
B2534: [ 013, 011 ] Một cái vại be bé đựng nhiều loại đũa phép.
B2535: [ 014, 010 ] Quả địa cầu này có 6 đại dương và 7 lục địa.
B2536: [ 014, 009 ] Sao cái gậy phép thuật kia nhìn na ná gậy của Nanoha thế nhỉ? Nhìn mà muốn mua ghê…
B2537: [ 015, 009 ] Trong đây có gậy phép thuật hai đầu có thể tách ra làm hai gậy phép thuật nhỏ. Nó làm mình liên tưởng đến Suit Precure.
B2538: [ 016, 009 ] Hai chiếc gậy phép thuật này trông khá bình thường.
B2539: TƯƠNG TÁC MAP “ PHÒNG CHẾ TẠO “
B2540: ( 005, 009 ): Kệ phụ tùng thay thế. Hộp đựng nhãn cầu nhân tạo của mình được để ở đây.
B2541: ( 006, 009 ): Kệ bảo quản mẫu sinh học. Ồ, cánh tay phải của mình được bảo quản tốt thế!
B2542: ( 007, 009 ): Kệ bảo quản vảy và sừng rồng để chế tạo thuốc tăng tốc.
B2543: ( 008, 009 ): Kệ nước cam đông lạnh.
B2544: ( 005, 004 – 006, 004 ): Ống dẫn năng lượng Nethervoid.
B2545: ( 007, 005 – 009,005 ): Bàn chế tạo vũ khí. Mình hay nằm ngủ ở đây vì bàn này mát lắm luôn.
B2546: ( 010, 004 ): Tủ dự trữ năng lượng Nethervoid dạng viên nén. Mình hay lấy vài viên để nạp vô găng tay Ruby Moon.
B2547: ( 011 – 004 ): Vũ khí hỗ trợ ở văn phòng đa phần đều sử dụng viên nén năng lượng Nethervoid. Không những tiết kiệm tối đa ma lực mà còn hỗ trợ người sử dụng gây ra sát thương khủng khiếp.
B2548: ( 012, 004 ): Tủ dự trữ hợp chất năng lượng Nethervoid-Vibranium dạng lỏng đựng trong các lọ nhỏ. Chúng thường được sử dụng để gia tăng độ bền và độ cứng cho vũ khí. Có thể dùng để ném trực tiếp như bom sinh học, khiến cho sinh vật hữu cơ bị ném trúng tan chảy thành đống bầy nhầy.
B2549: ( 013, 004 ): Buồng sạc điện của UNIT 4 SRA-FL-04, loại mech hỗ trợ dạng drone không người lái.
B2550: ( 014, 004 ): Buồng sạc điện của UNIT 9 SRA-RX-36, loại mech tác chiến được trang bị hai khẩu pháo nòng dài trên lưng cùng các ụ súng liên thanh ở hai cánh tay.
B2551: ( 015, 004 ): Nút kích hoạt UNIT 9 SRA-RX-36 và UNIT 9 SRA-FX-67.
B2552: ( 016, 004 ): Buồng sạc điện của UNIT 9 SRA-FX-67, loại mech tác chiến được trang bị kiếm và khiên được tráng một lớp Nethervoid có khả năng chống ăn mòn dị thường, hấp thụ và phản lại mọi đòn tấn công kể cả phép thuật.
B2553: ( 017, 005 ): Bình năng lượng Theosphoros đã tinh chế được nối vào buồng hồi phục của Kohi.
B2554: ( 018, 006 ): Buồng hồi phục của Kohi. Thơm mùi cà phê.
B2555: ( 019, 006 ): Buồng hồi phục của Shylvie. Cũng dùng năng lượng Theosphoros để hồi phục.
B2556: ( 020, 006 ): Trong kia là bình năng lượng Abyssalnite đã tinh chế được nối vào buồng hồi phục của mình.
B2557: ( 021, 006 ): Buồng hồi phục của mình. Abyssalnite là chất kịch độc đối với các thành viên còn lại.
B2558: ( 022, 006 ): Trong kia là bình năng lượng Luminidite nguyên chất được nối vào buồng hồi phục của Leo.
B2559: ( 023, 006 ): Buồng hồi phục của Leo. Còn kia là bình năng lượng Rubinite đặc chế riêng của Hakase.
B2560: ( 024, 006 ): Buồng hồi phục của Hakase. Thơm hương hạt dẻ nướng.
B2561: ( 025, 006 ): Bình năng lượng trống không được nối vào buồng hồi phục dự phòng.
B2562: ( 026, 006 ): Buồng hồi phục dự phòng.
B2563: ( 023, 010 ): Máy thiết lập cổng dịch chuyển. Hửm? Có tờ giấy ghi chú nè. Ủa, đây không phải là tọa độ của thế giới đang có trận chiến giữa con người và loài rồng à?
B2564: [ Nếu tương tác lần hai tại ( 002, 004 ) - ( 003, 004 )  map của Leo ] À phải rồi! EPSILON-017 – HÀNH TINH BELLAMONT…Ủa? Ồ, hành tinh này vẫn đang trong quá trình hình thành bộ tộc này!
B2565: ( 022, 011 ): Siêu máy tính phát hiện sai lệch không-thời gian. Shylvie là người điều hành máy này.
B2566: ( 023, 012 ): Máy điều khiển SRA-UNIT. Mình hay ngồi ở đây để điều khiển các robot hỗ trợ các thành viên khi chưa được điều động. Nếu bị điều động thì SIERRA sẽ là người điều khiển chúng.
B2567: ( 010, 013 – 013, 013 ): Thùng sắt đựng vũ khí đã hỏng. Bán cho chị đồng nát là kiếm được khối tiền mua sting cho Leo luôn!
B2568: ( 005, 011 ): Thùng đựng khiên. Đa số đều là hàng “ phế phẩm “ mà Shylvie lụm về từ các chuyến thăm dò. Mọi người có thể lấy khiên ở đây để tùy ý sử dụng.
B2569: ( 006, 011 ): Thùng đựng vũ khí hỗ trợ chiến đấu như kiếm, khiên có cưa, rìu, chùy…v..v
B2570: ( 007, 011 ): Thùng đựng khiên xịn của Shylvie. Không một ai được động vô.
B2571: ( 008, 011 ): Thùng đựng giáp hỗ trợ do Hakase chế tạo.
B2572: ( 009, 011 ): Thùng đựng thiết bị hỗ trợ như chiếc vòng tay có gắn la bàn, bút dò đường, mặt nạ chống ăn mòn..v…v. Khi trước từng có người dành hàng giờ để sửa chữa chúng sau mỗi chuyến thăm dò.
B2573: ( 017, 015 – 019, 015 ): Hakase đã trưng dụng mấy chiếc quan tài cũ của Leo làm hòm đựng xác các sinh vật dị biến. Chả hiểu sao mỗi lần mình nhìn vào đây thì trong đầu sẽ vang vảng câu:” Bật nắp quan tài, nhận ngay tài lộc “.
B2574: ( 020, 015 – 022, 015 ): Bàn mổ xác chết. Tận dụng xác chết của các sinh vật dị biến là món nghề của Hakase. Lâu lâu mình lôi về mấy con quái vật biển sâu để anh ấy mổ lấy thịt và lấy các cơ quan có thể dùng để chế tạo vật phẩm khác.
B2575: ( 024, 016 ): Dụng cụ phẫu thuật được rửa sạch sẽ. Mình nhớ có hôm Leo bị dính con ký sinh trùng bắt buộc phải mổ sống. Thế là Shylvie phải dùng phép thuật để khóa chân tay Leo lại và để Hakase xử lý con ký sinh đó. Nhớ lại vẫn hãi, máu me tùm lum, Leo la hét thảm thương luôn.
B2576: ( 005, 014 – 008, 014 ):  Các loại máy móc gì đó mà mình không biết sử dụng. Nhớ mang máng là máy phân tích thành phần, máy trộn chất hóa học, máy sàng lọc thì phải.
B2577: ( 008, 018 ): Máy lọc tạp chất Nethervoid. Vị của Nethervoid chưa lọc na ná xá xị trộn trà ô long.
B2578: ( 005, 018 – 007, 018 ): Bình chứa chất Nethervoid đã lọc. Uống ngon như nước có ga vị sấu muối.
B2579: ( 013, 017 ): Tháp dò tín hiệu của mình. Nhìn vào đây sẽ biết được vị trí hiện tại của mình đang ở đâu. Ngay khi mất tín hiệu thì SIERRA sẽ ngay lập tức ghi nhận.
B2580: ( 014, 017 ): Tháp dò tín hiệu của Shylvie và Leo.
B2581: ( 015, 017 ): Tháp dò tín hiệu của Kohi và Hakase.
B2582: ( 016, 017 ): Tháp dò tín hiệu đã tắt nguồn.
B2583: ( 014, 014 ):  Máy thăm dò đánh giá vật chất dị giới.
B2584: ( 015, 014 ): Máy đo đạc biên độ biến dạng dị giới. Hình như đang đặt ở tọa độ chiều không gian Epsilon 017, hành tinh Bellamont?
B2585: AFTER ENDING HINT
B2586: ROUTE KHĂN LEN
B2587: [ Sprite Bully Quỳ ]
B2588: Leo dễ tính thế nhỉ?
B2589: Chiếc khăn len ngươi may trông xấu òm mà vẫn khen lấy khen để.
B2590: Điều đó làm ta tự hỏi rằng…
B2591: Nếu các thành viên còn lại cũng nhận chiếc khăn len xấu xí này
B2592: Họ sẽ nói gì nhỉ?
B2593: Kohi đáng mến thật đấy.
B2594: Cô ấy đón nhận chiếc khăn xấu xí của ngươi một cách vui vẻ.
B2595: Điều đó làm ta tự hỏi rằng...
B2596: Chưa gì ta thấy có người chê ngươi rồi đó.
B2597: HAHAAHAHAHAHAHA.
B2598: Shylvie đáng ghét thật ha.
B2599: Nhưng sự thật mất lòng mà!
B2600: Thôi thì chiếc khăn xấu xí của ngươi ít ra vẫn được dùng.
B2601: Cơ mà ta đang tự hỏi rằng…
B2602: Nếu mà Shylvie dám chê ngươi thì các thành viên còn lại…
B2603: Sẽ nói gì ta?
B2604: Ôi, ta đã nói với ngươi rằng nên mua cho hắn một quyển sách phép rồi mà.
B2605: Cái đồ ngốc này!
B2606: Sách phép không có ở siêu thị đâu!
B2607: Quay lại và mua cho hắn một quyển đi!
B2608: ROUTE MÁY CÀ PHÊ
B2609: Ê.
B2610: Cà phê Atlantis cũng ngon đấy, nhưng ta vẫn thích cà phê Luminous ở quê nhà Leo hơn.
B2611: Chỉ cần đổ vào một chút nước nóng, khuấy đều lên.
B2612: Cà phê Luminous đậm đà, sánh kẹo, thơm lừng.
B2613: Hậu vị không có bị chua.
B2614: Ngươi mau đi nói chuyện với Leo để hỏi chỗ mua cà phê Luminous đi!
B2615: Ta thấy hơi chán
B2616: Ngươi tặng cho Kohi món quà tuyệt vời nhất. Best Ending luôn rồi còn gì?
B2617: Ngươi chưa từng nghĩ đến việc tặng cho cô ấy một món quà độc lạ hả?
B2618: Tặng cái gì khác ngoài cà phê đi!!
B2619: Nghe ta nói này.
B2620: Tuyệt đối.
B2621: Đừng tặng món này.
B2622: Cho Hakase.
B2623: Ngươi mà tặng hắn món này.
B2624: “ Ngu tuyệt đối “
B2625: Sẽ là tên cún cơm mà ta sẽ gọi ngươi đấy.
B2626: Ê!
B2627: NGƯƠI NGHĨ GÌ MÀ TẶNG HAKASE MÓN NÀY VẬY HẢ?
B2628: NGU TUYỆT ĐỐI!!
B2629: DA CHÚNG TA RÁM LẠI RỒI ĐÂY NÀY!!
B2630: RÁM HƠN MÀU BÁNH CAM NỮA!!!
B2631: NGU, NGƯỜI GÌ ĐÂU MÀ NGU THẾ KHÔNG BIẾT!!
B2632: Mau quay lại mà tặng hắn món khác đi!!
B2633: TẶNG MÓN GÌ CŨNG ĐƯỢC!!
B2634: ROUTE DAO VÀ CHẢO
B2635: Ta không ngờ rằng Leo biết nấu mì cay đấy.
B2636: Lại còn ngon nữa là đằng khác.
B2637: Mì cay hắn nấu làm ta có chút cảm hứng.
B2638: Sẽ ra sao nếu ta hoặc ngươi nấu mì cay tặng hắn vào giáng sinh nhỉ?
B2639: Siêu thị này không có mấy món để ta nấu mì cay
B2640: Nên lần sau đừng có đến đây nữa, đi đường khác đi!
B2641: Ồ, ngươi đang tò mò vị phở mà Kohi nấu à?
B2642: Đáng tiếc cho ngươi.
B2643: Ngươi ngất ngay đúng khoảnh khắc Kohi làm gãy thớt rồi.
B2644: Người gì đâu mà yếu nhớt.
B2645: Ngươi rốt cuộc đói đến mức nào vậy hả?
B2646: Cứ như thể ngươi đang ở….
B2647: ….
B2648: Chỉ khi nào ở nhà ngươi mới được làm vậy thôi.
B2649: Nghe chưa?
B2650: Omurice trứng hắc ám ăn kèm với thịt Leviathan chiên xù!!
B2651: Món ưa thích của ta!
B2652: Ta không ngờ ta chỉ nấu cho hắn ăn món này một lần
B2653: Mà hắn đã nấu được gần như chính xác công thức của ta.
B2654: Đỉnh của chóp!
B2655: ROUTE BỘ PHÁ KHÓA
B2656: May mà ngươi tặng món quà kỳ lạ này cho Leo đấy!
B2657: Chứ không thì ta sẽ chui vô máy giặt mà tự giận cho ngươi coi!
B2658: Ta ghét bị nhốt trong phòng vệ sinh lắm.
B2659: Cơ mà ta thấy ngươi nên tặng món nào đó đàng hoàng tử tế hơn.
B2660: Chứ cái này…không được gọi là quà đâu.
B2661: NGƯƠI ĐẤY!
B2662: NGU SI ĐẦN ĐỘN HẾT SỨC!
B2663: Tặng cái gì không tặng, lại tặng cái thứ của nợ này!
B2664: Tệ! Quá tệ!
B2665: May cho ngươi là ta đã thủ sẵn một máy pha cà phê mới toanh ở nhà!
B2666: Cứu ngươi một bàn thua trông thấy rồi đấy nhé!
B2667: Nhớ mà đãi ta một bữa..
B2668: Ê, ta có ý này.
B2669: Ta thấy mấy món quà ở chỗ này tầm thường quá.
B2670: Hay là ngươi qua dị giới mua quà đi.
B2671: Ta nhớ Văn Phòng còn một thiết bị du hành gì gì đó chưa bị hỏng.
B2672: Cứ hỏi Leo hoặc Shylvie cho chắc.
B2673: HAHAHAHA!
B2674: AI MÀ NGỜ ĐƯỢC MA VƯƠNG LẠI PHẢI E DÈ CẢNH SÁT!!
B2675: Ồ, ta mới để ý là Shylvie khá thích mấy dụng cụ làm bếp.
B2676: Hay là ngươi sắm cho nó một bộ đi?
B2677: Ừ, ta biết là ta ghét nó quá trời quá đất.
B2678: Nhưng mà giáng sinh mà.
B2679: Ta đang tò mò câu chuyện sẽ rẽ hướng thế nào…
B2680: Nếu người tặng chúng cho nó là ngươi?
B2681: Ờ mà nếu ngươi biết kết cục rồi thì khỏi tặng cũng được.
B2682: Dù sao cũng là Wonder Chrismast Fiesta mà
B2683: Ngươi quay lại thời điểm nào mà chẳng được!
B2684: ROUTE NHẮN TIN SHYLIE
B2685: May cho ngươi nhé.
B2686: Leo dù là ma cà rồng nhưng đang tại chức Vệ Thần Không Gian.
B2687: Nên là viên đá phong thủy ngươi tặng hắn đã không thể “ thanh trừng “ được hắn.
B2688: Thậm chí sức mạnh của nó còn bị Leo hút ngược về.
B2689: Ồ, ngươi nhận ra rồi à?
B2690: Nếu mà ngươi muốn tặng thì cứ tặng đi, ta không cản đâu.
B2691: Ngươi đầu óc đơn giản thật đó.
B2692: Vì nó có hình hạt cà phê mà ngươi ngay lập tức mua
B2693: Mà không mảy may về công dụng của đá phong thủy.
B2694: Thà rằng ngươi tặng cà phê hay là máy pha cà phê đi.
B2695: Chứ tặng cái này tổn thọ quá chừng.
B2696: Đến cả một viên ngọc cũng có thể biến thành một chiếc khiên…
B2697: Đừng nói đến cả một cục đá ven đường cũng thế nhé?
B2698: Èo, chán quá, tặng cho nó món khác đi.
B2699: Ai mà ngờ được một viên đá phong thủy lại có thể lưu trữ phép thuật.
B2700: Giống cuốn sách phép ghê ha!
B2701: Ta biết ngươi đã từng hoặc đang có ý định tặng hắn một cuốn sách phép khác.
B2702: Nhưng mà nghe ta nói này.
B2703: Ma vương phải có áo choàng!
B2704: Ta nhớ Leo biết chỗ bán áo choàng hay lắm.
B2705: Đi hỏi hắn thử xem.
B2706: ROUTE NHẮN TIN LEO
B2707: Ái chà chà, cà phê Luminous sao!!
B2708: Cà phê Luminous thì ngon không bàn cãi!
B2709: Cũng coi như là Best Ending rồi ha!
B2710: Một cục đá chùi đít ngẫu nhiên nào đó cũng có thể biến thành khiên…
B2711: GÌ KỲ VẬY TRỜI?
B2712: Ta không chấp nhận đây là Best Ending!!
B2713: Đi tìm Ending khác mau!!
B2714: [ Sprite Drosalya ]
B2715: Ôi, cháu gái yêu quý của ta!
B2716: …
B2717: Gương mặt đó là sao thế?
B2718: Cháu quên ta rồi sao?
B2719: Là bà ngoại yêu dấu, Drosalya của cháu đây!
B2720: Cháu quên cũng phải thôi
B2721: Ta đã lặn mất tăm mà không nói lời nào mà.
B2722: Chưa kể là cháu vẫn đang sử dụng thứ “ thuốc “ ấy.
B2723: Ta ghét thứ “ thuốc “ đó thế không biết!
B2724: Làm cháu quên cả gốc gác của mình!
B2725: Nên là để ta “ hint “ nhẹ cho cháu gái yêu quý nè!
B2726: Ta có để lại một món quà cho cháu ở tiệm sách cũ đó!
B2727: Đến đó mà nhận lấy món quà đặc biệt của ta đi!!
B2728: ROUTE MUA MÌ CAY CHO LEO
B2729: BEST ENDING CỦA LEO!!
B2730: Xin chúc mừng!!
B2731: Trong các kết quả mà ta nhìn thấy…
B2732: Chỉ có cái này mới là Best Ending cho Leo thôi!
B2733: Gì? Ngươi muốn biết các Best Ending còn lại á?
B2734: Còn lâu!
B2735: Ta chỉ có thể kể cho ngươi Bad Ending thôi!
B2736: Nhưng mà ta không kể đâu.
B2737: Vì kể xong ngươi sẽ đi thực hành liền.
B2738: Tốn mạng lắm.
B2739: Nếu ngươi muốn quay lại để tìm Best Ending thì quay lại liền đi.
B2740: ROUTE XUỐNG ATLANTIS MUA SÁCH
B2741: Ending này cũng đẹp đấy.
B2742: Thật yên bình và hoài niệm làm sao.
B2743: Làm ta nhớ về thời kỳ văn phòng Wanderer chỉ có ba mống.
B2744: Cả đám cũng rủ nhau đi ăn với đi phá phách như thế này.
B2745: Cơ mà yên bình như này chán lắm, kiếm ending khác đi!
B2746: …..
B2747: Sao, ngươi không hiểu chuyện gì vừa xảy ra à?
B2748: Ngươi, à không.
B2749: Hải Quỳ, không phải là người Atlantis.
B2750: Chính xác hơn, Hải Quỳ không phải người Atlantis thuần chủng.
B2751: Nên là nhỏ mới không bị ràng buộc bởi lời sai khiến từ ma vương.
B2752: Và hoàn toàn miễn nhiễm với sức mạnh thao túng từ các quái vật vực sâu cấp cao.
B2753: Vì thế Poseidon mới trọng dụng con nhỏ ăn hại này đó.
B2754: Ồ, ngươi bắt đầu ngờ ngợ ra rồi phải không?
B2755: Nhỏ này chưa bao giờ đề cập đến vụ này hả?
B2756: Ừ, nhỏ này có nhớ gì đâu mà đề cập. Giờ ngươi có hỏi nó nó cũng đơ mặt nó ra.
B2757: Đúng rồi, người duy nhất biết rõ chân tướng của Hải Quỳ.
B2758: Chỉ có ta mà thôi.
B2759: Nhưng ta sẽ không “ sì poi “ đâu.
B2760: Paii paii~
B2761: HẢI QUỲ
B2762: Ôi cháu gái yêu đã nhận được món quà của ta chưa?
B2763: Món quà tuyệt vời quá ha, “ mụ già “
B2764: [ Drosalya ]
B2765: Kìa, lâu rồi mới gặp mà cháu nỡ nào gọi ta là “ mụ già “?
B2766: Ôi, đau lòng quá đi…!
B2767: [ Bully Quỳ ]
B2768: Hừ.
B2769: Quà chẳng tuyệt vời tí nào cả.
B2770: Ôi, biết bao nhiêu kẻ thèm khát mà chẳng có được.
B2771: Cháu thì được trao tận một nửa sức mạnh mà còn chê ỏng chê eo.
B2772: Ta không cần thứ sức mạnh này.
B2773: Cháu nỡ nào hắt hủi ta vậy?
B2774: Ta không có hắt hủi bà.
B2775: Món quà của bà tuyệt vời thật đấy.
B2776: Nhưng nó sẽ khiến cho việc tận hưởng niềm vui giết chóc của ta trở nên nhàm chán.
B2777: Ôi cháu yêu ngốc này.
B2778: Cháu chẳng hiểu gì cả.
B2779: Đứng từ trên nhìn xuống dưới những kẻ đang cố leo lên bằng vị trí của cháu…
B2780: Mới thú vị chứ?
B2781: Ta có tự cao nhưng không tự cao đến vậy.
B2782: Chẳng vui gì cả.
B2783: Vậy thì ta lấy lại nhé?
B2784: Quà đã tặng rồi mà còn đòi lại là sao?
B2785: “ Mụ già “ tồi quá vậy?
B2786: Ồ, vậy là cháu chấp nhận sức mạnh này sao!
B2787: Vui quá!
B2788: Quà được nhét tận tay chả lẽ không nhận?
B2789: Phải ép buộc thì cháu mới nhận.
B2790: Ta rõ cháu ta quá mà.
B2791: Hừ…
B2792: Dahria hay là Aira, đều là cháu ta hết.
B2793: Đều là “ tạo vật đáng yêu “ của ta.
B2794: ………..
B2795: Thứ thuốc mà Dahria hay sử dụng…
B2796: Không chỉ ức chế ký ức của kẻ bị tước đoạt danh phận…
B2797: Mà còn ức chế cả “ bản ngã “ của cháu.
B2798: Ôi, nhìn thứ sức mạnh quý báu của ta bị mai một dần làm ta buồn lắm.
B2799: Nên đành phải dùng cách này thôi.
B2800: Bà đã…can thiệp vào ký ức bọn ta?
B2801: Chính xác.
B2802: Mà thôi, ta chỉ nói tới đây thôi.
B2803: Sử dụng sức mạnh như thế nào, là tùy cháu.
B2804: Trở thành kẻ hủy diệt.
B2805: Hoặc đấng cứu thế.
B2806: Là ở cháu thôi, Aira.
B2807: À, suýt nữa quên mất kẻ đang ngồi xem bà cháu mình trò chuyện.
B2808: Hãy thương yêu Dahria với Aira nhiều hơn nhé.
B2809: Ê-
B2810: ROUTE RƯỢT ĐUỔI
B2811: Ôi, chán thế?
B2812: Ngươi cũng thấy buồn mà đúng không?
B2813: Không sao!
B2814: Ta có thể giúp ngươi đó!
B2815: Với “ Wonder Chrismast Fiesta “ này
B2816: Ta sẽ giúp ngươi tận hưởng kỳ nghỉ đáng mơ ước nhất mà ngươi có thể mơ.
B2817: Hmmm?
B2818: Chuyện của Hải Quỳ á?
B2819: Ồ, tự thân ngươi hiểu đi chứ.
B2820: Ta lười giải thích quá.
B2821: Lỡ bung bét hết rồi.
B2822: Giờ ta chỉ muốn tận hưởng giáng sinh thôi.
B2823: Nên là…!
B2824: WONDER CHRISMAST FIESTA!!
B2825: [ Sfx xe buýt mở cửa + bước chân. BGM Seascape – Knuckles Chaotix. Màn hình đen. ]
B2826: [Hộp lựa chọn hiện ra - Xuống Atlantis mua sách phép]
B2827: Mua sách phép làm quà tặng giáng sinh là ý tưởng không tồi!!
B2828: Lâu rồi mình cũng chưa ghé tiệm sách phép “ đó “ dưới Atlantis! Chắc là mình sẽ về nhà nghỉ ngơi một xíu rồi đi tiệm sách vậy!
B2829: [ Hải Quỳ về nhà. Khám phá nhà + lore của Hải Quỳ ]
B2830: Đúng là không có nơi nào thoải mái bằng nhà!
B2831: Vừa bước vào nhà, tôi thấy đôi ủng của Oni Onii trên kệ giày. Chứng tỏ ổng đang ở nhà!
B2832: HAI ƠI, EM VỀ RỒI!!! NHÀ CÓ GÌ ĂN KHÔNG HAI???
B2833: Pha mì ăn đỡ đi!!
B2834: Popo với Momo đâu haiiii
B2835: Đi du lịch rồi!!
B2836: Ỏ dị hả! Hai ăn hông thì em úp mì luôn?
B2837: Có! Úp mì trứng thịt kho chiên xù. Thêm hai cái trứng chiên nữa.
B2838: Chắc chắn ổng đang nằm ì trên giường!!
B2839: [ Giai đoạn đi khám phá nhà và mở được hầm. Điều kiện mở hầm: tương tác ở ( 007, 033 ) để đổi sprite và lấy chìa khóa mở hầm ]
B2840: [ ĐỌC XONG LÁ THƯ LÀ NGAY LẬP TỨC CHUYỂN SANG CẢNH DÍ. ]
B2841: Hải Quỳ: Đ-Đây là…!!
B2842: Hải Quỳ: Urg…
B2843: Hải Quỳ: Dahria…
B2844: [ Thoại hiện ngang màn hình ]
B2845: ( ??? ) Ngươi chỉ là đống phế phẩm thất bại thảm hại.
B2846: ( ??? ) Ngươi.
B2847: ( ??? ) Không xứng đáng ở đây.
B2848: ( SFX tiếng súng + đá vào người )
B2849: ( Map nhà kho biến mất thành map đen, Sprite Hải Quỳ_Athome rơi xuống như Undertales )
B2850: ( Sprite Hải Quỳ ngã xuống bãi rác. Cutscene Hải Quỳ ngồi dậy và lết từng bước. Đi được vài bước phải ngừng lại để hiện thoại )
B2851: ( ??? ) Một đứa thất bại.
B2852: [ Thoại của Hải Quỳ nhưng không hiện avachat ]
B2853: Hải Quỳ: Không phải…Urg…
B2854: ( ??? ) Phế phẩm như mày không nên tồn tại.
B2855: ( ??? ) Thí nghiệm thất bại. Ghi nhận cảm xúc tồn tại bên trong cá thể.
B2856: ( ??? ) Em là…
B2857: ( ??? ) Tại sao…Ngươi phải trống rỗng chứ! Sao lại ngươi lại có xúc cảm?
B2858: ( ??? ) Mau giết nó đi.
B2859: ( ??? ) D…a…h…
B2860: ( ??? ) Ghi nhớ đi.
B2861: ( ??? ) Tại sao phải quan tâm đến chúng?
B2862: ( ??? ) Niềm hi vọng…
B2863: ( ??? ) Sao lại nhìn ta bằng ánh mắt đó?
B2864: ( ??? ) Chúng là cỗ máy giết chóc.
B2865: Hải Quỳ: Không…phải…cỗ máy…
B2866: ( ??? ) Nhiệm vụ…duy nhất….
B2867: Hải Quỳ: Giết….Không…Urg…
B2868: ( Chuyển sang map có gương )
B2869: ( ??? ) CÚT ĐI! MAU CÚT KHUẤT MẤT TA!!
B2870: ( BGM nhạc rượt đuổi )
B2871: ( Nếu mà người chơi cho Hải Quỳ ngoảnh đầu lại sẽ bị một Clone Tele đến giết - Gameover )
B2872: [ Giai đoạn đi khám phá nhà và úp mì cho hai người ăn ]
B2873: [ Cutscene Hải Quỳ ngồi ăn cùng Oni Onii ]
B2874: Mì trứng thịt kho chiên xù còn đúng hai gói anh em mình ăn luôn!
B2875: Mốt tao mua thêm vài thùng.
B2876: Cả hạt với cát cho MSG với Black Pepper nữa!
B2877: Cái đó thì mày tự mua đi!!
B2878: Hoy mà haii, mua dùm điiii
B2879: Mày lại đền bù thiệt hại gì gì đó nữa rồi à?
B2880: Đ-Đâu có…
B2881: Không đền bù mà mở mồm ra nhờ tao. Hay quá ha.
B2882: Rồi lần này mày gây họa gì?
B2883: …!!
B2884: Hahaha…Em lỡ…ờm…Bắn nổ nóc tòa nhà hành chính ở khu Icarus…
B2885: Gì?
B2886: Haha…
B2887: Mày…bắn nổ nóc tòa nhà hành chính…chỗ tao làm?
B2888: Dạ…
B2889: Mày báo hại tao phải tăng ca hôm đó!! Con nhóc ăn hại này!!
B2890: [ Hiệu ứng gõ vào đầu ]
B2891: Ui da!!!
B2892: Đáng lý hôm đó tao được nghỉ!! Nhờ ơn mày mà tao phải lết cái thân già này lên chỗ làm lúc 1h sáng!
B2893: Sao không dùng phép trói buộc tao dạy mày hả đầu đất!!
B2894: E-Em không dùng kịp…!!
B2895: Không dùng kịp cái gì mà không dùng kịp!!
B2896: Mày ỷ nại vào trò bắn beam của mày thì có!!
B2897: Ui da!!
B2898: Thiệt tình, không hiểu sao mày với chị Tư đều thích cái trò bắn beam vậy…!
B2899: Hả gì! Chị Tư cũng thích bắn beam hả!
B2900: Ừ. Tao nhớ khi ấy chị Tư cố học Aero Blast để làm được trò đó.
B2901: Mỗi lần chị Tư đút cho tao ăn toàn hô “ Aero Twinkle Blast! “ xong đút tọt vào mồm tao.
B2902: Trùng hợp vậy! Tôi cũng tạo ra chiêu thức “ Anemone Diamond Shower “ từ “ Aero Blast “ đó!
B2903: Cho tới khi…
B2904: Thôi.
B2905: Kể nữa chắc không ăn nổi mì mất.
B2906: Nói xong Oni Onii cắm cúi ăn. Bầu không khí đột ngột yên tĩnh.
B2907: Tôi để ý rằng, mỗi lần Oni Onii, Popo và Momo tôi vô tình nhắc đến chị Tư thì ngay sau đó mọi người sẽ lập tức im bặt không nói thêm lời nào.
B2908: [ Cutscene Hải Quỳ đứng ở bồn rửa chén, Oni Onii nói vài câu rồi đi lên lầu ]
B2909: [ Nếu không tương tác ở ( 007, 033 ) ]
B2910: À mà phép biến hình của mày lại lỗi nữa hả? Xíu nữa kiểm tra lại mỏ neo biến hình đi, không là cạn ma lực đấy.
B2911: Dạ, em biết rồi!!
B2912: [ Sprite Oni Onii đi mất ]
B2913: Được rồi! Rửa đống chén này xong phải nghỉ ngơi một chút để còn sửa cái mỏ neo rồi còn đi mua sách nữa!!
B2914: [ Nếu tương tác ở ( 007, 033 ) ]
B2915: Chứ nhìn cái dạng hồi còn bé này của mày làm tao ớn quá!
B2916: Người gì kỳ cục à!!
B2917: Thôi được rồi! Rửa đống chén này xong phải nghỉ ngơi một chút để còn sửa cái mỏ neo rồi còn đi mua sách nữa!!
B2918: [ BG Tiệm sách phép Atlantis ]
B2919: Uầy, cái mùi sách này…hoài niệm ghê!
B2920: Đây chính là tiệm sách phép “ đó “. Một tiệm bán sách phép cũ, huyền thoại đối với tôi. Toàn bộ sách phép ở đây đều không dán niêm phong. Thế nên bạn có thể ngồi ở đây cả ngày đọc sách hoàn toàn miễn phí mà không phải mua chúng. Vì thế hồi tôi còn bé, tôi hay được OniOnii-chan đèo ra đây đọc sách.
B2921: Chủ tiệm sách khi ấy là một bà lão dễ tính, vô cùng thương yêu trẻ con, mỗi khi thấy tôi đến đều mang một rổ bánh kẹo và bình trà gạo rang cho tôi vừa nhâm nhi vừa đọc sách. Thế là cứ tuần này sang tháng nọ, tôi mau chóng đọc gần hết sách ở cửa tiệm.
B2922: Tôi còn nhớ, trước khi tôi tham gia khóa tập huấn của Poseidon, bà lão từng hứa sẽ tặng cho tôi cuốn sách mà bà ấy thích nhất sau khi tôi trở về. Tiếc rằng lời hứa ấy không thể hoàn thành. Bẵng đi một khoảng thời gian mà tôi không thể xác định, bà lão đã qua đời.
B2923: Ngần ấy năm đã trôi qua, cửa tiệm đương nhiên sẽ thay đổi. Nhưng chỗ ngồi năm ấy của tôi và bà lão vẫn nguyên vẹn, chưa bị thời gian chạm vào. Mà thôi, không nhung nhớ quá khứ nữa! Tập trung tìm sách nào!!
B2924: [ Khám phá map để tìm sách ]
B2925: [ NẾU TƯƠNG TÁC VỚI CHỦ TIỆM TRƯỚC KHI TÌM SÁCH ]
B2926: Ồ, xin chào quý khác đến với Tiệm Sách Thời Gian Lay Đọng! Liệu tôi có thể giúp gì- Ô! Là em hả?
B2927: ???
B2928: Màu tóc này, tuy hơi nhạt một chút, nhưng màu mắt này không lẫn vào đâu được! Em là cô bé đó hả?
B2929: Chị biết em à?
B2930: Biết chứ! Bà chị lúc nào cũng kể về em đó!
B2931: Vậy ạ?
B2932: Ừa! Từ từ! Chị đang nhớ cái gì đó….Hmmm!! À à, đúng rồi đúng rồi! “ NÓ “!
B2933: “ Nó “??
B2934: Món quà mà bà chị tính tặng cho em mà không kịp!! Đợi chị một xíu!!
B2935: Chị chủ tiệm vội chạy vô trong. Đợi khoảng một lúc lâu, chị ấy chạy ra cùng một hộp thiếc dán chi chít giấy niêm phong đã ố vàng, rách bươm đôi chỗ. Chị ấy nhét thẳng chiếc hộp vào tay tôi.
B2936: Đây!! Là “ nó “ nè!
B2937: Hộp thiếc này…là quà của em hả?
B2938: Ừa đúng rồi! Trước khi bà mất đã dặn tụi chị tìm em và trao tận tay hộp thiếc này đó! Cơ mà tụi chị chưa gặp em bao giờ nên không xác định được hình dáng em trông ra sao nên tụi chị cứ chờ hoài chờ mãi thôi! Đúng như bà nói, màu mắt của em đặc biệt thiệt đó! Nhìn phát nhận ra luôn!
B2939: Haha…Vậy ạ?
B2940: Về món quà này, tụi chị cũng không biết bên trong có gì! Chỉ biết trong hộp thiếc này là món quà mà bà đã chuẩn bị kỹ cho em thôi! Kỹ đến mức dán quá trời quá đất giấy niêm phong, tụi chị có lần tò mò mở thử mà không được!
B2941: Chị chủ tiệm vừa nói xong, những tờ giấy niêm phong chiếc hộp lần lượt rơi xuống. Cả tôi và chị chủ tiệm tròn xoe mắt nhìn vào chiếc hộp.
B2942: Ủa…giấy niêm phong rơi ra rồi nè… - Chị chủ tiệm thúc giục tôi - Mở ra đi em!!
B2943: “ Rồi là quà của chị hay là quà của em? “, tôi nói thầm trong lòng. Tôi nậy nắp hộp thiếc ra, bên trong hộp là một quyển sách trông đầy nghi vấn. Bìa cuốn sách được đóng bằng loại da sẫm màu của quái vật vực sâu có dính một vài vệt màu đỏ làm nổi bật phần xù xì của lớp da. Xung quanh cuốn sách tỏa ra một luồng ma năng bất ổn. Tôi hơ nhẹ tay lên để kiểm tra thì cảm nhận được cái nóng thiêu đốt đến rát cả da, luồng điện giật mạnh làm đầu óc choáng váng từ cuốn sách.
B2944: Đây chắc chắn là tạo vật vực sâu, không nhầm lẫn đi đâu được!
B2945: Tiếng chuông cảnh báo sự tấn công của quái vật vực sâu từ điện thoại trong túi tôi và loa công cộng bên ngoài cửa tiệm ngay lập tức vang lên ầm ĩ. Giây sau, cuốn sách trong hộp thiếc nổ tung, thổi bay tiệm sách cũ và khu vực xung quanh tiệm sách. Chỉ trong khoảnh khắc ngắn ngủi, tạo vật vực sâu này đã xóa sạch mọi thứ, cướp đi hàng trăm sinh mạng. Chị chủ tiệm may mắn được tôi tạo khiên chống đỡ nên cơ thể chỉ bị xây xát nhẹ.
B2946: E-Em không sao chứ?
B2947: Em ổn. Trước khi chiếc khiên chống đỡ mà em tạo hết tác dụng, chị mau tìm hầm trú ẩn. NHANH!
B2948: Chị ấy gật đầu, mau chóng chạy đi.
B2949: Cuốn sách bay lên ngang tầm mắt tôi, mở tung và xé toạc từng trang, bao quanh lấy tôi như một cơn lốc xoáy. Tôi chạm nhẹ vào chiếc mỏ neo trong túi, triệu hồi đôi găng tay của tôi để chuẩn bị nghênh chiến với nó.
B2950: [ Animation triệu hồi găng tay ]
B2951: Nào, tới giờ tính sổ tội lỗi của ngươi rồi! [ Q2 ]
B2952: [ CHUYỂN ĐẾN CẢNH 12 ]
B2953: [CHOICES] Mua Ma Vương Cổ Đại | Phép thuật dịch chuyển nâng cao
B2954: Ma Vương Cổ Đại
B2955: Nhắc đến Hakase lại nhớ tới Ma Vương…Ma vương…Ma Vương…À nhớ rồi! Tôi nhớ trong tiệm sách này có một quyển sách cũ rích không rõ nguồn gốc có nói về Ma Vương Atlantis. Đến cả tôi lúc đọc cuốn đó còn bất ngờ mà! Nào giờ ở dưới Atlantis ai cũng tôn thờ thần Poseidon hết, tự dưng tòi đâu ra ông Ma Vương không ai biết mặt biết tên lại chả bất ngờ. Ban đầu tôi còn tưởng cuốn này là tiểu thuyết được viết bởi ai đó nhưng khi thử một số phép thuật được viết trong đây, tôi chắc chắc cuốn này là sách siêu cổ đại! Đa phần số phép thuật mà tôi dùng hiện giờ đều học từ cuốn này mà ra.
B2956: Mua cuốn này cho Hakase là chuẩn bài rồi đấy!! Vì Hakase từng là ma vương mà! Trong cuốn này cũng còn nhiều phép thuật tôi chưa sử dụng được, cá chắn Hakase đọc phát thông thạo ngay!
B2957: Phép thuật dịch chuyển
B2958: Ồ, cuốn phép thuật dịch chuyển này? Nhớ có lần Shylvie từng hỏi tôi rằng phép thuật dịch chuyển ở Atlantis có gì khác với phép thuật dịch chuyển mà bà ấy từng học không. Đương nhiên là…Ờm…Tôi không biết? Thú thực là tôi không rành về các phép thuật hỗ trợ lắm, nói trắng ra là mù tịt. Vậy mua cuốn này cho Shylvie là chuẩn bài rồi! Tôi cũng tò mò xem liệu có sự khác biệt giữa các phép thuật dịch chuyển không.
B2959: Rượt đuổi
B2960: ( Hải Quỳ chạy thoát khỏi hành lang gương. Sprite đứng thở hồng hộc. Lưu game ở đoạn này. )
B2961: ( ??? ) Nghĩa vụ của ngươi…
B2962: Hải Quỳ: Im đi! Im đi! Im đi!
B2963: ( Xuất hiện các clone của Hải Quỳ đứng rải rác xung quanh )
B2964: ( ??? ) Nghĩa vụ của chúng ta…
B2965: ( Các clone dần dần đi về phía Hải Quỳ )
B2966: ( ??? ) Tại sao chỉ có ngươi là còn sống?
B2967: ( ??? ) Còn sống nhưng thất bại…
B2968: ( ??? ) Tại sao không chết đi?
B2969: ( ??? ) Mì…thịt…kho…
B2970: ( ??? ) Không thể chết.
B2971: ( ??? ) Thà chết còn hơn.
B2972: ( ??? ) Thất bại.
B2973: ( ??? ) Thành công.
B2974: ( ??? ) Thảm hại.
B2975: ( Màn hình rung lắc, các clone biến mất. Xuất hiện bóng hình quái vật to đùng đằng sau lưng. Sprite Hải Quỳ quay lại nhìn một lúc rồi bắt đầu màn rượt đuổi. Cho các clone xuất hiện để chặn đường, nếu đụng trúng là gameover. Chạy được một đoạn thì các clone phía trước bị sét đánh biến mất cho người chơi dễ chạy. Đến cuối map thì chạy cutscene )
B2976: [ Cutscene Hải Quỳ đối đầu với quái vật khổng lồ ]
B2977: ( ??? ) Ngươi…
B2978: ( ??? ) Chấp nhận…
B2979: ( ??? ) Nghĩa vụ…
B2980: ( ??? ) Bản năng…
B2981: ( ??? ) Nấu mì…
B2982: ( ??? ) Vứt bỏ…
B2983: Hải Quỳ: K-Không có nghĩa vụ nào hết! Bản năng gì chứ? Im đi!
B2984: ( ??? ) Đã là phế phẩm…
B2985: ( ??? ) Còn dám lên tiếng sao…?
B2986: ( ??? ) Được ban ân huệ…
B2987: ( ??? ) Lãng phí…
B2988: Hải Quỳ: Phế phẩm? Ta…Không phải phế phẩm!
B2989: Hải Quỳ: Ta là…Dahria…!
B2990: ( ??? ) Không phải tên ngươi…
B2991: ( ??? ) Ngươi chẳng là gì…
B2992: ( ??? ) Ngươi chẳng có tên…
B2993: ( ??? ) Dahria…
B2994: ( ??? ) Cũng là phế thải…
B2995: Hải Quỳ: …!!
B2996: ( Quái vật tiến sát hơn )
B2997: ( ??? ) Mau nhớ lại đi…
B2998: ( ??? ) Ngươi là…ai…?
B2999: ( ??? ) Ai…là ngươi…?
B3000: Hải Quỳ:...Ta…Ta là…
B3001: Hải Quỳ:....
B3002: Hải Quỳ: Dahria…có thể không phải tên của ta.
B3003: Hải Quỳ: Nên…
B3004: Hải Quỳ: Ta sẽ khẳng định…Dahria…chính là ta!
B3005: Hải Quỳ: Tính chơi đòn tâm lý với ta à?
B3006: Hải Quỳ: Ngươi cũng to gan đấy…!
B3007: Hải Quỳ: Lại còn dám cả gan đột nhập vào nhà ta nữa!
B3008: ( ??? ) ???
B3009: Hải Quỳ: Để ta nói cho thấu nhé!
B3010: Hải Quỳ: TA!
B3011: Hải Quỳ: Không phải thí nghiệm, tạo vật hay phế phẩm thất bại mà ngươi nói!
B3012: Hải Quỳ: Ta cũng muốn cù nhây với ngươi thêm chút nữa đó.
B3013: Hải Quỳ: Cơ mà anh ta không cho phép đâu.
B3014: ( ??? ) DAHRIAAAAAAAAAAAAAAAAAAAAAA
B3015: Hải Quỳ: Đấy, thấy chưa?
B3016: Hải Quỳ: À, để ta nói cho ngươi nghe cái này.
B3017: Hải Quỳ: Anh trai ta…cực ghét quái vật vực sâu luôn.
B3018: Hải Quỳ: Nên là…!!!
B3019: Oni Onii: ECLIPSE BLOCKCHAIN!!!
B3020: ( Quái vật bị trói, sprite Oni Onii rơi xuống trước mặt Hải Quỳ )
B3021: Oni Onii: Tao đợi mày úp mì chắc tới tết công gô mất!
B3022: Oni Onii: Nhanh giải quyết nó đi!
B3023: Hải Quỳ: Biết rồi!!!
B3024: Hải Quỳ: ANEMONE DIAMOND SHOWERRRRRRR
B3025: ( Hiệu ứng bắn beam đùng đùng xuống liên tục. Dùng hiệu ứng có sẵn đi, hehe C: )
B3026: ( Màn hình đen. Sang thẳng cảnh cuối. )
B3027: Tôi mang cuốn sách ra quầy cho chủ tiệm gói lại cẩn thận. Chị ấy còn tặng kèm một thẻ đánh dấu trang giấy có in hình hoa oải hương trên đấy.
B3028: Ngươi tính tặng cho tên ma vương đáng gờm đó à ?[ Q2 ]
B3029: Ừ đúng rồi, sao thế ?[ Q1 ]
B3030: Chưa bao giờ ta thấy ngươi đưa ra lựa chọn đúng đắn như thế này. Ngoan quá! [ Q2 ]
B3031: Ê nha, có ẩn ý gì đấy? [ Q1 ]
B3032: Ẩn ý gì đâu, ngươi nghĩ nhiều quá rồi đó! [ Q2 ]
B3033: Phép Thuật Dịch Chuyển
B3034: Đọc tin nhắn xong mắt tôi nổ đom đóm. Cái nhỏ Shylvie chết tiệt khó ưa này!
B3035: Tặng cho nhỏ đó cuốn phép thuật dịch chuyển này không phải ý tồi đâu. [ Q2 ]
B3036: Tôi mang cuốn sách ra quầy cho chủ tiệm gói lại cẩn thận. Chị ấy còn tặng kèm một thẻ đánh dấu trang giấy có in hình hoa cẩm chướng màu hồng.
B3037: Tôi…ngủ một mạch….đến…GIÁNG SINH ?!
B3038: Chết rồi !! Vỡ kế hoạch rồi !! Nửa bên kia của tôi ơi !! SAO KHÔNG GỌI TÔI DẬY?! Còn vài tiếng nữa là đến tiệc giáng sinh trong văn phòng rồi !!
B3039: Giờ này thì làm sao mà kịp bắt xe đến văn phòng được ?! Chìa khóa dịch chuyển đâu rồi… !! Nó nằm ở đâu vậy ?!
B3040: Mình còn chưa chuẩn bị trang phục nữa !! Nên mặc bộ nào đây !!
B3041: Cũng không phải bộ này nốt !!
B3042: Bộ này ổn này !!
B3043: Ý chết ! Suýt nữa là quên hộp quà !
B3044: Quỳ !! Hello !
B3045: Tôi lập tức đứng dậy, cầm theo túi quà được gói kỹ càng tiến đến chỗ của Hakase.
B3046: Hakase xé giấy gói quà của tôi rách thành trăm mảnh bay xuống nền nhà như pháo giấy. Hakase cầm cuốn sách lên, mắt chữ A và miệng chữ O nhìn tôi, kinh ngạc hết cỡ.
B3047: - Đây là…sách “ Ma Vương Cổ Đại “ á anh! Cuốn này kể về Ma Vương Cổ Đại từng trị vì Atlantis.
B3048: - Nghe nó cứ sai sai làm sao ấy Hải Quỳ! Anh tưởng Atlantis nào giờ được trị vì bởi Poseidon?
B3049: - Thú thực là em cũng không rõ lắm. Chỉ biết là cuốn này được viết bằng ngôn ngữ cổ, phép thuật được viết trong này toàn bộ là phép thuật không ai dùng ở Atlantis thời đại bây giờ nữa.
B3050: - Trời! Em đọc được ngôn ngữ cổ hả?
B3051: - Em đọc bặp bẹ được vài từ thôi!
B3052: - Ê ê Quỳ, tôi có câu hỏi - Shylvie chen vào - Rồi sao bà biết phép thuật ở trong cuốn này không còn ai dùng nữa? Bà thử rồi phải không??
B3053: - T-Thì đọc chứ sao má!! Ngộ ghê!
B3054: - Oblivion Blast.
B3055: “ ĐÙNG “
B3056: Cả văn phòng Wanderer rung chuyển dữ dội làm mọi người hoảng hốt. Sierra phát báo động đỏ.
B3057: -Cảnh báo. Cảnh báo. Ghi nhận sự nhiễu động mạnh từ luồng ma lực bất thường trong văn phòng.
B3058: -Cái gì vừa xảy ra vậy? - Kohi bất ngờ - Thiên thạch đâm trúng văn phòng hả? Ủa đâu…
B3059: - Leo…sao người ông cháy đen thui vậy?!?! - Shylvie hoảng hốt - TỪ TỪ, ĐỂ TUI HỒI PHỤC CHO!!
B3060: - Uầy Quỳ, phép thuật này ở Atlantis có ai dùng chưa? - Hakase quay sang hỏi tôi
B3061: - Chưa…! Anh chỉ em với! Em cũng muốn học!
B3062: - Đưa tay em đây.
B3063: Tôi chìa tay, Hakase lập tức chộp lấy, truyền dạy cho tôi “ Oblivion Blast “. Một luồng điện xẹt qua đầu, trong đầu tôi bỗng dưng hiện lên hàng chục dòng ngôn ngữ cổ được dịch sang ngôn ngữ Atlantis hiện đại.
B3064: OBLIVION BLAST!!!
B3065: TRỜI ƠI QUỲ ƠI!! BÀ LÀM CÁI GÌ VẬY?! SUÝT NỮA TRÚNG TÔI RỒI!!
B3066: Úi da, xin lỗi nha! Ehe
B3067: EHE CÁI QUẦN!!!
B3068: Hakase lướt nhanh qua cuốn sách, vừa đọc vừa gật gù.
B3069: Cảm ơn em nha!! Món quà này tuyệt vời lắm!
B3070: Nói rồi Hakase cất cuốn sách vào túi không gian của anh ấy, đồng thời lôi ra một hộp giấy đính nhiều ruy băng.
B3071: Kohi gọi ới Sierra một tiếng, toàn bộ đèn trong văn phòng được bật sáng trở lại. Kohi đứng dậy đi vào phòng để cất chiếc đèn ngủ ma thuật rồi đi ra ngoài với một chiếc váy dạ hội màu xanh lơ lấp lánh kim tuyến. Chỉ cần nhìn vào chúng thôi, tôi có thể xác định được món quà này sẽ dành tặng cho ai.
B3072: Ôi, cảm ơn con gái yêu của bố! Váy đẹp quá!!
B3073: Sau khi nhận được chiếc váy dạ hội mà Kohi tặng, Shylvie cẩn thận cất nó vào trong chiếc túi không gian ma thuật của mình. Xong, Shylvie rút ra một chiếc ốp lưng điện thoại màu đen từ trong chiếc túi và đưa nó cho Leo.
B3074: Tôi đưa túi quà cho Shylvie. Ngay khi cầm, Shylvie vô cùng tò mò, đôi tay liên tục sờ soạng túi quà.
B3075: - Giáng sinh an lành Shi-ru-vi! Tui hi vọng bà thích cuốn sách này!
B3076: - UẦY! BIẾT NGAY LÀ SÁCH MÀ!!
B3077: Shylvie vui vẻ xé túi giấy, lập tức mở cuốn sách ra đọc làu làu.
B3078: - Hồi lâu bà có nói là bà tò mò tui học phép thuật dịch chuyển như thế nào và muốn so sánh với phép thuật của bà nên là tada!
B3079: - Chuẩn rồi, nhớ dai dữ! Phép thuật dịch chuyển này….là phép thuật nâng cao…ủa, nâng cao??
B3080: - Hử? Nâng cao thì sao?
B3081: - Nghĩa là bà không học căn bản, học luôn nâng cao hả?
B3082: - Có căn bản hả??
B3083: - Trời… - Leo ngạc nhiên - Giờ thì tui có thể hiểu được lý do vì sao bả dùng phép thuật dịch chuyển tệ rồi đấy…
B3084: - WOW! Em giống anh ghê! - Hakase nói
B3085: - Bả còn không biết là có phép căn bản luôn chứ - Kohi tò mò - Vậy ở Atlantis ai cũng học nâng cao ngay từ đầu…hay chỉ mỗi bà thôi?
B3086: - Không, họ học từ cơ bản ấy chứ…Xong mới từ từ nâng cao.
B3087: - Rồi sao bà học cuốn này ngay từ đầu vậy? - Shylvie đổ mồ hôi hột
B3088: - Thì tại nó không có tập cơ bản….
B3089: - THÌ BÀ PHẢI TÌM ĐI CHỨ!!
B3090: Shylvie gõ vào đầu tôi một cái.
B3091: Rồi Shylvie cất cuốn sách của tôi vào túi không gian, đồng thời lôi ra một túi cà phê dát vàng thượng hạng ở chiều không gian của mình. Nhận lấy túi cà phê, Kohi cười híp cả mắt.
B3092: [ TƯƠNG TÁC VỚI CHỦ TIỆM TRƯỚC KHI TÌM SÁCH ]
B3093: [ BG Văn Phòng Wanderer đầy tuyết, mọi người đang ngồi chờ trong lo lắng ]
B3094: Đã quá giờ luôn rồi mà vẫn không thấy Quỳ đâu - Leo lo lắng
B3095: Chắc không có chuyện gì đâu, đúng không? Có lẽ bà ấy ngủ quên chăng? - Kohi lo lắng
B3096: Không có chuyện ngủ quên mà không báo chúng ta đâu - Shylvie lo lắng - Không phải bà ấy gặp chuyện gì đấy chứ?
B3097: Khả năng cao là vậy - Hakase nói - Nãy giờ anh không liên lạc được với Quỳ. Tin nhắn cũng không gửi được.
B3098: Sierra, mau chóng xác định vị trí hiện tại của Hải Quỳ đi - Leo ra lệnh cho Sierra
B3099: Nhận lệnh. Kích hoạt hệ thống định vị. Đang phân tích. Không thể xác định. Vị trí cuối cùng: 25°B 71°T. Thời gian: 3 ngày 13 tiếng trước.
B3100: Vậy là ngay sau khi xuống Atlantis thì mất liên lạc sao? - Leo đáp
B3101: Sao Leo biết Quỳ xuống Atlantis? - Kohi hỏi
B3102: Tọa độ đó là tọa độ “ nhà ga “ xuống Atlantis đó.
B3103: Chắc chắn có chuyện rồi. - Shylvie nói - Thiết bị liên lạc của chúng ta phủ sóng đa chiều không gian, kể cả Atlantis mà.
B3104: Giờ làm sao tìm được bà ấy đây? - Kohi lo lắng
B3105: Anh có phép thuật dò tìm - Hakase đáp - Nhưng phải dùng tới món đồ đã lưu trữ ma pháp của Hải Quỳ.
B3106: Có! Băng đạn của Quỳ! - Leo la lớn - Để tui đi lấy!
B3107: Leo chạy đi lấy băng đạn rồi đưa cho Hakase. Hakase thiết lập vòng tròn ma pháp và đặt băng đạn xuống. Chỉ trong thoáng chốc, ma lực còn sót lại trong băng đạn của Hải Quỳ văng ra ngoài, tạo thành một khối cầu ma lực bay lơ lửng ngang tầm mắt tất cả mọi người.
B3108: Mọi người, chuẩn bị đi. Chúng ta đi tìm Hải Quỳ - Hakase nói
B3109: [MUA SÁCH TẶNG SHYLVIE/HAKASE ]
B3110: Sáng hôm sau, tôi mệt mỏi dịch chuyển về văn phòng để ăn kem như lời đã hẹn. Nhưng Shylvie đã dùng hết số kem socola tối qua để làm một món tráng miệng mới theo kiểu Tây Âu cho cả văn phòng, đến chiều mới được ăn.
B3111: Bù lại, sáng nay Shylvie nấu bữa sáng theo kiểu Đức, ăn ngon lắm.
B3112: Thế Hakase đâu rồi?
B3113: Đang thử phép thuật trong phòng nghiên cứu á. - Shylvie đáp - Vậy có gì ăn xong bà mang bữa sáng qua cho ổng nhé?
B3114: Ọ, biết ùi.
B3115: Tui liếm sạch đĩa, chùi miệng rồi lon ton mang khay bữa sáng vô phòng nghiên cứu. Tại đây, tôi nghe thấy giọng Hakase vọng ra từ một luồng sáng gì đó cháy rực làm đôi mắt mỏi mệt của tôi muốn mù.
B3116: Quỳ! Em đến đúng lúc lắm! Nhìn nè!
B3117: Hakase bước ra từ luồng sáng ấy. Mặt Hakase điển trai hơn, có sức hút kỳ lạ hơn.
B3118: Tada! Tối hôm qua anh nghiên cứu cuốn sách này và phát hiện ra ma lực còn sót lại của Ma Vương! Rồi anh hấp thụ nó và thế là…!!
B3119: Nhìn ngầu thiệt đó!!
B3120: Nhưng chả hiểu vì sao cơ thể tôi cảm thấy khó chịu khôn lường. Một cảm giác quen thuộc? Tức giận? Không đời nào tôi lại ghen tỵ với Hakase vì ông ấy mở khóa được hình dạng mới. Hakase xứng đáng mà.
B3121: Hải Quỳ, mang bữa sáng qua bàn mổ đi!
B3122: Hả? Okay, bữa sáng đây.
B3123: Tôi đặt bữa sáng lên bàn mổ của Hakase.
B3124: Hải Quỳ! Mau chồng cây chuối đi!
B3125: Hả…Em đâu biết chồng cây chuối đâu…
B3126: …??? - Hakase khó hiểu - Hmm, Hải Quỳ, sử dụng Moonlight Delulu Breaker đi!!
B3127: Nó là Moonlight Divine Breaker!! Cơ mà sao em phải dùng vậy??
B3128: Quái lạ…! Trong sách bảo là với hình dạng này, anh có thể sai khiến cư dân Atlantis làm theo điều anh muốn, kể cả Poseidon mà…! Chả lẽ…
B3129: Hả….???
B3130: Em…không phải là người Atlantis à…?
B3131: Sáng hôm sau, tôi mệt mỏi dịch chuyển về văn phòng để ăn kem như lời đã hẹn.
B3132: Tôi buồn chán chuẩn bị rời đi thì bị dịch chuyển lên bầu trời cao vút.
B3133: DÙNG MOONLIGHT DELUSION BREAKER!! MAU MAU!! BẮN XUỐNG DƯỚI!
B3134: Nó là Moonlight Illusion Breaker má ơi….MOONLIGHT IILUSION BREAKER!
B3135: Ê!! NHƯ VẬY LÀ ĂN GIAN-
B3136: Hóa ra Shylvie và Leo đang tranh nhau hộp kem cuối cùng. Leo thì muốn để dành cho tôi, trong khi Shylvie lại muốn dùng nó để dụ con rồng nào đấy.
B3137: Sau khi dụ con rồng bất thành thì cả Shylvie quyết định kéo cả ba đứa đi ăn mỳ cay để đền bù cho Leo.
B3138: Để mà so sánh thì…phép thuật dịch chuyển này còn kém xa phép thuật dịch chuyển của tui - Shylvie nói - Giờ tui hiểu sao bà không dùng được phép dịch chuyển rồi đấy.
B3139: Vì sao thế?
B3140: Vì cái phép bà học thực chất là phép hoán đổi. Bà muốn hoán đổi vật A với vật B thì bà phải cầm vật A hoặc vật B có cùng ma lực…Nói ngăn gọn, ban nãy tui hoán đổi bà với băng đạn ma thuật của bà, thứ sở hữu ma lực của bà đó.
B3141: À…hóa ra là vậy… - Leo nói - Bảo sao có lúc bả dùng được, có lúc không.
B3142: Không, Leo. Bả còn không dùng được cái phép này - Shylvie lo lắng - Bằng cách nào đấy, bả học phép này lại dùng được mấy phép dịch chuyển khác…
B3143: Đàm….
B3144: Rồi tôi được ăn kem chưa?
B3145: Đây đây, kem của bà đây.
B3146: Shylvie làm đông hũ kem rồi đưa cho tôi.
B3147: Ngon! - Tôi múc từng muỗng ăn ngấu nghiến
B3148: Và rồi tôi múc từng muỗng cho vô tô mì cay trước sự chứng kiến của Leo và Shylvie.
B3149: Bà…AI LẠI CHO KEM SOCOLA VÀO MÌ CAY HẢ?!?!?!
B3150: TƯƠNG TÁC VỚI CHỦ TIỆM TRƯỚC KHI TÌM SÁCH
B3151: [ Cutscene ]
B3152: Theo chỉ dẫn của cầu ma lực, mọi người đã tìm đến chỗ của Hải Quỳ. Tại đây, họ thấy Hải Quỳ ( ?? ) đang ngồi trong lồng phép thuật.
B3153: Ô kìa? Mấy người mò được đến đây luôn à? Đỉnh thế?
B3154: Cái giọng này…Bully Quỳ? Chuyện gì đã xảy ra vậy? - Shylvie hét lên
B3155: Ờ thì bọn ta chạm trán quái vật vực sâu. Và ngươi thấy rồi đó.
B3156: Thấy gì? Ngươi tự nhốt bản thân? - Leo đáp
B3157: Ừ. Con này khó nhai quá, nó nhập hồn vô xác bọn ta rồi. Thế nên đành phải tự nhốt bản thân thôi.
B3158: Hai người không còn cách nào hạ nó sao? - Kohi hỏi
B3159: Đang làm đây thôi. Ngồi đây chờ chết. Khi nào bọn ta chết, nó cũng sẽ chết.
B3160: NGƯƠI BỊ ĐIÊN À?! - Shylvie gắt - Tụi tui sẽ có cách giải quyết, đừng tự ý quyết định ngu xuẩn thế!
B3161: Khỏi, cảm ơn. Ê tên đầu tảo màu tím khoai lang kia, lại đây nói cái.
B3162: Hakase bước lại gần chiếc lồng.
B3163: Ngươi là cựu ma vương đúng không?
B3164: Cũng có thể nói vậy.
B3165: Thấy cuốn sách đằng kia không? Lụm lại đây đi.
B3166: Hakase làm theo lời của Bully Quỳ, ra chỗ cô ta chỉ tay để lấy cuốn sách rồi quay lại.
B3167: Trong đây có phép thuật trục xuất của Ma Vương đấy. Lật trang 512 đi.
B3168: Ồ, đúng thật. Oblivion Blast. “ Blast “ một phát thì “ đăng xuất “ chứ trục xuất gì…?
B3169: Thì cho đăng xuất con quái vật chứ sao ba nội? Mấy cái phép này không đủ làm bọn ta bay màu đâu, yên tâm dùng nhé.
B3170: Nói nghe an tâm dữ ha. Cô chưa tính đến vụ phải học phép thuật này trong bao lâu à?
B3171: Ngươi là ma vương mà, học hành là bỡn. Có khi đọc xong là ngươi đã dùng được rồi.
B3172: Hai người thì thầm gì đó? - Kohi ngoái đầu hỏi
B3173: Cách để trục xuất quái vật! - Hakase đáp - Mọi người đợi chút.
B3174: Sao? Nhắm dùng được không?
B3175: Dùng được! Có kế hoạch gì không?
B3176: Ta sẽ gỡ phong ấn chiếc lồng lẫn phong ấn con quái vật. Ngay khoảnh khắc chiếc lồng vừa bị phá, ngươi phải dùng phép thuật này ngay lập tức. Chỉ cần chậm một khắc thôi, tất cả các ngươi đều bán muối đấy.
B3177: Haha. Tôi lại không nghĩ mọi người yếu đến mức đấy đâu.
B3178: Hakase hét lớn.
B3179: MỌI NGƯỜI! SẴN SÀNG CHIẾN ĐẤU!
B3180: Shylvie ngay lập tức triệu hồi khiên chắn cho Kohi, Leo thì xông lên trước với thanh kiếm trong tay.
B3181: Được rồi Bully Quỳ, làm đi!
B3182: Cơn rung chấn bất ngờ diễn ra. Chiếc lồng vỡ tung. Con quái vật trỗi dậy, nuốt chửng thân xác của Hải Quỳ. Ngay khoảnh khắc đó, Hakase hét to:
B3183: OBLIVION BLAST!!
B3184: Từ trên giáng xuống một cột sáng khiến con quái vật tan thành khói bụi. Khói bụi tan đi, Hải Quỳ đang đứng sừng sững hiện ra, từ từ quay lại nhìn mọi người.
B3185: [ CG Hải Quỳ mỉm cười ]
B3186: Tui đói quá à...Tụi mình đi ăn ha, tui mời!
B3187: ( Map Hải Quỳ ngủ trong phòng, sprite của Oni Onii đứng kế bên )
B3188: Oni Onii: Mày thấy sao rồi?
B3189: Hải Quỳ: Cũng đỡ đỡ…
B3190: Oni Onii: Ai mà ngờ được cái con quái vật vực sâu có khả năng ngụy trang mà mọi người ráo riết truy đuổi
B3191: Oni Onii: Lại ở nhà mình cơ chứ?
B3192: Hải Quỳ: Hả…?
B3193: Oni Onii: Ban nãy tao nhận được tin báo là có một con quái vật vực sâu lọt vào thành phố.
B3194: Oni Onii: Cấp trên điều động tao đi tìm nó nên tao tính xuống ăn mì cho lại sức rồi đi.
B3195: Oni Onii: Dè đâu mì chẳng thấy mà lại thấy nó.
B3196: Oni Onii: Thế mà lại hay.
B3197: Oni Onii: Phen này tao có huân chương là cái chắc.
B3198: Hải Quỳ: Thế hai không tính khao em à?
B3199: Hải Quỳ: Tính ra em là đứa giúp hai có huy chương luôn á.
B3200: Oni Onii: Rồi rồi! Tao sẽ suy nghĩ.
B3201: Oni Onii: Giờ mày nghỉ ngơi đi, tao đi xuống báo cáo với anh em.
B3202: Hải Quỳ: Dạ…!
B3203: ( Sprite Oni Onii đi ra ngoài. Gần đến cửa thì Oni Onii nói vọng lại )
B3204: Oni Onii: Cái chiêu “ Anemone Diamond Shower “ gi gì đó của mày…
B3205: Oni Onii: Sao nó gần giống “ Aero Blast “ vậy?
B3206: Hải Quỳ: Thì em nâng cấp từ chiêu đó mà…!
B3207: Oni Onii: Ồ, vậy hả?
B3208: Oni Onii: Sao không đặt là “ Aero Twinkle Blast “?
B3209: Oni Onii: Tên mày đặt nghe thối tai quá.
B3210: ( Sprite Oni Onii đi ra ngoài )
B3211: Hải Quỳ: ÔNG ANH HAI ĐÁNG GHÉT!!!!!
B3212: Hải Quỳ: Cơ mà…người ngợm thế này chắc không tham gia tiệc giáng sinh được rồi…
B3213: Hải Quỳ: Phải nhắn cho mọi người biết…
B3214: [ Hiện tin nhắn của các thành viên Wanderer ]
B3215: Hải Quỳ: Mọi người ơi…
B3216: Leo: Sao vậy Quỳ? Có chuyện gì vậy?
B3217: Hải Quỳ: E là giáng sinh lần này…tui không tham gia được.
B3218: Hakase: Hả! Sao đột ngột vậy?
B3219: Kohi: Sao lại không tham gia?
B3220: Hải Quỳ: Đại khái là tui bị úp sọt…!
B3221: Hải Quỳ: Giờ đang phải dưỡng thương…!
B3222: Shylvie: Cái gì? Bà bị úp sọt? Khó tin thế?
B3223: Hải Quỳ: Úp sọt thật mà.
B3224: Hải Quỳ: Tui bị úp sọt bởi quái vật vực sâu có khả năng cải trang.
B3225: Hải Quỳ: Chuyện kể ra thì dài lắm!
B3226: Hải Quỳ: Nhưng tóm cái quần lại là tui không tham gia chung với mọi người được!
B3227: Leo: Không sao!
B3228: Kohi: Cứ nghỉ ngơi cho khỏe đã!
B3229: Hakase: Aww, không lần này thì lần khác!!
B3230: Shylvie: Quan trọng là sức khỏe.
B3231: Shylvie: Không tham gia trực tiếp được thì tham gia gián tiếp được mà, đúng không?
B3232: Leo: Ừ ha!
B3233: Leo: Triển đi!!
B3234: Hải Quỳ: Mọi người…!!
B3235: ( Màn hình đen một lúc rồi hiện lần lượt CG ending Route rượt đuổi )
B3236: TƯƠNG TÁC MAP PHÒNG NGỦ HẢI QUỲ Ở VĂN PHÒNG WANDERER
B3237: ( Tương tác ba lần tại [ 016, 008 ]
B3238: Tủ bị khóa bằng mã điện tử. Nhập mã chứ? ( Mã: 0290120240012202 )
B3239: Ồ, cái hộp blu-ray Sousou no Frieren của Shylvie nè? Để năm sau trả vậy.
B3240: Uầy, cuốn album ảnh thẻ của những thân phận mình cải trang nè. Ngồi xem chứ?
B3241: [ Ngồi xem ] ( Cho người chơi xem album ảnh thẻ )
B3242: [ Để sau ]
B3243: Một xấp bản thiết kế trang phục cũ của mình. Ngồi xem chứ?
B3244: [ Ngồi xem ] ( Cho người chơi xem bản thiết kế cũ )
B3245: [ Để sau ] )
B3246: [ 015, 008 ] Trang lịch tháng 10 của năm 2022. Ngày 04 tháng 10 được khoanh tròn bằng bút dạ màu đỏ.
B3247: [ 014, 008 ] Khung ảnh chụp bông hoa dưới vực sâu. Mình nhớ sau khi mình chụp tấm ảnh này, bông hoa đã phát nổ.
B3248: [ 013, 008 ] Rìu chiến phòng bị. Lâu lâu đang ngủ mà bị Leo gọi giật dậy tham chiến thì mình luôn vác con hàng này đi thay vì găng tay Ruby Moon.
B3249: [ 012, 008 ] Tủ pajama của mình. Đa phần là pajama màu cam hoặc có hoa văn trái cam.
B3250: [ 011, 008 ] Ủa, trong khe hẹp này có quyển doujinshi Touhou hồi bữa mình lỡ tay dịch chuyển nè? Để lấy sau vậy.
B3251: [ 010, 008 ] Tủ đựng vủ khí quân dụng và thiết bị hỗ trợ nhiệm vụ nằm vùng. Ôi vẫn tiếc đứt ruột “ Bát Họ “…! Cái bát biến ra mọi món ăn mà mình nghĩ trong đầu…!!
B3252: [ 006, 009 ] - [ 006, 010 ] Bồn tắm. Tắm ngay bây giờ chứ?
B3253: [ Tắm thôi! ] Cutscene tắm
B3254: [ Để sau! ]
B3255: [ 005, 004 ] - [ 006, 004 ] Ngồi xem TV một chút chứ?
B3256: [ Xem xíu đi! ] Xem hết phim này đến phim khác, nhận Bad Ending:” Thêm tập nữa thôi! “
B3257: [ Không xem ]
B3258: [ 006, 005 ] Muốn leo lên giường nằm ngủ ghê! Nhưng mà mình ngủ sâu với lâu lắm! Thôi, để tối ngủ!!
B3259: Tương tác nhà Hải Quỳ
B3260: *** Về nhà không được dùng hệ thống hoán đổi . Vô nhà sẽ dùng HaiQuyGlitch_Base ***
B3261: ( 015, 010 ) Bồn rửa tay.
B3262: ( 016, 010 ),( 017, 010 ) Lối vào phòng sửa chữa của Popo.
B3263: ( 014, 011 ) Máy giặt cửa trên. Hồi bé mình hay chui vào đây ngủ.
B3264: ( 010, 010 ) Cửa sổ mô phỏng này vẫn còn hoạt động tốt. Ánh nắng chiếu vào dễ chịu quá.
B3265: ( 008, 011 ) Hồi bé mình hay ngâm mình trong bồn tắm này lắm.
B3266: Có lần mình ngâm tới năm tiếng, da tong teo hết cả.
B3267: ( 007, 033 ) Ảnh chân dung và album ảnh của anh ba và chị tư được trưng lên đây. Kế bên là một bình hoa cúc trắng.
B3268: OniOnii kể lại, hồi ấy ai cũng bảo mình trông giống chị em sinh đôi với chị tư.
B3269: OniOnii mới quyết định cắt tóc cho mình. Dè đâu trong lúc cắt tóc, cây kéo sượt qua tai mình, làm mình khóc ré lên, tóc từ màu xanh nhạt chuyển thành xanh đậm.
B3270: [ đổi thành HaiQuyAtHome_Base ]
B3271: Thật kỳ lạ, dù trong đầu mình chẳng có chút ký ức gì về hình dạng này.
B3272: Nhưng mình vẫn biến hình được, lại còn có cảm giác quen thuộc khó tả.
B3273: ( 006, 033 ) Cây đèn này được Popo sửa liên tục.
B3274: ( 005, 033 ) Tủ đựng thuốc sơ cứu của Momo.
B3275: ( 004, 033 ) Tủ đựng đủ kiểu ly tách, ấm trà của Popo. Trong đó có một ngăn toàn trà được xếp gọn.
B3276: ( 003, 033 ) Tủ đựng nhiều loại túi được Momo xếp gọn gàng. Tầng trên là túi vải, tầng dưới là túi được làm từ sợi tổng hợp thân thiện với môi trường.
B3277: ( 008, 033 ) Tủ đựng nhang, đèn cầy, trầm hương.
B3278: [ Sau khi tương tác 3 lần ở ( 004, 026 ) ] Ồ, chìa khóa phòng dưới cầu thang đây rồi!
B3279: ( 004, 037 ), ( 004, 038 ) Tủ treo nón áo, giày dép có chức năng tự động sấy khô.
B3280: ( 012, 038 ) Ủng của Oni Onii.
B3281: ( 017, 037 ), ( 017, 038 ) Tủ đựng các dụng cụ trồng cây và các loại phân bón của Popo.
B3282: ( 016, 032 ) Mình và OniOnii hay mua đĩa phim về xem. Để xem OniOnii có mua thêm đĩa nào mới không?
B3283: Ồ, dạo này ổng đang xem lại Garfield à?
B3284: ( 006, 029 ) Ảnh chụp hoàng hôn thành phố Atlantis.
B3285: ( 005, 029 ) Ảnh chụp chậu hoa mẫu lan.
B3286: ( 004, 029 ) Bằng khen của anh ba. Popo kể rằng anh ba là người duy nhất thừa hưởng được khả năng bắn súng của Popo và mãi tự hào về anh ấy.
B3287: Tương tác bốn lần ở ( 003, 029 )
B3288: Ảnh chụp về…arg…[ màn hình giật ]
B3289: Mình…không biết.
B3290: Nhìn quen lắm nhưng không nhớ nổi tên.
B3291: Khu vực này…Là… [ Màn hình giật ]
B3292: Mình không thể nhớ được. [ Màn hình giật ]
B3293: Cảm giác có cây đinh trong đầu mình vậy.
B3294: [ Sprite quay lại ] Đã bảo không muốn nhớ rồi mà sao cứ ép người ta nhớ thế hả?
B3295: Đôi mắt này nhiều chuyện quá rồi đó.
B3296: Không nhớ.
B3297: ( 013, 026 ) Ảnh chụp hồi bé của mình.
B3298: ( 012, 026 ), ( 011, 026 ) Ảnh chụp cả gia đình đi dã ngoại.
B3299: ( 010, 026 ) Ảnh chụp hoa súng trắng.
B3300: ( 009, 026 ) Kệ trưng bày rượu.
B3301: Mình hay trộm rượu của Popo để uống cho tới ngày mình bị dị ứng đồ cồn.
B3302: Rượu táo nho uống ngon lắm luôn!
B3303: ( 008, 026 ) Hồi bé mình lén Momo nhét đồ ăn vặt mua ở ngoài cổng trường vào đây.
B3304: Mình chưa kịp xơi thì đã bị tụi Tí Si ăn hết rồi!
B3305: Cũng nhờ thế mà Popo mới biết nhà có Tí rồi tiến hành kế hoạch đuổi chúng nó ra ngoài.
B3306: ( 005, 026 ) đến ( 007, 026 ) Tủ sách dạy lái xe tăng và các loại tàu chiến của Popo.
B3307: Tương tác ba lần ở ( 004, 026 )
B3308: Lần 1: Cửa này luôn bị khóa.
B3309: Chắc là kho chứa đồ hay gì đấy.
B3310: Lần 2: Mình từng tò mò trong này có gì.
B3311: Nhưng khi thấy Popo lấy đồ từ trong đây đem đi bán đồng nát thì mình mặc định rằng phòng này là phòng kho.
B3312: Lần 3: Mình nhớ là Momo từng cất chìa khóa phòng này ở cái tủ nào đó dưới đây.
B3313: ( 005, 017 ) Tủ lạnh luôn đầy ắp thức ăn.
B3314: Có một lần mình uống nhiều nước cam mà bị bệnh nên từ đó tới nay, Momo không cho mình trữ nước cam đóng hộp vô tủ lạnh nữa.
B3315: ( 004, 017 ) Nhìn tới lò vi song là lại nhớ tới bánh mì bơ tỏi.
B3316: Mà nhớ tới bánh mì bơ tỏi thì cái bản mặt khó ưa của OniOnii xuất hiện trong đầu mình.
B3317: ( 003, 017 ) Tủ dựng nhiều muỗng, đũa, nĩa, đĩa dùng một lần.
B3318: Chúng được làm từ nguyên vật liệu ăn được.
B3319: Đôi lúc đói, mình hay xuống đây lấy thật nhiều đĩa lên ăn. Giòn giòn như bánh tráng vậy.
B3320: ( 004, 021 ), ( 004, 020 ), ( 004, 019 ) Tủ gia vị.
B3321: ( 006, 016 ) Tủ mì ăn liền của OniOnii. Mình hay ăn ké mì của ổng.
B3322: Mì trứng thịt kho chiên xù rất ngon.
B3323: [ Pha mì nhé? ]
B3324: ( 007, 016 ) Bồn rửa.
B3325: ( 008, 016 ) Bếp và lò nướng.
B3326: ( 009, 016 ) Máy làm sữa hạt và lò nướng bánh.
B3327: ( 010, 016 ) Tủ đựng các loại nước rửa chén, lau sàn và bịch rác.
B3328: ( 011, 016 ) Thùng rác.
B3329: ( 012, 016 ) Bình thường giờ này là giờ ăn của gia đình mình.
B3330: Mà Popo với Momo đi du lịch rồi! Mau mau úp mì cho Oni Onii và mình ăn mới được!
B3331: TƯƠNG TÁC PHÒNG HẢI QUỲ Ở NHÀ
B3332: Tương tác hai lần ở ( 011, 004 )
B3333: Lần 1: “ Cô Gái Thi Ca “ – Câu chuyện kể về một nam sinh trung học từng là thần đồng sáng tác nhạc nhưng từ bỏ năng khiếu sau một biến cố. Cậu tham gia câu lạc bộ âm nhạc và gặp được một cô gái kỳ lạ có sở thích ăn các bảng nhạc. Cô nói rằng mỗi bản nhạc đều có hương vị riêng và yêu cầu nam sinh trung học phải viết những “ món ăn mới “ cho mình.
B3334: Lần 2: Có một tấm ảnh rơi ra từ tệp hồ sơ.
B3335: [ Ảnh chụp chung của Hoàng Hà, Ánh Lam và Omega D-13 ]
B3336: Tương tác hai lần ở ( 012, 004 )
B3337: Lần 1: “ Berry Pohta “ – Câu chuyện kể về một cô bé mồ côi sống cùng gia đình dì dượng. Vào sinh nhật lần thứ 11, cô bé phát hiện mình là một Rap Sư và được mời theo học tại hệ thống trường riêng biệt dành cho các Rap Sư tài năng.
B3338: Lần 2: Một tờ ghi chú rơi ra từ một cuốn sách.
B3339: “ Cách để hoán đổi thân phận:
B3340: Cách một: Dùng Brilliant Anchor để sao chép dữ liệu ADN.
B3341: Ưu điểm: Tái tạo ngoại hình nhanh.
B3342: Nhược điểm: Không có ký ức của chủ thể. Chỉ sử dụng ADN được sao chép tối đa ba lần.
B3343: Cách hai: Trực tiếp nhai xương. Nên dùng cách này đối với “ kẻ phản bội “.
B3344: Ưu điểm: Lưu giữ được ký ức của chủ thể. ADN tồn tại vĩnh viễn, có thể dùng bất kỳ lúc nào.
B3345: Nhược điểm: Mất một thời gian để hấp thụ. Phải uống thuốc ức chế để không bị chồng chéo ký ức. “
B3346: ( 013, 005 ) Máy tính bàn của mình. Nhắc mới nhớ, mình chưa chơi xong Dave The Diver thì phải?
B3347: Tương tác hai lần ở ( 014, 005 )
B3348: Lần 1: Đầu đĩa than được tặng bởi OniOnii.
B3349: Lần 2: Hai thanh kiếm được viết bùa chú diệt quái vật vực sâu được làm bởi Popo. Một quẹt là phát nổ.
B3350: ( 010, 004 ) Ảnh chụp gia đình mình.
B3351: Tương tác hai lần ở ( 008, 004 )
B3352: Lần 1: Tủ kê đầu giường. Trong hộc tủ nhét đầy đồ ăn vặt.
B3353: Lần 2: Ảnh chân dung của mình hồi còn bé.
B3354: OniOnii bảo màu tóc khi ấy của mình nhìn y đúc chị cả.
B3355: ( 008, 005 ) Giường ngủ vỏ sò.
B3356: ( 004, 005 ) Thùng đựng băng game mà mình đã chơi.
B3357: ( 013, 009 ) ( quay lên ) Máy chơi game đầu tiên của mình được tặng bởi Popo.
B3358: ( quay phải ) Máy chơi game Polystation này mình mượn từ OniOnii.
B3359: ( quay trái ) Laptop để mình ngồi viết tiểu thuyết.
B3360: ( 007, 011 ) Tủ quần áo.
B3361: ( 004, 011 ) Tủ lưu trữ các thiết bị “ biến hình “ của mình.
B3362: Trước khi có mỏ neo Brilliant Anchor mình toàn dùng mấy món này để hoán đổi thân phận.
B3363: Xem nào, có bút bi biến hình, hộp phấn biến hình, nước hoa biến hình, son môi biến hình.
B3364: Nước hoa biến hình là món xài vui nhất! Xịt xịt khắp người, múa may quay cuồng một xíu là hoán đổi cả cơ thể lẫn trang phục! Giống như ma pháp thiếu nữ biến hình vậy!
B3365: Ngầu đét!
B3366: ( 005, 011 ) Tủ lưu trữ mô hình gậy phép thuật của các series ma pháp thiếu nữ mà mình coi.
B3367: Bao nhiêu tiền lương đổ hết vào đây…Nó đáng! Nó đáng!!
B3368: ( 006, 011 ) Tủ trưng bày các mô hình người máy, robot.
B3369: Ôi, mình là khách hàng thân thiết của cửa hàng bán mô hình gần Wanderer Office!
B3370: Lần nào có sản phẩm mới họ cũng chào mời mình.
B3371: Leo cảnh cáo mình bao lần rồi nhưng mình vẫn lén lút mua, hehe.
B3372: ( 008, 011 ) Tủ quần áo mùa đông của mình.
B3373: ( 009, 011 ) Tủ lưu trữ “ chiến tích “ mà mình chưa kịp gửi cho Poseidon.
B3374: Bao gồm mắt, lưỡi, ngón tay, nội tạng của những “ kẻ phản bội “ mà mình đã thanh trừng đợt rồi.
B3375: Để sau kỳ nghỉ làm báo cáo đầy đủ chi tiết vậy.
B3376: Thanh trừng bọn này mệt khiếp.
B3377: Tương tác phòng Hakase
B3378: ( 009, 005 ) Tại sao trên kệ này lại để hai cuộn giấy vệ sinh vậy?
B3379: ( 008, 005 ) [ Quay trái ] Tablet và Swutch OLED nằm tứ tung trên giường.
B3380: ( 008, 005 ) [ Quay lên] Mấy cái hộc tủ khóa rồi. Mình nhớ Hakase hay nhét đĩa game Swutch vào mấy cái hộc này.
B3381: ( 004, 007 ) Trời má, tượng Lucario 1:1 luôn! Oách thế!!!
B3382: ( 003, 007 ) Hửm? Hakase đang tải Hogwarts Legacy về chơi à?
B3383: ( 002, 007 ) Tủ lạnh mini nhét đầy thức uống có cồn.
B3384: ( 002, 011 ) So với mấy hôm trước thì Hakase đã dọn dẹp gọn gàng phòng ngủ của mình…
B3385: Bằng cách nhét không biết bao nhiêu thứ vào mấy thùng cạc tông này.
B3386: Chà, muốn đem đống này bán đồng nát ghê.
B3387: ( 003, 010 ) Thỏ Bông. Hakase hay điều khiển con này đi xuống bếp lấy đồ ăn.
B3388: ( 004, 010 ) Có một chậu hoa hồng gai trên bàn. Chạm nó chứ?
B3389: [ Chạm ] Hải Quỳ lăn ra chết.
B3390: [ Không chạm ] Hải Quỳ: Urg, khùng hông mà chạm vô cái chậu đầy gai vậy.
B3391: ( 010, 007 ) Trên kệ trưng figure anime. Ngoài ra còn một tấm ảnh selfie của Hakase được đóng khung và gắn tùm lum charm nhỏ xinh.
B3392: ( 011, 007 ) Đầu đĩa than. Chà, nhạc có bản quyền. Bật không?
B3393: [ Bật ] https://www.youtube.com/watch?v=TLXdmt_k0ig
B3394: [ Đổi nhạc ] https://www.youtube.com/watch?v=kiQxfZg7Z68
B3395: [ Đổi nhạc ] https://www.youtube.com/watch?v=tJH-7u4kAyw
B3396: [ Không bật ]
B3397: ( 012, 007 ) [ Đây là chỗ có thể nhét thanh ram của Diana, anh tự biên nhe ]
B3398: ( 013, 007 ) Mèo chiêu tài. Hakase từng bảo mắt con mèo này có thể bắn laze vừa đủ để nướng kẹo dẻo.
B3399: ( 014, 007 ) Chậu Bonsai này cao hơn mình. Hakase nhìn vậy chứ chăm cây tốt phết.
B3400: ( 014, 011 ) Thùng đựng các hộp Gundam chưa lắp.
B3401: ( 009, 008 ) Thùng đựng các hộp mô hình chưa lắp.
B3402: Tương tác phòng kho ( ??? )
B3403: ( 008, 007 ) Tủ quần áo cũ. Bên trong có treo bộ đầm xòe nhiều lớp màu đỏ của trẻ em. Chiếc đầm không bị dính chút bụi nào.
B3404: ( 011, 007 ) Trong thùng này có rất nhiều băng cát-sét. Lấy băng nào?
B3405: [ Paulie biết đi ]
B3406: [ Bánh Mì Bơ Tỏi ]
B3407: [ Xích đu ]
B3408: [ Có thể cho player cất băng hoặc đổi băng ]
B3409: [ ( 007, 007 ) Một chiếc TV cũ cùng một đầu băng cát-sét vẫn còn dùng được.
B3410: - Nếu trong người có đoạn băng thì sẽ dùng được cát-sét và TV -
B3411: “ Anh trai anh trai! Nhìn nè, em trai biết đi rồi! “
B3412: “ Em trai giỏi quá! Thật may là anh ghi hình kịp lúc! “
B3413: “ Popo! Momo! Paulie biết đi rồi! “
B3414: “ Wow! Paulie giỏi quá!!! “
B3415: “ Aira! Em đang nấu gì đấy? “
B3416: “ Bánh mì bơ tỏi! Em muốn cho Paulie ăn món tủ của anh! “
B3417: “ Này, em biết là em bé không ăn được đồ cứng mà, đúng không? “
B3418: “ Hơn nữa là bánh khét rồi kìa “
B3419: “ ÚI!! “
B3420: “ Dahria Dahria!! Xem tớ nè!! “
B3421: “ Wow, ngầu quá đi! Cậu đu được một vòng luôn! “
B3422: “ Dahria! Aira! Hai đứa dừng lại ngay!! “
B3423: “ Awawawa, Popo, cứu con với, con không ngừng đu được!! “
B3424: ( 006, 006 ) Nhiều sách báo cũ được cất ở đây. Đa phần nội dung nói về camera và cách quay phim.
B3425: ( 005, 007 ) Bật đèn?
B3426: ( 011, 008 ) Bật đèn?
B3427: ( 005, 008 ) [ Nếu chưa bật đèn ở ( 005, 007 ): Tối quá, mình chẳng đọc được gì cả ]
B3428: Cuốn nhật ký được viết nguệch ngoạc.
B3429: “ Ôi nhật ký, đây là lần đầu tiên mình viết nhật ký. Không biết mình nên viết gì ta?
B3430: Hồi hộp quá! Mình chưa bao giờ viết nhật ký hết! Dahria bảo rằng mình viết cái chi cũng được.
B3431: Nhật ký, hôm nay Dahria đưa mình cho cậu, à đâu, phải là đưa cậu cho mình! Nhân dịp sinh nhật lần thứ tám! Mình hứa sẽ viết thật nhiều thật nhiều! “
B3432: “ Nay mình được anh trai dẫn đi chơi đu quay! Nó hơi chóng mặt nhưng rất vui! Rồi tụi mình còn đi ăn kem, đi bộ trên những bậc thang dài với ánh hoàng hồn trải xuống. Mình sẽ nhớ mãi ngày hôm nay! Vui lắm! “
B3433: “ Dahria rất thích làm ma pháp thiếu nữ trừ gian diệt bạo. Hôm nay mình với cô ấy hóa thân thành bộ đôi ma pháp thiếu nữ, đi loanh quanh khắp xóm để giúp đỡ mọi người. “
B3434: “ Popo hôm nay không đến đón mình nên anh trai đã đạp xe đến đón mình về. Anh bảo rằng tụi mình sắp có em trai. Nhật ký ơi, mình sắp làm chị rồi! Mình cũng tò mò nên hỏi anh trai rằng Popo và Momo kiếm đâu được em trai vậy, thế là anh trai bật cười. Anh bảo rằng em trai được Poseidon đưa đến.
B3435: Mình mong được gặp em trai quá. “
B3436: “ Hôm nọ khi mình được Momo dắt đi học, có đi ngang qua một cửa tiệm trưng bày bộ váy đỏ nhiều vải gực gỡ, nhìn đẹp lắm. Mình ước gì được mặc nó trong dịp năm mới. “
B3437: “ Ôi nhật ký ơi! Momo đã mua bộ váy đỏ đó cho mình! Đẹp quá trời là đẹp!
B3438: Cả nhà hôm nay đi xem pháo hoa nữa. Nhưng lúc mình đi thì giày bị hỏng nên anh trai đã cõng mình, cũng vì thế mà mình mới nhìn rõ được pháo hoa. Đẹp quá. Mình ước gì năm mới kéo dài mãi, để ngày nào mình cũng được xem pháo hoa, được ăn bánh, cả nhà quay quần bên nhau! “
B3439: “ Popo bảo với mình rằng anh trai đã đi đến một nơi xa ơi là xa để làm nhiệm vụ cho Poseidon.
B3440: Mình không chịu đâu. Anh trai đã hứa sẽ luôn ở bên mình, chăm sóc mình mà…Sao lại bỏ đi? “
B3441: “ Nhật ký ơi, hình như mình bị các giáo viên trong trường ghét rồi. Nhưng mình hứa là mình đã không làm gì cả. Hôm nay mình đến trường, các giáo viên nhìn mình với ánh mắt kỳ lạ lắm. “
B3442: “ Bạn bè trong lớp mình bảo anh trai mình chết rồi, sẽ không quay về nữa đâu.
B3443: Chết là gì? Họ chẳng biết gì cả, anh trai mình đang làm việc cho Poseidon mà! “
B3444: ( 004, 006 ) Một tủ sách toàn truyện cổ tích bị vẽ bút màu tèm lem lên.
B3445: Tự dưng mình lại nhớ câu chuyện “ kinh dị “ mà hồi bé Momo kể cho mình nghe trước khi mình đi ngủ…
B3446: ( 009, 007 ) Trong tủ sách có một cuốn album tranh vẽ bị phủ đầy bụi và mạng nhện. Mở ra xem?
B3447: [ Cho player mở ra xem tranh ]
B3448: ( 010, 007 ) Có một cuốn nhật ký bị mã hóa bằng phép thuật. Mở ra xem?
B3449: “ Nhật ký, xin lỗi vì bỏ bê cậu trong kho một thời gian qua.
B3450: Mình đã trưởng thành hơn, cuộc sống bộn bề thay đổi chóng mặt, nhất là trong tim mình.
B3451: Khi xưa, tim mình nặng trĩu mỗi lần bước vào đây. Nhưng bây giờ thì khác, mình cảm thấy tim mình được an ủi, hơi thở của mình nhẹ nhàng hơn khi nhốt mình trong này với cậu.
B3452: Chà, mình không biết mình đang viết gì nữa, nhưng mỗi khi đặt bút viết gì đấy, đầu óc mình thoải mái hơn. “
B3453: “ Mình không phải một đứa vô dụng.
B3454: Mình không biết giấc mơ của mình là gì.
B3455: Mình cảm thấy xấu hổ, đau đớn, buồn bã, ăn năn.
B3456: Mình thực sự cảm thấy lạc lõng…
B3457: Mình chỉ biết cố gắng để vượt qua. “
B3458: Trang nhật ký này có vài vết hoen ố.
B3459: “ Mình nhớ anh trai mình. Giá như anh còn ở đây, mình sẽ biết mình phải làm gì. Mình quen với việc dựa dẫm vào anh trai…thật thảm hại. Mình chẳng làm được trò trống gì cả. Trong mắt mọi người, mình chỉ là một đứa vô năng, vô tích sự. Mặc dù Popo, Momo và em trai mình luôn thương yêu mình, mình cảm thấy mình không xứng đáng có được tình yêu thương ấy. Họ luôn bảo rằng mình cứ là chính mình đi, đừng phải e sợ trước ánh nhìn hay lời nói của người khác, nhưng…chính mình là như thế nào? Mình không biết mình là ai…Mình…thực sự cảm thấy khó thở.
B3460: Nhưng mình không thể để họ lo lắng được. Mình đã thành chị cả rồi mà…Mình phải trưởng thành…”
B3461: “ Trưởng thành là khi giấu nỗi đau vào trong tâm thức. Thật cay đắng…Mình chắc chắn là Popo và Momo cũng vậy…Đôi mắt họ trĩu buồn mỗi khi nhìn thấy tấm ảnh của anh trai.
B3462: Giá như mình tốt đẹp hơn thì hay biết mấy…”
B3463: “ Mình không là gì cả. Mình không là gì cả. Mình không là gì cả. Mình không là gì cả.
B3464: Mình nên biến mất. Mình nên biến mất. Mình nên biến mất. Mình nên biến mất. Mình nên biến mất. “
B3465: “ Mình cảm thấy có lỗi. Popo và Momo ắt hẳn phải buồn lắm khi phải nuôi nấng mình. “
B3466: “ Mệt mỏi quá. Cảm giác như trong tim có hàng ngàn cây kim đâm xuyên vậy. Mặc cảm, tội lỗi, sầu uất, tất cả những cảm xúc tiêu cực đang chiếm lấy mình. Dahria bảo rằng mình nên vẽ tranh để trút bỏ cảm xúc ấy đi, mình đã vẽ, nhưng chúng vẫn ở đây. “
B3467: “ Mình suýt nữa ngả ngửa khi Dahria bảo với mình rằng cô ấy có con. Nhưng hóa ra “ con “ mà cô ấy bảo lại là đứa trẻ mồ côi mà cô ấy chăm sóc. Cô ấy quý con bé lắm. Dù con bé có đầy khiếm khuyết so với bạn bè cùng trang lứa nhưng ít ra con bé là người tốt, Dahria bảo vậy. Mình muốn biết mặt mũi con bé ra sao nhưng Dahria nhất quyết không cho mình xem. “
B3468: “ Dahria bảo với mình rằng trước mặt cô ấy thì mình phải buông bỏ, đừng cố gồng nữa.
B3469: Mình đã khóc rất nhiều, bao nhiêu nỗi đau trong mình cứ thế tuôn trào, không kìm lại được.
B3470: Dahria là một người bạn tốt hiếm hoi và duy nhất mà mình có.
B3471: Ánh trăng hôm nay thật đẹp. Cả hai đứa bọn mình dựa lưng vào nhau và giải bày hết tâm sự trong lòng. “
B3472: “ Hôm nay Dahria lạ lắm. Cô ấy đột ngột mua nhiều quà cho mình. Mình gặng hỏi lý do nhưng cô ấy chỉ bảo rằng cô ấy thích thế. Đến tối, bọn mình đi chơi đu quay, cùng nhau ăn kem, cùng nhau tản bộ trên những bậc thang dài dằng dặc. Cảm xúc khó tả này là gì…? “
B3473: “ Trong lòng mình dâng trào nỗi bất an. Mình cố gọi cho Dahria nhưng cô ấy không bắt máy. Mình chạy đến nhà cô ấy mới biết tin cô ấy đã chuyển nhà ngay trong đêm “
B3474: “ Hôm nay mình gọi cho Dahria hàng trăm cuộc. Cô ấy vẫn không bắt máy.
B3475: Thôi mà, không phải cả Dahria nữa chứ…Làm ơn, Poseidon ơi, đừng…”
B3476: “ Đã hơn hai tháng trôi qua. Cuộc sống của mình vẫn cứ tiếp diễn. Nỗi đau đáu và bất an ngày một dâng cao thành núi. Mình vẽ, mình viết, mình hát nhưng chẳng thấy cảm xúc nặng nề này vơi đi tí nào cả. “
B3477: ( 011, 007 ) Tương tác ba lần.
B3478: Lần 1: Thùng đầu tiên toàn là bài tập về nhà của OniOnii. Có cả “ phao “ nữa này!!
B3479: Lần 2: Thùng thứ hai lại toàn là bài tập điểm kém của mình. Hóa ra OniOnii giấu chúng ở đây!!
B3480: [ NẾU NGƯỜI CHƠI CHỈ TƯƠNG TÁC ĐẾN LẦN 2]
B3481: ( Ngay khi vừa bước ra cửa, cho màn hình có hiệu ứng tua ngược, cho Sprite Hải Quỳ đi ngược )
B3482: [ NẾU NGƯỜI CHƠI CHỈ TƯƠNG TÁC ĐẾN LẦN 3]
B3483: Lần 3: Dưới đáy thùng thứ ba có một lá thư bị vò nhăn nhúm. Chữ viết nhìn có vẻ vội vã. Đọc lá thư?
B3484: “ Aira, mình xin lỗi vì đã giấu cậu.
B3485: Mình xin lỗi vì là người đã bảo cậu buông bỏ tất cả để mở lòng trong khi bản thân mình lại không làm được. Mình xin lỗi vì không nghe điện thoại của cậu.
B3486: Mình xin lỗi vì đã viết lá thư này cho cậu.
B3487: Mình không phải là bảo mẫu chăm trẻ mồ côi. “ Đứa con yêu “ mà mình kể cho cậu nghe, thực chất là bản sao lai tạo giữa gen di truyền của Poseidon và quái vật vực sâu, là bản sao không hoàn hảo trong hàng ngàn bản sao được sinh ra để làm vũ khí chiến tranh. Sự thương yêu mình dành cho nó là giả tạo, mình đã không ngần ngại vứt bỏ nó ra bãi rác, mặc cho nó tự sinh tự diệt.
B3488: Aira à, mình thật sự dại dột. Mình ngỡ rằng mình đang cống hiến cho một dự án tốt đẹp, đào tạo ra những siêu chiến binh bảo vệ Atlantis. Nhưng hóa ra, mình đang cống hiến cho một dự án vô nhân đạo, chế tạo ra những cỗ máy giết chóc vô nhân tính.
B3489: Vì sự dại dột ấy mà giờ đây mình phải trả giá. “ Kẻ trừng phạt “ sắp tìm được phòng nghiên cứu của dự án rồi. Tất cả những ai liên quan đến dự án đều phải biến mất không dấu vết.
B3490: Mình không muốn biến mất hoàn toàn khỏi thế gian này.
B3491: Mình sợ lắm, Aira. Mình sợ ngày mai không nhìn thấy cậu. Mình sợ cậu sẽ phát điên và tìm kiếm mình, một người bạn không tồn tại. Mình không muốn liên lụy đến cậu, nên sau khi đọc xong lá thư này, kích hoạt vòng tròn phép thuật ở mặt sau để xóa đi toàn bộ ký ức liên quan về mình cũng như lá thư.
B3492: Hẹn gặp cậu vào một ngày nắng vàng.
B3493: Tạm biệt. “
B3494: [ ĐỌC XONG LÁ THƯ LÀ NGAY LẬP TỨC CHUYỂN SANG CẢNH DÍ ]
B3495: TƯƠNG TÁC PHÒNG LEO
B3496: ( 006, 004 ) Giá đỡ thanh Muramasa của Leo.
B3497: ( 006, 004 ) Trên kệ là ảnh chụp của Leo và Sakura Usagi.
B3498: Tương tác hai lần tại ( 002, 004 ) - ( 003, 004 )
B3499: Lần 1: Sách điềm báo. Cuốn sách này giúp Leo biết trước các thảm họa tồi tệ ở đa chiều không gian để kịp thời xử lý.
B3500: Lần 2: EPSILON-017 – HÀNH TINH BELLAMONT. NGỦ YÊN. NGÀN THU. KHÔNG LỐI THOÁT.
B3501: ( 004, 004 ) Lò sưởi.
B3502: ( 002, 008 ), ( 003, 008 ) Đây là hai cái đèn ngủ mà Shylvie tặng Leo mà nhỉ.
B3503: ( 008, 005 ), ( 009, 005 ) Quan tài, à nhầm, giường ngủ đứng của Leo. Vì Leo đang ở ngoài nên viên ngọc trên quan tài mới sáng đèn.
B3504: ( 013, 004 ) Chà, trăng hôm nay sáng ghê! Cửa sổ mô phỏng môi trường này hay thật đó.
B3505: ( 011, 005 ), ( 012, 005 ) Bàn làm việc của Leo. Ồng đang nghiên cứu gì vậy nè?
B3506: Hừm…Ku-ro-ya-mi? Sừng rồng có thế chế biến thành thuốc súng siêu cấp?
B3507: ( 013, 006 ) Mình không biết tên của cây này là gì. Chỉ biết mỗi lần Leo bị thương nặng đều sẽ cắn rất nhiều lá từ cây này để ngủ. Mình cắn không xi nhê gì.
B3508: ( 010, 010 ) Trời đất ơi, ổng đang chơi dở God of War Fimbulwinter nè!
B3509: Tương tác 3 lần ở ( 009, 010 )
B3510: Lần 1: Rất nhiều đĩa game đến từ dòng thời gian khác. Pragmator 2? Pragmator 1 đâu?!
B3511: Lần 2: Bún Bò Phố Cổ? Phần tiếp theo của Phở Anh Ba à?
B3512: Lần 3: Falling Out Lastest Last Vegan? Huh?
B3513: ( 011, 010 ) Quá trời tay cầm YCARTON luôn.
B3514: ( 007, 011 ) Ồ, kính lão này! Hình như Leo đang đọc Độc Đắc Cõi Ma Cà Rồng hả?
B3515: ( 013, 011 ) Tủ quần áo của Leo. Có một hộc toàn là quần xì ma thuật màu hồng chấm bi.
B3516: ( 015, 011 ) Tủ trưng bày các loại Sting. Sting vàng, Sting xanh, Sting Wasabi, Sting Tỏi…v..v
B3517: Tương tác phòng ngủ Kohi
B3518: Tương tác 3 lần tại ( 014, 011 )
B3519: Đây đúng là một tuyệt tác nghệ thuật. Một bức tranh về nụ cười khả ố của Kohi.
B3520: Hình như đây là cái meme mà bả dùng trong sever discord của mình mà đúng không?
B3521: Mình có thể nghe thấy tiếng cười của bả ở trong đầu.
B3522: ( 006, 007 ) Tủ quần áo của Kohi.
B3523: ( 008, 007 ) Tranh chân dung của Kohi.
B3524: ( 013, 007 ) Hửm? Có gì dưới gầm giường vậy? Ồ, là một thanh ram! [ Nhét thanh ram vào đây ]
B3525: ( 010, 005 ) Chà, ngoài trời ánh nắng dịu dàng ghê.
B3526: Làm mình nhớ tới hồi còn bé mình nhìn thẳng vào mặt trời. Nhớ lại mà mắt trái dựt dựt rồi đó.
B3527: ( 014, 012 ) Ồ, bông này là bông gì nhỉ? Nhìn tươi tốt phết.
B3528: Tương tác 3 lần tại ( 003, 008 )
B3529: Bộ ấm chén đặc biệt mà Kohi đã mua ở hành tinh Luminous. Chất lượng tốt khỏi phải bàn. Đặc biệt là chiếc ấm có thể dùng để nấu mì ăn liền.
B3530: Sao mắt con mèo chiêu tài này nhìn lạ thế? Ồ, là camera ẩn! Hello Kohi!
B3531: Kohi cũng thích đọc sách. Trên kệ này có vài cuốn nhìn hay ho quá chừng.
B3532: ( 009, 005 ) Tủ đồ cá nhân của Kohi.
B3533: ( 011, 005 ) Sao cái tủ này có mùi cà phê nhỉ?
B3534: ( 007, 011 ) Kohi có sở thích mới sao? Vậy là gần đủ cầm kỳ thi họa rồi.
B3535: ( 008, 011 ) Rất là Bocchi The Đá.
B3536: Tương tác phòng ngủ Shylvie
B3537: ( 011, 007 ) Máy Swutch 3 mà Shylvie tậu được ở chiều không gian khác.
B3538: ( 012, 007 ) Tranh chân dung Shylvie được vẽ bởi Kohi.
B3539: ( 008, 007 ) Tủ quần áo của Shylvie.
B3540: ( 008, 008 ) Tủ trưng bày khiên steampunk.
B3541: ( 008, 009 ) Tủ trưng bày khiên cổ xưa. Chiếc khiên này được đính rất nhiều ngọc ma thuật.
B3542: ( 008, 010 ) Tủ trưng bày Reverse Bunny mà mình tặng Shylvie này! WOW!
B3543: ( 008, 011 ) Tủ đựng đĩa chơi game Swutch 3 và các loại tay cầm chơi game khác.
B3544: ( 002, 007 ) Tủ đựng đồ dùng cá nhân của Shylvie.
B3545: ( 003, 007 ) Tủ đựng đồ chăm sóc thú cưng.
B3546: ( 004, 007 ) Đồng hồ kiêm quả bom mà mình tặng cho Shylvie. Hình như Shylvie tháo mất bộ phận gây nổ của nó rồi.
B3547: ( 006, 008 ) Hình như Shylvie đang tải game gì đó. Rhythm Hellaly Megamix Groove à?
B3548: ( 002, 008 ) Công tắc đèn. Bật đèn chứ? [ Bật đèn thì đổi sang Map LightOn ]
B3549: ( 013, 015 ) WanderSister hay ngồi đây mỗi lần chơi Katrio Slicing.
B3550: ( 014, 015 ) Mình sẽ nằm dài ở đây khi chơi Katrio Slicing cùng WanderSister. Cái ghế này siêu êm.
B3551: ( 015, 008 ) Một cái chiêng thần thoại có khả năng dịch chuyển người được đọc tên. Eden thường xuyên bị Shylvie “ triệu hồi “ bằng chiếc chiêng này.
B3552: ( 014, 007 ) Bản sao của chiếc khiên biểu tượng cho Shylvie.
B3553: ( 011, 003 ) Chiếc gương này từng là gương dịch chuyển nhưng đã bị vỡ sau một trận chiến.
B3554: Leo đã phải phong ấn chiếc gương này lại, phòng cho kẻ địch lợi dụng nó để úp sọt Shylvie.
B3555: ( 013, 002 ) Tấm tranh ma thuật vẽ hình cửa sổ. Chức năng y chang cửa sổ mô phỏng ở phòng của Kohi và Leo.
B3556: ( 015, 002 ) Tủ chứa đồ vô hạn. Shylvie lúc nào cũng bảo:” Sẽ sửa sau “ xong rồi vứt mấy đồ hỏng hóc vào đây, chả bao giờ sửa.
B3557: ( 002, 014 ), ( 003, 015 ) S T E V E.
B3558: Tương tác quán cà phê
B3559: ( 014, 005 ) Hmm, chữ này có nghĩa là…linh hồn?
B3560: ( 015, 005 ) Chữ này…chữ này…tình thương yêu?
B3561: ( 016, 005 ) Trời, quá trời truyện tranh luôn nè!
B3562: ( 016, 007 ), ( 017, 007 ) Úi chà, pancake to dữ!
B3563: ( 018, 007 ) Ủa, chị gái này nhìn quen thế nhỉ? Nhìn giống cháu gái của bà lão chủ cửa tiệm sách cũ mà mình hay ghé hồi bé.
B3564: Chắc người giống người thôi.
B3565: ( 007, 012 ), ( 006, 013 )
B3566: Hải Quỳ: Hawo Mèo!!
B3567: Mèo Trắng: Ồ, hello Hải Quỳ! Chà, nhìn phong cách quá ta! Nhuộm tóc vàng luôn!
B3568: Hải Quỳ: Hehe, cảm ơn!
B3569: Mèo Trắng: Bà uống gì hông? Cứ gọi đi, tui mời!! Hiếm lắm mới gặp nhau bất ngờ thế này mà!
B3570: Hải Quỳ: Oke luôn!!
B3571: [ Đổi scene Café_MeoTrang, Hải Quỳ ngồi kế bên Mều Trắng. Nếu player đã tương tác ở ( 016, 007 ) hoặc ( 017, 007 ) thì đổi scene Pancake_Coffee. ]
B3572: Mều Trắng và mình ngồi trò chuyện một hồi lâu.
B3573: Mèo Trắng: Ồ, hóa ra là vậy! Bảo sao khó liên lạc với bà.
B3574: Hải Quỳ: Haizz, nhắc tới là lại rầu à!
B3575: Mèo Trắng: À Quỳ ơi, cậu có muốn nghe chuyện cười không
B3576: Hải Quỳ: Nó phải thực sự buồn cười đó Mèo…!!
B3577: Mèo Trắng: Yên tâm, cái này có hài mà!
B3578: Mèo Trắng: Đố Quỳ một quán bar nhưng chỉ bán chuối được gọi là gì
B3579: Hải Quỳ: ...Hả?
B3580: Mèo Trắng: Barnana
B3581: Hải Quỳ: Hahaha…HAHAHAHAHA!! BAR-NANA!
B3582: [ Đổi lại scene cũ ]
B3583: Hải Quỳ: Tui xin phép đi trước do có việc. Bye bye Mèo nha!
B3584: Mèo Trắng: Hehe, bye bye bà nha!
B3585: ( 013, 009 ) [ Đây là chỗ cho event mua cà phê cho Kohi ]
B3586: ( 004, 007 ) Không thể ngờ là ở quán cà phê này lại có những cuốn truyện đã ngưng xuất bản của Samurai Cầu Vồng! Con bé Mây hay thật, thế mà lại tìm ra quán cà phê này!
B3587: ( 008, 011 )
B3588: Vân Phượng: Mây à, đây là cái bánh kếp cuốn kem trái cây thứ ba em ăn rồi đấy.
B3589: Không để bụng ăn phở bò vò viên sao?
B3590: Huyền Mây: Bụng em còn chỗ cho phở mà anh, đừng có lo!
B3591: Nomnom, kem trái cây tươi mát, ngọt ngào quá đi mất!
B3592: ( 009, 012 )
B3593: Huyền Mây: Giá như mà tụi mình rủ được bà Hoàn Mỹ đi chung ha!
B3594: Em nghĩ là bả cũng sẽ thích món bánh kếp cuốn kem trái cây này thôi!
B3595: Vân Phượng: Urg…Nhắc tới cái tên đó anh lại sởn gai ốc, tay với chân cứ run lên, mặt với mũi cảm giác nóng ran!
B3596: Huyền Mây: Haha, anh ám ảnh đòn roi của Hoàn Mỹ tới vậy luôn á hả?
B3597: Vân Phượng: Em cười cái gì! Em may mắn lắm đó, biết không!
B3598: Anh không dám tưởng tượng đến cảnh ba đứa mình ngồi chung đâu!
B3599: Cơ mà, không biết cuộc sống bây giờ của Hoàn Mỹ ra sao rồi.
B3600: Huyền Mây: Chắc là đang làm mưa làm gió bên bển rồi. Dù sao bả là “ hoàn mỹ “ mà.
B3601: ( 010, 012 )
B3602: Vân Phượng: Rốt cuộc em rủ Văn Sắc kiểu gì mà cậu ta ngay lập tức chạy xe đến đón anh vậy?
B3603: Đã thế em lại còn ngồi sẵn trong xe cậu ta nữa chứ!
B3604: Huyền Mây: Em nói là:” Anh Sắc, chúng ta cần giải cứu thế giới! “ thế là nhoằng một cái ảnh gọi cho anh Sam bàn giao công việc luôn. Anh Sam hét quá trời quá đất.
B3605: Vân Phượng: Tội ông Sam ghê…Thế hóa ra “ giải cứu thế giới “ mà em nói là đọc mấy cuốn truyện tranh Samurai Cầu Vồng đã ngưng xuất bản kia ấy hả?
B3606: Huyền Mây: Ừm ừm, đúng rồi!
B3607: Vân Phượng: Thiệt tình…!
B3608: Huyền Mây: Sao vậy anh?
B3609: Vân Phượng: À không có gì, anh nhớ lại chuyện cũ thôi ấy mà…!
B3610: Huyền Mây: Anh giấu cái gì đó! Em thấy hết rồi nha! Quá trời khóa tâm thức luôn!!
B3611: Vân Phượng: Ê nha, ai cho dùng magatama!
B3612: ( 009, 010 )
B3613: Huyền Mây: Quán cà phê này không gian thoải mái ghê! Em ước gì văn phòng mình cũng thư thái như thế này!
B3614: Hay là mình cải tạo lại văn phòng đi anh!
B3615: Vân Phượng: Thôi cô nương, tiền đâu mà cải tạo!
B3616: Huyền Mây: Hmm, hay là tụi mình quay quảng cáo đi! Em có ý tưởng này hay lắm!
B3617: Tụi mình sẽ thay đổi mô típ văn phòng, anh sẽ là Samurai Thép, còn em là Hường Công Chúa!
B3618: Kết hợp lại, ta có Samurai Thép đi phá án! Sao nào, thấy em tài tình chưa!
B3619: Vân Phượng: Em tày đình thì có!
B3620: Giờ chỉ có nước em nhịn ăn mới đủ tiền cải tạo văn phòng.
B3621: Huyền Mây: Thôi mà anhhhhhhhhh
B3622: ( 010, 010 )
B3623: Vân Phượng: Lâu rồi không thấy bé Ngọc ghé văn phòng.
B3624: Huyền Mây: Òm..nòm..Bé Bơ đang tham gia khóa tu á anh. Con bé chăm chỉ luyện tập, không nghỉ một ngày nào hết.
B3625: Vân Phượng: Anh tưởng chăm chỉ như thế là tốt mà, sao giọng em nghe buồn vậy?
B3626: Huyền Mây: Ừm, nói sao ta…? Cách bé Bơ luyện tập có phần khắc khổ so với tuổi của bé.
B3627: Em muốn bé Bơ được tự do vui chơi, nghịch ngợm hơn.
B3628: Mấy lần em cố dụ ngọt mà Bơ nhất quyết cự tuyệt em, buồn chết đi được!
B3629: Vân Phượng: Hay là xíu về tụi mình mua bánh ngọt cho con bé?
B3630: Có thực mới vực được đạo chứ.
B3631: Huyền Mây: Ồ được đó anh!! Chúng ta sẽ càn quét hết menu của quán luôn!
B3632: Vân Phượng: VÌ BÉ BƠ!
B3633: Huyền Mây: VÌ BÉ BƠ!
B3634: Văn Sắc: Vì bé Bơ!
B3635: Huyền Mây + Vân Phượng: HUH?!
B3636: ( 004, 005 ) [ quay xuống ] Anh Sắc thực sự đọc Siêu Nhân Dũng Mãnh: Samurai Cầu Vồng!
B3637: [ quay lên ] < Gloaming > Câu chuyện về một chàng trai đã phải lòng với một cương thi, kẻ tỏa ra mùi hương gỗ sồi khi phơi mình dưới ánh mặt trời.
B3638: ( 002, 005 ) [ quay lên ] < Animorphs > Câu chuyện về nhóm thiếu niên có khả năng biến hình thành bất kỳ loài động vật nào họ chạm vào và sử dụng khả năng ấy để chống lại cuộc xâm lược của người ngoài hành tinh.
B3639: ( 007, 007 ) Ồ, Karin nè! Không ngờ gặp Karin ở đây.
B3640: Không biết dạo này cuộc sống của Karin sao rồi nhỉ?
B3641: Karin: Hi! Đằng ấy có chuyện gì muốn nói với tui hả?
B3642: Hải Quỳ: Không!! Xin lỗi vì đã nhận nhầm người!
B3643: Karin: Haha, không sao không sao!
B3644: Cơ mà, nhìn đằng ấy quen lắm. Nhất là cái vòng tay la bàn này…
B3645: Đằng ấy là thành viên của Wanderer hả?
B3646: Hải Quỳ: À…Ừm ừm! Đúng rồi…!
B3647: Sao cậu biết…!
B3648: Karin: Chà, xem ra nhóm vẫn hoạt động tốt.
B3649: Mình từng là thành viên của Wanderer mà.
B3650: Xin lỗi vì làm phiền! Đằng ấy cứ tiếp tục việc của mình đi!
B3651: Hải Quỳ: V-Vậy mình đi đây…!
B3652: Karin: Bye bye!
B3653: ( 007, 009 ) [ Nếu chưa tương tác với ( 007, 007 ) ] Chà, vẫn hương vị xưa cũ.
B3654: [ Nếu đã tương tác ] Tương tác ba lần:
B3655: Lần 1: Thành viên mới của Wanderer nhìn rụt rè ghê.
B3656: Nhưng mà cô ấy buộc tóc hai bím. Chắc chắn sẽ được Hải Quỳ ưu ái lắm đây.
B3657: Lần 2: Chà, mình nhớ những chuyến “ phiêu lưu “ hồi ấy.
B3658: Lần 3: Không biết Kohi và Hakase bây giờ ra sao rồi?
B3659: ( 008, 007 ), ( 009, 007 ), ( 008, 009 ) Bé lại đây, chị cho nghe mẹo này hay lắm.
B3660: Hải Quỳ: Dạ thôi ạ.
B3661: ( 003, 012 )
B3662: ???: Umm! Cái bánh Tiramesshua này ngon thiệt đó! Đáng lẽ Traveller nên gọi món này.
B3663: ???: Thôi, tôi không hảo ngọt. Tôi vẫn thích uống cà phê hơn.
B3664: ( 004, 015 )
B3665: ???: Cốc Cappucianalatta này uống ngon ghê. Đáng lẽ Erufu nên gọi cốc này.
B3666: ???: Thôi, tôi thích nước ép trái cây hơn. Cà phê uống ghê bỏ xừ.
B3667: ( 014, 013 ), ( 014, 014 ), ( 014, 015 ) Không phải nhân viên, xin đừng vào!
B3668: TƯƠNG TÁC TIỆM SÁCH CŨ
B3669: Tương tác ba lần tại ( 011, 029 ) – ( 012, 029 )
B3670: Hải Quỳ: Chị ơi, cho em hỏi chút!
B3671: Chủ tiệm: zz…z…z…zzz
B3672: Hải Quỳ: Bả ngủ luôn rồi?!
B3673: Hải Quỳ: Chị ơi, dậy chị ơi!!
B3674: Chủ tiệm:….
B3675: Chủ tiệm: Chào mừng….
B3676: Chủ tiện: zz…z…zzzzz
B3677: Hải Quỳ: Ngủ gì say dữ vậy!!!
B3678: Lần 3: ( theo script xuống Atlantis mua sách đoạn “ Tương tác với chủ tiệm trước khi tìm sách “ )
B3679: Tương tác hai lần tại ( 013, 029 )
B3680: Lần 1: Nhìn bìa cuốn sách này hơi mờ ám một chút nhưng thực chất nó là cuốn sách ma thuật giới thiệu chi tiết danh sách ấn phẩm xuất hiện trong cửa tiệm này.
B3681: Tóm tắt lại…
B3682: Tầng 1 là tầng sách phép thuật và truyện tranh thiếu nhi.
B3683: Tầng 2 là sách lịch sử, văn hóa và tiểu thuyết tuổi vị thành niên.
B3684: Tầng 3 và 4 là khu vực bàn ghế đọc sách.
B3685: ( 018, 029 ) Tuyển tập sách hướng dẫn sử dụng ma thuật đất, dung nham và kim loại.
B3686: Ồ nhớ rồi, hồi bé sau khi đọc xong tuyển tập này, mình đã tạo ra một con búp bê đất khóc ra dung nham!
B3687: ( 019, 029 ) Ở trên kệ có cuộn giấy ố vàng bị xé mất niêm phong.
B3688: Tới giờ vẫn không hiểu ai lại để cuộn giấy hướng dẫn sử dụng búp bê nguyền rủa ở đây nữa?
B3689: ( 020, 029 ) Tuyển tập sách hướng dẫn sử dụng phép thuật điều trị.
B3690: Ai mà được Hestia phù hộ mới học được phép thuật điều trị.
B3691: Beta M-34 có diễm phúc đó. Cơ mà bả lại cóc thèm học.
B3692: ( 021, 029 ) Tuyển tập truyện cổ tích thiếu nhi của Nardesen.
B3693: Nhớ nhất là câu chuyện về nàng Bồ Hóng.
B3694: Mẹ kế và chị kế trong câu chuyện không hề hà khắc.
B3695: Ngược lại còn giúp và bảo vệ Bồ Hóng khỏi Hoàng Tử xấu xa.
B3696: Đoạn kết, Bồ Hóng đập nguyên cái giày pha lê vào đầu Hoàng Tử.
B3697: Oách xà lách.
B3698: ( 022, 029 ) Có tờ ghi chú được dính lên kệ tủ.
B3699: “ Xin chào, tớ là Flowey. “
B3700: ( 022, 030 ) Ô, cuốn “ Dahlia Witchianna, cô phù thủy nhỏ tài năng “ này!
B3701: Hai người dì của Dahlia đẹp điên đảo!
B3702: Còn nội dung thì mình quên béng mất rồi.
B3703: ( 022, 031 ) Ê, ai để cuốn “ Bí Mật – Giao ước bóng tối “ ở đây vậy?
B3704: Đáng lẽ nó nên ở tầng trên chứ!
B3705: ( Có thể làm quest cất lại cuốn sách này nếu muốn )
B3706: ( 022, 032 ) Đây rồi! Cuốn phép thuật dịch chuyển này!
B3707: Nhớ có lần Shylvie từng hỏi tôi rằng phép thuật dịch chuyển ở Atlantis
B3708: có gì khác với phép thuật dịch chuyển mà bà ấy từng học không.
B3709: Đương nhiên là…Ờm…Tôi không biết?
B3710: Thú thực là tôi không rành về các phép thuật hỗ trợ lắm, nói trắng ra là mù tịt.
B3711: Nên là mua cuốn này cho Shylvie là chuẩn bài rồi!
B3712: Tôi cũng tò mò xem liệu có sự khác biệt giữa các phép thuật dịch chuyển không.
B3713: [ Hiện lựa chọn có mua hay không ]
B3714: [ Có ] Ok, mua luôn!
B3715: [ Không ] Từ từ, để xem còn cuốn nào hay không?
B3716: ( 017, 028 ) Nhìn đồng hồ này chả hiểu sao mình lại nhớ đến series Luật Sư Đại Tài.
B3717: ( 008, 029 ) Sách hướng dẫn sử dụng phép thuật Aero Blast đã sờn màu.
B3718: Mình học Aero Blast từ cuốn này.
B3719: Hm? Sao lại có tờ giấy ghi chú ố vàng bị dính chặt vào bìa chính thế này?
B3720: “ Gửi Dahria, tớ đã học được Aero Blast trước cậu rồi nhé, lêu lêu “
B3721: ( 009, 029 ) Tuyển tập sách hướng dẫn sử dụng phép thuật căn bản dành cho nhi đồng.
B3722: Oni Onii từng mượn cuốn này về nhà cho mình đọc để đọc.
B3723: Và…Mình chả học được cái gì cả.
B3724: ( 007, 033 ) Tủ đựng các cuốn sách hướng dẫn chiêm tinh dành cho nhi đồng.
B3725: ( 007, 034 ) Tủ đựng các cuốn sách hướng dẫn làm bạn dành cho nhi đồng.
B3726: ( 007, 035 ) Tủ đựng các cuốn truyện đạo đức dành cho nhi đồng.
B3727: ( 013, 031 ) Quả địa cầu này có bảy đại dương.
B3728: ( 014, 031 ) Dương dương dương là cái giường để ngủ.
B3729: ( 015, 031 ) Chỗ này là vị trí của văn phòng Silverwing nè.
B3730: ( 013, 034 ) Ngủ ngủ ngủ là cái tủ đựng tiền.
B3731: ( 014, 034 ) Chỗ này là vị trí của Đội phòng chống thảm họa Nguyệt Thực 6 nè.
B3732: ( 015, 034 ) Tiền tiền tiền là cô tiên biết múa.
B3733: ( 012, 032 ) À, trạm xe xuống Atlantis đây rồi.
B3734: ( 016, 032 ) Chỗ này là vị trí văn phòng Wanderer nè.
B3735: ( Thực ra nếu được thì ( 013, 031 ), ( 014, 031 ), ( 013, 034 ), ( 015, 034 ) làm thành tương tác chuỗi. Tưởng tượng của em là player bắt đầu nhấn ô nào đầu tiên thì sẽ là “ Quả địa cầu này có bảy đại dương “, xong ô tiếp theo họ nhấn sẽ là “ Dương dương dương là cái giường để ngủ “ ).
B3736: ( 009, 021 ), ( 010, 021 ) Chân dung về người phụ nữ quyền quý.
B3737: Bà lão từng bảo mình đây là tranh về cụ cố của bà ấy.
B3738: Cụ cố của bà ấy là một người thích đọc và sưu tầm sách.
B3739: Xưa kia, dòng họ bà lão là một trong những dòng họ quyền quý bậc nhất Atlantis.
B3740: Nhưng vì sa cơ lỡ vận nên bao nhiêu tài sản bay biến hết.
B3741: Poseidon thương tình nên đã giữ lại tòa lâu đài…
B3742: Cùng thư viện phép thuật với biết bao nhiêu cuốn sách cổ của dòng họ bà.
B3743: Cái tên “ Tiệm Sách Thời Gian Lay Đọng “ cũng vì thế mà ra đời.
B3744: ( 011, 019 ) “ Gloaming “ Câu chuyện về một chàng trai đã phải lòng với một cương thi, kẻ tỏa ra mùi hương gỗ sồi khi phơi mình dưới ánh mặt trời.
B3745: ( 012, 019 ) “ Atlantis vòng quanh, lòng ai có cặn “ Câu chuyện về một cô gái trẻ hồn lìa khỏi xác đang tìm cách trở về cuộc sống bình thường cùng Vital – một linh hồn lang thang vui tính luôn giúp đỡ cô.
B3746: ( 013, 019 ) “ Animorphs “ Câu chuyện về nhóm thiếu niên có khả năng biến hình thành bất kỳ loài động vật nào họ chạm vào và sử dụng khả năng ấy để chống lại cuộc xâm lược của người ngoài hành tinh.
B3747: ( 014, 019 ) “ Có hai con cá bơi giữa dòng đời “ Câu chuyện xoay quanh hai con cá Thiên Đường và Thanh Ngọc ngồi sau song sắt ngắm nhìn thế giới và chia sẻ những suy nghĩ về cuộc sống.
B3748: ( 015, 019 ) “ Thời vàng son “ Câu chuyện kể về cá Anh Đào, một cô cá mồ côi, xuất thân nghèo khó liên tiếp gặp vận đỏ nhờ những sự trùng hợp may mắn và khả năng ứng biển.
B3749: ( 017, 019 ) “ Hoa viên ngôn từ “ Câu chuyện đẹp về tình bạn giữa chàng trai có năng khiếu đóng giày và một cô gái mắc bệnh trầm cảm đang tìm lại lý do sống của mình tại một hoa viên xinh đẹp.
B3750: ( 018, 019 ) “ Vivid “ Câu chuyện về một linh hồn vô danh sau khi chết được thiên thần Frapputa thông báo rằng mình đã "trúng số" và có cơ hội thứ hai để chuộc lại lỗi lầm trong quá khứ.
B3751: ( 023, 022 ) Mình nhớ cuốn Ma Vương Cổ Đại nằm đâu đó ở kệ này…
B3752: À, đây rồi!!
B3753: Đây là quyển sách cũ rích không rõ nguồn gốc có nói về Ma Vương Atlantis.
B3754: Đến cả tôi lúc đọc cuốn này còn bất ngờ mà!
B3755: Nào giờ ở dưới Atlantis ai cũng tôn thờ thần Poseidon hết, tự dưng tòi đâu ra ông Ma Vương không ai biết mặt biết tên lại chả bất ngờ.
B3756: Ban đầu tôi còn tưởng cuốn này là tiểu thuyết được viết bởi ai đó nhưng khi thử một số phép thuật được viết trong đây…
B3757: Tôi chắc chắc cuốn này là sách siêu cổ đại!
B3758: Đa phần số phép thuật mà tôi dùng hiện giờ đều học từ cuốn này mà ra.
B3759: Mua cuốn này cho Hakase là chuẩn bài rồi đấy!!
B3760: Vì Hakase từng là ma vương mà!
B3761: Trong cuốn này cũng còn nhiều phép thuật tôi chưa sử dụng được, cá chắn Hakase đọc phát thông thạo ngay!
B3762: Mua cuốn này cho Hakase chứ?
B3763: [ Có ] Mua luôn!
B3764: [ Không ] Từ từ, để xem còn cuốn nào không.
B3765: ( 019, 022 ) Tủ này là tủ sách về văn hóa ở Atlantis.
B3766: Ở Atlantis vào ngày 31/10 sẽ là ngày trăng máu.
B3767: Khi ấy, sức mạnh của quái vật vực sâu sẽ tăng lên gấp trăm lần.
B3768: Ngược lại, cư dân Atlantis sẽ bị giảm sức mạnh thậm tệ.
B3769: Có người thì bị hiện tượng “ lại tổ “.
B3770: Có người thì bị mất phép thuật tạm thời hoặc vĩnh viễn.
B3771: Cho nên mỗi khi đến 31/10, mình bắt buộc phải trực xuyên suốt không ngơi nghỉ.
B3772: Vì mình may mắn không bị ảnh hưởng bởi trăng máu.
B3773: Mà còn mạnh khủng khiếp nữa!
B3774: ( 020, 022 ) Ôi cái tủ này có nguyên ổ nhện biển!!
B3775: Tủ này là tủ sách về lịch sử chiến tranh ở Atlantis.
B3776: Loại giấy dùng làm những cuốn sách này lại là món ưa thích của tụi nhện.
B3777: ( 021, 022 ) Tủ này là tủ sách thi ca thời cổ đại.
B3778: Toàn bộ các bài thơ, bài ca thời đấy…
B3779: Đều là phép thuật phong ấn và khai triển kết giới.
B3780: Mình may mắn học được một vài bài.
B3781: Siêu hữu ích.
B3782: ( 022, 022 ) Tầng cuối cùng của kệ này bị nhện biển làm tổ rồi…
B3783: ( 024, 022 ) Mình nhớ tủ sách này từng là tủ sách lịch sử phép thuật ở Atlantis.
B3784: Ôi, chưa kịp đọc!! Mấy con nhện biển chết tiệt!!
B3785: ( 020, 016 ), ( 021, 016 ) Đây là chiếc bàn mà mình với bà lão hay ngồi chung.
B3786: ( 020, 013 ), ( 021, 013 ) Đây là cửa dịch chuyển kết nối với phòng của bà lão.
B3787: ( 019, 013 ) Trên tủ này vẫn còn cuốn sách viết tay của bà lão về sở thích của các vị khách.
B3788: “ Buttercup “ hay mượn sách về nghệ thuật hình ảnh. Luôn đi chung với Aira.
B3789: Dahria hay mượn sách cổ tích và truyện tranh về các phù thủy. Hay lén lút mang sách về.
B3790: Aira hay mượn sách về phép thuật. Con bé rất chăm chỉ luyện tập.
B3791: “ Paupipo “ hay mượn sách về văn hóa Atlantis. Thằng bé nghiêm túc hơn anh chị em mình.
B3792: “ Nhện biển xanh “ hay mượn sách phép thuật. Cũng là đứa trẻ hay gặm sách lúc ngủ.
B3793: ( 014, 013 ), ( 015, 013 ) Đây là cửa dịch chuyển kết nối với phòng vệ sinh.
B3794: ( 008, 013 ), ( 009, 013 ) Đây là cửa dịch chuyển kết nối với một thư viện toàn sách thời đại mới.
B3795: ( 010, 013 ) Chậu cây này có thể nhại lại âm thanh.
B3796: ( 006, 013 ), ( 007, 013 ) Chân dung của ba bà lão.
B3797: ( 009, 006 ) Mình với Oni Onii hay ngồi bàn này.
