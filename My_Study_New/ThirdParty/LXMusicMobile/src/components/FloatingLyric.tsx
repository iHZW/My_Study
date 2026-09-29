import { useEffect, useMemo, useRef, useState } from 'react'
import { Animated, PanResponder, Pressable, StyleSheet, View } from 'react-native'
import { useLrcPlay, useLrcSet } from '@/plugins/lyric'
import { useTheme } from '@/store/theme/hook'
import { useWindowSize } from '@/utils/hooks'
import { hideFloatingLyric } from '@/navigation/utils'
import Text from '@/components/common/Text'
import { Icon } from '@/components/common/Icon'
import Slider from '@/components/common/Slider'
import {
  DEFAULT_FLOATING_LYRIC_SETTINGS,
  getFloatingLyricSettings,
  saveFloatingLyricSettings,
  type FloatingLyricSettings,
} from '@/utils/floatingLyricSettings'

const COLLAPSED_HEIGHT = 92
const SETTINGS_HEIGHT = 292
const HORIZONTAL_MARGIN = 12
const TOP_MARGIN = 54
const BOTTOM_MARGIN = 30
const BACKGROUND_COLORS = ['#14191E', '#FFFFFF', '#2E4057', '#5B3A70', '#1E5B4F']
const TEXT_COLORS = ['#FFFFFF', '#111111', '#FFD166', '#7DD3FC', '#86EFAC']

const clamp = (value: number, min: number, max: number) => Math.max(min, Math.min(max, value))
const withOpacity = (hex: string, opacity: number) => {
  const value = hex.replace('#', '')
  return `rgba(${parseInt(value.slice(0, 2), 16)}, ${parseInt(value.slice(2, 4), 16)}, ${parseInt(value.slice(4, 6), 16)}, ${opacity})`
}

