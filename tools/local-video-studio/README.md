# 本地视频工作室

在 Apple Silicon Mac 上用文字或首帧图生成短视频。选一张 PNG 或 JPEG、写清楚角色要做的动作，再选画幅、时长和是否生成声音。生成后可以直接预览 MP4。推理走本机 MLX，模型准备好以后可以离线运行，无需视频平台账号或按次付费。

## 启动与准备

需要 macOS 14 或更新版本、Apple Silicon、16 GB 或更多内存、Xcode 命令行工具。安装前请在数据盘上留出至少 32 GiB，供量化模型、文字编码器、依赖和视频导出使用。准备脚本仅下载当前生成模式所需的权重。模型权重适用各自的许可，详见 [LTX 模型仓库](https://huggingface.co/dgrauet/ltx-2.3-mlx-q4) 和 [Gemma 模型仓库](https://huggingface.co/mlx-community/gemma-3-12b-it-4bit)。

从此目录执行以下命令。第一行需要已有 Homebrew，安装的是免费依赖。第二行联网下载安装模型。如果已有合适的外置盘，修改示例中的目录并在两条命令中使用同一个目录。

```bash
brew install uv ffmpeg
bash prepare.sh "/Volumes/你的外置盘/视频工作室"
bash start.sh "/Volumes/你的外置盘/视频工作室"
```

磁盘空间充裕时，两条脚本也可省略目录参数，默认使用此目录下的 `.data`。首次模型下载失败后，可使用同一目录重跑准备脚本。准备完成前可以用 `bash start.sh` 查看界面，生成按钮会保持禁用。

## 第一次试做

用单张场景图作首帧，例如让橘百万和虎墩墩已经坐在桌旁、各拿一只杯子。竖屏选约 2 秒，先试一个动作：

> Two chubby cartoon animals, an orange cat in a red scarf and a tiger in a blue vest, gently clink their ceramic cups. The tiger smiles. Keep their clothes and faces unchanged. Static camera, warm lantern light.

生成结果和日志存放在数据目录的 `videos` 下，每次生成有独立目录。默认选用 LTX 2.3 的 4 位模型和低内存模式，先用低分辨率短镜头试出动作，再考虑更长镜头。16 GB M1 的生成用时与稳定性以实际试跑为准。

[本地 MLX 引擎及参数说明](https://github.com/dgrauet/ltx-2-mlx/tree/v0.18.0)
