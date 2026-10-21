"""生成宝宝时光离线音频。传统公版旋律与原创旋律均由本脚本合成演奏。"""
import array
import math
import wave
from pathlib import Path

DIRECTORY = Path(__file__).resolve().parents[1] / "My_Study" / "Business" / "BabyTime" / "Audio"
SAMPLE_RATE = 22050
SONGS = {
    "star": ([60, 60, 67, 67, 69, 69, 67, 65, 65, 64, 64, 62, 62, 60,
              67, 67, 65, 65, 64, 64, 62, 67, 67, 65, 65, 64, 64, 62,
              60, 60, 67, 67, 69, 69, 67, 65, 65, 64, 64, 62, 62, 60], 0.72),
    "river": ([60, 64, 67, 64, 62, 65, 69, 65, 64, 67, 72, 71, 69, 67, 64,
               62, 60, 64, 67, 72, 69, 67, 65, 64, 62, 65, 64, 62, 60, 60], 1.0),
    "cloud": ([60, 67, 64, 62, 60, 64, 65, 67, 69, 67, 64, 60, 62, 65,
               64, 62, 60, 64, 67, 72, 71, 67, 65, 64, 62, 64, 62, 60], 1.18),
    "morning": ([60, 64, 67, 72, 67, 64, 65, 69, 72, 69, 65, 64,
                 62, 65, 69, 74, 69, 65, 64, 67, 72, 67, 64, 60] * 2, 1.25),
    "breeze": ([64, 67, 71, 67, 64, 62, 65, 69, 65, 62, 60, 64,
                67, 64, 60, 59, 62, 65, 62, 59, 60, 64, 62, 60] * 2, 1.35),
    "waiting": ([60, 62, 64, 67, 64, 62, 60, 65, 67, 69, 67, 65,
                 64, 67, 72, 69, 67, 64, 62, 65, 64, 62, 60, 60] * 2, 1.4),
    "garden": ([60, 64, 67, 69, 67, 64, 62, 65, 69, 72, 69, 65,
                64, 67, 72, 71, 69, 67, 64, 62, 60, 64, 62, 60] * 3, 1.15),
    "sunset": ([57, 60, 64, 69, 67, 64, 60, 59, 62, 65, 69, 65,
                64, 62, 60, 57, 60, 64, 67, 65, 62, 60, 59, 57] * 3, 1.2),
    "firefly": ([64, 67, 72, 71, 67, 64, 65, 69, 72, 69, 65, 62,
                 64, 67, 71, 69, 67, 65, 64, 60, 62, 65, 64, 60] * 3, 1.12),
    "harbor": ([55, 60, 64, 67, 64, 60, 59, 62, 65, 69, 65, 62,
                60, 64, 67, 72, 69, 67, 64, 60, 59, 62, 60, 55] * 3, 1.22),
    "dandelion": ([62, 65, 69, 72, 69, 65, 64, 67, 71, 74, 71, 67,
                   65, 69, 72, 69, 67, 64, 62, 65, 64, 62, 60, 62] * 3, 1.1),
    "raindrop": ([60, 67, 65, 64, 62, 64, 67, 60, 62, 69, 67, 65,
                  64, 62, 60, 64, 67, 72, 69, 65, 64, 62, 60, 60] * 3, 1.18),
    "humming": ([60, 62, 65, 69, 65, 62, 60, 64, 67, 71, 67, 64,
                 62, 65, 69, 72, 69, 65, 64, 62, 60, 62, 60, 60] * 3, 1.16),
    "nightlight": ([57, 64, 62, 60, 57, 60, 64, 69, 67, 64, 62, 59,
                    57, 60, 65, 64, 62, 60, 59, 62, 60, 57, 57, 57] * 3, 1.2),
}


def render(notes, beat):
    frames = array.array("h", [0]) * int((len(notes) * beat + 2) * SAMPLE_RATE)
    for index, note in enumerate(notes):
        duration = beat * 1.6
        start = int((index * beat + 0.2) * SAMPLE_RATE)
        frequency = 440 * 2 ** ((note - 69) / 12)
        for offset in range(min(int(duration * SAMPLE_RATE), len(frames) - start)):
            seconds = offset / SAMPLE_RATE
            envelope = (1 - math.exp(-seconds * 45)) * math.exp(-seconds * 3.2)
            envelope *= min(1, (duration - seconds) * 12)
            tone = math.sin(2 * math.pi * frequency * seconds)
            tone += 0.16 * math.sin(4 * math.pi * frequency * seconds)
            frames[start + offset] = max(-32767, min(32767, frames[start + offset] + int(tone * envelope * 4700)))
    return frames


if __name__ == "__main__":
    DIRECTORY.mkdir(parents=True, exist_ok=True)
    for name, (notes, beat) in SONGS.items():
        with wave.open(str(DIRECTORY / f"baby_{name}.wav"), "wb") as output:
            output.setparams((1, 2, SAMPLE_RATE, 0, "NONE", "not compressed"))
            output.writeframes(render(notes, beat).tobytes())
        print(f"{name}: {len(notes) * beat:.1f} 秒")
