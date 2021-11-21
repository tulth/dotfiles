import qualified Data.Map as M
import Data.Tree ( Tree (Node) )

import System.Exit ( exitWith, ExitCode( ExitSuccess ) )

import XMonad
import XMonad.Util.Cursor ( setDefaultCursor )
import XMonad.Util.SpawnOnce ( spawnOnce )
import XMonad.Util.EZConfig ( additionalKeysP )
import XMonad.Util.Run ( spawnPipe )

import qualified XMonad.StackSet as W
import XMonad.Layout.NoBorders (noBorders, smartBorders)
import XMonad.Layout.ToggleLayouts (ToggleLayout(..), toggleLayouts)
import XMonad.Layout.Named ( named )
import XMonad.Layout.Spacing ( Border(..), spacingRaw)
import XMonad.Layout.Tabbed ( tabbed, shrinkText )
import qualified XMonad.Layout.Tabbed as TAB
import XMonad.Hooks.ManageDocks ( avoidStruts, docks
                                , Direction2D (L, R, D, U)
                                )
import XMonad.Hooks.StatusBar ( StatusBarConfig, statusBarPropTo, withSB )
import qualified XMonad.Hooks.StatusBar.PP as SBPP
import XMonad.Prompt as PROMPT
import XMonad.Prompt.ConfirmPrompt ( confirmPrompt )
import XMonad.Prompt.Shell ( shellPrompt )
import XMonad.Prompt.DotDesktop ( appLaunchPrompt )
import XMonad.Prompt.FuzzyMatch ( fuzzySort, fuzzyMatch )
import XMonad.Actions.GroupNavigation ( nextMatch
                                      , Direction( Forward, Backward )
                                      )
import XMonad.Actions.Navigation2D ( windowGo, windowSwap )
import qualified XMonad.Actions.GridSelect as GS
import qualified XMonad.Actions.TreeSelect as TS
import XMonad.Util.Hacks ( trayerPaddingXmobarEventHook )

-- START_KEYS
myKeymap :: [(String, X ())]
myKeymap =
  [ ("M-d", shellPrompt myXPConfig) -- spawn "dmenu_run")
  , ("M-M1-d", myDotDeskTopLaunch)
--  , ("M-M1-<Space>", setLayout $ XMonad.layoutHook conf)
  , ("M-M1-r", spawn "xmonad --recompile && xmonad --restart")
  , ("M-M1-q", kill)
  , ("M-t", withFocused $ windows . W.sink)
  , ("M-h", sendMessage Shrink) -- Shrink the master area
  , ("M-l", sendMessage Expand) -- EXpand the master area
  , ("M-<Space>", sendMessage NextLayout)
  , ("M-<Return>", windows W.swapMaster)
  , ("M-f", sendMessage $ Toggle $ "Full")
  , ("M-<Tab>", windows W.focusDown)
  , ("M-S-<Tab>", windows W.focusUp)
  -- , ("M-<Tab>", nextMatch Forward (return True))
  -- , ("M-S-<Tab>", nextMatch Backward (return True))
--  , ("M-S-M1-a", myTestAction)
--  , ("M-M1-s", swapNextScreen)
  , ("M-M1-<Return>", spawn myTerminal)
  , ("M-<Up>", windowGo U False)
  , ("M-<Down>", windowGo D False)
  , ("M-<Left>", windowGo L False)
  , ("M-<Right>", windowGo R False)
  , ("M-M1-<Up>", windowSwap U False)
  , ("M-M1-<Down>", windowSwap D False)
  , ("M-M1-<Left>", windowSwap L False)
  , ("M-M1-<Right>", windowSwap R False)
  -- multimedia keys
  , ("<XF86AudioRaiseVolume>", spawn "pactl set-sink-volume @DEFAULT_SINK@ +10%")
  , ("<XF86AudioLowerVolume>", spawn "pactl set-sink-volume @DEFAULT_SINK@ -10%")
  , ("<XF86AudioMute>", spawn "pactl set-sink-mute @DEFAULT_SINK@ toggle")
  , ("<Print>", spawn "flameshot gui")
  , ("M1-<Print>", spawn "flameshot full -p /home/tulth/scratch/pictures/screenshots")
  , ("M-M1-e", exitXmonadAction)
  , ("M-g", GS.goToSelected myGsConfig)
  , ("M-<Escape>", myStartMenu)
  , ("<XF86MonBrightnessUp>", spawn "xbacklight -inc 3%")
  , ("<XF86MonBrightnessDown>", spawn "xbacklight -dec 3%")
  ]
  ++
  [ ("M-M1-" ++ ws, windows $ W.shift ws) | ws <- myWorkspaces
  ]
  ++
  [ ("M-" ++ ws, windows $ W.view ws) | ws <- myWorkspaces
  ]
