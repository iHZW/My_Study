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

export interface LyricsActivityTimelineLine { time: number, text: string }

export type LyricsActivityUpdateStatus = 'started' | 'updated' | 'inactive' | 'unsupported' | 'disabled' | 'moduleUnavailable' | 'failed'
export type LyricsActivityAuthorizationStatus = 'enabled' | 'disabled' | 'unsupported' | 'moduleUnavailable'

export const updateLyricsActivity = async(_payload: LyricsActivityPayload): Promise<LyricsActivityUpdateStatus> => 'unsupported'

export const setLyricsActivityTimeline = (_songId: string, _lines: LyricsActivityTimelineLine[], _offset: number) => {}

export const getLyricsActivityAuthorizationStatus = async(): Promise<LyricsActivityAuthorizationStatus> => 'unsupported'

export const endLyricsActivity = () => {}
