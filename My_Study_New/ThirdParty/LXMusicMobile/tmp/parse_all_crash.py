import json, glob, os

files = sorted(glob.glob('/tmp/lx_crash/LxMusicMobile-*.ips'))
print(f'共 {len(files)} 个 crash 日志\n')

for f in files:
    with open(f) as fp:
        content = fp.read()
    # ips 文件第一行是 metadata json，后面是主体 json
    nl = content.find('\n')
    try:
        data = json.loads(content[nl+1:])
    except Exception as e:
        print(f'{os.path.basename(f)}: 解析失败 {e}')
        continue

    name = os.path.basename(f)
    exc = data.get('exception', {})
    term = data.get('termination', {})
    ft = data.get('faultingThread', 0)
    threads = data.get('threads', [])
    images = data.get('usedImages', [])

    print(f'========== {name} ==========')
    print(f"  exception: {exc}")
    print(f"  termination: {term}")

    # 打印崩溃线程前 25 帧
    if ft < len(threads):
        t = threads[ft]
        print(f'  faultingThread={ft} name={t.get("name", "")} queue={t.get("queue", "")}')
        for i, frame in enumerate(t.get('frames', [])[:25]):
            idx = frame.get('imageIndex', 0)
            img = images[idx] if idx < len(images) else {}
            iname = img.get('name', '?')
            sym = frame.get('symbol', '')
            if sym:
                print(f'    {i:2d} {iname}  {sym} + {frame.get("symbolLocation", 0)}')
            else:
                print(f'    {i:2d} {iname}  0x{frame.get("imageOffset", 0):x}')
    # asi 信息
    asi = data.get('asi', {})
    if asi:
        print(f'  asi: {json.dumps(asi, ensure_ascii=False)[:500]}')
    print()
