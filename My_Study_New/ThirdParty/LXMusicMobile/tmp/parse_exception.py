import json

for f in ['/tmp/lx_crash/LxMusicMobile-2026-09-24-151812.ips',
          '/tmp/lx_crash/LxMusicMobile-2026-09-24-153549.ips']:
    print(f'########## {f} ##########')
    with open(f) as fp:
        content = fp.read()
    data = json.loads(content[content.find('\n')+1:])

    asi = data.get('asi', {})
    print('asi:', json.dumps(asi, ensure_ascii=False)[:2000])
    print()

    leb = data.get('lastExceptionBacktrace')
    images = data.get('usedImages', [])
    if leb:
        print('lastExceptionBacktrace:')
        for frame in leb:
            idx = frame.get('imageIndex', 0)
            img = images[idx] if idx < len(images) else {}
            name = img.get('name', '?')
            sym = frame.get('symbol', '')
            if sym:
                print(f'  {name}  {sym} + {frame.get("symbolLocation", 0)}')
            else:
                print(f'  {name}  0x{frame.get("imageOffset", 0):x}')
    print()

    # 崩溃线程完整栈
    ft = data.get('faultingThread', 0)
    threads = data.get('threads', [])
    if ft < len(threads):
        print(f'faulting thread {ft} 完整栈:')
        for i, frame in enumerate(threads[ft].get('frames', [])):
            idx = frame.get('imageIndex', 0)
            img = images[idx] if idx < len(images) else {}
            name = img.get('name', '?')
            sym = frame.get('symbol', '')
            if sym:
                print(f'  {i:2d} {name}  {sym} + {frame.get("symbolLocation", 0)}')
            else:
                print(f'  {i:2d} {name}  0x{frame.get("imageOffset", 0):x}')
    print()
