// @flow
//
// Notes:
// leaving headerhoc
// default screens have no header
// opt into new split header, MUST set header to undefined in their connector navigatinoOptions
//
// Offline
//
//
import * as Kb from '../common-adapters/mobile.native'
import * as Styles from '../styles'
import * as React from 'react'
import GlobalError from '../app/global-errors/container'
import TabBar from './tab-bar/container'
import {createAppContainer} from '@react-navigation/native'
import {createSwitchNavigator} from '@react-navigation/core'
import StackHeader from 'react-navigation-stack/src/views/Header/Header'
import {createStackNavigator} from 'react-navigation-stack'
import {modalRoutes, routes, nameToTab, loggedOutRoutes} from './routes'
import {LeftAction} from '../common-adapters/header-hoc'
import * as Shared from './router.shared'
import {useScreens} from 'react-native-screens'
// turn on screens
useScreens()

// The nested modal nav can't easily show a header so we just inject it in
// TODO move this into common
// const ModalHeader = p => {
// // const scene = {index: 0, isActive: true, descriptor: {options: {}}}
// const scene = {descriptor: {options: {...p.navigationOptions}}, index: 0, isActive: true}
// const scenes = [scene]
// // const navigation = {state: {index: 0}}
// // const getScreenDetails = () => ({
// // options: {
// // title: 'Modal',
// // // headerLeft: <Kb.Button type='title="Cancel" onPress={() => p.navigation.goBack()} />,
// // },
// // })
// // <StackHeader scene={scene} scenes={scenes} navigation={navigation} getScreenDetails={getScreenDetails} />
// return <StackHeader mode="screen" scene={scene} scenes={scenes} navigation={p.navigation} />
// }

const headerMode = 'float'
const MainStackNavigator = createStackNavigator(routes, {
  defaultNavigationOptions: p => ({
    header: null,
    headerLeft: hp => (
      <LeftAction
        badgeNumber={0}
        leftAction="back"
        onLeftAction={hp.onPress}
        disabled={hp.scene.index === 0}
      />
    ),
    headerTitle: null,
  }),
  headerMode,
  initialRouteName: 'tabs:peopleTab',
  initialRouteParams: undefined,
})

const LoggedInStackNavigator = createStackNavigator(
  {
    Main: {screen: MainStackNavigator},
    ...modalRoutes,
  },
  {
    headerMode: 'none',
    mode: 'modal',
  }
)

const LoggedOutStackNavigator = createStackNavigator(
  {...loggedOutRoutes},
  {
    defaultNavigationOptions: p => ({
      header: null,
      headerLeft: hp => (
        <LeftAction
          badgeNumber={0}
          leftAction="back"
          onLeftAction={hp.onPress}
          disabled={hp.scene.index === 0}
        />
      ),
      headerTitle: null,
    }),
    headerMode,
    initialRouteName: 'login',
    initialRouteParams: undefined,
  }
)

const RootStackNavigator = createSwitchNavigator(
  {
    loggedIn: LoggedInStackNavigator,
    loggedOut: LoggedOutStackNavigator,
  },
  {initialRouteName: 'loggedOut'}
)

/// / gets the current screen from navigation state
function getActiveRouteName(navigationState) {
  if (!navigationState) {
    return null
  }
  const route = navigationState.routes[navigationState.index]
  // dive into nested navigators
  if (route.routes) {
    return getActiveRouteName(route)
  }
  return route.routeName
}
class CustomStackNavigator extends React.PureComponent<any> {
  static router = RootStackNavigator.router

  render() {
    return (
      <Kb.Box2 direction="vertical" fullWidth={true} fullHeight={true}>
        <Kb.NativeKeyboardAvoidingView style={styles.keyboard} behavior="padding">
          <RootStackNavigator navigation={this.props.navigation} />
        </Kb.NativeKeyboardAvoidingView>
        <TabBar selectedTab={nameToTab[this.props.activeKey]} />
        <GlobalError />
      </Kb.Box2>
    )
  }
}
const AppContainer = createAppContainer(CustomStackNavigator)

class RNApp extends React.PureComponent<any, any> {
  // state = {selectedTab: 'tabs:peopleTab'}
  state = {activeKey: 'tabs:peopleTab'}
  _nav = null
  _onNavigationStateChange = (prevState, currentState) => {
    const activeKey = getActiveRouteName(currentState)
    this.setState(p => (p.activeKey === activeKey ? null : {activeKey}))
  }

  // getState = () => this._nav.state
  // dispatch = (p: any) => p && this._nav.dispatch(p)
  // TODO remove this eventually, just so we can handle the old style actions
  dispatchOldAction = (old: any) => {
    const nav = this._nav
    if (!nav) {
      throw new Error('Missing nav?')
    }

    const actions = Shared.oldActionToNewActions(old, nav._navigation) || []
    actions.forEach(a => nav.dispatch(a))
  }

  render() {
    // selectedTab={this.state.selectedTab}
    return (
      <AppContainer
        ref={nav => (this._nav = nav)}
        onNavigationStateChange={this._onNavigationStateChange}
        activeKey={this.state.activeKey}
      />
    )
  }
}

// const AppNavigator = createNavigator(
// AppView,
// // TODO don't hardcode this
// StackRouter(routes, {initialRouteName: 'tabs:peopleTab'}),
// {}
// )

// const createRNApp = App => {
// const initAction = NavigationActions.init()

// // Based on https://github.com/react-navigation/react-navigation-web/blob/master/src/createBrowserApp.js
// class RNApp extends React.Component<any, any> {
// state = {nav: App.router.getStateForAction(initAction)}
// _actionEventSubscribers = new Set()
// _navigation: any
// componentDidMount() {
// this._actionEventSubscribers.forEach(subscriber =>
// subscriber({action: initAction, lastState: null, state: this.state.nav, type: 'action'})
// )
// }
// render() {
// this._navigation = getNavigation(
// App.router,
// this.state.nav,
// this._dispatch,
// this._actionEventSubscribers,
// () => this.props.screenProps,
// () => this._navigation
// )
// return (
// <NavigationProvider value={this._navigation}>
// <App navigation={this._navigation} />
// </NavigationProvider>
// )
// }
// // just so we have nice access to this in the action
// push = route => this._dispatch(StackActions.push(route))
// pop = () => this._dispatch(StackActions.pop())
// _dispatch = action => {
// const lastState = this.state.nav
// const newState = App.router.getStateForAction(action, lastState)
// const dispatchEvents = () =>
// this._actionEventSubscribers.forEach(subscriber =>
// subscriber({action, lastState, state: newState, type: 'action'})
// )
// if (newState && newState !== lastState) {
// this.setState({nav: newState}, dispatchEvents)
// } else {
// dispatchEvents()
// }
// }
// }
// return RNApp
// }

// const RNApp = createRNApp(AppNavigator)
// const RNApp = createAppContainer(tabNavigator)

const styles = Styles.styleSheetCreate({
  keyboard: {
    flexGrow: 1,
    position: 'relative',
  },
  safeAreaViewTop: {flexGrow: 1},
  modalContainer: {},
})

export default RNApp