-- END_KEYS

exitXmonadAction = confirmPrompt myXPConfig "exit xmonad" $ io (exitWith ExitSuccess)
rebootAction = confirmPrompt myXPConfig "reboot" $ spawn "reboot"
shutdownAction = confirmPrompt myXPConfig "shutdown" $ spawn "shutdown"
myGsConfig = def { GS.gs_cellheight = 60
                 , GS.gs_cellwidth = 400
                 , GS.gs_cellpadding = 10
                 , GS.gs_font = font myXPConfig
                 }

mostlyClearedKeys :: XConfig Layout -> M.Map (KeyMask, KeySym) (X ())
mostlyClearedKeys conf@(XConfig {XMonad.modMask = modMask}) = M.fromList $ [
  ((modMask .|. mod1Mask, xK_space ), setLayout $ XMonad.layoutHook conf) -- %!  Reset the layouts on the current workspace to default
  ]

myStartupHook :: X ()
myStartupHook = do
  setDefaultCursor xC_left_ptr
  spawnOnce "xset m 0 0"
  spawnOnce "feh --bg-fill /home/tulth/pictures/starry-night.jpg"
  spawnOnce "trayer --edge top --align right --widthtype request --padding 2 --SetDockType true --expand true --monitor 0 --transparent true --alpha 0 --tint 0x0  --height 33 --SetPartialStrut true &"
  spawnOnce "nm-applet &"
  spawnOnce "telegram-desktop -startintray &"
  spawnOnce "pasystray &"
  spawnOnce "libinput-gestures &"
  spawnOnce "emacs &"
  spawnOnce "firefox &"
  spawn "/home/tulth/.xmonad/xmonad_keys.sh > ~/.xmonad/xmonad_keys.txt &"
  
myModMask = mod4Mask -- GUI key
myTerminal = "alacritty"

myXmobarLauncher = "/home/tulth/.local/bin/xmobar -x 0 $HOME/.config/xmobar/xmobarrc"
myBorderWidth = 3

myFont :: String
myFont = "xft:Deja Vu Sans Mono:regular:pixelsize=28:antialias=true:hinting=true"
myFontSmall :: String
myFontSmall = "xft:Deja Vu Sans Mono:regular:size=9:antialias=true:hinting=true"

myTabConfig :: TAB.Theme
myTabConfig =  TAB.def { TAB.fontName = myFontSmall
                       , TAB.activeColor = "#FFA500"
                       , TAB.decoHeight = 32
                       , TAB.activeTextColor     = "#000000"
                       }
               
myLayout = toggleLayouts (named "Full" (noBorders Full)) (
  avoidStruts ( named "tabbed" (tabbed shrinkText myTabConfig)
            ||| named "tiled" tiled
            ||| named "mirrorTiled" (Mirror tiled)
            ||| named "almostFull" Full))
  where
     -- default tiling algorithm partitions the screen into two panes
     tiled = mySpacing 3 $ Tall nmaster delta ratio

     -- The default number of windows in the master pane
     nmaster = 1

     -- Default proportion of screen occupied by master pane
     ratio = 1/2

     -- Percent of screen to increment by when resizing panes
     delta = 3/100

