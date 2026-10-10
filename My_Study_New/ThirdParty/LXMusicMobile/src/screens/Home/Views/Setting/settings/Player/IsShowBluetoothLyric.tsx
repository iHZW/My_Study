import { updateSetting } from '@/core/common'
import { useI18n } from '@/lang'
import { remoteLyricTip } from '@/utils/tools'
import { memo } from 'react'
import { Alert, Linking, Platform, StyleSheet, Text, TouchableOpacity, View } from 'react-native'
import { useSettingValue } from '@/store/setting/hook'
import settingState from '@/store/setting/state'


import CheckBoxItem from '../../components/CheckBoxItem'
import { showRemoteLyric } from '@/core/desktopLyric'
import { setLastLyric } from '@/core/player/playInfo'
import { updateNowPlayingTitles } from '@/plugins/player/utils'
import playerState from '@/store/player/state'
import { syncLockScreenLyricsActivity } from '@/core/init/player/lyric'
import { endLyricsActivity, getLyricsActivityAuthorizationStatus } from '@/utils/nativeModules/lyricsActivity'
import SubTitle from '../../components/SubTitle'

const backgroundColors = ['#17191F', '#101820', '#201820', '#182018', '#202020', '#F2F2F2']
const lyricColors = ['#62D8FF', '#FFFFFF', '#FFD166', '#FF8FA3', '#A8E6A3', '#242424']

export default memo(() => {
  const t = useI18n()
  const isShowBluetoothLyric = useSettingValue('player.isShowBluetoothLyric')
  const isShowLyricsActivity = useSettingValue('player.isShowLyricsActivity')
  const backgroundColor = useSettingValue('player.lyricsActivityBackgroundColor')
  const foregroundColor = useSettingValue('player.lyricsActivityForegroundColor')
  const setActivityColor = (key: 'player.lyricsActivityBackgroundColor' | 'player.lyricsActivityForegroundColor', color: string) => {
    updateSetting({ [key]: color })
    if (settingState.setting['player.isShowLyricsActivity']) {
      void syncLockScreenLyricsActivity()
    }
  }
  const promptActivityColor = (key: 'player.lyricsActivityBackgroundColor' | 'player.lyricsActivityForegroundColor', color: string) => {
    Alert.prompt('自定义颜色', '请输入十六进制颜色值，例如 #62D8FF', [
      { text: '取消', style: 'cancel' },
      {
        text: '应用',
        onPress: value => {
          if (!value || !/^#[0-9A-Fa-f]{6}$/.test(value.trim())) {
            Alert.alert('颜色格式不正确', '请使用 #RRGGBB 格式，例如 #62D8FF。')
            return
          }
          setActivityColor(key, value.trim())
        },
      },
    ], 'plain-text', color)
  }
  const setShowBluetoothLyric = async(isShowBluetoothLyric: boolean) => {
    if (isShowBluetoothLyric) {
      await remoteLyricTip()
    }
    updateSetting({ 'player.isShowBluetoothLyric': isShowBluetoothLyric })
    void showRemoteLyric(isShowBluetoothLyric)
    if (!isShowBluetoothLyric) {
      setLastLyric()
      void updateNowPlayingTitles({
        title: playerState.musicInfo.name,
        artist: playerState.musicInfo.singer ?? '',
        album: playerState.musicInfo.album ?? '',
      })
    }
  }

  const setShowLyricsActivity = async(isShow: boolean) => {
    if (!isShow) {
      updateSetting({ 'player.isShowLyricsActivity': false })
      endLyricsActivity()
      return
    }

    const status = await getLyricsActivityAuthorizationStatus()
    if (status === 'moduleUnavailable') {
      Alert.alert(
        '需要重新安装 App',
        '当前安装包不包含锁屏歌词扩展。请停止 Metro 热更新后，在 Xcode 中重新编译并安装 App。',
      )
      return
    }
    if (status === 'unsupported') {
      Alert.alert('系统版本不支持', '锁屏实时歌词需要 iOS 16.1 或更高版本。')
      return
    }
    if (status === 'disabled') {
      Alert.alert(
        '实时活动未开启',
        '请在系统设置中允许此 App 使用“实时活动”，然后重新播放歌曲。',
        [
          { text: '取消', style: 'cancel' },
          { text: '打开设置', onPress: () => { void Linking.openSettings() } },
        ],
      )
      return
    }

    updateSetting({ 'player.isShowLyricsActivity': true })
    const result = await syncLockScreenLyricsActivity()
    if (result === 'failed') {
      updateSetting({ 'player.isShowLyricsActivity': false })
      Alert.alert('锁屏歌词启动失败', '实时活动创建失败，请重新编译安装后再试，并查看 Xcode 控制台中的“锁屏歌词”日志。')
    }
  }

  return (
    <View style={styles.content}>
      <CheckBoxItem check={isShowBluetoothLyric} onChange={setShowBluetoothLyric} label={t('setting_play_show_bluetooth_lyric')} />
      {Platform.OS === 'ios' && <CheckBoxItem check={isShowLyricsActivity} onChange={setShowLyricsActivity} label={t('setting_play_show_lyrics_activity')} />}
      {Platform.OS === 'ios' && isShowLyricsActivity && <>
        <SubTitle title="锁屏卡片背景色">
          <View style={styles.colorList}>
            {backgroundColors.map(color => <TouchableOpacity
              key={color}
              accessibilityLabel={`背景色 ${color}`}
              accessibilityRole="button"
              onPress={() => { setActivityColor('player.lyricsActivityBackgroundColor', color) }}
              style={[styles.swatch, { backgroundColor: color }, backgroundColor === color && styles.selected]}
            />)}
            <TouchableOpacity accessibilityRole="button" onPress={() => { promptActivityColor('player.lyricsActivityBackgroundColor', backgroundColor) }} style={styles.customColor}>
              <Text style={styles.customColorText}>自定义</Text>
            </TouchableOpacity>
          </View>
        </SubTitle>
        <SubTitle title="歌词与波形颜色">
          <View style={styles.colorList}>
            {lyricColors.map(color => <TouchableOpacity
              key={color}
              accessibilityLabel={`歌词颜色 ${color}`}
              accessibilityRole="button"
              onPress={() => { setActivityColor('player.lyricsActivityForegroundColor', color) }}
              style={[styles.swatch, { backgroundColor: color }, foregroundColor === color && styles.selected]}
            />)}
            <TouchableOpacity accessibilityRole="button" onPress={() => { promptActivityColor('player.lyricsActivityForegroundColor', foregroundColor) }} style={styles.customColor}>
              <Text style={styles.customColorText}>自定义</Text>
            </TouchableOpacity>
          </View>
        </SubTitle>
      </>}
    </View>
  )
})


const styles = StyleSheet.create({
  content: { marginTop: 5 },
  colorList: { flexDirection: 'row', flexWrap: 'wrap', marginTop: 4 },
  swatch: { width: 28, height: 28, borderRadius: 14, marginRight: 12, marginBottom: 8, borderWidth: 1, borderColor: 'rgba(128,128,128,0.55)' },
  selected: { borderWidth: 3, borderColor: '#4A90E2' },
  customColor: { minHeight: 28, justifyContent: 'center', paddingHorizontal: 8, marginBottom: 8, borderRadius: 14, borderWidth: StyleSheet.hairlineWidth, borderColor: 'rgba(128,128,128,0.7)' },
  customColorText: { fontSize: 12, color: '#4A90E2' },
})

