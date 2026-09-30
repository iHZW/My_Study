import { AppState, NativeEventEmitter, NativeModules } from 'react-native'

const { UtilsModule } = NativeModules

export const exitApp = UtilsModule.exitApp

export const getSupportedAbis = UtilsModule.getSupportedAbis

export const installApk = (filePath: string, fileProviderAuthority: string) => UtilsModule.installApk(filePath, fileProviderAuthority)


export const screenkeepAwake = () => {
  if (global.lx.isScreenKeepAwake) return
  global.lx.isScreenKeepAwake = true
  UtilsModule.screenkeepAwake()
}
export const screenUnkeepAwake = () => {
  // console.log('screenUnkeepAwake')
  if (!global.lx.isScreenKeepAwake) return
  global.lx.isScreenKeepAwake = false
  UtilsModule.screenUnkeepAwake()
}

export const getWIFIIPV4Address = UtilsModule.getWIFIIPV4Address as () => Promise<string>

export const getDeviceName = async(): Promise<string> => {
  return UtilsModule.getDeviceName().then((deviceName: string) => deviceName || 'Unknown')
}

export const isNotificationsEnabled = UtilsModule.isNotificationsEnabled as () => Promise<boolean>

type NotificationPermissionStatus = 'notDetermined' | 'authorized' | 'denied'

const openNotificationSettings = async() => new Promise<boolean>((resolve) => {
  let subscription = AppState.addEventListener('change', (state) => {
    if (state != 'active') return
    subscription.remove()
    setTimeout(() => {
      void isNotificationsEnabled().then(resolve)
    }, 1000)
  })
  UtilsModule.openNotificationPermissionActivity().then((result: boolean) => {
    if (result) return
    subscription.remove()
    resolve(false)
  })
})

export const requestNotificationPermission = async(): Promise<boolean> => {
  const status = await (UtilsModule.getNotificationPermissionStatus() as Promise<NotificationPermissionStatus>)
  if (status == 'authorized') return true
  if (status == 'notDetermined') {
    return UtilsModule.requestNotificationAuthorization() as Promise<boolean>
  }
  return openNotificationSettings()
}

export const shareText = async(shareTitle: string, title: string, text: string): Promise<void> => {
  UtilsModule.shareText(shareTitle, title, text)
}

/** 打开 iOS 原生网页浏览器。 */
export const openWebBrowser = (): void => {
  UtilsModule.openWebBrowser()
}

export const getSystemLocales = async(): Promise<string> => {
  return UtilsModule.getSystemLocales()
}

export const onScreenStateChange = (handler: (state: 'ON' | 'OFF') => void): () => void => {
  // eslint-disable-next-line @typescript-eslint/no-unsafe-argument
  const eventEmitter = new NativeEventEmitter(UtilsModule)
  const eventListener = eventEmitter.addListener('screen-state', event => {
    handler(event.state as 'ON' | 'OFF')
  })

  return () => {
    eventListener.remove()
  }
}

export const getWindowSize = async(): Promise<{ width: number, height: number }> => {
  return UtilsModule.getWindowSize()
}

export const onWindowSizeChange = (handler: (size: { width: number, height: number }) => void): () => void => {
  // eslint-disable-next-line @typescript-eslint/no-unsafe-argument
  const eventEmitter = new NativeEventEmitter(UtilsModule)
  const eventListener = eventEmitter.addListener('screen-size-changed', event => {
    handler(event as { width: number, height: number })
  })
  UtilsModule.listenWindowSizeChanged()

  return () => {
    eventListener.remove()
  }
}

export const isIgnoringBatteryOptimization = async(): Promise<boolean> => {
  return UtilsModule.isIgnoringBatteryOptimization()
}

export const requestIgnoreBatteryOptimization = async() => new Promise<boolean>((resolve) => {
  let subscription = AppState.addEventListener('change', (state) => {
    if (state != 'active') return
    subscription.remove()
    setTimeout(() => {
      void isIgnoringBatteryOptimization().then(resolve)
    }, 1000)
  })
  UtilsModule.requestIgnoreBatteryOptimization().then((result: boolean) => {
    if (result) return
    subscription.remove()
    resolve(false)
  })
})
