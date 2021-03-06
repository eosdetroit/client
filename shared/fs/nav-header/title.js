// @flow
import * as React from 'react'
import * as Types from '../../constants/types/fs'
import * as Constants from '../../constants/fs'
import * as Kb from '../../common-adapters'
import * as Kbfs from '../common'
import * as Styles from '../../styles'
import {memoize} from '../../util/memoize'

type Props = {|
  path: Types.Path,
  onOpenPath: (path: Types.Path) => void,
|}

// /keybase/b/c => [/keybase, /keybase/b, /keybase/b/c]
const getAncestors = memoize(path =>
  path === Constants.defaultPath
    ? []
    : Types.getPathElements(path)
        .slice(1, -1)
        .reduce((list, current) => [...list, Types.pathConcat(list[list.length - 1], current)], [
          Constants.defaultPath,
        ])
)

const withAncestors = f => ({path, ...rest}) => f({ancestors: getAncestors(path), ...rest})

const Breadcrumb = Kb.OverlayParentHOC(
  withAncestors(props => (
    <Kb.Box2 direction="horizontal" fullWidth={true}>
      {props.ancestors.length > 2 && (
        <React.Fragment key="dropdown">
          <Kb.Text key="dots" type="BodyTiny" onClick={props.toggleShowingMenu} ref={props.setAttachmentRef}>
            •••
          </Kb.Text>
          <Kb.FloatingMenu
            containerStyle={styles.floating}
            attachTo={props.getAttachmentRef}
            visible={props.showingMenu}
            onHidden={props.toggleShowingMenu}
            items={props.ancestors
              .slice(0, -2)
              .reverse()
              .map(path => ({
                onClick: () => props.onOpenPath(path),
                title: Types.getPathName(path),
                view: (
                  <Kb.Box2 direction="horizontal" gap="tiny" fullWidth={true}>
                    <Kbfs.PathItemIcon path={path} size={16} />
                    <Kb.Text type="Body" lineClamp={1}>
                      {Types.getPathName(path)}
                    </Kb.Text>
                  </Kb.Box2>
                ),
              }))}
            position="bottom left"
            closeOnSelect={true}
          />
        </React.Fragment>
      )}
      {props.ancestors.slice(-2).map(path => (
        <React.Fragment key={`text-${path}`}>
          <Kb.Text key={`slash-${Types.pathToString(path)}`} type="BodyTiny" style={styles.slash}>
            /
          </Kb.Text>
          <Kb.Text
            key={`name-${Types.pathToString(path)}`}
            type="BodyTiny"
            onClick={() => props.onOpenPath(path)}
          >
            {Types.getPathName(path)}
          </Kb.Text>
        </React.Fragment>
      ))}
    </Kb.Box2>
  ))
)

const MainTitle = (props: Props) => (
  <Kb.Box2 direction="horizontal" fullWidth={true}>
    <Kb.Text type="Header">{Types.getPathName(props.path)}</Kb.Text>
  </Kb.Box2>
)

const FsNavHeaderTitle = (props: Props) =>
  props.path === Constants.defaultPath ? (
    <Kb.Text type="Header" style={styles.rootTitle}>
      Files
    </Kb.Text>
  ) : (
    <Kb.Box2 direction="vertical" style={styles.container}>
      <Breadcrumb {...props} />
      <MainTitle {...props} />
    </Kb.Box2>
  )
export default FsNavHeaderTitle

const styles = Styles.styleSheetCreate({
  container: {
    marginTop: -Styles.globalMargins.xsmall,
    paddingLeft: Styles.globalMargins.xsmall,
  },
  dropdown: {
    marginLeft: -Styles.globalMargins.tiny, // the icon has padding, so offset it to align with the name below
  },
  floating: Styles.platformStyles({
    isElectron: {
      width: 196,
    },
  }),
  icon: {
    padding: Styles.globalMargins.tiny,
  },
  rootTitle: {
    marginLeft: Styles.globalMargins.xsmall,
  },
  slash: {
    paddingLeft: Styles.globalMargins.xxtiny,
    paddingRight: Styles.globalMargins.xxtiny,
  },
})
