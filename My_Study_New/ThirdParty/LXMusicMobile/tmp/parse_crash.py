import json

with open('/tmp/lx_crash/LxMusicMobile-2026-09-24-151812.ips') as f:
    lines = f.read().split('\n', 1)
    data = json.loads(lines[1])

print('=== exception ===')
print(json.dumps(data.get('exception'), indent=2, ensure_ascii=False))
print('=== asi ===')
print(json.dumps(data.get('asi'), indent=2, ensure_ascii=False))
print('=== termination ===')
print(json.dumps(data.get('termination'), indent=2, ensure_ascii=False))
print('=== vmRegionInfo ===')
print(data.get('vmRegionInfo'))
print('=== faultingThread ===')
print(data.get('faultingThread'))

images = data.get('usedImages', [])
threads = data.get('threads', [])
ft = data.get('faultingThread', 0)
if ft < len(threads):
    print(f'\n=== 崩溃线程 {ft} 调用栈 ===')
    for frame in threads[ft].get('frames', []):
        idx = frame.get('imageIndex', 0)
        img = images[idx] if idx < len(images) else {}
        name = img.get('name', '?')
        symbol = frame.get('symbol', '')
        offset = frame.get('imageOffset', 0)
        if symbol:
            print(f'  {name}  {symbol} + {frame.get("symbolLocation", 0)}')
        else:
            print(f'  {name}  0x{offset:x}')