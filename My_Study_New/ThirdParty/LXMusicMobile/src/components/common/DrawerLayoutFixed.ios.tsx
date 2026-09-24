import {
  forwardRef,
  useCallback,
  useEffect,
  useImperativeHandle,
  useMemo,
  useRef,
  useState,
} from 'react'
import {
  Animated,
  PanResponder,
  Pressable,
  StyleSheet,
  View,
  type DrawerLayoutAndroidProps,
  type LayoutChangeEvent,
} from 'react-native'
import { type COMPONENT_IDS } from '@/config/constant'

interface Props extends DrawerLayoutAndroidProps {
  visibleNavNames: COMPONENT_IDS[]
  widthPercentage: number
  widthPercentageMax?: number
}

export interface DrawerLayoutFixedType {
  openDrawer: () => void
  closeDrawer: () => void
  fixWidth: () => void
}

const EDGE_GESTURE_WIDTH = 24
const ANIMATION_DURATION = 220

const DrawerLayoutFixed = forwardRef<DrawerLayoutFixedType, Props>(({
  widthPercentage,
  widthPercentageMax,
  children,
  renderNavigationView,
  drawerPosition = 'left',
  drawerBackgroundColor,
  style,
  onDrawerOpen,
  onDrawerClose,
}, ref) => {
  const [drawerWidth, setDrawerWidth] = useState(0)
  const [drawerVisible, setDrawerVisible] = useState(false)
  const drawerWidthRef = useRef(0)
  const drawerVisibleRef = useRef(false)
  const dragStartRef = useRef(0)
  const gestureStartedOpenRef = useRef(false)
  const translateX = useRef(new Animated.Value(-1000)).current
  const isRight = drawerPosition == 'right'

  const getClosedPosition = useCallback(() => {
    return isRight ? drawerWidthRef.current : -drawerWidthRef.current
  }, [isRight])

  const animateDrawer = useCallback((open: boolean) => {
    const width = drawerWidthRef.current
    drawerVisibleRef.current = open
    if (open) setDrawerVisible(true)
    if (!width) return

    Animated.timing(translateX, {
      toValue: open ? 0 : getClosedPosition(),
      duration: ANIMATION_DURATION,
      useNativeDriver: true,
    }).start(({ finished }) => {
      if (!finished) return
      if (open) {
        onDrawerOpen?.()
      } else {
        setDrawerVisible(false)
        onDrawerClose?.()
      }
    })
  }, [getClosedPosition, onDrawerClose, onDrawerOpen, translateX])

  const openDrawer = useCallback(() => {
    animateDrawer(true)
  }, [animateDrawer])

  const closeDrawer = useCallback(() => {
    animateDrawer(false)
  }, [animateDrawer])

  useEffect(() => {
    translateX.setValue(drawerVisibleRef.current ? 0 : getClosedPosition())
  }, [getClosedPosition, translateX])

  useImperativeHandle(ref, () => ({
    openDrawer,
    closeDrawer,
    fixWidth() {
      translateX.setValue(drawerVisibleRef.current ? 0 : getClosedPosition())
    },
  }), [closeDrawer, getClosedPosition, openDrawer, translateX])

  const handleLayout = useCallback((event: LayoutChangeEvent) => {
    const containerWidth = event.nativeEvent.layout.width
    const percentageWidth = Math.floor(containerWidth * widthPercentage)
    const nextWidth = widthPercentageMax
      ? Math.min(percentageWidth, widthPercentageMax)
      : percentageWidth
    if (nextWidth == drawerWidthRef.current) return

    drawerWidthRef.current = nextWidth
    setDrawerWidth(nextWidth)
    translateX.setValue(drawerVisibleRef.current ? 0 : (isRight ? nextWidth : -nextWidth))
  }, [isRight, translateX, widthPercentage, widthPercentageMax])

  const finishGesture = useCallback((distance: number, velocity: number) => {
    const width = drawerWidthRef.current
    const shouldOpen = gestureStartedOpenRef.current
      ? isRight
        ? !(distance > width * 0.25 || velocity > 0.5)
        : !(distance < -width * 0.25 || velocity < -0.5)
      : isRight
        ? distance < -width * 0.25 || velocity < -0.5
        : distance > width * 0.25 || velocity > 0.5
    animateDrawer(shouldOpen)
  }, [animateDrawer, isRight])

  const panResponder = useMemo(() => PanResponder.create({
    onMoveShouldSetPanResponder: (_, gestureState) => {
      return Math.abs(gestureState.dx) > 6 && Math.abs(gestureState.dx) > Math.abs(gestureState.dy)
    },
    onPanResponderGrant: () => {
      gestureStartedOpenRef.current = drawerVisibleRef.current
      setDrawerVisible(true)
      translateX.stopAnimation(value => {
        dragStartRef.current = value
      })
    },
    onPanResponderMove: (_, gestureState) => {
      const width = drawerWidthRef.current
      const nextPosition = dragStartRef.current + gestureState.dx
      translateX.setValue(isRight
        ? Math.max(0, Math.min(width, nextPosition))
        : Math.max(-width, Math.min(0, nextPosition)))
    },
    onPanResponderRelease: (_, gestureState) => {
      finishGesture(gestureState.dx, gestureState.vx)
    },
    onPanResponderTerminate: () => {
      animateDrawer(drawerVisibleRef.current)
    },
  }), [animateDrawer, finishGesture, isRight, translateX])

  const drawerSideStyle = isRight ? styles.right : styles.left
  const edgeSideStyle = isRight ? styles.right : styles.left

  return (
    <View onLayout={handleLayout} style={[styles.container, style]}>
      {children}

      <Animated.View
        pointerEvents={drawerVisible ? 'auto' : 'none'}
        style={[styles.mask, {
          opacity: translateX.interpolate({
            inputRange: isRight ? [0, Math.max(drawerWidth, 1)] : [-Math.max(drawerWidth, 1), 0],
            outputRange: isRight ? [0.35, 0] : [0, 0.35],
            extrapolate: 'clamp',
          }),
        }]}
      >
        <Pressable style={styles.container} onPress={closeDrawer} />
      </Animated.View>

      <Animated.View
        {...panResponder.panHandlers}
        pointerEvents={drawerVisible ? 'auto' : 'none'}
        style={[
          styles.drawer,
          drawerSideStyle,
          {
            width: drawerWidth,
            backgroundColor: drawerBackgroundColor,
            transform: [{ translateX }],
          },
        ]}
      >
        {renderNavigationView?.()}
      </Animated.View>

      {!drawerVisible && (
        <View
          {...panResponder.panHandlers}
          style={[styles.edgeGesture, edgeSideStyle]}
        />
      )}
    </View>
  )
})

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  mask: {
    ...StyleSheet.absoluteFillObject,
    backgroundColor: '#000',
    zIndex: 100,
  },
  drawer: {
    position: 'absolute',
    top: 0,
    bottom: 0,
    zIndex: 101,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.24,
    shadowRadius: 5,
  },
  edgeGesture: {
    position: 'absolute',
    top: 0,
    bottom: 0,
    width: EDGE_GESTURE_WIDTH,
    zIndex: 99,
  },
  left: {
    left: 0,
  },
  right: {
    right: 0,
  },
})

export default DrawerLayoutFixed
