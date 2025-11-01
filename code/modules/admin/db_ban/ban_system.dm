// Система логов банов в Discord для Baystation12

// Просто вставь свой webhook URL здесь
#define BAN_WEBHOOK_URL "https://discord.com/api/webhooks/your_webhook_here"

/proc/log_ban_to_discord(banned_ckey, admin_ckey, reason, duration, ban_type = "Игра")
    var/message = "🚫 **БАН ВЫДАН**\n"
    message += "👤 **Игрок:** [banned_ckey || "Неизвестно"]\n"
    message += "🛡️ **Администратор:** [admin_ckey || "Сервер"]\n" 
    message += "📝 **Причина:** [reason || "Не указана"]\n"
    
    if(duration && duration > 0)
        message += "⏰ **Длительность:** [duration] минут\n"
    else
        message += "⏰ **Длительность:** Перманентно\n"
    
    message += "🔧 **Тип:** [ban_type]\n"
    message += "🕐 **Время:** [time2text(world.realtime, "YYYY-MM-DD HH:MM:SS")]"
    
    world.log << "Sending ban to Discord: [banned_ckey]"
    
    // Простая отправка
    spawn(0)
        world.Export("[BAN_WEBHOOK_URL]?wait=1", list("content" = message))

// Тестовый верб
/client/proc/test_ban_webhook()
    set name = "Test Ban Webhook"
    set category = "Admin.Debug"
    
    if(!check_rights(R_BAN))
        return
    
    log_ban_to_discord(
        "TestPlayer", 
        usr.ckey, 
        "Тестовый бан", 
        60, 
        "Тест"
    )
    to_chat(usr, "<span class='adminnotice'>Тест отправлен в Discord</span>")
