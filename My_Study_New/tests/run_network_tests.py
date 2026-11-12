"""使用真实 AFNetworking 和本地 URLProtocol 验证传输层；不访问外部服务。"""
from pathlib import Path
import subprocess
import tempfile

root = Path(__file__).resolve().parents[1]
af = root / "Pods/AFNetworking/AFNetworking"
transport = root / "My_Study/Business/Common/Http/Transport"
logs = root / "My_Study/Business/Common/DoKitPlugin/ZWLog"
with tempfile.TemporaryDirectory(prefix="my-study-network-") as directory:
    executable = Path(directory) / "network-tests"
    command = ["xcrun", "clang", "-fobjc-arc", "-fblocks", "-Wno-deprecated-declarations"]
    for framework in ["Foundation", "AppKit", "Security", "SystemConfiguration", "CoreServices"]:
        command += ["-framework", framework]
    for folder in [af.parent, af, transport, logs]:
        command += ["-I", str(folder)]
    command += [str(root / "tests/ZWNetworkTransportTests.m"), str(transport / "ZWNetworkTransport.m"), str(logs / "ZWDokitLog.m")]
    command += [str(path) for path in sorted(af.glob("*.m"))]
    command += ["-o", str(executable)]
    subprocess.run(command, check=True, timeout=40)
    subprocess.run([str(executable)], check=True, timeout=10)