mySpacing i = spacingRaw False (Border i i i i) True (Border i i i i) True

-- xmonad prompt config
myXPConfig = PROMPT.def
  { PROMPT.position = Top
  , PROMPT.alwaysHighlight = True
  , PROMPT.promptBorderWidth = 0
  , PROMPT.font = myFont -- "xft:Deja Vu Sans Mono:size=12:bold:antialias=true"
  , PROMPT.height = 50
  }
  
myWorkspaces = ["1","2","3","4","5","6","7","8","9"]

myXmobarPP = SBPP.xmobarPP {
    SBPP.ppCurrent = SBPP.xmobarColor "#c792ea" "" . SBPP.wrap "<box type=Bottom width=2 mb=2 color=#c792ea>" "</box>"
  , SBPP.ppVisible = SBPP.xmobarColor "#c792ea" ""
  , SBPP.ppHidden = SBPP.xmobarColor "#82AAFF" "". SBPP.wrap "<box type=Top width=2 mt=2 color=#82AAFF>" "</box>" 
  , SBPP.ppHiddenNoWindows = SBPP.xmobarColor "#82AAFF" ""
  , SBPP.ppTitle = SBPP.xmobarColor "#b3afc2" "" . safeXmobarTitle . SBPP.shorten 40 -- Title of active window
  , SBPP.ppSep = "<fc=#666666> <fn=1>|</fn> </fc>"                         -- Separator character
  , SBPP.ppUrgent = SBPP.xmobarColor "#C45500" "" . SBPP.wrap "!" "!"                -- Urgent workspace
  , SBPP.ppOrder = \(ws:l:t:ex) -> [ws,l]++ex++[t]                         -- order of things in xmobar
  }

safeXmobarTitle :: String -> String
safeXmobarTitle rawTitle = map repl rawTitle
  where repl '<' = '\x226E'
        repl other = other
  
xmobarLog :: StatusBarConfig
xmobarLog = statusBarPropTo "_XMONAD_LOG_0" myXmobarLauncher (pure myXmobarPP)

myDotDeskTopLaunch = appLaunchPrompt (
  myXPConfig { complCaseSensitivity = CaseInSensitive
             , searchPredicate = fuzzyMatch
             , sorter = fuzzySort
             , maxComplRows = Just 2
             })

myConfig = def { modMask = myModMask
               , borderWidth = myBorderWidth
               , terminal = myTerminal
               , startupHook = myStartupHook
               , focusFollowsMouse = True
               , layoutHook = smartBorders $ myLayout
               , workspaces = myWorkspaces
               , keys = mostlyClearedKeys
               , handleEventHook = handleEventHook def
                                   <> trayerPaddingXmobarEventHook
               } `additionalKeysP` myKeymap

main = do
  xmonad
    $ withSB (xmobarLog)
    $ docks
    $ myConfig

------------------------------------------------------------
-- treeSelect
myTsConfig = TS.def { TS.ts_node_height = 60
                    , TS.ts_node_width = 400
                    , TS.ts_font = font myXPConfig
                    }

myStartMenu = TS.treeselectAction myTsConfig
   [ Node (TS.TSNode "Launcher" "Xfce4 App Launcher" (spawn "xfce4-appfinder")) []
   , Node (TS.TSNode "Emacs" "Launch emacs client" (spawn "emacsclient -c -a emacs")) []
   , Node (TS.TSNode "Xmobar Overview" "Displays help on xmobar fields" (spawn "xdg-open /home/tulth/.config/xmobar/xmobar_diagram.pdf")) []
   , Node (TS.TSNode "Key Bindings" "Show Key Bindings" (spawn "xmessage -default okay -file ~/.xmonad/xmonad_keys.txt")) []
   , Node (TS.TSNode "Logout" "Log out of the Xmonad session" exitXmonadAction) []
   , Node (TS.TSNode "Reboot" "Reboot the computer" rebootAction) []
   , Node (TS.TSNode "Shutdown" "Powerdown the system" shutdownAction) []
   ]
   
