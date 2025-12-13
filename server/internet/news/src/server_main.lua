local NEWS_ARTICLES = {
    [1] = {
        title = "GGHJK Has Officaly Internet!",
        date = "13.12.2025",
        author = "",
        content = ""
    }
}

    elseif message.type == "news" then

        
        print("NEWS: Pozadavek na noviny od ID " .. senderId)
        
        rednet.send(senderId, {
            type = "news_success",
            articles = NEWS_ARTICLES 
        })
        
    elseif message.token then