export default ({ componentId }: { componentId: string }) => {
  const theme = useTheme()
  const windowSize = useWindowSize()
  const lyricLines = useLrcSet()
  const { line, text } = useLrcPlay()
  const [settingsVisible, setSettingsVisible] = useState(false)
  const [settings, setSettings] = useState<FloatingLyricSettings>(DEFAULT_FLOATING_LYRIC_SETTINGS)
  const floatHeight = settingsVisible ? SETTINGS_HEIGHT : COLLAPSED_HEIGHT
  const width = Math.min(340, Math.max(220, windowSize.width - HORIZONTAL_MARGIN * 2))
  const maxX = Math.max(HORIZONTAL_MARGIN, windowSize.width - width - HORIZONTAL_MARGIN)
  const maxY = Math.max(TOP_MARGIN, windowSize.height - floatHeight - BOTTOM_MARGIN)
  const positionRef = useRef({
    x: Math.max(HORIZONTAL_MARGIN, (windowSize.width - width) / 2),
    y: Math.min(maxY, Math.max(TOP_MARGIN, windowSize.height * 0.16)),
  })
  const dragStartRef = useRef(positionRef.current)
  const position = useRef(new Animated.ValueXY(positionRef.current)).current

  const updatePosition = (x: number, y: number) => {
    const next = { x: clamp(x, HORIZONTAL_MARGIN, maxX), y: clamp(y, TOP_MARGIN, maxY) }
    positionRef.current = next
    position.setValue(next)
  }
  const updateSettings = (value: Partial<FloatingLyricSettings>, persist = false) => {
    setSettings(current => {
      const next = { ...current, ...value }
      if (persist) void saveFloatingLyricSettings(next)
      return next
    })
  }

  useEffect(() => {
    let mounted = true
    void getFloatingLyricSettings().then(value => { if (mounted) setSettings(value) })
    return () => { mounted = false }
  }, [])
  useEffect(() => {
    updatePosition(positionRef.current.x, positionRef.current.y)
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [windowSize.width, windowSize.height, width, floatHeight])

  const panResponder = useMemo(() => PanResponder.create({
    onMoveShouldSetPanResponder: (_, state) => Math.abs(state.dx) > 4 || Math.abs(state.dy) > 4,
    onPanResponderGrant: () => { dragStartRef.current = positionRef.current },
    onPanResponderMove: (_, state) => {
      updatePosition(dragStartRef.current.x + state.dx, dragStartRef.current.y + state.dy)
    },
    onPanResponderRelease: (_, state) => {
      updatePosition(dragStartRef.current.x + state.dx, dragStartRef.current.y + state.dy)
    },
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }), [maxX, maxY])

  const currentText = text || lyricLines[line]?.text || '歌词加载中…'
  const nextText = line >= 0 ? lyricLines[line + 1]?.text : undefined
  const renderColors = (colors: string[], active: string, key: 'backgroundColor' | 'textColor') => (
    <View style={styles.colors}>
      {colors.map(color => <Pressable
        key={color}
        onPress={() => { updateSettings({ [key]: color }, true) }}
        style={[styles.colorButton, { backgroundColor: color }, active == color ? styles.activeColor : null]}
      />)}
    </View>
  )

  return <View pointerEvents="box-none" style={StyleSheet.absoluteFill}>
    <Animated.View style={[styles.container, {
      width,
      height: floatHeight,
      backgroundColor: withOpacity(settings.backgroundColor, settings.backgroundOpacity),
      borderColor: theme['c-primary-alpha-500'],
      transform: position.getTranslateTransform(),
    }]}>
      <View {...panResponder.panHandlers} style={styles.lyricContent}>
        <Text numberOfLines={1} style={[styles.currentLyric, { opacity: settings.textOpacity }]} size={settings.fontSize} color={settings.textColor}>{currentText}</Text>
        {nextText ? <Text numberOfLines={1} style={[styles.nextLyric, { opacity: settings.textOpacity * 0.72 }]} size={Math.max(11, settings.fontSize - 3)} color={settings.textColor}>{nextText}</Text> : null}
      </View>
      <Pressable hitSlop={8} style={styles.settingButton} onPress={() => { setSettingsVisible(value => !value) }}>
        <Icon name="slider" rawSize={16} color={settings.textColor} />
      </Pressable>
      <Pressable hitSlop={8} style={styles.closeButton} onPress={() => { void hideFloatingLyric(componentId) }}>
        <Icon name="close" rawSize={16} color={settings.textColor} />
      </Pressable>
      {settingsVisible ? <View style={styles.settingsPanel}>
        <SettingSlider label="背景透明度" value={settings.backgroundOpacity} min={0.2} max={1} step={0.05} color={settings.textColor} onChange={value => { updateSettings({ backgroundOpacity: value }) }} onComplete={value => { updateSettings({ backgroundOpacity: value }, true) }} />
        <SettingSlider label="文字透明度" value={settings.textOpacity} min={0.3} max={1} step={0.05} color={settings.textColor} onChange={value => { updateSettings({ textOpacity: value }) }} onComplete={value => { updateSettings({ textOpacity: value }, true) }} />
        <SettingSlider label={`字号 ${settings.fontSize}`} value={settings.fontSize} min={12} max={24} step={1} color={settings.textColor} onChange={value => { updateSettings({ fontSize: value }) }} onComplete={value => { updateSettings({ fontSize: value }, true) }} />
        <View style={styles.colorRow}>
          {renderColors(BACKGROUND_COLORS, settings.backgroundColor, 'backgroundColor')}
          {renderColors(TEXT_COLORS, settings.textColor, 'textColor')}
        </View>
      </View> : null}
    </Animated.View>
  </View>
}

const SettingSlider = ({ label, value, min, max, step, color, onChange, onComplete }: {
  label: string
  value: number
  min: number
  max: number
  step: number
  color: string
  onChange: (value: number) => void
  onComplete: (value: number) => void
}) => <View style={styles.settingRow}>
  <Text size={12} color={color}>{label}</Text>
  <Slider value={value} minimumValue={min} maximumValue={max} step={step} onValueChange={onChange} onSlidingComplete={onComplete} />
</View>

const styles = StyleSheet.create({
  container: { position: 'absolute', left: 0, top: 0, borderRadius: 16, borderWidth: StyleSheet.hairlineWidth, shadowColor: '#000', shadowOffset: { width: 0, height: 4 }, shadowOpacity: 0.2, shadowRadius: 10, elevation: 8, overflow: 'hidden' },
  lyricContent: { height: COLLAPSED_HEIGHT, paddingHorizontal: 40, justifyContent: 'center' },
  currentLyric: { textAlign: 'center', fontWeight: '600' },
  nextLyric: { textAlign: 'center', marginTop: 7 },
  settingButton: { position: 'absolute', left: 8, top: 8, width: 26, height: 26, alignItems: 'center', justifyContent: 'center' },
  closeButton: { position: 'absolute', right: 8, top: 8, width: 26, height: 26, alignItems: 'center', justifyContent: 'center' },
  settingsPanel: { flex: 1, paddingHorizontal: 14, paddingBottom: 10, borderTopWidth: StyleSheet.hairlineWidth, borderTopColor: 'rgba(127,127,127,0.35)' },
  settingRow: { height: 47, flexDirection: 'row', alignItems: 'center', gap: 8 },
  colorRow: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center' },
  colors: { flexDirection: 'row', gap: 6 },
  colorButton: { width: 22, height: 22, borderRadius: 11, borderWidth: StyleSheet.hairlineWidth, borderColor: '#999' },
  activeColor: { borderColor: '#4DAF7C', borderWidth: 3 },
})
