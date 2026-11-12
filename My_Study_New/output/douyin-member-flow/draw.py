from PIL import Image, ImageDraw, ImageFont
from pathlib import Path

OUT = Path(__file__).parent
im = Image.new('RGB', (2160, 1770), '#f5f7fc')
d = ImageDraw.Draw(im)
font_path = '/System/Library/Fonts/STHeiti Light.ttc'
def font(n):
    return ImageFont.truetype(font_path, n)
def text(x, y, s, size=27, color='#26344c'):
    d.text((x,y), s, font=font(size), fill=color, spacing=15)
def box(rect, title, lines, color):
    x,y,r,b = rect
    d.rounded_rectangle(rect, radius=22, fill='white', outline=color, width=3)
    d.rounded_rectangle((x,y,r,y+57), radius=20, fill=color)
    d.rectangle((x,y+30,r,y+57), fill=color)
    text(x+22,y+12,title,29,'white')
    for i,line in enumerate(lines):
        text(x+22,y+77+i*38,line,25)
def arrow(points, color='#8b97ac'):
    d.line(points, fill=color, width=5, joint='curve')
    x,y=points[-1]; px,py=points[-2]
    if y>py: tip=[(x,y),(x-10,y-16),(x+10,y-16)]
    elif x>px: tip=[(x,y),(x-16,y-10),(x-16,y+10)]
    else: tip=[(x,y),(x+16,y-10),(x+16,y+10)]
    d.polygon(tip,fill=color)

text(70,40,'抖店订单 → 公司账号 → 按商品发优惠券',48)
text(70,112,'两条后台链路独立运行；通过手机号与 OpenID 汇合',29,'#607089')
box((700,180,1460,315),'核心目标',[
    '确认哪个公司用户买了什么，发放对应优惠券'
], '#263c70')
arrow([(900,315),(900,345),(540,345),(540,380)])
arrow([(1260,315),(1260,345),(1620,345),(1620,380)])
box((70,380,1020,610),'① 会员链路｜抖店主动调用你们',[
    '用户在抖音内主动授权加入品牌会员',
    '调用方：抖店会员通 → 被调用方：公司后台',
    '接口：公司提供并在平台配置的会员绑定 SPI',
    '保存：店铺范围＋会员 open_id；验签并返回绑定结果'
], '#3971c6')
box((1140,380,2090,610),'② 订单链路｜你们主动调用抖店',[
    '调用方：公司后台 → 被调用方：抖店开放平台',
    '接口：/order/searchList',
    '携带：店铺授权凭证＋时间等查询条件',
    '获取：订单列表、订单号及订单数据'
], '#138a82')
arrow([(540,610),(540,650)])
arrow([(1620,610),(1620,650)])
box((70,650,1020,880),'③ 查询会员手机号',[
    '调用方：公司后台 → 被调用方：抖店开放平台',
    '接口：/member/mGetMemberInfoByOpenIdList',
    '携带：授权凭证＋会员 OpenID',
    '获取：会员信息，含按规则返回的明文／密文手机号'
], '#3971c6')
box((1140,650,2090,880),'④ 必要时补齐订单明细',[
    '调用方：公司后台 → 被调用方：抖店开放平台',
    '接口：/order/orderDetail；携带：授权凭证＋订单号',
    '保存：店铺、订单号、doudian_open_id',
    '以及商品 ID／SKU ID、数量、支付状态'
], '#138a82')
arrow([(540,880),(540,920)])
box((70,920,1020,1150),'⑤ 第一次比对｜手机号关联公司账号',[
    '四端 → 公司后台登录接口：验证手机号、确定用户 ID',
    '会员明文手机号 ＝ 公司账号已验证手机号',
    '确认授权且无冲突 → 绑定公司用户 ID 与抖店会员',
    '仅有密文：暂不匹配；按平台规则补查'
], '#3971c6')
arrow([(1620,880),(1620,1185),(1080,1185),(1080,1220)])
arrow([(540,1150),(540,1185),(1080,1185),(1080,1220)])
box((270,1220,1890,1410),'⑥ 第二次比对｜OpenID 关联订单（公司后台内部执行）',[
    '限定同一店铺：订单.doudian_open_id ＝ 会员.open_id',
    '含义：两个字段的值完全相等，无需加密、解密或转换',
    '例如：ABC123 ＝ ABC123 → 确认该订单属于已关联的公司用户'
], '#7954af')
arrow([(1080,1410),(1080,1450)])
box((270,1450,1890,1640),'⑦ 匹配规则并发券｜公司后台内部执行',[
    '店铺＋订单商品 ID／SKU ID＋支付条件 → 匹配优惠券规则',
    '发券给公司用户 ID；记录来源订单／子订单＋规则，防止重复发券',
    '安卓／iOS／鸿蒙／微信小程序 → 调用公司优惠券接口，共用券数据'
], '#bd7630')
text(70,1675,'字段说明：店铺、手机号等为业务含义；实际参数及权限以获批接口文档为准。',25,'#607089')
text(70,1714,'官方依据：op.jinritemai.com/docs/guide-docs/210 ｜ 会员通－商家接入方案 3.0',25,'#607089')
im.save(OUT / 'douyin-member-flow.png')
