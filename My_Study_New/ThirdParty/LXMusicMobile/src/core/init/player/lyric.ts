import { init as initLyricPlayer, toggleTranslation, toggleRoma, play, pause, stop, setLyric, setPlaybackRate, setOffset } from '@/core/lyric'
import { updateSetting } from '@/core/common'
import { onDesktopLyricPositionChange, showDesktopLyric, onLyricLinePlay, showRemoteLyric } from '@/core/desktopLyric'
import playerState from '@/store/player/state'
import { updateNowPlayingTitles } from '@/plugins/player/utils'
import { setLastLyric } from '@/core/player/playInfo'
import { Platform } from 'react-native'
import { getLyricLineWindow, onLrcPlay, onLrcSet } from '@/plugins/lyric'
import settingState from '@/store/setting/state'
import { endLyricsActivity, setLyricsActivityTimeline, updateLyricsActivity } from '@/utils/nativeModules/lyricsActivity'
import { getPosition } from '@/plugins/player'

export const syncLockScreenLyricsActivity = async(line?: number, isPlaying = playerState.isPlay) => {
  if (Platform.OS !== 'ios') return 'unsupported' as const
  if (!settingState.setting['player.isShowLyricsActivity']) {
    endLyricsActivity()
    return 'inactive' as const
  }

  const musicInfo = playerState.musicInfo
  if (!musicInfo.id) {
    endLyricsActivity()
    return 'inactive' as const
  }

  const lyricWindow = getLyricLineWindow(line)
  const position = Number(await getPosition())
  if (!lyricWindow.currentLine) {
    lyricWindow.currentLine = musicInfo.lrc == null ? '歌词加载中…' : '纯音乐，请欣赏'
  }
  return updateLyricsActivity({
    songId: musicInfo.id,
    title: musicInfo.name || '未知歌曲',
    artist: musicInfo.singer || '未知歌手',
    ...lyricWindow,
    isPlaying,
    backgroundColor: settingState.setting['player.lyricsActivityBackgroundColor'] || '#17191F',
    foregroundColor: settingState.setting['player.lyricsActivityForegroundColor'] || '#62D8FF',
    position: Number.isFinite(position) ? position : playerState.progress.nowPlayTime,
    playbackRate: settingState.setting['player.playbackRate'],
  })
}

const getSongDescription = () => `${playerState.musicInfo.name}${playerState.musicInfo.singer ? ` - ${playerState.musicInfo.singer}` : ''}`
const getLyricSubtitle = (nextLrc?: string) => nextLrc?.trim() ? nextLrc : getSongDescription()

const updateRemoteLyric = async(lrc?: string, nextLrc?: string) => {
  setLastLyric(lrc)
  if (lrc == null) {
    void updateNowPlayingTitles({
      title: playerState.musicInfo.name,
      artist: playerState.musicInfo.singer ?? '',
      album: playerState.musicInfo.album ?? '',
    })
  } else {
    void updateNowPlayingTitles({
      title: lrc,
      // iOS 锁屏媒体卡片用标题和副标题同时展示当前、下一句歌词；
      // 末句没有下一句时回退歌曲信息，避免副标题留空。
      artist: Platform.OS === 'ios' ? getLyricSubtitle(nextLrc) : getSongDescription(),
      album: playerState.musicInfo.album ?? '',
    })
  }
}

export default async(setting: LX.AppSetting) => {
  await initLyricPlayer()
  await Promise.all([
    setPlaybackRate(setting['player.playbackRate']),
    setOffset(setting['player.lyricOffset']),
    toggleTranslation(setting['player.isShowLyricTranslation']),
    toggleRoma(setting['player.isShowLyricRoma']),
  ])

  if (Platform.OS === 'android' && setting['desktopLyric.enable']) {
    showDesktopLyric().catch(() => {
      updateSetting({ 'desktopLyric.enable': false })
    })
  }
  if (setting['player.isShowBluetoothLyric']) {
    showRemoteLyric(true).catch(() => {
      updateSetting({ 'player.isShowBluetoothLyric': false })
    })
  }
  if (Platform.OS === 'android') {
    onDesktopLyricPositionChange(position => {
      updateSetting({
        'desktopLyric.position.x': position.x,
        'desktopLyric.position.y': position.y,
      })
    })
  }
  let lastUpdatedLineKey = ''
  const updateLine = (line: number, text: string) => {
    const lineKey = `${playerState.musicInfo.id ?? ''}:${line}:${text}`
    if (lineKey == lastUpdatedLineKey) return
    lastUpdatedLineKey = lineKey
    if (settingState.setting['player.isShowBluetoothLyric']) {
      if (!text && !playerState.isPlay) {
        void updateRemoteLyric()
      } else {
        const nextLine = Platform.OS === 'ios' ? getLyricLineWindow(line).nextLine : undefined
        void updateRemoteLyric(text, nextLine)
      }
    }
    if (settingState.setting['player.isShowLyricsActivity']) void syncLockScreenLyricsActivity(line)
  }
  if (Platform.OS === 'android') onLyricLinePlay(({ text }) => { updateLine(-1, text) })
  else onLrcPlay((line, text) => { updateLine(line, text) })
  if (Platform.OS === 'ios') {
    onLrcSet(lines => {
      const songId = playerState.musicInfo.id
      if (!songId) return
      setLyricsActivityTimeline(
        songId,
        lines.map(({ time, text }) => ({ time, text })),
        100 + settingState.setting['player.lyricOffset'],
      )
      if (settingState.setting['player.isShowLyricsActivity']) void syncLockScreenLyricsActivity()
    })
  }


  global.app_event.on('play', play)
  global.app_event.on('play', () => { void syncLockScreenLyricsActivity(undefined, true) })
  global.app_event.on('pause', pause)
  global.app_event.on('pause', () => { void syncLockScreenLyricsActivity(undefined, false) })
  global.app_event.on('stop', stop)
  global.app_event.on('stop', endLyricsActivity)
  global.app_event.on('error', pause)
  global.app_event.on('error', () => { void syncLockScreenLyricsActivity(undefined, false) })
  // 切歌时复用同一个实时活动，避免结束与新建之间出现闪烁或异步竞态。
  global.app_event.on('musicToggled', stop)
  global.app_event.on('lyricUpdated', setLyric)
}
