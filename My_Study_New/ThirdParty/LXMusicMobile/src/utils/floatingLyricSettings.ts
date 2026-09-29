import { getData, saveData } from '@/plugins/storage'

export interface FloatingLyricSettings {
  backgroundColor: string
  backgroundOpacity: number
  textColor: string
  textOpacity: number
  fontSize: number
}

export const DEFAULT_FLOATING_LYRIC_SETTINGS: FloatingLyricSettings = {
  backgroundColor: '#14191E',
  backgroundOpacity: 0.82,
  textColor: '#FFFFFF',
  textOpacity: 1,
  fontSize: 16,
}

const STORAGE_KEY = 'floatingLyricSettings'

export const getFloatingLyricSettings = async(): Promise<FloatingLyricSettings> => {
  const value = await getData<Partial<FloatingLyricSettings>>(STORAGE_KEY)
  return { ...DEFAULT_FLOATING_LYRIC_SETTINGS, ...value }
}

export const saveFloatingLyricSettings = async(settings: FloatingLyricSettings) => {
  await saveData(STORAGE_KEY, settings)
}
