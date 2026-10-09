import TrackPlayer, { State } from 'react-native-track-player'
import BackgroundTimer from 'react-native-background-timer'
import { defaultUrl } from '@/config'
// import { action as playerAction } from '@/store/modules/player'
import settingState from '@/store/setting/state'
import playerState from '@/store/player/state'


const list: LX.Player.Track[] = []

const defaultUserAgent = 'Mozilla/5.0 (Linux; Android 10; Pixel 3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/79.0.3945.79 Mobile Safari/537.36'
const streamHeaders = {
  // Android 原生播放器识别 userAgent 字段；iOS 的 AVURLAsset 只读取 headers。
  // 两端同时保留，避免部分音源因缺少 UA 直接返回 403 后不断切歌。
  'User-Agent': defaultUserAgent,
  Accept: '*/*',
  'Accept-Encoding': 'identity',
}
const httpRxp = /^(https?:\/\/.+|\/.+)/

export const state = {
  isPlaying: false,
  prevDuration: -1,
}

const formatMusicInfo = (musicInfo: LX.Player.PlayMusic) => {
  return 'progress' in musicInfo ? {
    id: musicInfo.id,
    pic: musicInfo.metadata.musicInfo.meta.picUrl,
    name: musicInfo.metadata.musicInfo.name,
    singer: musicInfo.metadata.musicInfo.singer,
    album: musicInfo.metadata.musicInfo.meta.albumName,
  } : {
    id: musicInfo.id,
    pic: musicInfo.meta.picUrl,
    name: musicInfo.name,
    singer: musicInfo.singer,
    album: musicInfo.meta.albumName,
  }
}

const getCurrentFullLyric = (targetId: string | null) => {
  return (settingState.setting['player.isShowBluetoothFullLyric'] && targetId &&
      playerState.musicInfo.id == targetId && playerState.musicInfo.lrc)
    ? playerState.musicInfo.lrc
    : undefined
}

const buildTracks = (musicInfo: LX.Player.PlayMusic, url?: LX.Player.Track['url'], duration?: LX.Player.Track['duration']): LX.Player.Track[] => {
  const mInfo = formatMusicInfo(musicInfo)
  const track = [] as LX.Player.Track[]
  const isShowNotificationImage = settingState.setting['player.isShowNotificationImage']
  const album = mInfo.album || undefined
  const artwork = isShowNotificationImage && mInfo.pic && httpRxp.test(mInfo.pic) ? mInfo.pic : undefined
  const lyric = getCurrentFullLyric(mInfo.id)
  if (url) {
    track.push({
      id: `${mInfo.id}__//${Math.random()}__//${url}`,
      url,
      title: mInfo.name || 'Unknow',
      artist: mInfo.singer || 'Unknow',
      album,
      artwork,
      userAgent: defaultUserAgent,
      headers: streamHeaders,
      musicId: mInfo.id,
      lyric,
      // original: { ...musicInfo },
      duration,
    })
  }
  track.push({
    id: `${mInfo.id}__//${Math.random()}__//default`,
    url: defaultUrl,
    title: mInfo.name || 'Unknow',
    artist: mInfo.singer || 'Unknow',
    album,
    artwork,
    musicId: mInfo.id,
    lyric,
    // original: { ...musicInfo },
    duration: 0,
  })
  return track
  // console.log('buildTrack', musicInfo.name, url)
}
// const buildTrack = (musicInfo: LX.Player.PlayMusic, url: LX.Player.Track['url'], duration?: LX.Player.Track['duration']): LX.Player.Track => {
//   const mInfo = formatMusicInfo(musicInfo)
//   const isShowNotificationImage = settingState.setting['player.isShowNotificationImage']
//   const album = mInfo.album || undefined
//   const artwork = isShowNotificationImage && mInfo.pic && httpRxp.test(mInfo.pic) ? mInfo.pic : undefined
//   return url
//     ? {
//         id: `${mInfo.id}__//${Math.random()}__//${url}`,
//         url,
//         title: mInfo.name || 'Unknow',
//         artist: mInfo.singer || 'Unknow',
//         album,
//         artwork,
//         userAgent: defaultUserAgent,
//         musicId: `${mInfo.id}`,
//         original: { ...musicInfo },
//         duration,
//       }
//     : {
//         id: `${mInfo.id}__//${Math.random()}__//default`,
//         url: defaultUrl,
//         title: mInfo.name || 'Unknow',
//         artist: mInfo.singer || 'Unknow',
//         album,
//         artwork,
//         musicId: `${mInfo.id}`,
//         original: { ...musicInfo },
//         duration: 0,
//       }
// }

export const isTempTrack = (trackId: string) => /\/\/default$/.test(trackId)


export const getCurrentTrackId = async() => {
  const currentTrackIndex = await TrackPlayer.getCurrentTrack()
  if (currentTrackIndex == null) return
  return (await TrackPlayer.getTrack(currentTrackIndex))?.id
}
export const getCurrentTrack = async() => {
  const currentTrackIndex = await TrackPlayer.getCurrentTrack()
  if (currentTrackIndex == null) return
  return await TrackPlayer.getTrack(currentTrackIndex) as LX.Player.Track | null
}

