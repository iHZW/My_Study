import { forwardRef, useCallback, useEffect, useImperativeHandle, useRef, useState } from 'react'
import { Alert, View } from 'react-native'
import Button from '@/components/common/Button'
import Text from '@/components/common/Text'
import { createStyle } from '@/utils/tools'
import { useTheme } from '@/store/theme/hook'
import { useI18n } from '@/lang'
import { clearHistoryList, getSearchHistory, removeHistoryWord } from '@/core/search/search'
import { Icon } from '@/components/common/Icon'


const PREVIEW_COUNT = 10

const ListItem = ({ keyword, onSearch, onRemove }: {
  keyword: string
  onSearch: (keyword: string) => void
  onRemove: (keyword: string) => void
}) => {
  const theme = useTheme()
  const t = useI18n()
  return (
    <View style={[styles.chip, { backgroundColor: theme['c-button-background'], borderColor: theme['c-border-background'] }]}>
      <Button style={styles.keywordButton} onPress={() => { onSearch(keyword) }} accessibilityRole="button" accessibilityLabel={keyword}>
        <Text color={theme['c-button-font']} size={13} numberOfLines={1} style={styles.keyword}>{keyword}</Text>
      </Button>
      <Button
        style={styles.removeButton}
        onPress={() => { onRemove(keyword) }}
        accessibilityRole="button"
        accessibilityLabel={`${t('delete')} ${keyword}`}
        hitSlop={3}
      >
        <Icon name="close" color={theme['c-font-label']} size={10} />
      </Button>
    </View>
  )
}


interface HistorySearchProps {
  onSearch: (keyword: string) => void
}
export interface HistorySearchType {
  show: () => void
}

export default forwardRef<HistorySearchType, HistorySearchProps>((props, ref) => {
  const [list, setList] = useState<string[]>([])
  const [expanded, setExpanded] = useState(false)
  const isUnmountedRef = useRef(false)
  const t = useI18n()
  const theme = useTheme()

  useEffect(() => {
    isUnmountedRef.current = false
    void getSearchHistory().then((list) => {
      if (!isUnmountedRef.current) setList(list)
    }).catch((error: unknown) => { console.warn('搜索历史读取失败', error) })
    return () => {
      isUnmountedRef.current = true
    }
  }, [])

  useImperativeHandle(ref, () => ({
    show() {
      void getSearchHistory().then((list) => {
        if (isUnmountedRef.current) return
        setList(list)
      }).catch((error: unknown) => { console.warn('搜索历史读取失败', error) })
    },
  }), [])

  const handleClear = () => {
    Alert.alert(t('search_history_clear'), t('search_history_clear_tip'), [
      { text: t('cancel'), style: 'cancel' },
      {
        text: t('search_history_clear'),
        style: 'destructive',
        onPress: () => {
          clearHistoryList()
          setList([])
          setExpanded(false)
        },
      },
    ])
  }

  const handleRemove = useCallback((keyword: string) => {
    // 在状态更新函数外执行存储副作用，避免严格模式重复执行。
    void getSearchHistory().then((history) => {
      const index = history.indexOf(keyword)
      if (index < 0) return
      removeHistoryWord(index)
      if (!isUnmountedRef.current) setList(history.filter(word => word !== keyword))
    }).catch((error: unknown) => { console.warn('搜索历史读取失败', error) })
  }, [])

  return (
    list.length
      ? (
          <View style={styles.container}>
            <View style={styles.titleContent}>
              <View style={styles.heading}>
                <View style={[styles.accent, { backgroundColor: theme['c-primary'] }]} />
                <Text size={16} style={styles.title}>{t('search_history_search')}</Text>
                <Text size={11} color={theme['c-font-label']} style={styles.count}>{list.length}/50</Text>
              </View>
              <Button onPress={handleClear} style={styles.titleBtn} accessibilityRole="button" accessibilityLabel={t('search_history_clear')}>
                <Icon name="eraser" color={theme['c-300']} size={14} />
                <Text size={12} color={theme['c-font-label']} style={styles.clearText}>{t('search_history_clear')}</Text>
              </Button>
            </View>
            <View style={styles.list}>
              {
                (expanded ? list : list.slice(0, PREVIEW_COUNT)).map(keyword => <ListItem keyword={keyword} key={keyword} onSearch={props.onSearch} onRemove={handleRemove} />)
              }
            </View>
            {list.length > PREVIEW_COUNT ? (
              <Button style={styles.expandButton} onPress={() => { setExpanded(value => !value) }} accessibilityRole="button" accessibilityState={{ expanded }}>
                <Text size={12} color={theme['c-primary-font']}>{t(expanded ? 'search_history_collapse' : 'search_history_expand')}</Text>
              </Button>
            ) : null}
          </View>
        )
      : null
  )
})


const styles = createStyle({
  container: {
    paddingTop: 20,
    paddingBottom: 10,
  },
  titleContent: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    marginBottom: 6,
  },
  heading: {
    flexDirection: 'row',
    alignItems: 'center',
    flexShrink: 1,
  },
  accent: {
    width: 3,
    height: 16,
    borderRadius: 2,
    marginRight: 8,
  },
  title: {
    fontWeight: '600',
  },
  count: {
    marginLeft: 8,
  },
  titleBtn: {
    flexDirection: 'row',
    alignItems: 'center',
    padding: 10,
    borderRadius: 16,
  },
  clearText: {
    marginLeft: 5,
  },
  list: {
    flexDirection: 'row',
    flexWrap: 'wrap',
  },
  chip: {
    flexDirection: 'row',
    alignItems: 'center',
    maxWidth: '100%',
    borderWidth: 0.5,
    borderRadius: 18,
    overflow: 'hidden',
    marginRight: 8,
    marginTop: 8,
  },
  keywordButton: {
    flexShrink: 1,
    paddingLeft: 14,
    paddingRight: 4,
    paddingVertical: 9,
  },
  keyword: {
    flexShrink: 1,
  },
  removeButton: {
    padding: 11,
  },
  expandButton: {
    alignSelf: 'center',
    paddingHorizontal: 18,
    paddingVertical: 12,
    marginTop: 6,
    borderRadius: 18,
  },
})
