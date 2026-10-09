import { useCallback } from 'react'
import { TouchableOpacity, View } from 'react-native'
import Text from '@/components/common/Text'
import { useTheme } from '@/store/theme/hook'
import { useSettingValue } from '@/store/setting/hook'
import { updateSetting } from '@/core/common'
import { setOffset } from '@/core/lyric'
import { createStyle } from '@/utils/tools'

const STEP = 250
const MAX_OFFSET = 5000

const clampOffset = (value: number) => Math.max(-MAX_OFFSET, Math.min(MAX_OFFSET, value))

export default () => {
  const theme = useTheme()
  const offset = useSettingValue('player.lyricOffset')

  const applyOffset = useCallback((nextOffset: number) => {
    const value = clampOffset(Math.round(nextOffset / STEP) * STEP)
    updateSetting({ 'player.lyricOffset': value })
    void setOffset(value)
  }, [])

  const label = offset === 0
    ? '同步 0.00s'
    : `${offset > 0 ? '提前' : '延后'} ${(Math.abs(offset) / 1000).toFixed(2)}s`

  return (
    <View pointerEvents="box-none" style={styles.wrapper}>
      <View style={{ ...styles.container, backgroundColor: theme['c-primary-alpha-700'] }}>
        <TouchableOpacity
          accessibilityRole="button"
          accessibilityLabel="歌词延后四分之一秒"
          style={styles.button}
          onPress={() => { applyOffset(offset - STEP) }}>
          <Text color={theme['c-primary-font']} size={12}>延后</Text>
        </TouchableOpacity>
        <TouchableOpacity
          accessibilityRole="button"
          accessibilityLabel="歌词偏移归零"
          style={styles.value}
          onPress={() => { applyOffset(0) }}>
          <Text color={theme['c-primary-font']} size={12}>{label}</Text>
        </TouchableOpacity>
        <TouchableOpacity
          accessibilityRole="button"
          accessibilityLabel="歌词提前四分之一秒"
          style={styles.button}
          onPress={() => { applyOffset(offset + STEP) }}>
          <Text color={theme['c-primary-font']} size={12}>提前</Text>
        </TouchableOpacity>
      </View>
    </View>
  )
}

const styles = createStyle({
  wrapper: {
    position: 'absolute',
    left: 0,
    right: 0,
    bottom: 12,
    alignItems: 'center',
  },
  container: {
    minHeight: 36,
    borderRadius: 18,
    paddingHorizontal: 4,
    flexDirection: 'row',
    alignItems: 'center',
  },
  button: {
    minWidth: 52,
    minHeight: 36,
    paddingHorizontal: 10,
    alignItems: 'center',
    justifyContent: 'center',
  },
  value: {
    minWidth: 92,
    minHeight: 36,
    paddingHorizontal: 8,
    alignItems: 'center',
    justifyContent: 'center',
  },
})
