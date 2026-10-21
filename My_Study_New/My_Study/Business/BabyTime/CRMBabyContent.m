#import "CRMBabyStore.h"

// 扩充内容独立存放，既便于校对，也避免影响基础内容的离线可用性。
static NSDictionary *BabyTimeCatalog(void) {
    static NSDictionary *catalog;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURL *url = [NSBundle.mainBundle URLForResource:@"BabyTimeContent" withExtension:@"json"];
        NSData *data = url ? [NSData dataWithContentsOfURL:url] : nil;
        id decoded = data ? [NSJSONSerialization JSONObjectWithData:data options:0 error:nil] : nil;
        if ([decoded isKindOfClass:NSDictionary.class] && [decoded[@"version"] integerValue] == 1) catalog = decoded;
        else catalog = @{};
    });
    return catalog;
}

static NSArray<NSDictionary *> *BabyTimeExtraReadings(NSString *key) {
    id raw = BabyTimeCatalog()[key];
    if (![raw isKindOfClass:NSArray.class]) return @[];
    NSMutableArray *valid = [NSMutableArray new];
    for (id item in raw) {
        if (![item isKindOfClass:NSDictionary.class]) continue;
        BOOL complete = YES;
        for (NSString *field in @[@"id", @"title", @"category", @"icon", @"body", @"source"]) {
            if (![item[field] isKindOfClass:NSString.class] || [item[field] length] == 0) { complete = NO; break; }
        }
        if (complete) [valid addObject:item];
    }
    return valid;
}

NSArray<NSDictionary *> *CRMBabyPodcastLetters(void) {
    NSMutableArray<NSDictionary *> *letters = [NSMutableArray new];
    NSMutableSet<NSString *> *identifiers = [NSMutableSet new];
    for (NSDictionary *item in BabyTimeExtraReadings(@"podcastLetters")) {
        NSString *identifier = item[@"id"];
        NSString *address = item[@"sourceURL"];
        NSURL *url = [address isKindOfClass:NSString.class] ? [NSURL URLWithString:address] : nil;
        if ([identifiers containsObject:identifier] || ![url.scheme isEqualToString:@"https"] || ![url.host isEqualToString:@"podcasts.apple.com"]) continue;
        [identifiers addObject:identifier];
        [letters addObject:item];
    }
    return letters.copy;
}

NSArray<NSString *> *CRMBabyConversationPrompts(BOOL afterBirth) {
    id raw = BabyTimeCatalog()[afterBirth ? @"afterBirthPrompts" : @"prenatalPrompts"];
    if (![raw isKindOfClass:NSArray.class]) raw = nil;
    NSMutableArray *valid = [NSMutableArray new];
    for (id prompt in raw) if ([prompt isKindOfClass:NSString.class] && [prompt length]) [valid addObject:prompt];
    if (valid.count) return valid;
    return afterBirth ? @[@"看看宝宝今天对什么感兴趣，跟着说一说，再停下来等一等。"] : @[@"讲讲今天的一件小事，也问问妈妈现在需要什么。"];
}

