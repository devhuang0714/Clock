import { Icons } from '../constants/Constants'

export function getIconResource(name: string): ResourceStr {
  switch (name) {
    case Icons.SETTINGS:
      return $r('app.media.clock_icon_setting')
    case Icons.THEME_DARK:
      return $r('app.media.clock_icon_yueliang')
    case Icons.THEME_LIGHT:
      return $r('app.media.clock_icon_liangse')
    case Icons.ARROW_RIGHT:
      return $r('app.media.clock_icon_arrow')
    case Icons.EMAIL:
      return $r('app.media.clock_icon_feedback')
    case Icons.FEEDBACK:
      return $r('app.media.clock_icon_feedback1')
    case Icons.PRIVACY:
      return $r('app.media.clock_icon_yinsixieyi')
    case Icons.PACK_UP:
      return $r('app.media.clock_icon_shouqi2')
    case Icons.TIPS:
      return $r('app.media.clock_icon_tips')
    case Icons.COMMENTS:
      return $r('app.media.clock_icon_pinglunxiao')
    case Icons.CUSTOM:
      return $r('app.media.clock_icon_a_shezhixianxing')
    case Icons.ABOUT:
      return $r('app.media.clock_icon_guanyuwomen')
    case Icons.CLOCK:
      return $r('app.media.clock_icon_shizhong')
    case Icons.FLIP:
      return $r('app.media.clock_icon_fanye')
    case Icons.SCREEN_ORIENTATION:
      return $r('app.media.clock_icon_xuanzhuanpingmu')
    case Icons.THEME_STROKE_ICON:
      return $r('app.media.clock_icon_zhuti')
    case Icons.THEME_FILL_ICON:
      return $r('app.media.clock_icon_zhuti1')
    case Icons.CHECKED:
      return $r('app.media.clock_icon_checked')
    case Icons.BACK:
      return $r('app.media.clock_icon_arrow_copy')
    case Icons.MINI_WINDOW:
      return $r('app.media.clock_icon_xiaochuangkou')
    case Icons.SHARE:
      return $r('app.media.clock_icon_fenxiang')
    case Icons.CHECK_UPDATE:
      return $r('app.media.clock_icon_jianchagengxin')
    case Icons.USER_AGREEMENT:
      return $r('app.media.clock_icon_a_useragreement')
    case Icons.CLOSE:
      return $r('app.media.clock_icon_back1')
    case Icons.ADD:
      return $r('app.media.clock_icon_plus1')
    case Icons.DELETE:
      return $r('app.media.clock_icon_close')
    default:
      return $r('app.media.clock_icon_setting')
  }
}
