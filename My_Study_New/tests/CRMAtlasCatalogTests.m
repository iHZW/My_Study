#import "../My_Study/TabsIndexVc/CRMAtlasParsing.h"
#include <assert.h>

int main(void) {
    @autoreleasepool {
        NSData *data = [NSData dataWithContentsOfFile:@"My_Study/Assets.xcassets/DigimonAtlas/digimon_catalog.dataset/catalog.json"];
        assert(data.length);
        NSDictionary *catalog = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        NSArray *entries = catalog[@"entries"];
        assert(entries.count == 1321 && [catalog[@"count"] unsignedIntegerValue] == entries.count);
        NSMutableSet *ids = [NSMutableSet set];
        NSRegularExpression *validID = [NSRegularExpression regularExpressionWithPattern:@"^[a-zA-Z0-9_:-]+$" options:0 error:nil];
        for (NSDictionary *entry in entries) {
            NSString *identifier = entry[@"id"];
            assert(identifier.length && [entry[@"name"] length] && [entry[@"level"] length]);
            assert(![ids containsObject:identifier]); [ids addObject:identifier];
            assert([validID numberOfMatchesInString:identifier options:0 range:NSMakeRange(0, identifier.length)] == 1);
            assert(CRMAtlasMatches(entry, entry[@"name"], nil));
            assert(CRMAtlasMatches(entry, identifier.uppercaseString, entry[@"level"]));
            assert(!CRMAtlasMatches(entry, @"绝对不存在的图鉴名字XYZ", nil));
            NSURLComponents *url = [NSURLComponents componentsWithString:@"https://digimon.net/reference_zh-CHS/detail.php"];
            url.queryItems = @[[NSURLQueryItem queryItemWithName:@"directory_name" value:identifier]];
            assert(url.URL && [url.queryItems.firstObject.value isEqualToString:identifier]);
        }
        for (NSString *identifier in @[@"agumon", @"wargreymon", @"omegamon", @"tailmon", @"miragegaogamon:burstmode"]) assert([ids containsObject:identifier]);
        NSDictionary *alias = @{@"name":@"哥玛兽", @"officialName":@"芝蒙兽", @"id":@"gomamon", @"level":@"成长期"};
        assert(CRMAtlasMatches(alias, @"芝蒙", nil));
        assert(!CRMAtlasMatches(alias, @"哥玛", @"究极体"));
        NSString *html = @"<div class='c-titleSet__sub'>TESTMON</div><dl><dt class='c-txtStrong_A'>等级</dt><dd>成熟期</dd></dl><dl><dt>类型</dt><dd>兽型</dd></dl><dl><dt>属性</dt><dd>数据种</dd></dl><dl><dt>必杀技</dt><dd>动作一<br />动作二</dd></dl><p class='p-ref__txt -txtProfile'>这是一段<br>测试&lt;介绍&gt; &amp; &quot;文本&quot;。</p>";
        NSDictionary *profile = CRMAtlasParseProfile(html);
        assert([profile[@"level"] isEqualToString:@"成熟期"]);
        assert([profile[@"type"] isEqualToString:@"兽型"]);
        assert([profile[@"attribute"] isEqualToString:@"数据种"]);
        assert([profile[@"move"] isEqualToString:@"动作一\n动作二"]);
        assert([profile[@"english"] isEqualToString:@"TESTMON"]);
        assert([profile[@"intro"] isEqualToString:@"这是一段\n测试<介绍> & \"文本\"。"]);
        assert(!CRMAtlasParseProfile(@"<html>错误页面</html>"));
        assert(!CRMAtlasParseProfile(nil));
        NSLog(@"通过：1321条唯一目录、搜索、等级筛选、特殊标识URL、官方详情字段解析及错误页处理。");
    }
}
