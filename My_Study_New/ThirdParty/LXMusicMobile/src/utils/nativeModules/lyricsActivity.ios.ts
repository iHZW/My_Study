import { NativeModules } from 'react-native'

export interface LyricsActivityPayload {
  songId: string
  title: string
  artist: string
  previousLine: string
  currentLine: string
  nextLine: string
  isPlaying: boolean
  backgroundColor: string
  foregroundColor: string
  position: number
  playbackRate: number
}

export interface LyricsActivityTimelineLine {
  time: number
  text: string
}

export type LyricsActivityUpdateStatus = 'started' | 'updated' | 'inactive' | 'unsupported' | 'disabled' | 'moduleUnavailable' | 'failed'
export type LyricsActivityAuthorizationStatus = 'enabled' | 'disabled' | 'unsupported' | 'moduleUnavailable'

interface LyricsActivityBridge {
  startOrUpdate: (
    songId: string,
    title: string,
    artist: string,
    previousLine: string,
    currentLine: string,
    nextLine: string,
    isPlaying: boolean,
    backgroundColor: string,
    foregroundColor: string,
    position: number,
    playbackRate: number,
  ) => Promise<Exclude<LyricsActivityUpdateStatus, 'moduleUnavailable' | 'failed'>>
  setTimeline: (songId: string, lines: LyricsActivityTimelineLine[], offset: number) => void
  getAuthorizationStatus: () => Promise<Exclude<LyricsActivityAuthorizationStatus, 'moduleUnavailable'>>
  end: () => void
}

const bridge = NativeModules.LXLyricsActivityModule as LyricsActivityBridge | undefined

export const updateLyricsActivity = async(payload: LyricsActivityPayload): Promise<LyricsActivityUpdateStatus> => {
  if (!bridge) return 'moduleUnavailable'
  try {
    return await bridge.startOrUpdate(
      payload.songId,
      payload.title,
      payload.artist,
      payload.previousLine,
      payload.currentLine,
      payload.nextLine,
      payload.isPlaying,
      payload.backgroundColor,
      payload.foregroundColor,
      payload.position,
      payload.playbackRate,
    )
  } catch (error) {
    console.warn('[锁屏歌词] 创建实时活动失败', error)
    return 'failed'
  }
}

export const setLyricsActivityTimeline = (songId: string, lines: LyricsActivityTimelineLine[], offset: number) => {
  bridge?.setTimeline(songId, lines, offset)
}

export const getLyricsActivityAuthorizationStatus = async(): Promise<LyricsActivityAuthorizationStatus> => {
  if (!bridge) return 'moduleUnavailable'
  return bridge.getAuthorizationStatus()
}

export const endLyricsActivity = () => {
  bridge?.end()
}