static NSDictionary *Reading(NSString *identifier, NSString *title, NSString *category, NSString *icon, NSString *body) {
    return @{@"id": identifier, @"title": title, @"category": category, @"icon": icon, @"body": body, @"source": @"宝宝时光 · 原创陪伴短文"};
}
NSArray<NSDictionary *> *CRMBabyReadings(void) {
    static NSArray *items;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSArray *base = @[
            Reading(@"hello", @"你好呀，小小的你", @"爸爸来读", @"🌱", @"你好呀，小小的你，我是爸爸。\n\n今天的风很轻，树叶在窗外慢慢摇晃。我想把这些平常的小事，一件一件讲给你听。等你来到我们身边，我们可以一起看树叶，听雨点，也可以什么都不做，就安静地坐一会儿。\n\n你不用着急长大，也不用急着回答。我会慢慢学着抱你，学着听懂你的声音，学着成为你的爸爸。也许我偶尔会有一点笨拙，但我会一直认真地练习。\n\n今天先说到这里。小小的你，晚安。妈妈也辛苦啦。"),
            Reading(@"moon", @"月亮的口袋", @"睡前短篇", @"🌙", @"天快黑的时候，小熊问月亮：你的口袋里装着什么？\n\n月亮轻轻翻了翻口袋。里面有一缕傍晚的风、一片没有落地的叶子，还有小河今天唱过的歌。\n\n能装下我的梦吗？小熊又问。\n\n当然可以。月亮说，梦很轻，可它们都很珍贵。\n\n小熊把一个小小的梦放了进去：明天和朋友一起，在草地上找一朵黄色的花。月亮把口袋合好，给每一扇窗都留下一点温柔的光。\n\n夜很安静。小熊盖好被子，想着那朵还没有见面的花，慢慢睡着了。"),
            Reading(@"rain", @"雨点来做客", @"睡前短篇", @"🌧", @"笃，笃，笃。谁在敲窗？\n\n是小雨点来做客啦。它们没有带礼物，却给屋顶唱了一首细细的歌。\n\n一滴雨落在叶子上，叶子弯了弯腰。一滴雨落进小水洼，画出一个圆圈。还有一滴雨停在窗边，透过玻璃看屋里的灯。\n\n小兔搬来一张小凳子，安静地听。妈妈在旁边织围巾，偶尔抬起头，和它一起数窗上的水珠。\n\n雨渐渐小了。小兔挥挥手：谢谢你们的歌。下次来，记得也带上彩虹。\n\n屋里暖暖的，窗外也有了青草的气味。"),
            Reading(@"seed", @"一粒慢慢长大的种子", @"睡前短篇", @"🌼", @"泥土里住着一粒小种子。它听见地面上有风，也听见小鸟走过的脚步。\n\n我什么时候才能看看外面呢？它问。\n\n不着急。泥土说，我会陪着你。\n\n太阳把温暖送下来，雨水沿着小路来到它身边。种子每天做一点点事情：伸一伸根，舒一舒腰，再好好休息。\n\n一个清晨，它终于探出一小片绿色。外面没有掌声，只有风轻轻地说：你好呀。\n\n小种子很开心。原来，慢慢长大也很好。它不知道自己会开出什么颜色的花，但今天，它有了一片属于自己的小叶子。"),
            Reading(@"boat", @"小船回家", @"睡前短篇", @"⛵️", @"河边有一只小纸船，船上画着一颗红色的心。\n\n它经过石桥，经过垂到水边的柳树，也经过一群晒太阳的小鸭子。河水不急，它也不急。\n\n天边的云变成了粉色，小船有一点想家。小鸭子说：沿着灯光走吧，那边有人等你。\n\n小船顺着水面上的亮光，来到一双熟悉的手边。小朋友把它轻轻捧起来：你回来啦。\n\n纸船靠在窗台上，听大家讲今天的故事。原来，回家的意思，就是走过许多地方以后，还能有人温柔地接住你。"),
            Reading(@"wind", @"风的悄悄话", @"温柔小诗", @"🍃", @"风走过树梢，\n把叶子轻轻摇。\n\n风走过小桥，\n听见河水笑。\n\n风来到窗前，\n把白云的消息捎。\n\n我把声音放轻一点，\n把今天讲给你知道。\n\n等你睁开眼睛，\n我们一起，\n向这个世界问好。\n\n——读到这里可以停一停，用自己的话，说说今天窗外的天气。"),
            Reading(@"light", @"给你留一盏灯", @"温柔小诗", @"✨", @"晚风慢下来，\n小路静下来。\n\n星星在天空，\n一颗一颗亮起来。\n\n桌上有温水，\n窗边有花开。\n\n我把今天的小欢喜，\n慢慢装进口袋。\n\n等你来到身边，\n我们再一起打开。\n\n不管是晴天，\n还是雨落下来，\n总有一盏小小的灯，\n为你温柔地亮着。"),
            Reading(@"dad-day", @"爸爸今天的一件小事", @"爸爸来读", @"☀️", @"宝宝，今天爸爸想和你分享一件小事。\n\n早上出门时，我看见路边有一朵小花。昨天它还躲在叶子后面，今天已经悄悄开了。我停下来多看了一眼，觉得平常的早晨也变得有一点特别。\n\n我开始想，等你来了，我们走路也可以慢一点。你想看蚂蚁，我们就停下来；你想听鸟叫，我们就安静一会儿。\n\n当然，今天也有忙碌和不顺利的时候。不过现在能坐下来，和妈妈一起说说话，我觉得很踏实。\n\n以后你也可以把开心和不开心讲给我们听。我们愿意听，也会陪你一起想办法。"),
            Reading(@"name", @"关于你的小名", @"写给宝宝", @"💌", @"亲爱的宝宝，我们常常聊起你。\n\n有时想象你的小手，有时讨论你的小名。每想到一个名字，我们都会轻轻念几遍，看看它听起来是不是温柔，是不是像一声亲切的招呼。\n\n名字里可能藏着一棵树、一阵风，或者一个家人共同喜欢的字。但比名字更早准备好的，是我们对你的期待。\n\n我们期待认识真实的你：你的笑声，你喜欢的颜色，你慢慢形成的脾气。你不需要和想象中一模一样，我们会一点一点了解你。\n\n今天，可以在这里添上你们给宝宝起小名的故事，再亲口念一遍。"),
            Reading(@"mom", @"也抱抱辛苦的妈妈", @"写给宝宝", @"🌷", @"亲爱的宝宝，今天也想谢谢妈妈。\n\n她带着你过每一个普通的日子。有时候觉得轻松，有时候会疲惫，也可能有说不清的心情。她不需要每天都精神满满，也不用每件事都做得完美。\n\n今天我想问问她：有没有什么想吃的？要不要休息一会儿？有什么是我能帮忙的？\n\n我可以接过手边的家务，准备一杯水，也可以认真听她说话。陪伴有时候很简单，就是把一件小事真正做好。\n\n宝宝，我们都在学习照顾彼此。等你来了，你会住在一个愿意互相体谅的家里。"),
            Reading(@"morning", @"一起看清晨", @"亲子共读", @"🐦", @"早上好，小小的你。\n\n窗帘拉开一点点，光落在墙上。我们先看看光，再看看彼此。你好呀，这是我的脸，这是我的手。\n\n外面有一只鸟，它停在树枝上，叫了两声。我也轻轻学一声，然后停下来，等一等你的声音。\n\n桌上有一本书，书里有一朵花。我们慢慢翻，不着急读完，也不用记住什么。你想看这一页，我们就多看一会儿；你想休息，我们就把书合起来。\n\n今天还有很长很长的时间。能和你一起看见这个清晨，已经很好。"),
            Reading(@"goodnight", @"今天就到这里吧", @"睡前短篇", @"🧸", @"今天就到这里吧。\n\n太阳已经回家，云朵也放慢了脚步。小熊把积木放进盒子，小猫在垫子上团成一个小圆。\n\n有些事情做完了，有些事情留给明天。没有关系。\n\n我们可以想一件今天喜欢的小事：一碗热汤，一句问候，一次安静的拥抱。也可以什么都不想，就听听房间里熟悉的声音。\n\n我在这里，陪你待一会儿。你不用努力表现，也不用急着长大。\n\n晚安，小小的你。晚安，今天也认真生活的我们。")
        ];
        items = [base arrayByAddingObjectsFromArray:BabyTimeExtraReadings(@"afterBirthReadings")];
    });
    return items;
}
NSArray<NSDictionary *> *CRMBabyMelodies(void) {
    return @[
        @{@"id": @"star", @"title": @"小星星 · 轻柔木琴", @"file": @"baby_star.wav", @"detail": @"传统旋律 · 本项目合成演奏 · 约 32 秒"},
        @{@"id": @"river", @"title": @"小河慢慢流", @"file": @"baby_river.wav", @"detail": @"原创旋律 · 柔和音色 · 约 32 秒"},
        @{@"id": @"cloud", @"title": @"云朵晚安", @"file": @"baby_cloud.wav", @"detail": @"原创旋律 · 舒缓节奏 · 约 35 秒"},
        @{@"id": @"morning", @"title": @"晨光慢慢来", @"file": @"baby_morning.wav", @"detail": @"原创旋律 · 约 1 分钟"},
        @{@"id": @"breeze", @"title": @"晚风的问候", @"file": @"baby_breeze.wav", @"detail": @"原创旋律 · 约 1 分钟"},
        @{@"id": @"waiting", @"title": @"陪你等天亮", @"file": @"baby_waiting.wav", @"detail": @"原创旋律 · 约 1 分钟"},
        @{@"id": @"garden", @"title": @"花园散步", @"file": @"baby_garden.wav", @"detail": @"原创旋律 · 轻盈舒缓 · 约 1 分半"},
        @{@"id": @"sunset", @"title": @"落日余温", @"file": @"baby_sunset.wav", @"detail": @"原创旋律 · 慢速聆听 · 约 1 分半"},
        @{@"id": @"firefly", @"title": @"萤火微光", @"file": @"baby_firefly.wav", @"detail": @"原创旋律 · 夜晚放松 · 约 1 分半"},
        @{@"id": @"harbor", @"title": @"安静港湾", @"file": @"baby_harbor.wav", @"detail": @"原创旋律 · 柔和节奏 · 约 1 分半"},
        @{@"id": @"dandelion", @"title": @"蒲公英的路", @"file": @"baby_dandelion.wav", @"detail": @"原创旋律 · 轻声陪伴 · 约 1 分半"},
        @{@"id": @"raindrop", @"title": @"雨滴与窗", @"file": @"baby_raindrop.wav", @"detail": @"原创旋律 · 安静聆听 · 约 1 分半"},
        @{@"id": @"humming", @"title": @"温柔哼唱", @"file": @"baby_humming.wav", @"detail": @"原创旋律 · 放慢脚步 · 约 1 分半"},
        @{@"id": @"nightlight", @"title": @"床边小灯", @"file": @"baby_nightlight.wav", @"detail": @"原创旋律 · 睡前时光 · 约 1 分半"}
    ];
}

