# Palworld Server Manager
 管理伺服器備份以及記憶體高佔用處理的批次檔(bat)
> [!IMPORTANT]
> 這個批次檔已經過時。
>
> 專用伺服器已經修正了記憶體洩漏(memory leak)的問題，並且內建了自動備份，請參考這個網站並在palworldsetting.ini開啟該功能。
>
> https://docs.berrybyte.net/games/palworld/enable-autosave-automatic-backups

## 主要功能
- 伺服器存檔(包含地圖及人物數據)每隔10分鐘自動備份，備份最多保留最新的200個
- 每隔30分鐘輸出一次記憶體使用情況到聊天視窗
- 監測伺服器的記憶體佔用，如果進程佔用高於10GB，則伺服器會在5分鐘後自動重啟，重啟前會廣播提醒以及自動備份

## 如何使用這個批次檔?
1.下載這個批次檔

2.下載<a href=https://github.com/radj307/ARRCON/releases>ARRCON工具</a>

3.將ARRCON執行檔放到你的PalServer資料夾根目錄

4.對批次檔點右鍵->"編輯"批次檔，用記事本或notepad++等軟體打開

5.在批次檔上方修改以下內容:

- baseDir :更改為你的伺服器根目錄(Palserver.exe的所在位置)
- source :在路徑的最後面，把地圖ID更改為你自己的地圖ID
- rconIP :伺服器IP，通常可以直接用127.0.0.1
- rconPort :除非你有變更伺服器配置檔，否則請保留25575
- rconPassword :改成你的伺服器AdminPassword

6.執行

## 注意事項
這個批次檔使用RCON進行伺服器指令推送，因此請確保你的伺服器配置檔有開啟RCON連線(RCONEnabled=True)，並設置AdminPassword
