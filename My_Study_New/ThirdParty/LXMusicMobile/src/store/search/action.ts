import state, { type InitState } from './state'

export const SEARCH_HISTORY_LIMIT = 50

export default {
  setSearchType(type: InitState['searchType']) {
    state.searchType = type
  },
  setSearchText(text: string) {
    state.searchText = text
  },
  setTipListInfo(keyword: InitState['tipListInfo']['text'], source: InitState['tipListInfo']['source']) {
    state.tipListInfo.text = keyword
    state.tipListInfo.source = source
  },
  setTipList(list: InitState['tipListInfo']['list']) {
    state.tipListInfo.list = list
  },
  setHistoryWord(list: string[]) {
    state.historyList = list
  },
  addHistoryWord(word: string) {
    word = word.trim()
    if (!word) return
    const index = state.historyList.indexOf(word)
    if (index == 0) return
    if (index > -1) state.historyList.splice(index, 1)
    state.historyList.unshift(word)
    state.historyList = state.historyList.slice(0, SEARCH_HISTORY_LIMIT)
    return [...state.historyList]
  },
  removeHistoryWord(index: number) {
    if (index >= 0 && index < state.historyList.length) state.historyList.splice(index, 1)
    return [...state.historyList]
  },
  clearHistoryList() {
    state.historyList = []
    return state.historyList
  },
}
