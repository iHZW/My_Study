import { NativeModules } from 'react-native'
import { temporaryDirectoryPath, readDir, extname } from '@/utils/fs'
import type { MusicMetadata, MusicMetadataFull } from 'react-native-local-media-metadata'

export type { MusicMetadata, MusicMetadataFull }

interface MetadataBridge {
  readMetadata: (path: string) => Promise<MusicMetadataFull | null>
  writeMetadata: (path: string, data: MusicMetadata, overwrite: boolean) => Promise<void>
  readPic: (path: string, directory: string) => Promise<string>
  writePic: (path: string, picture: string) => Promise<void>
  readLyric: (path: string, readFile: boolean) => Promise<string>
  writeLyric: (path: string, lyric: string) => Promise<void>
}

const bridge = NativeModules.LXMediaMetadataModule as MetadataBridge
const pictureCachePath = temporaryDirectoryPath + '/local-media-metadata'

export const readMetadata = async(path: string) => bridge.readMetadata(path)
export const writeMetadata = async(path: string, data: MusicMetadata, overwrite = false) =>
  bridge.writeMetadata(path, data, overwrite)
export const readPic = async(path: string) => bridge.readPic(path, pictureCachePath)
export const writePic = async(path: string, picture: string) => bridge.writePic(path, picture)
export const readLyric = async(path: string, readFile = true) => bridge.readLyric(path, readFile)
export const writeLyric = async(path: string, lyric: string) => bridge.writeLyric(path, lyric)

export const scanAudioFiles = async(directory: string) => {
  const files = await readDir(directory)
  return files.filter(file => file.mimeType?.startsWith('audio/') || extname(file.name) === 'ogg')
}
