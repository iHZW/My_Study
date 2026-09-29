import { createStyle } from '@/utils/tools'
import { Platform, View } from 'react-native'
import PlayModeBtn from './PlayModeBtn'
import MusicAddBtn from './MusicAddBtn'
import DesktopLyricBtn from './DesktopLyricBtn'
import CommentBtn from './CommentBtn'
import Btn from './Btn'
import { showFloatingLyric } from '@/navigation/utils'

export default () => {
  return (
    <View style={styles.container}>
      {Platform.OS === 'android'
        ? <DesktopLyricBtn />
        : <Btn icon="lyric-on" onPress={showFloatingLyric} />}
      <MusicAddBtn />
      <PlayModeBtn />
      <CommentBtn />
    </View>
  )
}


const styles = createStyle({
  container: {
    // flexShrink: 0,
    // flexGrow: 0,
    width: '100%',
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-around',
    // backgroundColor: 'rgba(0,0,0,0.1)',
  },
})