/**
 * 获取原生播放轨道对应的业务歌曲 ID。
 *
 * 部分 iOS 桥接场景不会稳定回传自定义的 musicId 字段，但轨道 id 的第一段
 * 始终是歌曲 ID，因此保留轨道 id 作为可靠兜底，避免误判后清空锁屏信息。
 */
const getTrackMusicId = (track?: LX.Player.Track | null) => {
  if (!track) return
  if (track.musicId != null) return String(track.musicId)
  if (typeof track.id !== 'string') return
  return track.id.split('__//', 1)[0]
}

export const updateMetaData = async(musicInfo: LX.Player.MusicInfo, isPlay: boolean, force = false) => {
  if (!force && isPlay == state.isPlaying) {
    const duration = await TrackPlayer.getDuration()
    if (state.prevDuration != duration) {
      state.prevDuration = duration
      const trackInfo = await getCurrentTrack()
      if (trackInfo && musicInfo) {
        delayUpdateMusicInfo(musicInfo)
      }
    }
  } else {
    const [duration, trackInfo] = await Promise.all([TrackPlayer.getDuration(), getCurrentTrack()])
    state.prevDuration = duration
    if (trackInfo && musicInfo) {
      delayUpdateMusicInfo(musicInfo)
    }
  }
}

export const initTrackInfo = async(musicInfo: LX.Player.PlayMusic, mInfo: LX.Player.MusicInfo) => {
  const tracks = buildTracks(musicInfo)
  await TrackPlayer.add(tracks).then(() => list.push(...tracks))
  const queue = await TrackPlayer.getQueue() as LX.Player.Track[]
  await TrackPlayer.skip(queue.findIndex(t => t.id == tracks[0].id))
  delayUpdateMusicInfo(mInfo)
}

/**
 * 启动当前曲目，并由业务层确认播放已开始。
 *
 * iOS 快速切歌时，原生 Playing 事件可能早于曲目切换事件到达，导致它因
 * 临时轨判断而被忽略。仅依赖该事件会让音频正常播放，但进度与歌词轮询
 * 没有启动。TrackPlayer.play() 成功返回后主动同步一次，消除事件先后竞态。
 */
const playCurrentTrack = async() => {
  await TrackPlayer.play()
  global.app_event.playerPlaying()
  global.app_event.play()
}


const handlePlayMusic = async(musicInfo: LX.Player.PlayMusic, url: string, time: number) => {
// console.log(tracks, time)
  const tracks = buildTracks(musicInfo, url)
  const track = tracks[0]
  // await updateMusicInfo(track)
  const currentTrackIndex = await TrackPlayer.getCurrentTrack()
  await TrackPlayer.add(tracks).then(() => list.push(...tracks))
  const queue = await TrackPlayer.getQueue() as LX.Player.Track[]
  await TrackPlayer.skip(queue.findIndex(t => t.id == track.id))

  if (currentTrackIndex == null) {
    if (!isTempTrack(track.id as string)) {
      if (time) await TrackPlayer.seekTo(time)
      if (global.lx.restorePlayInfo) {
        await TrackPlayer.pause()
        // let startupAutoPlay = settingState.setting['player.startupAutoPlay']
        global.lx.restorePlayInfo = null

      // TODO startupAutoPlay
      // if (startupAutoPlay) store.dispatch(playerAction.playMusic())
      } else {
        await playCurrentTrack()
      }
    }
  } else {
    await TrackPlayer.pause()
    if (!isTempTrack(track.id as string)) {
      await TrackPlayer.seekTo(time)
      await playCurrentTrack()
    }
  }

  if (queue.length > 2) {
    void TrackPlayer.remove(Array(queue.length - 2).fill(null).map((_, i) => i)).then(() => list.splice(0, list.length - 2))
  }
}
let playPromise = Promise.resolve()
let actionId = Math.random()
export const playMusic = (musicInfo: LX.Player.PlayMusic, url: string, time: number, onApplied?: () => void) => {
  const id = actionId = Math.random()
  void playPromise.finally(() => {
    if (id != actionId) return
    playPromise = handlePlayMusic(musicInfo, url, time).finally(onApplied)
  })
}

