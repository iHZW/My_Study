// 直接加载真实 TypeScript 模块，仅替换原生存储和全局事件依赖。
const assert = require('node:assert/strict')
const { readFileSync } = require('node:fs')
const { resolve } = require('node:path')
const vm = require('node:vm')
const { test } = require('node:test')
const ts = require('typescript')

const load = (file, dependencies) => {
  const module = { exports: {} }
  const code = ts.transpileModule(readFileSync(resolve(__dirname, '..', file), 'utf8'), {
    compilerOptions: { module: ts.ModuleKind.CommonJS, target: ts.ScriptTarget.ES2020 },
  }).outputText
  vm.runInNewContext(code, {
    module,
    exports: module.exports,
    require: name => {
      assert.ok(name in dependencies, `未替换的依赖：${name}`)
      return dependencies[name]
    },
  }, { filename: file })
  return module.exports
}

const setup = (stored = [], enabled = true) => {
  const state = { historyList: [] }
  const actions = load('src/store/search/action.ts', { './state': { default: state, __esModule: true } })
  const saved = []
  let reads = 0
  const core = load('src/core/search/search.ts', {
    '@/store/search/state': { default: state, __esModule: true },
    '@/store/search/action': actions,
    '@/store/setting/state': { default: { setting: { 'search.isShowHistorySearch': enabled } }, __esModule: true },
    '@/utils/data': {
      getSearchHistory: async() => { reads++; return [...stored] },
      saveSearchHistory: async list => { saved.push(Array.from(list)) },
    },
  })
  return { state, actions: actions.default, core, saved, reads: () => reads }
}

test('超过50条淘汰最早记录，重复搜索移到首位', async() => {
  const { core, state } = setup()
  for (let i = 0; i < 55; i++) await core.addHistoryWord(`歌曲${i}`)
  assert.equal(state.historyList.length, 50)
  assert.equal(state.historyList[0], '歌曲54')
  assert.equal(state.historyList[49], '歌曲5')
  await core.addHistoryWord('歌曲10')
  assert.equal(state.historyList[0], '歌曲10')
  assert.equal(state.historyList.length, 50)
  assert.equal(new Set(state.historyList).size, 50)
})

test('忽略空白，去除首尾空格，并遵循历史开关', async() => {
  const { core, state } = setup()
  await core.addHistoryWord('   ')
  await core.addHistoryWord('  周杰伦  ')
  await core.addHistoryWord('周杰伦')
  assert.deepEqual(Array.from(state.historyList), ['周杰伦'])
  const disabled = setup([], false)
  await disabled.core.addHistoryWord('歌名')
  assert.equal(disabled.state.historyList.length, 0)
  assert.equal(disabled.reads(), 0)
})

test('首次并发读取与搜索不覆盖新记录，空历史只读取一次', async() => {
  const { core, state, reads } = setup(['旧记录'])
  await Promise.all([core.getSearchHistory(), core.addHistoryWord('第一条'), core.addHistoryWord('第二条')])
  assert.deepEqual(Array.from(state.historyList), ['第二条', '第一条', '旧记录'])
  assert.equal(reads(), 1)
  const empty = setup()
  await empty.core.getSearchHistory()
  await empty.core.getSearchHistory()
  assert.equal(empty.reads(), 1)
})

test('删除、清空持久化，负下标不误删末条，重新加载可恢复', async() => {
  const { core, state, saved } = setup(['甲', '乙'])
  await core.getSearchHistory()
  core.removeHistoryWord(-1)
  assert.equal(state.historyList.length, 2)
  core.removeHistoryWord(0)
  assert.deepEqual(saved.at(-1), ['乙'])
  const restarted = setup(saved.at(-1))
  assert.deepEqual(Array.from(await restarted.core.getSearchHistory()), ['乙'])
  core.clearHistoryList()
  assert.deepEqual(saved.at(-1), [])
  assert.deepEqual(Array.from(await core.getSearchHistory()), [])
})

test('缓存读取时过滤空词、去重、限制50条，返回副本', async() => {
  const { core } = setup(['  歌名  ', '歌名', '', ...Array.from({ length: 60 }, (_, i) => String(i))])
  const list = await core.getSearchHistory()
  assert.equal(list.length, 50)
  assert.equal(list[0], '歌名')
  list.length = 0
  assert.equal((await core.getSearchHistory()).length, 50)
})

test('旧版升级启用历史，后续启动保留关闭设置', async() => {
  for (const [version, expected] of [['2.0', true], ['2.1', false]]) {
    const defaults = load('src/config/defaultSetting.ts', {}).default
    const setting = load('src/config/setting.ts', {
      '@/config/constant': { storageDataPrefix: { setting: 'setting' } },
      '@/config/defaultSetting': { default: defaults, __esModule: true },
      '@/plugins/storage': {
        getData: async() => ({ ...defaults, version, 'search.isShowHistorySearch': false }),
        saveData: async() => {},
      },
      './migrateSetting': {},
      '@/store/setting/state': {},
      './migrate': {},
      '@/utils/tools': {},
    })
    const result = await setting.initSetting()
    assert.equal(result.setting['search.isShowHistorySearch'], expected)
    assert.equal(result.setting.version, '2.1')
  }
})
