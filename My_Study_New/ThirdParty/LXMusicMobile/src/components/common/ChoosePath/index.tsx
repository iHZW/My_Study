import { useState, useRef, forwardRef, useImperativeHandle } from 'react'
import { Platform } from 'react-native'

// import { useGetter, useDispatch } from '@/store'
import List, { type ListType } from './List'

import ConfirmAlert, { type ConfirmAlertType } from '@/components/common/ConfirmAlert'
import { toast, TEMP_FILE_PATH, checkStoragePermissions, requestStoragePermission, confirmDialog } from '@/utils/tools'
import { useI18n } from '@/lang'
import { selectFile, unlink } from '@/utils/fs'
import { useUnmounted } from '@/utils/hooks'
import settingState from '@/store/setting/state'
import { log } from '@/utils/log'
import { updateSetting } from '@/core/common'

export interface ReadOptions {
  title: string
  isPersist?: boolean
  dirOnly?: boolean
  filter?: string[]
}
const initReadOptions = {}

interface ChoosePathProps {
  onConfirm: (path: string) => void
}

export interface ChoosePathType {
  show: (options: ReadOptions) => void
}

export default forwardRef<ChoosePathType, ChoosePathProps>(({
  onConfirm = () => {},
}: ChoosePathProps, ref) => {
  const t = useI18n()
  const listRef = useRef<ListType>(null)
  const confirmAlertRef = useRef<ConfirmAlertType>(null)
  const [deny, setDeny] = useState(false)
  const readOptions = useRef<ReadOptions>(initReadOptions as ReadOptions)
  const isUnmounted = useUnmounted()

  const handleOpenExternalStorage = async(options: ReadOptions) => {
    return checkStoragePermissions().then(isGranted => {
      readOptions.current = options
      if (isGranted) {
        listRef.current?.show(options.title, '', options.dirOnly, options.filter)
      } else {
        confirmAlertRef.current?.setVisible(true)
      }
    })
  }

  const handleOpenSystemFile = (options: ReadOptions) => {
    void selectFile({
      extTypes: options.filter,
      toPath: TEMP_FILE_PATH,
    }).then((file) => {
      if (!file || isUnmounted.current) return
      if (options.filter && !options.filter.some(ext => file.data.toLowerCase().endsWith('.' + ext))) {
        toast(t('storage_file_no_match'), 'long')
        void unlink(file.data)
        return
      }
      onConfirm(file.data)
    }).catch((err: { code?: string, message?: string }) => {
      if (isUnmounted.current || err.code == 'picker_cancelled') return
      log.warn('open document failed: ' + (err.message ?? 'unknown error'))

      // iOS 没有 Android 的外置存储目录概念，系统文件选择器失败时
      // 直接提示错误，不能回退到要求输入 SD 卡路径的内置浏览器。
      if (Platform.OS == 'ios') {
        toast(`打开系统文件选择器失败：${err.message ?? '未知错误'}`, 'long')
        return
      }

      void confirmDialog({
        message: t('storage_file_no_select_file_failed_tip'),
        bgClose: false,
      }).then((confirm) => {
        if (!confirm) {
          toast(t('disagree_tip'), 'long')
          return
        }
        updateSetting({ 'common.useSystemFileSelector': false })
        void handleOpenExternalStorage(options)
      })
    })
  }

  useImperativeHandle(ref, () => ({
    show(options) {
      // iOS 文件导入始终使用系统“文件”App。历史设置即使被切换为
      // 内置选择器，也不能让 iOS 进入 Android 风格的外置存储页面。
      const useSystemFileSelector = Platform.OS == 'ios' && !options.dirOnly
        ? true
        : settingState.setting['common.useSystemFileSelector'] && !options.dirOnly
      if (!useSystemFileSelector) {
        // if (options.isPersist) {
        void handleOpenExternalStorage(options)
        // } else {
        //   void selectManagedFolder().then((dir) => {
        //     if (!dir || isUnmounted.current) return
        //     listRef.current?.show(options.title, dir.path, options.dirOnly, options.filter)
        //   })
        // }
      } else {
        handleOpenSystemFile(options)
      }
    },
  }))

  const handleTipsCancel = () => {
    toast(t('disagree_tip'), 'long')
  }
  const handleTipsConfirm = () => {
    confirmAlertRef.current?.setVisible(false)
    void requestStoragePermission().then(result => {
      // console.log(result)
      setDeny(result == null)
      if (result) {
        listRef.current?.show(readOptions.current.title, '', readOptions.current.dirOnly, readOptions.current.filter)
      } else {
        toast(t('storage_permission_tip_disagree'), 'long')
      }
    })
  }
  const onPathConfirm = (path: string) => {
    listRef.current?.hide()
    onConfirm(path)
  }

  return (
    <>
      <List ref={listRef} onConfirm={onPathConfirm} />
      <ConfirmAlert
        ref={confirmAlertRef}
        onCancel={handleTipsCancel}
        onConfirm={handleTipsConfirm}
        bgHide={false}
        closeBtn={false}
        showConfirm={!deny}
        cancelText={t('disagree')}
        confirmText={t('agree')}
        text={t(deny ? 'storage_permission_tip_disagree_ask_again' : 'storage_permission_tip_request')} />
    </>
  )
})