NSArray<NSDictionary *> *CRMBabyPrenatalReadings(void) {
    static NSArray *items;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSArray *base = @[
            Reading(@"prenatal-hello", @"第一次，认真和你打招呼", @"和宝宝说话", @"👋", @"你好呀，小小的你。\n\n我是爸爸。今天开始，我想练习把生活讲给你听。现在我在家里，窗外有一点风，桌上放着一杯温水。妈妈正在休息，我想先轻轻问她：今天过得怎么样？\n\n我们也许还没有见过面，但已经会为你留意很多事情。路上的一棵树、下午的一阵雨、晚饭里喜欢的味道，都让我想到，等你来到我们身边，生活会多一双一起观看的眼睛。\n\n你不用回答，也不用表现什么。我会用平常的声音说说话；说累了就停下来陪妈妈坐一会儿。今天的第一声招呼，先送给你。"),
            Reading(@"prenatal-day", @"爸爸把今天讲给你听", @"爸爸来读", @"☀️", @"宝宝，今天我想讲三个小片段。\n\n早上，路口的树比昨天更绿了一点。中午，吃饭的时候我想到妈妈最近有没有特别想吃的东西。傍晚，回家路上看见有人抱着一束花，忍不住想象以后和你一起挑花的样子。\n\n这一天也有忙碌的时候，我可能皱过眉头，但现在坐下来讲给你听，心里慢慢安静了。\n\n我们希望你知道，家里的日子不用每一天都精彩。普通的早晨、重复的晚饭、偶尔疲惫却愿意互相照顾的我们，也可以组成很温暖的故事。\n\n明天如果有新的小事，我再来和你分享。"),
            Reading(@"prenatal-mom", @"今天先照顾好妈妈", @"写给妈妈", @"🌷", @"今天的这段话，先说给妈妈听。\n\n你带着宝宝走过每一个日常，身体和心情可能每天都不同。轻松的时候，我们一起开心；累的时候，不用强打精神。我可以准备水和食物，整理眼前的家务，也可以只安静听你讲一讲。\n\n宝宝还在肚子里，我们都在学着成为一家人。比起完成一张胎教清单，更想做的是让你有时间休息，觉得有人站在你身边。\n\n如果今天只做一件事，我想问：现在有什么能让我替你分担？\n\n等我们一起坐下，再用轻轻的声音向宝宝说声晚安。"),
            Reading(@"prenatal-window", @"窗外的一棵树", @"五分钟朗读", @"🌳", @"窗外有一棵树。晴天，它把影子放在地上；雨天，它让水珠沿着叶子慢慢落下来。\n\n有时我很忙，走过它也没有抬头。今天想停一会儿，把它讲给你听。树叶不都一样，有大有小。有一片被风吹动，很快又安静了；另一片一直向着亮的地方。\n\n我想，等你出生以后，我们可以一起看看这棵树。你可能会看它很久，也可能更喜欢旁边的小石头。都没关系，我愿意跟着你的兴趣重新认识它。\n\n现在，先让我把这片绿色和今天的风，轻轻放进我们的故事里。"),
            Reading(@"prenatal-rain", @"给你讲一场小雨", @"五分钟朗读", @"🌧", @"一场小雨从远处走来，先落在屋檐上，再落在街边的树叶上。\n\n它没有急着把路变湿，只是一下、一下地敲着窗。有人收起伞走进屋里，有人抬头看云的方向。小猫把自己团成一个圆，继续睡觉。\n\n如果你在这里，我想抱着你看一会儿窗外，告诉你雨是怎样把灰尘洗掉，让空气变得清新。我们不用数清每一滴雨，只要听一听，停一停。\n\n等雨停了，也许会看见路上有一小片亮光。今天的故事就到这里，我们一起把呼吸放轻，和妈妈安静地坐一会儿。"),
            Reading(@"prenatal-home", @"说说我们准备的家", @"和宝宝说话", @"🏡", @"宝宝，今天想向你介绍我们的小家。\n\n这里有一扇早上会照进光的窗，有大家常坐的椅子，还有一张偶尔堆着东西、我们正在学习整理的桌子。家不必总是整齐漂亮，但希望你在这里可以放心地哭、开心地笑，也可以安安静静地发呆。\n\n我和妈妈有时意见不一样，会慢慢商量。我们不可能每一刻都做得很好，不过会练习道歉、练习倾听，也练习把爱说出来。\n\n等你来了，这个家会有新的声音。我们会从你的每个表情里认识你，再一点一点，把这里变成你熟悉的地方。"),
            Reading(@"prenatal-name", @"关于你的小名", @"和宝宝说话", @"💌", @"今天想和你聊聊名字。\n\n我们试着念出几个音节，听一听哪个最像温柔的招呼。有的名字让人想到天空，有的像一棵树，也有的只是我们一家人都觉得亲切。\n\n小名可能会变，关于你的想象也会慢慢改变。这都没关系。你不必长成某个预设好的样子，等见面后，我们愿意认识真正的你。\n\n现在可以停下来，和妈妈一起念念你的小名，讲讲是谁先想到的。要是还没决定，也可以先叫你“小小的你”。\n\n无论叫什么，每次说起你，我们都在学着对一个新生命说：欢迎来到我们家。"),
            Reading(@"prenatal-food", @"晚饭的香气", @"和宝宝说话", @"🍲", @"晚饭时间到了。厨房里有轻轻的声音，锅里冒着热气。\n\n今天吃什么并不重要，我想讲的是，一家人坐在一起的那一会儿。有人说起白天遇到的事，有人想到明天要买的东西，偶尔也会安静地吃饭。\n\n妈妈最近喜欢什么味道？我可以问问她，和她一起准备舒服的一餐。她吃得开心、休息得好，比我严格完成某一项任务更重要。\n\n宝宝，等你长大一些，我们也会一起尝试不同的味道。你可能喜欢甜的，也可能偏爱清淡的。现在先把这一晚暖暖的灯光和饭香，讲给你听。"),
            Reading(@"prenatal-song", @"给你哼一首没有名字的歌", @"轻声唱唱", @"🎶", @"嗯——嗯——\n\n我先唱两个轻轻的音，再停下来听听房间里的声音。\n\n嗯——嗯——\n\n今天不需要漂亮的嗓音，也不需要记住歌词。我只是想选一个舒服的调子，唱给妈妈听，也唱给你听。可以慢一点，可以重复同一句，也可以把最后一个音换成你的昵称。\n\n如果唱着唱着想笑，就笑吧。妈妈喜欢的歌，爸爸记得的童年曲调，都能成为我们家的声音。\n\n唱完以后，我们可以把手机放下，喝一口水，问问彼此：今天有什么让你觉得安心？\n\n这首没有名字的小歌，下次想起时还可以再唱。"),
            Reading(@"prenatal-stars", @"今晚有几颗星星", @"五分钟朗读", @"⭐️", @"天暗下来，窗外的楼一盏盏亮起灯。\n\n小朋友问：星星也会回家吗？爸爸说，也许每一颗星星都有自己喜欢停留的地方。\n\n我们抬起头，先看到一颗，又看到更远的一颗。云飘过来时，星星暂时藏起了光，但没有消失。\n\n有时候我也会这样，今天忙得来不及讲故事。等安静下来，还是愿意回到你和妈妈身边，继续讲没有讲完的话。\n\n今晚不必数完所有星星。选一颗最喜欢的，在心里叫它一声，然后把窗关好，准备休息。明天夜里，再看看天空变成了什么样子。"),
            Reading(@"prenatal-letter", @"写给未来见面的你", @"写给宝宝", @"✉️", @"亲爱的宝宝：\n\n等你读到这封信，可能已经会跑、会问很多问题，也可能还小得需要我们抱着。写信的这一天，你还在妈妈肚子里，我们正试着猜想未来的生活。\n\n我想告诉你，期待与你见面，不等于要求你成为什么样的人。你可以有自己的速度、自己的兴趣，也可以在难过时来找我们。\n\n如果有一天我做错了，我希望自己能认真听你说话，承认错误，再一起重新开始。\n\n现在，我先练习做一件简单的事：照顾好你身边的人，耐心等你到来。愿我们相见的那天，先互相说声你好。"),
            Reading(@"prenatal-hands", @"爸爸的手可以做什么", @"爸爸来读", @"🤲", @"宝宝，爸爸的手今天做了几件事。\n\n早上把窗帘拉开，让屋里亮一点；中午洗了水果，给妈妈留了喜欢的那一份；晚上收拾好桌子，给我们留一处坐下来讲话的地方。\n\n这些事都不大，却让我觉得自己正在慢慢准备。以后，这双手可能会笨拙地给你换衣服，扶你走第一步，陪你搭一座很高的积木塔。做得不好时，我会再练习。\n\n此刻我最想做的，是握一握妈妈的手，听听她今天的心情。然后用平常的声音，把今天讲给你听。"),
            Reading(@"prenatal-slow", @"给我们一个慢一点的晚上", @"放松片刻", @"🕯", @"找一个舒服的位置坐下。手机放远一点，先看看身边的人。\n\n今天也许有没做完的事，先让它们留在明天。现在不需要正确的姿势、固定的节奏，也没有必须完成的次数。\n\n把肩膀放松，用自己舒服的方式呼吸。听一听房间里熟悉的声音：窗边的风、远处的人声，或者妈妈说的一句话。\n\n如果想开口，就聊一件今天喜欢的小事；如果想安静，就安静一会儿。身体不舒服时随时停下来休息。\n\n这一小段时间，是给妈妈、给爸爸，也给小小的你。"),
            Reading(@"prenatal-grandparents", @"家人的声音", @"和宝宝说话", @"👪", @"宝宝，今天我们想把家人的声音也带来。\n\n有人讲故事讲得慢，有人一说起吃的就特别开心。我们每个人的声音都不一样，却都可以用自己的方式向你打招呼。\n\n如果家人住得远，可以打个电话，先问问他们最近过得怎么样，再聊聊等你来了想一起做什么。要是今天只想安静地待着，也完全可以把这件事留给以后。\n\n我们慢慢认识彼此：你有自己的节奏，大人们也需要学着尊重妈妈的感受。期待你的到来，可以是一句问候，也可以是一份不过分打扰的照顾。"),
            Reading(@"prenatal-season", @"你来到时会是什么季节", @"写给宝宝", @"🍂", @"算一算日历，你来到我们身边时，窗外可能是什么样子？\n\n现在树上的叶子是什么颜色？到那时，风会不会更凉，或者花已经开了？我想把这些变化慢慢记下来。\n\n每过一个星期，我们都会多认识一点自己：妈妈什么时候需要休息，爸爸做什么能帮上忙，我们可以怎样把家安排得更舒服。\n\n预产期只是一个预计的日子，真正见面的时间由生活慢慢决定。我们不会因为倒数而催促你。\n\n今天先写下窗外的季节，也写下我们此刻的心情。等以后翻看，也许会想起这个特别普通的下午。"),
            Reading(@"prenatal-together", @"一起等，不着急", @"放松片刻", @"🌈", @"有时我们会很期待见面，忍不住想象你的模样；有时也会担心自己还没准备好。两种心情都可以存在。\n\n我们可以把能做的事慢慢做好：问候彼此，听取医生的建议，整理一点点生活，再给自己留些休息时间。没必要用某一张清单衡量自己是不是合格。\n\n现在我想说一句：妈妈，你已经很辛苦了。宝宝，我们在这里。\n\n如果今天有力气，就读一小段喜欢的文字；如果今天没有力气，就把书放下。安静地坐在一起，也是一种陪伴。")
        ];
        items = [base arrayByAddingObjectsFromArray:BabyTimeExtraReadings(@"prenatalReadings")];
    });
    return items;
}

