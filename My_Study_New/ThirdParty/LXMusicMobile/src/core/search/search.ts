import searchState from '@/store/search/state'
import searchActions, { SEARCH_HISTORY_LIMIT } from '@/store/search/action'
import { getSearchHistory as getSearchHistoryFromStore, saveSearchHistory } from '@/utils/data'
import settingState from '@/store/setting/state'


export const setSearchType: typeof searchActions['setSearchType'] = (type) => {
  searchActions.setSearchType(type)
}
export const setSearchText: typeof searchActions['setSearchText'] = (text) => {
  searchActions.setSearchText(text)
}
export const setTipListInfo: typeof searchActions['setTipListInfo'] = (text, source) => {
  searchActions.setTipListInfo(text, source)
}
export const setTipList: typeof searchActions['setTipList'] = (list) => {
  searchActions.setTipList(list)
}

// 共用首次读取，避免快速连续搜索时旧缓存覆盖刚新增的历史。
let historyReady: Promise<void> | undefined
export const getSearchHistory = async() => {
  historyReady ??= getSearchHistoryFromStore().then((list) => {
    searchActions.setHistoryWord([...new Set(list.map(word => word.trim()).filter(Boolean))].slice(0, SEARCH_HISTORY_LIMIT))
  }).catch((error: unknown) => {
    historyReady = undefined
    throw error
  })
  await historyReady
  return [...searchState.historyList]
}
export const addHistoryWord = async(word: string) => {
  word = word.trim()
  if (!settingState.setting['search.isShowHistorySearch'] || !word) return
  await getSearchHistory()
  const list = searchActions.addHistoryWord(word)
  if (!list) return
  void saveSearchHistory(list)
}
export const removeHistoryWord = (index: number) => {
  const list = searchActions.removeHistoryWord(index)
  void saveSearchHistory(list)
}
export const clearHistoryList = () => {
  const list = searchActions.clearHistoryList()
  void saveSearchHistory(list)
}