// let musicId = null
// let duration = 0
const updateMetaInfo = async(mInfo: LX.Player.MusicInfo) => {
  const isShowNotificationImage = settingState.setting['player.isShowNotificationImage']
  // const mInfo = formatMusicInfo(musicInfo)
  // console.log('+++++updateMusicPic+++++', track.artwork, track.duration)

  // if (track.musicId == musicId) {
  //   if (global.playInfo.musicInfo.img != null) artwork = global.playInfo.musicInfo.img
  //   if (track.duration != null) duration = global.playInfo.duration
  // } else {
  //   musicId = track.musicId
  //   artwork = global.playInfo.musicInfo.img
  //   duration = global.playInfo.duration || 0
  // }
  // console.log('+++++updateMetaInfo+++++', mInfo.name)
  const [playerStatus, duration, currentTrackIndex] = await Promise.all([
    TrackPlayer.getState(),
    TrackPlayer.getDuration(),
    TrackPlayer.getCurrentTrack(),
  ])
  if (currentTrackIndex == null) return
  const currentTrack = await TrackPlayer.getTrack(currentTrackIndex) as LX.Player.Track | null
  // 快速切歌时旧歌曲的异步更新可能晚到；只允许当前原生轨道写入锁屏信息。
  if (getTrackMusicId(currentTrack) !== String(mInfo.id)) return
  state.isPlaying = playerStatus == State.Playing
  state.prevDuration = duration
  const artwork = isShowNotificationImage ? mInfo.pic ?? undefined : undefined
  let title: string
  let artist: string
  if (playerState.lastLyric == null) {
    title = mInfo.name ?? 'Unknow'
    artist = mInfo.singer ?? 'Unknow'
  } else {
    title = playerState.lastLyric
    artist = `${mInfo.name}${mInfo.singer ? ` - ${mInfo.singer}` : ''}`
  }
  // 直接更新当前原生轨道：系统会把轨道元数据同步到锁屏媒体卡。
  // 不再先清空 MPNowPlayingInfoCenter，避免原生异步清空覆盖随后写入的数据。
  const verifiedTrackIndex = await TrackPlayer.getCurrentTrack()
  if (verifiedTrackIndex == null || verifiedTrackIndex !== currentTrackIndex) return
  const verifiedTrack = await TrackPlayer.getTrack(verifiedTrackIndex) as LX.Player.Track | null
  if (getTrackMusicId(verifiedTrack) !== String(mInfo.id)) return
  await TrackPlayer.updateMetadataForTrack(verifiedTrackIndex, {
    title,
    artist,
    album: mInfo.album ?? undefined,
    artwork,
    duration: duration || 0,
    lyric: getCurrentFullLyric(mInfo.id),
  })
}


// 解决快速切歌导致的通知栏歌曲信息与当前播放歌曲对不上的问题
const debounceUpdateMetaInfoTools = {
  updateMetaPromise: Promise.resolve(),
  musicInfo: null as LX.Player.MusicInfo | null,
  debounce(fn: (musicInfo: LX.Player.MusicInfo) => void | Promise<void>) {
    // let delayTimer = null
    let isDelayRun = false
    let timer: number | null = null
    let _musicInfo: LX.Player.MusicInfo | null = null
    return (musicInfo: LX.Player.MusicInfo) => {
      // console.log('debounceUpdateMetaInfoTools', musicInfo)
      if (timer) {
        BackgroundTimer.clearTimeout(timer)
        timer = null
      }
      // if (delayTimer) {
      //   BackgroundTimer.clearTimeout(delayTimer)
      //   delayTimer = null
      // }
      if (isDelayRun) {
        _musicInfo = musicInfo
        timer = BackgroundTimer.setTimeout(() => {
          timer = null
          let musicInfo = _musicInfo
          _musicInfo = null
          if (!musicInfo) return
          // isDelayRun = false
          void fn(musicInfo)
        }, 500)
      } else {
        isDelayRun = true
        void fn(musicInfo)
        BackgroundTimer.setTimeout(() => {
          // delayTimer = null
          isDelayRun = false
        }, 500)
      }
    }
  },
  init() {
    return this.debounce(async(musicInfo: LX.Player.MusicInfo) => {
      this.musicInfo = musicInfo
      return this.updateMetaPromise.then(() => {
        // console.log('run')
        if (this.musicInfo?.id === musicInfo.id) {
          this.updateMetaPromise = updateMetaInfo(musicInfo)
        }
      })
    })
  },
}

export const delayUpdateMusicInfo = debounceUpdateMetaInfoTools.init()

// export const delayUpdateMusicInfo = ((fn, delay = 800) => {
//   let delayTimer = null
//   let isDelayRun = false
//   let timer = null
//   let _track = null
//   return track => {
//     _track = track
//     if (timer) {
//       BackgroundTimer.clearTimeout(timer)
//       timer = null
//     }
//     if (isDelayRun) {
//       if (delayTimer) {
//         BackgroundTimer.clearTimeout(delayTimer)
//         delayTimer = null
//       }
//       timer = BackgroundTimer.setTimeout(() => {
//         timer = null
//         let track = _track
//         _track = null
//         isDelayRun = false
//         fn(track)
//       }, delay)
//     } else {
//       isDelayRun = true
//       fn(track)
//       delayTimer = BackgroundTimer.setTimeout(() => {
//         delayTimer = null
//         isDelayRun = false
//       }, 500)
//     }
//   }
// })(track => {
//   console.log('+++++delayUpdateMusicPic+++++', track.artwork)
//   updateMetaInfo(track)
// })