NSArray<NSDictionary *> *CRMBabyWeekGuides(void) {
    static NSArray *guides;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSArray<NSArray<NSString *> *> *topics = @[
            @[@"初次打招呼", @"介绍自己，讲讲今天窗外的天气。"],
            @[@"今天的声音", @"选一种你喜欢的日常声音，说说它从哪里来。"],
            @[@"我们的名字", @"念念宝宝的小名，聊聊它的来历。"],
            @[@"喜欢的味道", @"和妈妈聊一顿舒服的饭，把香气讲给宝宝听。"],
            @[@"一件开心事", @"分享这周一件小小的开心事。"],
            @[@"爸爸的故事", @"讲一个自己小时候记得的温柔片段。"],
            @[@"小小的家", @"介绍家里喜欢的一角，想想以后在那里做什么。"],
            @[@"一首熟悉的歌", @"用自己喜欢的调子轻轻哼唱，停下来问问妈妈的感受。"],
            @[@"和妈妈聊天", @"先听妈妈讲今天，再把她想分享的事情讲给宝宝。"],
            @[@"窗外的一棵树", @"描述树叶的颜色、风和光。"],
            @[@"慢下来的晚上", @"合上清单，读一小段喜欢的话，再一起休息。"],
            @[@"来自家人的问候", @"愿意的话，让亲近的家人用自己的声音说声你好。"],
            @[@"今天的天气", @"想想未来和宝宝一起看雨、看云是什么样子。"],
            @[@"一个小小的愿望", @"说一个想和宝宝共同经历的小事，不设目标。"],
            @[@"好好吃一顿饭", @"一起安排妈妈觉得舒服的一餐。"],
            @[@"重读喜欢的故事", @"拿出上次喜欢的短文，再读一遍。"],
            @[@"爸爸的一封信", @"写下现在想说的话，留待以后一起看。"],
            @[@"熟悉的旋律", @"回到那首你们喜欢的歌，轻轻唱几句。"],
            @[@"问候自己", @"说说这周自己和妈妈的心情，允许疲惫。"],
            @[@"我们准备的小角落", @"讲讲为宝宝留出的一个小角落。"],
            @[@"过去的一张照片", @"挑一张照片，讲讲照片里的故事。"],
            @[@"离见面又近一点", @"把期待写下来，不给见面的日期设倒计时压力。"],
            @[@"今天就在这里", @"谢谢一起走到现在的家人，安静休息。"]
        ];
        NSMutableArray *result = [NSMutableArray new];
        [topics enumerateObjectsUsingBlock:^(NSArray<NSString *> *topic, NSUInteger index, BOOL *stop) {
            [result addObject:@{@"week": @(index + 18), @"title": topic[0], @"prompt": topic[1]}];
        }];
        guides = result.copy;
    });
    return guides;
}
