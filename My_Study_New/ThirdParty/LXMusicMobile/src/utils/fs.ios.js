import RNFS from 'react-native-fs'
import { NativeModules } from 'react-native'
import { Buffer } from '@craftzdog/react-native-buffer'
import { gzip, ungzip } from 'pako'

// iOS 只能访问应用沙箱及用户明确导入的文件；路径统一使用 Documents。
const documentPath = RNFS.DocumentDirectoryPath
const audioTypes = {
  mp3: 'audio/mpeg',
  m4a: 'audio/mp4',
  aac: 'audio/aac',
  flac: 'audio/flac',
  wav: 'audio/wav',
  ogg: 'audio/ogg',
}
export const temporaryDirectoryPath = RNFS.CachesDirectoryPath
export const externalStorageDirectoryPath = documentPath
export const privateStorageDirectoryPath = documentPath

export const extname = name => name.lastIndexOf('.') > 0 ? name.substring(name.lastIndexOf('.') + 1) : ''

const describe = (item, fallbackPath = '') => {
  const path = item.path || item.originalFilepath || fallbackPath
  const name = item.name || path.substring(path.lastIndexOf('/') + 1)
  return {
    name,
    path,
    isDirectory: item.isDirectory(),
    isFile: item.isFile(),
    lastModified: item.mtime ? new Date(item.mtime).getTime() : 0,
    canRead: true,
    data: '',
    mimeType: audioTypes[extname(name).toLowerCase()] || '',
    size: Number(item.size || 0),
  }
}

export const getExternalStoragePaths = async() => [documentPath]
export const getManagedFolders = async() => [documentPath]
export const getPersistedUriList = getManagedFolders
export const removeManagedFolder = async() => false
export const selectManagedFolder = async() => stat(documentPath)

export const selectFile = async(options = {}) => {
  const selected = await NativeModules.LXDocumentPickerModule.pickFile(!!options.multi)
  const file = await stat(selected.path)
  if (options.toPath) {
    await RNFS.mkdir(options.toPath)
    const target = `${options.toPath}/${file.name}`
    if (await RNFS.exists(target)) await RNFS.unlink(target)
    await RNFS.copyFile(file.path, target)
    return { ...(await stat(target)), data: target }
  }
  return { ...file, data: await readFile(file.path, options.encoding || 'utf8') }
}

export const readDir = async path => (await RNFS.readDir(path)).map(describe)
export const existsFile = path => RNFS.exists(path)
export const stat = async path => describe(await RNFS.stat(path), path)
export const hash = (path, algorithm = 'md5') => RNFS.hash(path, algorithm)
export const readFile = (path, encoding = 'utf8') => RNFS.readFile(path, encoding)
export const writeFile = (path, data, encoding = 'utf8') => RNFS.writeFile(path, data, encoding)
export const appendFile = (path, data, encoding = 'utf8') => RNFS.appendFile(path, data, encoding)

export const unlink = async path => {
  if (!(await RNFS.exists(path))) return false
  await RNFS.unlink(path)
  return true
}
export const mkdir = async path => {
  await RNFS.mkdir(path)
  return stat(path)
}
export const moveFile = async(fromPath, toPath) => {
  await RNFS.moveFile(fromPath, toPath)
  return true
}
export const rename = async(path, name) => {
  const parent = path.substring(0, path.lastIndexOf('/'))
  await RNFS.moveFile(path, `${parent}/${name}`)
  return true
}

export const gzipString = async(data, encoding = 'utf8') => {
  const input = encoding === 'base64' ? Buffer.from(data, 'base64') : Buffer.from(data, 'utf8')
  return Buffer.from(gzip(input)).toString('base64')
}
export const unGzipString = async(data, encoding = 'utf8') => {
  const output = Buffer.from(ungzip(Buffer.from(data, 'base64')))
  return output.toString(encoding === 'base64' ? 'base64' : 'utf8')
}
export const gzipFile = async(fromPath, toPath) => {
  const content = await readFile(fromPath, 'base64')
  await writeFile(toPath, await gzipString(content, 'base64'), 'base64')
}
export const unGzipFile = async(fromPath, toPath) => {
  const content = await readFile(fromPath, 'base64')
  await writeFile(toPath, await unGzipString(content, 'base64'), 'base64')
}

export const downloadFile = (url, path, options = {}) => RNFS.downloadFile({
  fromUrl: url,
  toFile: path,
  headers: options.headers || {
    'User-Agent': 'Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X) AppleWebKit/605.1.15 Mobile/15E148',
  },
  ...options,
})
export const stopDownload = jobId => RNFS.stopDownload(jobId)
