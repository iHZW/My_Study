// 官方详情页只提取文本，不执行网页脚本，也不把远程HTML直接插入界面。
#import <Foundation/Foundation.h>

static inline NSString *CRMAtlasPlainText(NSString *html) {
    NSString *text = [html stringByReplacingOccurrencesOfString:@"<br\\s*/?>" withString:@"\n" options:NSRegularExpressionSearch | NSCaseInsensitiveSearch range:NSMakeRange(0, html.length)];
    text = [text stringByReplacingOccurrencesOfString:@"<[^>]*>" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, text.length)];
    NSDictionary *entities = @{@"&nbsp;":@" ", @"&quot;":@"\"", @"&#39;":@"'", @"&apos;":@"'", @"&lt;":@"<", @"&gt;":@">"};
    for (NSString *entity in entities) text = [text stringByReplacingOccurrencesOfString:entity withString:entities[entity]];
    text = [text stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
    return [text stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
}

static inline NSString *CRMAtlasCapture(NSString *html, NSString *pattern) {
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators error:nil];
    NSTextCheckingResult *match = [regex firstMatchInString:html options:0 range:NSMakeRange(0, html.length)];
    return match.numberOfRanges > 1 ? CRMAtlasPlainText([html substringWithRange:[match rangeAtIndex:1]]) : @"";
}

static inline NSDictionary<NSString *, NSString *> *CRMAtlasParseProfile(NSString *html) {
    if (!html.length) return nil;
    NSString *intro = CRMAtlasCapture(html, @"<p[^>]*class=[\"'][^\"']*p-ref__txt[^\"']*[\"'][^>]*>(.*?)</p>");
    if (!intro.length) return nil;
    NSMutableDictionary *profile = [@{@"intro":intro} mutableCopy];
    NSDictionary *fields = @{@"level":@"等级", @"type":@"类型", @"attribute":@"属性", @"move":@"必杀技"};
    for (NSString *key in fields) {
        NSString *pattern = [NSString stringWithFormat:@"<dt[^>]*>\\s*%@\\s*</dt>\\s*<dd[^>]*>(.*?)</dd>", fields[key]];
        NSString *value = CRMAtlasCapture(html, pattern);
        if (value.length) profile[key] = value;
    }
    NSString *english = CRMAtlasCapture(html, @"<div[^>]*class=[\"'][^\"']*c-titleSet__sub[^\"']*[\"'][^>]*>(.*?)</div>");
    if (english.length) profile[@"english"] = english;
    return profile;
}

static inline BOOL CRMAtlasMatches(NSDictionary *entry, NSString *query, NSString *level) {
    if (level.length && ![entry[@"level"] isEqualToString:level] && ![entry[@"secondaryLevel"] isEqualToString:level]) return NO;
    NSString *trimmed = [query stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    if (!trimmed.length) return YES;
    NSString *haystack = [NSString stringWithFormat:@"%@ %@ %@ %@", entry[@"name"] ?: @"", entry[@"officialName"] ?: @"", entry[@"id"] ?: @"", entry[@"english"] ?: @""];
    return [haystack rangeOfString:trimmed options:NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch].location != NSNotFound;
}
