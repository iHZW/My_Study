"""检查业务页面是否绕过统一 Router 直接调用 UIKit 的页面打开方法。"""
from pathlib import Path
import re

root = Path(__file__).resolve().parents[1] / "My_Study"
lexemes = re.compile(r"//[^\n]*|/\*[\s\S]*?\*/|@?\"(?:\\[\s\S]|[^\"\\])*\"|'(?:\\[\s\S]|[^'\\])*'|[A-Za-z_][A-Za-z_0-9]*|[^\s]")
violations = []
count = 0
for file in root.rglob("*.m"):
    if file.name == "RouterCoordinator.m":
        continue
    source = file.read_text()
    tokens = [token for token in lexemes.finditer(source)
              if not token.group().startswith(("//", "/*", '"', '@"', "'"))]
    stack = []
    for index, token in enumerate(tokens):
        if token.group() == "[":
            stack.append(index)
        elif token.group() == "]" and stack:
            start = stack.pop()
            depth = parens = braces = 0
            selectors = []
            for position in range(start + 1, index):
                word = tokens[position].group()
                if word == "[": depth += 1
                elif word == "]": depth -= 1
                elif word == "(": parens += 1
                elif word == ")": parens -= 1
                elif word == "{": braces += 1
                elif word == "}": braces -= 1
                elif depth == parens == braces == 0 and position + 1 < index and tokens[position + 1].group() == ":":
                    selectors.append(position)
            names = [tokens[position].group() for position in selectors]
            if names not in (["pushViewController", "animated"], ["presentViewController", "animated", "completion"]):
                continue
            receiver = source[tokens[start].end():tokens[selectors[0]].start()].strip()
            if receiver == "super":
                continue
            violations.append(f"{file.relative_to(root)}:{source.count(chr(10), 0, token.start()) + 1}")
    count += 1
if violations:
    raise SystemExit("发现绕过 Router 的页面打开调用：\n" + "\n".join(violations))
print(f"路由入口检查通过：扫描 {count} 个实现文件，无直接 UIKit 页面打开调用。")
